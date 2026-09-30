package HouseAppliance;

use parent 'Exporter'; 
our @EXPORT_OK = ();

sub new {
    my $class = shift; 
    my $self = {
        name         => shift,
        type         => shift,
        cost         => shift,
        purpose      => shift,
        manufacturer => shift,
        next         => undef,
    };
    
    bless $self, $class; 
    return $self;
}

sub getCost{
     my ($self) = @_;
     return ($self -> {cost});
}

sub setCost{
     my ($self, $newCost) = @_;
     $self -> {cost} = $newCost;
}

sub compareTypes{
     my ($self, $other) = @_;
     ($self -> {type} eq $other -> {type})?
          print "Тип одинаковый\n\n":
          print "Тип разный\n\n";
}

sub compareCost{
     my ($self, $other) = @_;
     if ($self -> {cost} > $other -> {cost}){
          print "Стоимость " .$self->{name} . " больше " . $other->{name};
     }
     elsif ($self -> {cost} > $other -> {cost}){
          print "Стоимость " . $self->{name} . " меньше ". $other->{name};
     }
     else{
          print "Стоимость у предметов ". $self ->{name} . " и " . $other->{name} . "одинаковая";
     }
}

1;