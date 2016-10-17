package Local::Source::Array;
use Moose;

extends 'Local::Source';

sub next{
    my $self = shift;

    my $arr = $self->{array};

    my $ind = \($self->{ind});
    
    if(@$arr && $$ind < scalar @$arr){
        return @$arr[$$ind++];
    }else{
        return undef;
    }
}

1;
