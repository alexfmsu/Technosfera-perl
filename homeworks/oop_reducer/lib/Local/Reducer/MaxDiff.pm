package Local::Reducer::MaxDiff;

use Moose;

extends 'Local::Reducer';



has 'top' => (
	is => 'ro',
	isa => 'Str'
);

has 'bottom' => (
	is => 'ro',
	isa => 'Str'
);

has '_max_diff' => (
	is => 'ro',
	isa => 'Int',
	default => 0
);

sub reduce_n{
	my($self, $n) = @_;
	
	my $top = $self->{top};
	my $bottom = $self->{bottom};
	
	my $source = $self->{source};
	my $row_class = $self->{row_class};
	my $initial_value = $self->{initial_value};
	
	for(1..$n){
		my $val = $source->next();
		
		my $top_val = $row_class->get($val, $top, $initial_value);
		my $bottom_val = $row_class->get($val, $bottom, $initial_value);
		
		my $diff = abs($top_val - $bottom_val);
		
		$self->{_max_diff} = $diff if($diff > $self->{_max_diff});
	}
	
	return $self->{_max_diff};
}

sub reduce_all{
	my($self, $n) = @_;
	
	my $top = $self->{top};
	my $bottom = $self->{bottom};
	
	my $source = $self->{source};
	my $row_class = $self->{row_class};
	my $initial_value = $self->{initial_value};
	
	while(1){
		my $val = $source->next();
		
		last if(!defined($val));

		my $top_val = $row_class->get($val, $top, $initial_value);
		my $bottom_val = $row_class->get($val, $bottom, $initial_value);
		
		my $diff = abs($top_val - $bottom_val);
		
		$self->{_max_diff} = $diff if($diff > $self->{_max_diff});
	}

	return $self->{_max_diff};
}

sub reduced{
	my $self = shift;

	return $self->{_max_diff};
}

1;