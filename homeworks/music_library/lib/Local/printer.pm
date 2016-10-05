#!/usr/bin/env perl

package printer;

use 5.16.0;
use strict;
use warnings;

sub print_library{
	(my $lengths, my $t2, my $arr_cut) = (shift, shift, shift);
	# --------------------------
	my $l = scalar @$t2;
	
	my $width = 3 * ($l -1) + 2;
	
	for(@$t2){
		my $value = %$lengths{$_};
		$width += $value if($value);
	}
	# --------------------------
	my $out;

	$out .= sprintf('/');
	$out .= sprintf("-" x $width);
	$out .= sprintf('\\');
	$out .= sprintf("\n");
	
	my $not_empty = 0;

	my $cnt = 0;

	for(my $i = 0; $i < scalar @$arr_cut; $i++){
		my %str = %{@$arr_cut[$i]};
	 	
		$out .= sprintf("|");
		
		for my $param(@$t2){	
			my $value = $str{$param};

			my $width = %$lengths{$param} + 3;
			$out .= sprintf("%".$width."s", " ".$value." |");		
			
			$not_empty = 1;
		}
		
		if($cnt < scalar @$arr_cut - 1){
			# separator
			$out .= sprintf("\n");
			$out .= sprintf("|");

			for my $param(@$t2){	
				my $width = %$lengths{$param} + 3;
				
				$out .= sprintf("%".$width."s", "-" x ($$lengths{$param}+2)."+");	
			}

			chop($out);
			
			$out .= sprintf("|");	
			# separator
		}

		$out .= sprintf("\n");
			
		$cnt++;
	}

	$out .= sprintf('\\');
	$out .= sprintf("-" x $width);
	$out .= sprintf("/");
	$out .= sprintf("\n");

	print $out if $not_empty;
}

1