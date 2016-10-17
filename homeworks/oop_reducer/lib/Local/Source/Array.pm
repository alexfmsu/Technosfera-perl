package Local::Source::Array;
use Moose;

extends 'Local::Source';

has '_ind' => (
    is       => 'ro',
    # writer   => 'inc'
    init_arg => undef,
    default => 0
);

sub BUILD{
	my $i = 0;
}

# sub inc{
# 	my $self = shift;

# 	# $self->{_ind} = 2;
# };

sub next{
	my $self = shift;

	my $arr = $self->{array};

	if(@$arr){
		return @$arr[$self->{_ind}++];
	}else{
		return undef;
	}
}

1;
