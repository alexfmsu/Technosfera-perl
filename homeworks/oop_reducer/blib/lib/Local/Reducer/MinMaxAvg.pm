package MinMaxAvgObj;

use Moose;

has min => (
    is => 'rw',
    isa => 'Num'
);

has max => (
    is => 'rw',
    isa => 'Num'
);

has avg => (
    is => 'rw',
    isa => 'Num'
);

sub set_min{
    my ($self, $value) = @_;
    
    $self->{min} = $value;
}

sub set_max{
    my ($self, $value) = @_;
    
    $self->{max} = $value;
}

sub set_avg{
    my ($self, $value) = @_;
    
    $self->{avg} = $value;
}

sub get_min{
    my ($self, $value) = @_;
    
    return $self->min;
}

sub get_max{
    my $self = shift;
    
    return $self->max;
}

sub get_avg{
    my $self = shift;
    
    return $self->avg;
}

# -------------------------------------------------------------------------------------------------

package Local::Reducer::MinMaxAvg;

use Moose;

extends 'Local::Reducer';

has field => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has result => (
    is => 'rw',
    # isa => MinMaxAvgObj
);


sub reduce_n{
    my($self, $n) = @_;

    $self->{source}->init_counter();
    
    $self->{result} = MinMaxAvgObj->new();
    undef $self->{result}->{min};
    undef $self->{result}->{max};
        
    my $field = $self->field;
    my $source = $self->source;
    my $row_class = $self->row_class;
    my $initial_value = $self->initial_value;
    
    my $res = $self->result;

    my $all_mode = !defined($n); 
    
    $n = 1 if $all_mode;
    
    my $counter = 0;
    
    while($counter < $n){
        my $next = $source->next();
        
        last if(!defined($next));

        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
            my $val = $row->get($field, $initial_value);

            if($counter == 0 || $val < $res->min){
                $res->set_min($val);            
            }

            if($counter == 0 || $val > $res->max){
                $res->set_max($val);            
            }

            $self->{sum} += $val;        
        }else{
            die 'Couldn\'t get data';
        }

        $counter++;
            
        $n++ if $all_mode;
    }

    $res->set_avg($self->{sum}/$counter);

    $self->{result} = $res;

    $self->{reduced_result} = $res;
    
    return $res;
}

sub reduce_all{
    my $self = shift;
    
    $self->{source}->init_counter();
    
    $self->{sum} = 0;
    
    $self->{result} = MinMaxAvgObj->new();
    undef $self->{result}->{min};
    undef $self->{result}->{max};

    return reduce_n($self);
}

1;