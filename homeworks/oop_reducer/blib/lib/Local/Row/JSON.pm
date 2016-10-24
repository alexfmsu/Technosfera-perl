use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Row::JSON;

use Moose;

extends 'Local::Row';

use JSON;

has '+data' => (
    lazy_build => 1,
    builder => 'hash_builder'
);

sub hash_builder{
    my $self = shift;

    my $str = $self->str;

    my $elem = JSON->new->utf8->decode($str);
    
    my %h = ();
    
    for my $keys(keys %$elem){
        $h{$keys} = %$elem{$keys};
    }
    
    return \%h;
}

1;