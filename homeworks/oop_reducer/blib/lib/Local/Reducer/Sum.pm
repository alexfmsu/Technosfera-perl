package Local::Reducer::Sum;

use Moose;

extends 'Local::Reducer';

has field => (
    is => 'ro',
    isa => 'Str',
    required => 1
);

sub reduce_n{
    my($self, $n, $all) = @_;
    
    my $field = $self->field;
    my $source = $self->source;
    my $row_class = $self->row_class;
    my $initial_value = $self->initial_value;
    
    my $all_mode = !defined($n); 
    
    $n = 1 if $all_mode;
    
    my $counter = 0;
    
    my $res = $self->reduced_result;    
    
    while($counter < $n){
        my $next = $source->next();
        
        last if(!defined($next));
        
        my $row = $row_class->new(str=>$next);
        
        if($row->can('get')){
            $res += $row->get($field, $initial_value);
        }else{
            die 'Couldn\'t get data';
        }
        
        $counter++;
        
        $n++ if $all_mode;
    }
    
    $self->set_reduced_result($res);
    
    return $res;
}

sub reduce_all{
    my $self = shift;
    
    $self->set_reduced_result(0);
    $self->source->init_counter();
    
    return reduce_n($self);
}

1;