package Local::Reducer::Sum;

use Moose;

extends 'Local::Reducer';

has field => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

has sum => (
    is => 'ro',
    isa => 'Int'
);

sub reduce_n{
    my($self, $n) = @_;
    
    my $field = $self->{field};
    my $source = $self->{source};
    my $row_class = $self->{row_class};
    my $initial_value = $self->{initial_value};
    
    for(1..$n){
        my $next = $source->next();
        
        last if(!defined($next));

        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
            $self->{sum} += $row->get($field, $initial_value);
        }else{
            die 'Couldn\'t get data';
        }
    }

    return $self->{sum};
}

before 'reduce_all' => sub{
    my $self = shift;

    $self->{sum} = 0;
    $self->{source}->init_counter();
};

sub reduce_all{
    my($self, $n) = @_;
    
    my $field = $self->{field};
    my $source = $self->{source};
    my $row_class = $self->{row_class};
    my $initial_value = $self->{initial_value};
    
    while(1){
        my $next = $source->next();
        
        last if(!defined($next));

        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
            $self->{sum} += $row->get($field, $initial_value);
        }else{
            die 'Couldn\'t get data';
        }
    }

    return $self->{sum};
}

sub reduced{
    my $self = shift;

    return $self->{sum};
}

1;