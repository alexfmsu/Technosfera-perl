# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
package Local::TCP::Calc::Server;

use 5.16.0;
use strict;
use warnings;
use utf8;

BEGIN{
    if($] < 5.018){
        package experimental;
        
        use warnings::register;
    }
}
no warnings 'experimental';

use Local::TCP::Calc;
use Local::TCP::Calc::Server::Queue;
use Local::TCP::Calc::Server::Worker;

use IO::Socket;
use POSIX ":sys_wait_h";

my $max_worker;
my $in_process;
my $max_forks_per_task;
my $receiver_count;

my @pids_receiver = ();
my @pids_worker = ();

# EXTERN CONST
our $TYPE_CONN_OK = Local::TCP::Calc::TYPE_CONN_OK();
our $TYPE_CONN_ERR = Local::TCP::Calc::TYPE_CONN_ERR();

our $TYPE_START_WORK = Local::TCP::Calc::TYPE_START_WORK();
our $TYPE_CHECK_WORK = Local::TCP::Calc::TYPE_CHECK_WORK();

our $STATUS_NEW = Local::TCP::Calc::STATUS_NEW();
our $STATUS_WORK = Local::TCP::Calc::STATUS_WORK();
our $STATUS_ERROR = Local::TCP::Calc::STATUS_ERROR();
our $STATUS_DONE = Local::TCP::Calc::STATUS_DONE();

# EXTERN SUBS
our $get_request = \&Local::TCP::Calc::get_request;
our $send_request = \&Local::TCP::Calc::send_request;
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub REAPER{
    my $pid;
    
    while(($pid = waitpid(-1, WNOHANG)) > 0 && WIFEXITED($?)){    
        my @pids_r = ();
        my @pids_w = ();
        
        for(@pids_receiver){
            push(@pids_r, $_) if $_ != $pid;
        }
        for(@pids_worker){
            push(@pids_w, $_) if $_ != $pid;
        }
        
        @pids_receiver = @pids_r;
        @pids_worker = @pids_w;
    }
    
    $SIG{CHLD} = \&REAPER;
}

$SIG{CHLD} = \&REAPER;

sub start_server{
    my ($pkg, $port, %opts) = @_;
    
    $max_worker         = $opts{max_worker}; 
    $max_forks_per_task = $opts{max_forks_per_task};
    $receiver_count     = $opts{max_receiver};
    
    my $server = IO::Socket::INET->new(
        LocalPort => $port,
        Type => SOCK_STREAM,
        ReuseAddr => 1,
        Listen => $receiver_count
    ) or die "Can't create server on port ".$port.": $@ $/";
    
    my $q = (__PACKAGE__."::Queue")->new(
        max_task => $opts{max_queue_task}
    );
    
    $q->init();
    
    while(1){        
        my $client = $server->accept();
        
        if(!defined($client)){
            next;
        }
        
        $in_process = scalar @pids_receiver;
        
        if($in_process >= $receiver_count){
            $client->syswrite($TYPE_CONN_ERR, 1);
            
            close($client);
            next;
        }
        
        my $child = fork();
        
        if($child){ 
            push(@pids_receiver, $child);
            
            close($client);
            next; 
        }
        
        if(defined $child){
            close($server);
            
            $client->syswrite($TYPE_CONN_OK, 1);
            
            my ($type, $msg) = $get_request->($client);
            
            if(!defined($type) || !defined($msg)){
                drop_connection($client);
            }
            
            given($type){
                when($TYPE_START_WORK){
                    my $id = $q->add($msg);
                    
                    check_queue_workers($q) if $id;
                    
                    $send_request->($client, [$id], $type);
                }
                when($TYPE_CHECK_WORK){
                    if(scalar @$msg != 1){
                        drop_connection($client, "Error: wrong id for CHECK_WORK");
                    }
                    
                    my $id = @$msg[0];
                    
                    my $status = $q->get_status($id);
                    
                    my @result = ();
                    
                    push(@result, $status); 
                    
                    given($status){
                        when([$STATUS_ERROR, $STATUS_DONE]){
                            push(@result, $q->get_result($id));
                            
                            $q->delete($id);
                        }
                    }
                    
                    $send_request->($client, \@result, $type);
                }
            }
            
            drop_connection($client);
        }else{
            die "Can't fork: $!";
        }
    }
} 

sub check_queue_workers{
    my $q = shift;
    
    return if $max_worker == scalar @pids_worker;
    return unless (my $id = $q->get());
    
    my $child_worker = fork();
    
    if($child_worker){
        push(@pids_worker, $child_worker);
        
        return;
    }
    
    if(defined($child_worker)){
        my $worker = (__PACKAGE__."::Worker")->new(
            cur_task_id=>$id,
            max_forks=>$max_forks_per_task,
            calc_ref=> sub{
                use Math::Expression;
                
                my $expr = shift;
                
                my $env = Math::Expression->new;
                
                my $result = $env->ParseString($expr);
                
                if(defined($result)){
                    $result = $env->EvalToScalar($result);
                }
                
                return defined($result) ? $result : "NaN";
            }
        );
        
        $worker->start();
        $q->to_done($id);
        
        exit(0);
    }else{
        die "Can't fork: $!";
    }
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub drop_connection{
    my $socket = shift;
    my $err_msg = shift;
    
    WARN($err_msg) if defined($err_msg);
    
    close($socket);
    exit(1);
}

sub WARN{
    my $msg = shift;
    
    warn "\n\n"."[SERVER] ".$msg."\n\n";
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

1;
