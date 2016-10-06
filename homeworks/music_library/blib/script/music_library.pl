#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings;
use utf8;

use Local::MusicLibraryReader;
use Local::MusicLibraryFilters;
use Local::MusicLibraryPrinter;

binmode(STDIN,':utf8');
binmode(STDOUT,':utf8');

my @titles = ('band', 'year', 'album', 'track', 'format');
my @args = ('band', 'year', 'album', 'track', 'format', 'sort', 'columns');

my $tb = MusicLibraryReader::read_library(\@titles);

(my $select_titles, my $select) = MusicLibraryFilters::apply_filters(\@titles, $tb, \@args);

$select = MusicLibraryFilters::sort_library(\@titles, $select);

MusicLibraryPrinter::print_library(\@titles, $select_titles, $select);