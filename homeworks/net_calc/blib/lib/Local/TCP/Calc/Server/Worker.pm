# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
package Local::TCP::Calc::Server::Worker;

use 5.16.0;
use strict;
use warnings;
use utf8;

use Mouse;

use POSIX;
use Fcntl qw(:flock);
use PerlIO::gzip;

use Local::Calculator::RPN;
use Local::Calculator::Evaluate;

has cur_task_id => (is => 'ro', isa => 'Int', required => 1);
has forks       => (is => 'rw', isa => 'ArrayRef', default => sub {return []});
has calc_ref    => (is => 'ro', isa => 'CodeRef', required => 1);
has max_forks   => (is => 'ro', isa => 'Int', required => 1);

# EXTERN CONST
our $PATH = Local::TCP::Calc::PATH();
our $WAIT_TIME = Local::TCP::Calc::WAIT_TIME();
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
has error => (is => 'rw', isa => 'Int', default => 0);

sub write_err{
    my $self = shift;
    my $error = shift;
    my $fh;

    alarm($WAIT_TIME);
    flock($fh, LOCK_EX) or die $!;    
    alarm(0);
                
    truncate $fh, 0;
    seek $fh, 0, SEEK_SET;
                
    print $fh $error;
                
    flock($fh, LOCK_UN) or die $!;        
}

sub write_res {
    my $self = shift;
    my $result = shift;
    my $fh = shift;

    alarm($WAIT_TIME);
    flock($fh, LOCK_EX) or die $!;    
    alarm(0);
            
    print $fh $result."\n";
            
    flock($fh, LOCK_UN) or die $!;        
}

sub start{
    my $self = shift;
    
    $SIG{CHLD} = "DEFAULT";
    
    my $id = $self->{cur_task_id};
    
    open(my $fh_in, '<:gzip', $PATH."task_".$id."_in.gz") or die $!;
    open(my $fh_out, '>', $PATH."task_$id.out") or die $!;
    
    my @forks = ();
    $self->{forks} = \@forks;

    my $max_forks = $self->{max_forks};
    
    while(my $expr = <$fh_in>){
        chomp($expr);
        
        while(scalar @forks == $max_forks){ 
            $self->wait_child();    
            
            if($self->{error}){ 
                $self->write_err("Error: task execution is corrupt", $fh_out);
                
                last;
            }
        }
        
        last if($self->{error});
        
        my $child = fork();
        
        if($child){
            push(@forks, $child);

            next;
        } 
        
        if(defined($child)){
            my $res = $self->{calc_ref}($expr);
            
            $self->write_res($res, $fh_out);
            
            exit(0);
        }else{
            die "Can't fork: $!"
        }
    }
    
    while($self->wait_child() != -1){}
    
    close $fh_in;
    close $fh_out;
}

sub wait_child{
    my $self = shift;
    
    my $w_pid = waitpid(0, 0);
    
    return $w_pid if $w_pid == -1;
    
    my @tmp = ();

    for(@{$self->{forks}}){
        push(@tmp, $_) if $_ != $w_pid;
    }
    
    @{$self->{forks}} = @tmp;
    
    if(!WIFEXITED($?)){
        kill('TERM', $_) for @{$self->{forks}};
        
        $self->{error} = 1;
    }
    
    return $w_pid;
}

no Mouse;
__PACKAGE__->meta->make_immutable();

1;
