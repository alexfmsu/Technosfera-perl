package Local::Reducer;

use Moose;

use 5.16.0;
use strict;
use warnings;
use utf8;

our $VERSION = '1.00';

has source => (
    is => 'ro',
    isa => 'Local::Source',
    required => 1
);

has row_class => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has initial_value => (
    is => 'ro',
    isa => 'Int',
    required => 1
);

has reduced_result => (
    is => 'ro'
);

sub reduced{
    my $self = shift;

    return $self->{reduced_result};
}


1;
