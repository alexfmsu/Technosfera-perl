package Local::Row::Simple;

use Moose;

extends 'Local::Row';



sub get{
	my($self, $str, $name, $default) = @_;
		
	my %h = ();

	$str =~ m{
		^
		(?:
			(?>
				(?<key> [^\:\,]+) \: (?<value> [^\:\,]+) \,?
			)
			
			(?{
				$h{$+{key}} = 0+$+{value};
			})		
		)*
		$
	}x;
		
	for my $keys(%h){
		return $h{$name} if($keys eq $name);
	}
		
	return $default;		
}

1;