package Local::JSONParser;

use strict;
use warnings;
use utf8;

use base qw(Exporter);
use Encode qw(encode decode);

our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

binmode(STDOUT,':utf8');

# NUMBER
our $number = qr{
	[\-]?
	(
		0
		|
		([1-9]\d*)
	)
	(
		\.\d+
	)*
	(
		[eE][\+\-]?\d+
	)?
}x;
# NUMBER

our $special_char = qr{
	[\\]
	(
		["|\\|/|b|f|n|r|t]
		|
		(u[[:xdigit:]]{4})
	)
}x;

our $string = qr{
 	\"
 	(
 		(??{$special_char})
 		|
 		[^\"\\]
 	)*
	\"
}x;
# STRING

# TRIM
sub trim{
	$_ = shift;

	s/^\s+//;
	s/\s+$//;
	
	return $_;
}
# TRIM

# SPLIT-OBJECT
sub splitObject{
	my $expr = trim(shift);

	my %obj;

	while($expr =~ /
		(
			(?<key>
				(
					\".+?\"
					|
					\w+?
				)
			)(\s*)\:
						
			(?<value>
				(
					$string
					|
					\[.*\]
					|
					\{.*\}
					|
					.+?
				)
				(?=\,|$)
			)(\,|$)
		)
	/gxsm){
		if(defined($+{key}) and defined($+{value})){
			my $key = $+{key};
			my $value = $+{value};

			$key = trim($key);
			
			if($key =~ /$string/){
				$key =~ s/^\"//;
				$key =~ s/\"$//;
			}
				
			$obj{$key} = getValue($value);
		}
	}

	die "Error: parse $_\n" if($_ ne '' && !%obj);
		
	return \%obj;
}
# SPLIT-OBJECT
	
# SPLIT-ARRAY
sub splitArray{
	my $expr = trim(shift);

	my @arr;

	while($expr =~ /
		(
			(?<obj>
				\{.*\}
				(?=\,|$)
			)		
		)
		|
		(
			(?<arr>
				\[.*\]
				(?=\,$)
			)
		)
		|
		(
			(^|\,\s*)
			(?<value>
				($string|\w+)
				(?=\,|$)
			)
		)
	/gxsm){
		if(defined($+{value})){
			push @arr, getValue($+{value});
		}elsif(defined($+{obj})){
			push @arr, getValue($+{obj});
		}elsif(defined($+{arr})){
			push @arr, getValue($+{arr});
		}
	}

	die "Error: parse $_\n" if($_ ne '' and !@arr);

	return \@arr;
}
# SPLIT-ARRAY

# GET-ARRAY
sub getArray{
	return splitArray(shift);
}
# GET-ARRAY
	
# GET-OBJECT
sub getObject{
	return splitObject(shift);
}
# GET-OBJECT

# GET-VALUE
sub getValue{ 
	$_ = trim(shift);
		
	return getArray($1) if /^\[(.*)\]$/s;
	return getObject($1) if /^\{(.*)\}$/s;
	return $1 if /^(\s*|null|true|false|$number)$/;

	my %spec_chars = (
		'\\\"' => "\"",
		'\\\\' => "\\",
		'\\\/' => "\/",
		'\\\b' => "\b",
		'\\\f' => "\f",
		'\\\n' => "\n",
		'\\\r' => "\r",
		'\\\t' => "\t" 
	);

	if(/^$string$/){
		$_ =~ s/^\"//;
		$_ =~ s/\"$//;
		
		for my $key(keys %spec_chars) {
        	my $value = $spec_chars{$key};
        	
        	$_ =~ s/(?<!\\)$key/$value/e;
    	}
			
		$_ =~ s/(?<!\\)\\u([[:xdigit:]]{4})/chr(hex $1)/ge;
			
		return $_;
	}
		
	die "Error";
}
# GET-VALUE
	
sub parse_json {
	my $source = shift;
		
	return getValue($source);	
}

1;
