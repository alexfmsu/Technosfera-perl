use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Reducer::Sum;

use Moose;

extends 'Local::Reducer';

has field => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

sub reduce_step{
    my($self, $next, $initial_value) = @_;
    
    my $field = $self->field;
    
    my $res = $self->tmp_reduced_result;
    
    if($next->can('get')){
        $res += $next->get($field, $initial_value);
    }else{
        die "Can't get data\n";
    }
    
    $self->tmp_reduced_result($res);
}

sub process_result{}

1;