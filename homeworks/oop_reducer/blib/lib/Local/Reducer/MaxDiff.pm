package Local::Reducer::MaxDiff;

use Moose;

extends 'Local::Reducer';

has top => (
    is => 'ro',
    isa => 'Str'
);

has bottom => (
    is => 'ro',
    isa => 'Str'
);

sub reduce_n{
    my($self, $n) = @_;
    
    my $top = $self->top;
    my $bottom = $self->bottom;
    
    my $source = $self->source;
    my $row_class = $self->row_class;
    my $initial_value = $self->initial_value;
    
    my $all_mode = !defined($n);
    
    $n = 1 if $all_mode;
    
    my $counter = 0;
    
    my $res;
    if(defined($self->{reduced_result})){
        $res = $self->{reduced_result};
    }else{
        $res = 0;
    }
    
    while($counter < $n){
        my $next = $source->next();
        
        last if(!defined($next));

        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
            my $top_val = $row->get($top, $initial_value);
            my $bottom_val = $row->get($bottom, $initial_value);
        
            my $diff = abs($top_val - $bottom_val);
        
            $res = $diff if($diff > $res);
        }else{
            die 'Couldn\'t get data';
        }

        $counter++;

        $n++ if $all_mode;
    }
    
    $self->{reduced_result} = $res;
    
    return $res;
}

1;