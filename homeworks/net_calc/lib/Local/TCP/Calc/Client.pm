# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
package Local::TCP::Calc::Client;

use 5.16.0;
use strict;
use warnings;
use utf8;

use IO::Socket;

our $VERSION = v1.0;

use Local::TCP::Calc qw(
    TYPE_CONN_ERR
    get_request send_request
);
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub set_connect{
    my $pkg = shift;
    my $ip = shift;
    my $port = shift;
    
    my $server = IO::Socket::INET->new(
        PeerAddr => $ip,
        PeerPort => $port,
        Proto => 'tcp',
        Type => SOCK_STREAM
    ) or "Can't connect to ".$ip." $/";
    
    my $status;
    
    $server->sysread($status, 1);
    
    if($status == TYPE_CONN_ERR){
        die "Connection refused by server ".$ip." on port ".$port; 
    }
    
    return $server;
}

sub do_request{ 
    my $pkg = shift;
    my $server = shift;
    my $type = shift;
    my $message = shift;
    
    send_request($server, $message, $type);
    
    my ($status, $struct) = get_request($server);
    
    return @$struct;
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
sub WARN{
    my $msg = shift;
    
    warn "\n\n"."[CLIENT] ".$msg."\n\n";
}

sub drop_connection{
    my $socket = shift;
    my $err_msg = shift;
    
    WARN($err_msg) if defined($err_msg);
    
    close($socket);
    exit(1);
}
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

1;
