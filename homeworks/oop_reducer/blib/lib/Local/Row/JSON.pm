package Local::Row::JSON;

use Moose;

extends 'Local::Row';

use JSON;
    
sub get{
    my($self, $name, $default) = @_;
    
    my $str = $self->str;
    
    my $elem = JSON->new->utf8->decode($str);
    
    if($elem->{$name}){
        return $elem->{$name};  
    }else{
        return $default;
    }
}

1;