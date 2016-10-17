package Local::Row::JSON;

use Moose;

extends 'Local::Row';



has field => (
	is => 'rw',
	isa => 'Str',
);

sub get{
	use JSON;
		
	my($self, $str, $name, $default) = @_;
		
	my $elem = JSON->new->utf8->decode($str);
		
	if($elem->{$name}){
		return $elem->{$name};	
	}else{
		return $default;
	}
}

1;