package Local::Source;

use Moose;

has array => (
    is => 'ro',
    isa => 'ArrayRef'
);

has ind => (
    is => 'rw',
    builder => 'init_counter'
);

sub init_counter{
    my $self = shift;

    $self->{ind} = 0;
};

sub next{
    my $self = shift;

    my $arr = $self->array;

    my $ind = \($self->{ind});
    
    if($$ind < scalar @$arr){
        return @$arr[$$ind++];
    }else{
        return undef;
    }
}

1;