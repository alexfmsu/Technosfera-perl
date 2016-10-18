package MinMaxAvgObj;

use Moose;

has min => (
    is => 'ro',
    isa => 'Num'
);

has max => (
    is => 'ro',
    isa => 'Num'
);

has avg => (
    is => 'ro',
    isa => 'Num'
);

sub get_min{
    my $self = shift;
    
    return $self->{min};
}

sub get_max{
    my $self = shift;
    
    return $self->{max};
}

sub get_avg{
    my $self = shift;
    
    return $self->{avg};
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

before 'reduce_n' => sub{
    my $self = shift;
    
    $self->{source}->init_counter();
    
    $self->{result} = MinMaxAvgObj->new();
    undef $self->{result}->{min};
    undef $self->{result}->{max};
};

sub reduce_n{
    my($self, $n) = @_;
    
    my $field = $self->{field};
    my $source = $self->{source};
    my $row_class = $self->{row_class};
    my $initial_value = $self->{initial_value};
    
    my $res = $self->{result};

    for(1..$n){
        my $next = $source->next();
        
        last if(!defined($next));

        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
            my $val = $row->get($field, $initial_value);

            if($_ == 1 || $val < $res->{min}){
                $res->{min} = $val;
            }

            if($_ == 1 || $val > $res->{max}){
                $res->{max} = $val;
            }

            $self->{sum} += $val;
        
        }else{
            die 'Couldn\'t get data';
        }
    }

    $res->{avg} = $self->{sum}/$n;

    $self->{result} = $res;

    return $res;
}

before 'reduce_all' => sub{
    my $self = shift;
    
    $self->{source}->init_counter();
    
    $self->{sum} = 0;
    
    $self->{result} = MinMaxAvgObj->new();
    undef $self->{result}->{min};
    undef $self->{result}->{max};
};

sub reduce_all{
    my($self, $n) = @_;
    
    my $field = $self->{field};
    my $source = $self->{source};
    my $row_class = $self->{row_class};
    my $initial_value = $self->{initial_value};
    
    my $res = $self->{result};
    
    my $counter = 0;

    while(1){
        my $next = $source->next();
        
        last if(!defined($next));

        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
            my $val = $row->get($field, $initial_value);

            if(!defined($res->{min}) || $val < $res->{min}){
                $res->{min} = $val;
            }

            if(!defined($res->{max}) || $val > $res->{max}){
                $res->{max} = $val;
            }

            $self->{sum} += $val;
            
            $counter++;
        }else{
            die 'Couldn\'t get data';
        }
    }
    
    $res->{avg} = $self->{sum}/$counter;
    
    $self->{result} = $res;
    
    return $res;
}

sub reduced{
    my $self = shift;

    return $self->{result};
}

1;