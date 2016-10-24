use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Source;

use Moose;

use Local::Row;

has array => (
    is => 'rw',
    isa => 'ArrayRef',
);

has ind => (
    is => 'rw',
    default => 0
);

has row_class => (
    is => 'ro',
    isa => 'Str'
);

sub set_row_class{
    my ($self, $row_class) = @_;

    $self->{row_class} = $row_class;
}

sub pack_to_row{
    my ($self, $arr) = @_;
    
    for(@$arr){
        $_ = $self->row_class->new(str=>$_);
    }

    return \@$arr;
}

sub next{
    my $self = shift;
    
    my $arr = $self->array;
    
    my $ind = \($self->{ind});
    
    if(@$arr && $$ind < scalar @$arr){
        return @$arr[$$ind++];
    }else{
        return undef;
    }
}

1;