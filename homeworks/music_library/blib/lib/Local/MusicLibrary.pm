package MusicLibrary;

use 5.16.0;
use strict;
use warnings;
use utf8;

use Getopt::Long;

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

our @titles = ('band', 'year', 'album', 'track', 'format');

our $band;
our $year;
our $album;
our $track;
our $format;

our $sort;
our $columns;

my @tb = ();
my @select = ();
my @select_titles = ();
my %cell_size = ();

sub read_library{
	GetOptions(
		"band:s" => \$band,
		"year:i" => \$year,
		"album:s" => \$album,
		"track:s" => \$track,
		"format:s" => \$format,
		"sort:s" => \$sort,
		"columns:s" => \$columns
	);	

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
			
			$h{$_} = $+{$_} for(@titles);
			
			push @tb, \%h;
		}else{
			die 'Incorrect input data\n';
		}
	}
}

sub apply_filters{
	exit 0 if(defined($band) && $band eq '');
	exit 0 if(defined($year) && $year == 0);
	exit 0 if(defined($album) && $album eq '');
	exit 0 if(defined($track) && $track eq '');
	exit 0 if(defined($format) && $format eq '');
	exit 0 if(defined($sort) && $sort eq '');
	exit 0 if(defined($columns) && $columns eq '');
	
	for(my $i = 0; $i < scalar @tb; $i++){
		my %str = %{$tb[$i]};
	 	
	 	next if($band && $str{$titles[0]} ne $band);
		next if($year && (0+$str{$titles[1]}) != $year);
		next if($album && $str{$titles[2]} ne $album);
		next if($track && $str{$titles[3]} ne $track);
		next if($format && $str{$titles[4]} ne $format);
		
		push @select, \%str; 
	}
	
	if(!defined($columns)){
		@select_titles = @titles;
	}else{
		my @cols = split(/,/, $columns);
	
		for(@cols){
			exit 0 if(!($_ ~~ @titles));
		
			push @select_titles, $_;
		}
	}
}

sub sort_library{
	if($sort && $sort ~~ @titles){
		for(my $i = 0; $i < @select-1; $i++){
			for(my $j = $i+1; $j < @select; $j++){
				my $a = $select[$i];
				my $b = $select[$j];
				
				if($sort eq 'year'){
					if(%{$a}{$sort} > %{$b}{$sort}){
						($select[$i], $select[$j]) = ($select[$j], $select[$i]);
					}	
				}else{
					if(%{$a}{$sort} gt %{$b}{$sort}){
						($select[$i], $select[$j]) = ($select[$j], $select[$i]);
					}		
				}
			}
		}
	}
};

sub format_output{
	my @len = (0,0,0,0,0);

	for(my $i = 0; $i < scalar @select; $i++){
		my %str = %{$select[$i]};
	 	
	 	for(my $j = 0; $j < scalar @titles; $j++){
			my $l = length $str{$titles[$j]};
			
			if($l > $len[$j]){
				$cell_size{$titles[$j]} = $len[$j] = $l; 
			}
		}
	}
};

sub print_library{
	format_output();

	my $l = scalar @select_titles;
	
	my $width = 3 * ($l -1) + 2;
	
	for(@select_titles){
		my $value = $cell_size{$_};
		$width += $value if($value);
	}
	# -------------------------------------------------------------------------
	
	# BEGIN---------------------------------HEADER-----------------------------
	my $out;

	$out .= sprintf('/');
	$out .= sprintf("-" x $width);
	$out .= sprintf('\\');
	$out .= sprintf("\n");
	# END-----------------------------------HEADER-----------------------------
		
	# BEGIN---------------------------------BODY-------------------------------
	my $not_empty_query = 0;

	my $cnt = 0;

	for(my $i = 0; $i < scalar @select; $i++){
		my %str = %{$select[$i]};
	 	
		$out .= sprintf("|");
		
		for my $param(@select_titles){	
			my $value = $str{$param};

			my $width = $cell_size{$param} + 3;
			$out .= sprintf("%".$width."s", " ".$value." |");		
			
			$not_empty_query = 1;
		}
		
		if($cnt < scalar @select - 1){
			# BEGIN-------------------------SEPARATOR--------------------------
			$out .= sprintf("\n");
			$out .= sprintf("|");

			for my $param(@select_titles){	
				my $width = $cell_size{$param} + 3;
				
				$out .= sprintf("%".$width."s", "-" x ($cell_size{$param}+2)."+");	
			}

			chop($out);
			
			$out .= sprintf("|");	
			# END---------------------------SEPARATOR--------------------------
		}

		$out .= sprintf("\n");
			
		$cnt++;
	}
	# END-----------------------------------BODY-------------------------------

	# BEGIN---------------------------------FOOTER-----------------------------
	$out .= sprintf('\\');
	$out .= sprintf("-" x $width);
	$out .= sprintf("/");
	$out .= sprintf("\n");
	# END-----------------------------------FOOTER-----------------------------

	print $out if $not_empty_query;
}

1;
