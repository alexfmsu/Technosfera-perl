use 5.16.0;
use strict;
use warnings;
use utf8;

package Local::Row::Simple;

use Moose;

extends 'Local::Row';

has '+h' => (
    lazy_build => 1,
    builder => 'h_builder'
);

sub h_builder{
    my $self = shift;

    my $str = $self->str;

    my %h = ();
    
    $str =~ m{
        ^
        (?:
            (?>
                (?<key> [^\:\,]+) \: (?<value> [^\:\,]+) \,?
            )
            
            (?{
                $h{$+{key}} = 0+$+{value};
            })      
        )*
        $
    }x;
    
    $h{$+{key}} = $+{value};
    
    return \%h;
}

1;