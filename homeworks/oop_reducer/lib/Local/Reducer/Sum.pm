package Local::Reducer::Sum;

use Moose;

extends 'Local::Reducer';


has sum => (
	is => 'rw',
	isa => 'Int'
);

sub reduce_n{
	my($self, $n) = @_;
	
	my $field = $self->{field};
	my $source = $self->{source};
	my $row_class = $self->{row_class};
	my $initial_value = $self->{initial_value};
	
	for(1..$n){
		my $val = $source->next();
		
		$self->{sum} += $row_class->get($val, $field, $initial_value);
	}

	return $self->{sum};
}

sub reduce_all{
	my($self, $n) = @_;
	
	my $field = $self->{field};
	my $source = $self->{source};
	my $row_class = $self->{row_class};
	my $initial_value = $self->{initial_value};
	
	while(1){
		my $val = $source->next();
		
		last if(!defined($val));

		$self->{sum} += $row_class->get($val, $field, $initial_value);
	}

	return $self->{sum};
}

sub reduced{
	my $self = shift;

	return $self->{sum};
}

1;