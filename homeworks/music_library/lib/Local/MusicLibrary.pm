package MusicLibrary;

use 5.16.0;
use strict;
use warnings;
use utf8;
use List::MoreUtils qw{any};
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

my @titles = ('band', 'year', 'album', 'track', 'format');
my @args = ('band', 'year', 'album', 'track', 'format', 'sort', 'columns');


our $band;
our $year;
our $album;
our $track;
our $format;

our $sort;
my $columns;

my @tb = ();
my @select = ();
my @select_titles = ();
my %cell_size = ();

sub read_library{
	# GetOptions(
	# 	"band:s" => \$band,
	# 	"year:i" => \$year,
	# 	"album:s" => \$album,
	# 	"track:s" => \$track,
	# 	"format:s" => \$format,
	# 	"sort:s" => \$sort,
	# 	"columns:s" => \$columns
	# );

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

sub get_tb{
	return \@tb;
}
sub get_columns{
	return $columns;
}
sub get_args{
	return \@args;
}
sub get_band{
	return $band;
}
sub get_year{
	return $year;
}
sub get_format{
	return $format;
}

sub get_album{
	return $album;
}
sub get_track{
	return $track;
}
sub get_sort{
	return $sort;
}

sub get_select_titles{
	return \@select_titles;
}

sub get_titles{
	return \@titles;
}

sub get_select{
	return \@select;
}

sub get_cell_size{
	return \%cell_size;
}

sub apply_filters{
	no strict 'refs';
	
	# for(@args){
		
	# 	if($_ eq 'year'){
	# 		die("Option --'".$_."' requires an argument\n") if(defined(${$_}) && ${$_} == 0);	
	# 	}else{
	# 		die("Option --'".$_."' requires an argument\n") if(defined(${$_}) && ${$_} eq '');	
	# 	}
	# }

	for(@tb){
		my %row = %{$_};
	 	
	 	my $found = 1;

	 	for my $i(@titles){
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
		@select_titles = @titles;
	}else{
		my @cols = split(/,/, $columns);
	
		for my $c(@cols){
			die "field '".$_."' does not exist" if(!(any{$_ eq $c} @titles));
			
			push @select_titles, $c;
		}
	}
}

sub apply_filters2{
	(my $_tb2, my $_titles2, my $columns2) = (shift, shift, shift);

	my @tb2 = @$_tb2;
	my @titles2 = @$_titles2;

	no strict 'refs';
	
	# for(@args){
		
	# 	if($_ eq 'year'){
	# 		die("Option --'".$_."' requires an argument\n") if(defined(${$_}) && ${$_} == 0);	
	# 	}else{
	# 		die("Option --'".$_."' requires an argument\n") if(defined(${$_}) && ${$_} eq '');	
	# 	}
	# }

	for(@tb2){
		my %row = %{$_};
	 	
	 	my $found = 1;

	 	for my $i(@titles2){
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

	if(!defined($columns2)){
		@select_titles = @titles2;
	}else{
		my @cols = split(/,/, $columns2);
	
		for my $c(@cols){
			die "field '".$_."' does not exist" if(!(any{$_ eq $c} @titles2));
			
			push @select_titles, $c;
		}
	}

	return (\@select_titles, \@select);
}


1;
