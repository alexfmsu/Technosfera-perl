#!/usr/bin/env perl

use 5.16.0;
use strict;
use warnings;
use utf8;
use Getopt::Long;
use Local::MusicLibrary;

no warnings 'experimental';

binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

MusicLibrary::set_filters();

MusicLibrary::read_library();

MusicLibrary::apply_filters();

MusicLibrary::sort_library();

MusicLibrary::print_library();