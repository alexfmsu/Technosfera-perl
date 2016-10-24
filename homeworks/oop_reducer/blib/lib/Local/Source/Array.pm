use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Source::Array;

use Moose;

extends 'Local::Source';

has '+array' => (
    lazy => 1,
    builder => 'split_array'
);

sub split_array{
    my $self = shift;
    
    return $self->pack_to_row($self->array);
};

1;