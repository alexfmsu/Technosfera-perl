package Local::Source::FileHandler;
use Moose;

extends 'Local::Source';

has 'fh' => (
    is => 'ro',
    isa => 'FileHandle'
);

has 'lines' => (
    is => 'rw',
    isa => 'ArrayRef'
);

sub BUILD{
    my $self = shift;

    my $fh = $self->{fh};
    
    my @lines = <$fh>;
    
    $self->{lines} = \@lines;

    close($fh);
}

sub next{
    my $self = shift;
    
    my $ind = \($self->{ind});
    my $lines = $self->{lines};
        
    if(@$lines && $$ind < scalar @$lines){
        return @$lines[$$ind++];
    }else{
        return undef;
    }
}

1;
