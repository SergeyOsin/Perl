#!/usr/bin/perl

open ($newFile, '>', "outputHanoi.txt") or die ("Не удалось открыть файл");

sub print_rods {
    my ($a, $b, $c) = @_;

    print $newFile "A: ";
    print $newFile @$a ? join(" ", @$a) : "-";
    print $newFile "\n";

    print $newFile "B: ";
    print $newFile @$b ? join(" ", @$b) : "-";
    print $newFile "\n";

    print $newFile "C: ";
    print $newFile @$c ? join(" ", @$c) : "-";
    print $newFile "\n";
}

sub move_disk {
    my ($from, $to, $rods) = @_;

    my $disk = pop @{$rods->{$from}};
    push @{$rods->{$to}}, $disk;

    print $newFile "\nПеренос диска диаметром $disk со стержня $from на стержень $to\n";

    print_rods(
        $rods->{A},
        $rods->{B},
        $rods->{C}
    );
}

sub hanoi {
    my ($n, $from, $to, $aux, $rods) = @_;

    return if $n == 0;

    hanoi($n - 1, $from, $aux, $to, $rods);

    move_disk($from, $to, $rods);

    hanoi($n - 1, $aux, $to, $from, $rods);
}

print "Введите количество дисков: ";
my $n = <STDIN>;
chomp $n;

print $newFile "Количество дисков: $n\n\n";

my @a;
my @b;
my @c;

for (my $i = $n; $i >= 1; $i--) {
    $a[$#a + 1] = $i;
}

my %rods = (
    A => \@a,
    B => \@b,
    C => \@c
);

print $newFile "Начальное состояние:\n";
print_rods($rods{A}, $rods{B}, $rods{C});

hanoi($n, "A", "C", "B", \%rods);

print $newFile "\nКонечное состояние:\n";
print_rods($rods{A}, $rods{B}, $rods{C});

print "Решение записано в текстовый файл - outputHanoi!";
close($newFile);
