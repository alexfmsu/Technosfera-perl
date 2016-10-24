use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Row;

use Moose;

has str => (
    is => 'ro',
    isa => 'Str',
);

has data => (
    is => 'rw',
    isa => 'HashRef'
);

sub get{
    my($self, $name, $default) = @_;

    my $h = $self->data;

    for my $key(keys %$h){
        return $h->{$key} if($key eq $name);
    }
    
    return $default;        
}


1;