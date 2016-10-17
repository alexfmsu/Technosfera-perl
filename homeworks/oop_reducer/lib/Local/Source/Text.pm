package Local::Source::Text;

use Moose;

extends 'Local::Source';

has 'text' => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has 'delimiter' => (
    is => 'ro',
    isa => 'Str',
    default => '\n'
);

has 'lines' => (
    is => 'ro',
    isa => 'ArrayRef'
);

sub BUILD{
    my $self = shift;

    my $delimiter = $self->{delimiter};

    my @lines = split(/$delimiter/, $self->{text});
    
    $self->{lines} = \@lines;
};

sub next{
    my $self = shift;
    
    my $lines = $self->{lines};
    
    my $ind = \($self->{ind});
    
    if(@$lines && $$ind < scalar @$lines){ 
        return @$lines[$$ind++];
    }else{
        return undef;
    }
}

1;



