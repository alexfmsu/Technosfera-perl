#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings;
use utf8;
use Getopt::Long;
use Local::printer;

BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

binmode(STDOUT, ':utf8');

sub sort_lib{
	(my $arr, my $title, my $sort) = (@_, @_, shift);

	for(my $i = 0; $i < @$arr-1; $i++){
		for(my $j = $i+1; $j < @$arr; $j++){
			if($sort eq 'year'){
				my $a = @$arr[$i];
				my $b = @$arr[$j];
				
				if(%{$a}{$sort} > %{$b}{$sort}){
					(@$arr[$i], @$arr[$j]) = (@$arr[$j], @$arr[$i]);
				}	
			}else{
				my $a = @$arr[$i];
				my $b = @$arr[$j];
				
				if(%{$a}{$sort} gt %{$b}{$sort}){
					(@$arr[$i], @$arr[$j]) = (@$arr[$j], @$arr[$i]);
				}		
			}
		}
	}

	return @$arr;
};

# -----------------------------------------------------------------------------
my $band;
my $year;
my $album;
my $track;
my $format;
my $sort;
my $columns;

GetOptions(
	"band:s" => \$band,
	"year:i" => \$year,
	"album:s" => \$album,
	"track:s" => \$track,
	"format:s" => \$format,
	"sort:s" => \$sort,
	"columnss:s" => \$columns
);
# -----------------------------------------------------------------------------
my @arr = ();

my @len = (0,0,0,0,0);

my @title = ('band', 'year', 'album', 'track', 'format');

while(<>){
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
		
		for my $c(@title){
			if($+{$c} eq 'year'){
				$h{$c} = qq{$+{$c}};	
			}else{
				$h{$c} = $+{$c};
			}
		}
		
		push @arr, \%h;
	}
}

exit 0 if(defined($band) && $band eq '');
exit 0 if(defined($year) && $year == 0);
exit 0 if(defined($album) && $album eq '');
exit 0 if(defined($track) && $track eq '');
exit 0 if(defined($format) && $format eq '');
exit 0 if(defined($sort) && $sort eq '');
exit 0 if(defined($columns) && $columns eq '');

if($sort && $sort ~~ @title){
	@arr = sort_lib(\@arr, \@title, $sort);
}

my $a = scalar @arr;

my @arr_cut = ();

for(my $i = 0; $i < $a; $i++){
	my %str = %{$arr[$i]};
 	
 	next if($band && $str{$title[0]} ne $band);
	next if($year && (0+$str{$title[1]}) != $year);
	next if($album && $str{$title[2]} ne $album);
	next if($track && $str{$title[3]} ne $track);
	next if($format && $str{$title[4]} ne $format);
	
	push @arr_cut, \%str; 
}

my %lengths = ();

my @t2 = ();

if(!defined($columns)){
	@t2 = @title;
}else{
	my @cols = split(/,/, $columns);
	
	for(@cols){
		exit 0 if(!($_ ~~ @title));
		
		push @t2, $_;
	}
}

for(my $i = 0; $i < scalar @arr_cut; $i++){
	my %str = %{$arr_cut[$i]};
 	
 	for(my $j = 0; $j < scalar @title; $j++){
		my $l = length $str{$title[$j]};
		
		if($l > $len[$j]){
			$lengths{$title[$j]} = $len[$j] = $l; 
		}
	}
}
# ---------------------------------------------------------------------
printer::print_library(\%lengths, \@t2, \@arr_cut);