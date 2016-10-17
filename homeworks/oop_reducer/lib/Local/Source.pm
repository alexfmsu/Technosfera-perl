package Local::Source;

use Moose;

has array => (
    is => 'rw',
    isa => 'ArrayRef',
);

has 'ind' => (
    is       => 'rw',
    default => init_counter()
);

sub init_counter{
    my $self = shift;

    $self->{ind} = 0;
};


1;