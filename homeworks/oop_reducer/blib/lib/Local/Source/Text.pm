package Local::Source::Text;

use Moose;

extends 'Local::Source';

has 'text' => (
	is => 'ro',
	isa => 'Str'
);

has 'lines' => (
	is => 'ro',
	isa => 'ArrayRef'
);

has 'ind' => (
	is => 'ro',
	isa => 'Int',
	default => 0
);

sub BUILD{
	my $self = shift;

	my @lines = split(/\n/, $self->{text});;
	$self->{lines} = \@lines;
};

sub next{
	my $self = shift;
	
	my $lines = $self->{lines};
	
	return @$lines[$self->{ind}++];
}

1;



