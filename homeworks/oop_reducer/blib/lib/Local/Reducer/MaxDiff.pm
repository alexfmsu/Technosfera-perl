package Local::Reducer::MaxDiff;

use Moose;

extends 'Local::Reducer';

has 'top' => (
    is => 'ro',
    isa => 'Str'
);

has 'bottom' => (
    is => 'ro',
    isa => 'Str'
);

has 'max_diff' => (
    is => 'ro',
    isa => 'Int',
    default => 0
);

sub reduce_n{
    my($self, $n) = @_;
    
    my $top = $self->{top};
    my $bottom = $self->{bottom};
    
    my $source = $self->{source};
    my $row_class = $self->{row_class};
    my $initial_value = $self->{initial_value};
    
    for(1..$n){
        my $next = $source->next();
        
        last if(!defined($next));

        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
            my $top_val = $row->get($top, $initial_value);
            my $bottom_val = $row->get($bottom, $initial_value);
        
            my $diff = abs($top_val - $bottom_val);
        
            $self->{max_diff} = $diff if($diff > $self->{max_diff});
        }else{
            die 'Couldn\'t get data';
        }
    }
    
    return $self->{max_diff};
}

before 'reduce_all' => sub{
    my $self = shift;

    $self->{max_diff} = 0;
    $self->{source}->init_counter();
};

sub reduce_all{
    my($self, $n) = @_;
    
    my $top = $self->{top};
    my $bottom = $self->{bottom};
    
    my $source = $self->{source};
    my $row_class = $self->{row_class};
    my $initial_value = $self->{initial_value};
    
    while(1){
        my $next = $source->next();
        
        last if(!defined($next));

        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
           my $top_val = $row->get($top, $initial_value);
            my $bottom_val = $row->get($bottom, $initial_value);
            
            my $diff = abs($top_val - $bottom_val);
            
            $self->{max_diff} = $diff if($diff > $self->{max_diff});
        }else{
            die 'Couldn\'t get data';
        }
    }

    return $self->{max_diff};
}

sub reduced{
    my $self = shift;

    return $self->{max_diff};
}

1;