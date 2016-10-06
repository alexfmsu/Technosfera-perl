package MusicLibraryFilters;

use 5.16.0;
use strict;
use warnings;
use utf8;

use Getopt::Long;
use List::MoreUtils qw{any};

our $band;
our $year;
our $album;
our $track;
our $format;

our $sort;
our $columns;

GetOptions(
	"band:s" => \$band,
	"year:i" => \$year,
	"album:s" => \$album,
	"track:s" => \$track,
	"format:s" => \$format,
	"sort:s" => \$sort,
	"columns:s" => \$columns
);

sub apply_filters{
	(my $titles, my $tb, my $args) = (shift, shift, shift);

	my @select = ();
	my @select_titles = ();

	no strict 'refs';
	
	for(@$args){
		if($_ eq 'year'){
			die("Option --'".$_."' requires an argument\n") if(defined(${$_}) && (${$_} == 0 || ${$_} == 0));	
		}
	}

	for(@$tb){
		my %row = %{$_};
	 	
	 	my $found = 1;

	 	for my $i(@$titles){
	 		if($i eq 'year'){
	 			if($$i && $row{$i} != $$i){
	 				$found = 0;
	 				next;
	 			}	
	 		}else{
	 			if($$i && $row{$i} ne $$i){
	 				$found = 0;
	 				next;
	 			}	
	 		}
	 	}

	 	next if(!$found);
		
		push @select, \%row; 
	}
	
	use strict;

	if(!defined($columns)){
		@select_titles = @$titles;
	}else{
		my @cols = split(/,/, $columns);
		
		for my $c(@cols){
			die "field '".$_."' does not exist" if(!(any{$_ eq $c} @$titles));
			
			push @select_titles, $c;
		}
	}

	return (\@select_titles, \@select);
}

sub sort_library{
	(my $_titles, my $_select) = (shift, shift);

	my @titles = @$_titles;
	my @select = @$_select;

	if($sort && any{$_ eq $sort} @titles){
		@select = sort{$a->{$sort} <=> $b->{$sort} || $a->{$sort} cmp $b->{$sort}} @select;
	}

	return \@select;
}

1;