package Local::MusicLibrary;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

# our $VERSION = '1.00';

use Getopt::Long;

my $band;
my $year;
my $album;
my $track;
my $format;
say "123";
binmode(STDOUT, ':utf8');
# no warnings 'layer';

GetOptions(
	"band=s" => \$band,
	"year=s" => \$year,
	"album=s" => \$album,
	"track=s" => \$track,
	"format=s" => \$format
);

my @arr = ();

my @len = (0,0,0,0,0);

my @title = ('band', 'year', 'album', 'track', 'format');

while(<>){
	# say $_;

	if(m{
		^
		\.
		/
		(?<band>[^/]+)
		/
		(?<year>\d+)
		\s+ - \s+
		(?<album>[^/]+)
		/
		(?<track>.+)
		\.
		(?<format>[^\.\n]+)
		$
	}x){
		my %h = ();
		
		my $i = 0;
		
		for my $c(@title){
			
			$h{$c} = $+{$c};

			my $l = length $h{$c};
			$len[$i] = $l if $l > $len[$i]; 
		
			$i++;	
		}
		
		push @arr, \%h;
	}
}
use utf8;
print("/");
for(my $j = 0; $j < scalar @title - 1; $j++){	
	printf("%".($len[$j]+3)."s", "-" x ($len[$j]+3));
}
printf("%".($len[scalar @title - 1]+2)."s", "-" x ($len[scalar @title - 1]+2));
printf('\\');
printf("\n");
for(my $i = 0; $i < scalar @arr; $i++){
	my %str = %{$arr[$i]};
 	
 	next if($year && $str{$title[1]} ne $year);
	next if($year && $str{$title[1]} ne $year);
	next if($album && $str{$title[2]} ne $album);
	next if($track && $str{$title[3]} ne $track);
	next if($format && $str{$title[4]} ne $format);

	
	# print('\\'."\n");
	print("|");
 	for(my $j = 0; $j < scalar @title; $j++){	
		my $v = $str{$title[$j]};

		printf("%".($len[$j]+3)."s", " ".$v." |");		
	}
	print("\n");
	if($i != scalar @arr - 1){
		print("|");
	}
	for(my $j = 0; $j < scalar @title; $j++){	
		if($i != scalar @arr - 1){
			if($j != scalar @title - 1){
				printf("%".($len[$j]+3)."s", "-" x ($len[$j]+2)."\x{2020}");		
			}else{
				printf("%".($len[$j]+3)."s", "-" x ($len[$j]+2)."|");	
			}
		}
	}
	if($i != scalar @arr - 1){
		print("\n");
	}	
}
print("\\");
for(my $j = 0; $j < scalar @title - 1; $j++){	
	printf("%".($len[$j]+3)."s", "-" x ($len[$j]+3));
}
printf("%".($len[scalar @title - 1]+2)."s", "-" x ($len[scalar @title - 1]+2));
printf('/');
printf("\n");

print(123);

return 1211;
=head1 SYNOPSIS

=cut

1;
