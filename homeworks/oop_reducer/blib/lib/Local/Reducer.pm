package Local::Reducer;

use Moose;

use strict;
use warnings;
use 5.16.0;

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

has field => (
	is => 'ro',
	isa => 'Str',
);

has source => (
	is => 'ro',
	isa => 'Local::Source',
);

has row_class => (
	is => 'ro',
	isa => 'Str',	
);

has initial_value => (
	is => 'ro',
	isa => 'Int',
);

our $VERSION = '1.00';


=head1 SYNOPSIS

=cut

1;
