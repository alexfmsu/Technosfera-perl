use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Source::Array;

use Moose;

extends 'Local::Source';

has '+array' => (
    lazy => 1,
    lazy_build => 1,
    builder => 'split_text'
);

sub split_text{
    my $self = shift;
    
    my $arr = $self->array;
    
    for(@$arr){
        $_ = $self->row_class->new(str=>$_);
    }

    return $arr;
};

1;