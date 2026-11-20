#!/usr/bin/perl

%h = ();

$head = undef;

print "Меню:\n";
print "1. Добавить лексему\n";
print "2. Удалить лексему\n";
print "3. Просмотреть список\n";
print "Любое другое число - выход\n";

print "Ваш выбор: ";
$choice = <STDIN>;
chomp $choice;

while ($choice >= 1 && $choice <= 3) {

    if ($choice == 3) {
        print "\nСписок:\n";

        $temp = $head;

        while ($temp ne "") {
            print $temp;

            if ($h{$temp} ne "") {
                print " -> ";
            }

            $temp = $h{$temp};
        }

        print "\n";
    }

    elsif ($choice == 1) {
        print "Введите лексему: ";
        $newWord = <STDIN>;
        chomp $newWord;

        if ($newWord eq "") {
            print "Лексема не может быть пустой!\n";
        }
        elsif (exists $h{$newWord}) {
            print "Такая лексема уже существует!\n";
        }
        elsif ($head eq "") {
            $head = $newWord;
            $h{$newWord} = "";
            print "Лексема добавлена.\n";
        }
        elsif ($newWord lt $head) {
            $h{$newWord} = $head;
            $head = $newWord;
            print "Лексема добавлена.\n";
        }
        else {
            $temp = $head;

            while ($h{$temp} ne "" && $h{$temp} lt $newWord) {
                $temp = $h{$temp};
            }

            $h{$newWord} = $h{$temp};
            $h{$temp} = $newWord;

            print "Лексема добавлена.\n";
        }
    }

    elsif ($choice == 2) {
        print "Введите лексему для удаления: ";
        $deleteWord = <STDIN>;
        chomp $deleteWord;

        if (!exists $h{$deleteWord}) {
            print "Такой лексемы нет в списке.\n";
        }
        elsif ($head eq $deleteWord) {
            $head = $h{$deleteWord};
            delete $h{$deleteWord};

            print "Лексема удалена.\n";
        }
        else {
            $temp = $head;
            $found = 0;

            while ($temp ne "") {
                if ($h{$temp} eq $deleteWord) {
                    $h{$temp} = $h{$deleteWord};
                    delete $h{$deleteWord};

                    $found = 1;
                    print "Лексема удалена.\n";
                    last;
                }

                $temp = $h{$temp};
            }

            if (!$found) {
                print "Такой лексемы нет в списке.\n";
            }
        }
    }

    print "\nВыберите пункт: ";
    $choice = <STDIN>;
    chomp $choice;
}

print "Программа завершена.\n";
