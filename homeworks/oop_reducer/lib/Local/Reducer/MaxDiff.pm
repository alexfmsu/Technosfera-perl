use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Reducer::MaxDiff;

use Moose;

extends 'Local::Reducer';

has top => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has bottom => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

sub reduce_step{
    my($self, $next, $initial_value) = @_;
        
    my $top = $self->top;
    my $bottom = $self->bottom;
    
    my $res = $self->tmp_reduced_result;
    
    if($next->can('get')){
        my $top_val = $next->get($top, $initial_value);
        my $bottom_val = $next->get($bottom, $initial_value);
        
        my $diff = abs($top_val - $bottom_val);
        
        $res = $diff if($diff > $res);
    }else{
        die "Can't get data";
    }
    
    $self->tmp_reduced_result($res);
}

sub process_result{}

1;