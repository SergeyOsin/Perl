#!/usr/bin/perl

sub print_rods {
    my ($a, $b, $c) = @_;

    print "A: ";
    print @$a ? join(" ", @$a) : "-";
    print "\n";

    print "B: ";
    print @$b ? join(" ", @$b) : "-";
    print "\n";

    print "C: ";
    print @$c ? join(" ", @$c) : "-";
    print "\n";
}

sub move_disk {
    my ($from, $to, $rods) = @_;

    my $disk = pop @{$rods->{$from}};
    push @{$rods->{$to}}, $disk;

    print "\nПеренос диска диаметром $disk со стержня $from на стержень $to\n";

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

my @a;
my @b;
my @c;

for (my $i = $n; $i >= 1; $i--) {
    push @a, $i;
}

my %rods = (
    A => \@a,
    B => \@b,
    C => \@c
);

print "\nНачальное состояние:\n";
print_rods($rods{A}, $rods{B}, $rods{C});

hanoi($n, "A", "C", "B", \%rods);

print "\nКонечное состояние:\n";
print_rods($rods{A}, $rods{B}, $rods{C});
