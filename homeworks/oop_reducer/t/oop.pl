use strict;
use warnings;

use Test::More tests => 3;

use FindBin; # added
use lib "$FindBin::Bin/../lib"; # added

use Local::Reducer::MinMaxAvg;
use Local::Source::Array;
use Local::Row::JSON;

my $min_max_avg_reducer = Local::Reducer::MinMaxAvg->new(
    field => 'price',
    source => Local::Source::Array->new(array => [
        '{"price": 1}',
        '{"price": 2}',
        '{"price": 3}',
    ]),
    row_class => 'Local::Row::JSON',
    initial_value => 0,
);

my $min_max_avg_result;

$min_max_avg_result = $min_max_avg_reducer->reduce_n(2);

use DDP;
p $min_max_avg_result;
is($min_max_avg_result->min, 1, 'min_max_avg reduced_min 1');
is($min_max_avg_result->max, 2, 'min_max_avg reduced_max 2');
is($min_max_avg_result->avg, 1.5, 'min_max_avg reduced_avg 1.5');

is($min_max_avg_reducer->reduced->get_min, 1, 'diff reducer saved');

# $min_max_avg_result = $diff_reducer->reduce_all();
# is($min_max_avg_result, 8192, 'diff reduced all');
# is($diff_reducer->reduced, 8192, 'diff reducer saved at the end');