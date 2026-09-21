#!/usr/bin/perl

sub insert {
    my ($root, $value) = @_;

    if (!defined $root) {
        return {
            value => $value,
            left  => undef,
            right => undef
        };
    }

    if ($value < $root->{value}) {
        $root->{left} = insert($root->{left}, $value);
    }
    elsif ($value > $root->{value}) {
        $root->{right} = insert($root->{right}, $value);
    }
    else {
        print "Такой элемент уже существует!\n";
    }

    return $root;
}


sub print_tree {
    my ($root, $level, $side) = @_;

    return unless defined $root;

    print_tree($root->{right}, $level + 1, "right");

    print "    " x $level;

    if ($side eq "left") {
        print "└── ";
    }
    elsif ($side eq "right") {
        print "┌── ";
    }
    else {
        print "── ";
    }

    print $root->{value}, "\n";

    print_tree($root->{left}, $level + 1, "left");
}


sub find_min {
    my ($root) = @_;

    return $root unless defined $root->{left};

    return find_min($root->{left});
}


sub delete_node {
    my ($root, $value) = @_;

    if (!defined $root) {
        return (undef, 0);
    }

    if ($value < $root->{value}) {

        my ($new_left, $deleted) =
            delete_node($root->{left}, $value);

        $root->{left} = $new_left;

        return ($root, $deleted);
    }

    elsif ($value > $root->{value}) {

        my ($new_right, $deleted) =
            delete_node($root->{right}, $value);

        $root->{right} = $new_right;

        return ($root, $deleted);
    }

    else {
        if (!defined $root->{left} &&
            !defined $root->{right}) {

            return (undef, 1);
        }

        if (!defined $root->{left}) {

            return ($root->{right}, 1);
        }

        if (!defined $root->{right}) {

            return ($root->{left}, 1);
        }

        my $min = find_min($root->{right});

        $root->{value} = $min->{value};

        my ($new_right, $deleted) =
            delete_node($root->{right}, $min->{value});

        $root->{right} = $new_right;

        return ($root, 1);
    }
}


my $root;

while (1) {

    print "\n";
    print "1. Добавить элемент\n";
    print "2. Вывести дерево\n";
    print "3. Удалить элемент\n";
    print "0. Выход\n\n";
    print "Выберите операцию: ";

    my $choice = <STDIN>;
    chomp $choice;

    if ($choice == 1) {

        print "Введите целое число: ";

        my $value = <STDIN>;
        chomp $value;

        my $old_root = $root;

        $root = insert($root, $value);

        if (!defined $old_root) {
            print "Элемент $value успешно добавлен.\n";
        }
           
    }
    elsif ($choice == 2) {

        if (defined $root) {

            print "\nДерево:\n";

            print_tree($root, 0, "root");
        }
        else {

            print "Дерево пустое.\n";
        }
    }

    elsif ($choice == 3) {

        print "Введите элемент для удаления: ";

        my $value = <STDIN>;
        chomp $value;

        if ($value =~ /^-?\d+$/) {

            if (defined $root) {

                my ($new_root, $deleted) =
                    delete_node($root, $value);

                $root = $new_root;

                if ($deleted) {
                    print "Элемент $value успешно удалён.\n";
                }
                else {
                    print "Элемент $value не найден в дереве.\n";
                }
            }
            else {

                print "Дерево пустое. Элемент $value не найден.\n";
            }
        }
        else {

            print "Введите целое число!\n";
        }
    }
    elsif ($choice == 0) {

        print "Программа завершена.\n";
        last;
    }
    else {

        print "Неверный пункт меню!\n";
    }
}