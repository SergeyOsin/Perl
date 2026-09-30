#!/usr/bin/perl

use lib '.';
use HouseAppliance;

sub create_node {
    return HouseAppliance->new(@_);
}

sub insert {
    my ($head, $new_node) = @_;
    if (!defined $head || $new_node->{name} lt $head->{name}) {
        $new_node->{next} = $head;
        return $new_node;
    }
    if ($new_node->{name} eq $head->{name}) {
        print "Прибор с названием " . $new_node->{name} . " уже в списке";
        return $head;
    }
    $head->{next} = insert($head->{next}, $new_node);
    return $head;
}

sub delete_appliance {
    my ($head, $name_key) = @_;
    
    return undef unless defined $head;

    if ($head->{name} eq $name_key) {
        return $head->{next};
    }
    
    $head->{next} = delete_appliance($head->{next}, $name_key);
    return $head;
}

sub find_node {
    my ($head, $name_key) = @_;
    return undef unless defined $head;
    if ($head->{name} eq $name_key) {
        return $head;
    }
    return find_node($head->{next}, $name_key);
}

sub print_list {
    my ($head) = @_;
    
    if (!defined $head) {
        print "Список пуст.\n\n";
        return;
    }

    local $~ = "HEADER";
    write;
    
    my $current = $head;
    while (defined $current) {
        $args = $current;
        local $~ = Appliance;
        write; 
    
        $current = $current->{next};
    }
    print "\n";
}

format HEADER =
--------------------------------------------------------------------------------------------------
| Название прибора       |    Тип               | Назначение    | Цена прибора |   Производитель  |
--------------------------------------------------------------------------------------------------
.

format Appliance =
| @<<<<<<<<<<<<<<<<<<<<< | @<<<<<<<<<<<<<<<<<<< | @<<<<<<<<<<<< | @<<<<<<<<<<< | @<<<<<<<<<<<<<<< |
$args->{name},            $args->{type}, $args->{purpose}, $args->{cost}, $args->{manufacturer}
--------------------------------------------------------------------------------------------------
.

print "Выберите один из пунктов: \n";
print "1. Добавить элемент\n";
print "2. Удалить элемент \n";
print "3. Сравнить элементы списка по типу\n";
print "4. Сравнить элементы списка по цене\n";
print "5. Вывести список\n";
print "Любой другой символ - завершение программы\n";

$choose = undef;
my $list_head = undef;
while ($choose >= 1 && $choose <=5 || !defined $choose){
    print "Выбор: ";
    $choose = <STDIN>;
    chomp ($choose);

    if ($choose == 1){
        print "\nНазвание: ";
        $Name = <STDIN>;
        chomp ($Name);

        print "Тип: ";
        $Type = <STDIN>;
        chomp ($Type);

        print "Стоимость: ";
        $Cost = <STDIN>;
        chomp ($Cost);

        print "Предназначение: ";
        $Purpose = <STDIN>;
        chomp ($Purpose);

        print "Производитель: ";
        $Manufacturer = <STDIN>;
        chomp ($Manufacturer);

        $list_head = insert($list_head, create_node(
            $Name,
            $Type,
            $Cost,
            $Purpose,
            $Manufacturer
        ));
        print "\n\n";

    } elsif ($choose == 2){
        print "Введите название прибора для удаления: ";
        my $del_name = <STDIN>;
        chomp($del_name);

        if (!defined find_node($list_head, $del_name)){
            print "Прибор с названием $del_name не найден в списке\n\n";
            next;
        }
        $list_head = delete_appliance($list_head, $del_name);
    } elsif ($choose == 3) {
        print "Введите название первого прибора: ";
        my $first_name = <STDIN>;
        chomp ($first_name);
        my $first_node = find_node($list_head, $first_name); 
        if (!defined $first_node){
             print "Прибор с названием $first_name не найден\n\n";
              next;
        }

        print "Введите название второго прибора: ";
        my $second_name = <STDIN>;
        chomp ($second_name);
        my $second_node = find_node($list_head, $second_name);
        if (!defined $second_node){
            print "Прибор с названием $second_name не найден\n\n";
            next;
        }
        
        $first_node->compareTypes($second_node);

    } elsif ($choose == 4) {
        print "Введите название первого прибора: ";
        my $first_name = <STDIN>;
        chomp ($first_name);
        my $first_node = find_node($list_head, $first_name);
        if (!defined $first_node){
            print "Прибор с названием $first_name не найден\n\n";
            next;
        }

        print "Введите название второго прибора: ";
        my $second_name = <STDIN>; 
        chomp ($second_name);
        my $second_node = find_node($list_head, $second_name);
        if (!defined $second_node){
            print "Прибор с названием $first_name не найден\n\n";
            next;
        }
        $first_node->compareCost($second_node);
        
    } elsif ($choose == 5) {
        print_list($list_head);
    } else {
        print "\nПрограмма завершена";
        last;
    }

}



