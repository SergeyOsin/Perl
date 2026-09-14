#!/usr/bin/perl

#!/usr/bin/perl

%h = (
    "enter" => "abc",
    "abc"   => "bcd",
    "bcd"   => "cda",
    "cda"   => "klm",
    "klm"   => ""
);

$head = "enter";

print "Меню:\n";
print "1. Добавить лексему\n";
print "2. Удалить лексему\n";
print "3. Просмотреть список\n";
print "Любое другое число - выход\n";

print "Ваш выбор: ";
$choice = <STDIN>;

while ($choice >=1 && $choice <=3) {
    if ($choice == 3) {
        print "\nСписок:\n";

        $temp = $head;

        while ($temp != "") {
            print "$temp";

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

        if ($h{$newWord} > 0) {
            print "Такая лексема уже существует!\n";
            next;
        }

        if ($head == "") {
            $head = $newWord;
            $h{$newWord} = "";
        }
        elsif ($newWord == $head) {
            $h{$newWord} = $head;
            $head = $newWord;
        }

        else {

            $temp = $head;

            while ($h{$temp} != "" &&
                   $h{$temp} lt $newWord) {

                $temp = $h{$temp};
            }
            $h{$newWord} = $h{$temp};
            $h{$temp} = $newWord;
        }

        print "Лексема добавлена.\n";
    } elsif ($choice == 2) {
        print "Введите лексему для удаления: ";
        $deleteWord = <STDIN>;
        chomp $deleteWord;

        if ($head == $deleteWord) {
            $head = $h{$deleteWord};
            delete $h{$deleteWord};
            print "Лексема удалена.\n";
        }

        else {
            $temp = $head;
            $found = 0;
            while ($temp != "") {
                if ($h{$temp} == $deleteWord) {
                    $h{$temp} = $h{$deleteWord};
                    delete $h{$deleteWord};
                    $found = 1;
                    print "Лексема удалена.\n";
                    last;
                }
                $temp = $h{$temp};
            }
            if ($found == 0) {
                print "Такой лексемы нет в списке.\n";
            }
        }
    }
    print "Выберите пункт: ";
    $choice = <STDIN>;
}
