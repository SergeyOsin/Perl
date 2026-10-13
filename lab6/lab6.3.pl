#!/usr/bin/perl

print "Файл (с расширением): ";
my $file = <STDIN>;
chomp($file);

if (!-f $file) {
    die "Файла с названием $file не существует\n";
}

open(my $readFile, '<', $file)
    or die "Не удалось открыть файл для чтения: $!\n";

my $text = do { local $/; <$readFile> };
close($readFile);

sub from_roman {
    my ($roman) = @_;

    my %values = (
        I => 1,
        V => 5,
        X => 10,
        L => 50,
        C => 100,
        D => 500,
        M => 1000,
        Vt => 5000,
        Xt => 10000
    );

    my $number = 0;
    my @symbols = split //, $roman;

    for (my $i = 0; $i < @symbols; $i++) {
        if ($i < $#symbols &&
            $values{$symbols[$i]} < $values{$symbols[$i + 1]}) {
            $number -= $values{$symbols[$i]};
        } else {
            $number += $values{$symbols[$i]};
        }
    }

    return $number;
}

my $pattern = qr/
    (?<![IVXLCDM])
    M{0,3}
    (?:CM|CD|D?C{0,3})
    (?:XC|XL|L?X{0,3})
    (?:IX|IV|V?I{0,3})
    (?![IVXLCDM])
/ix;

$text =~ s/($pattern)(?=\s|\W|$)/
    length($1) ? from_roman(uc($1)) : $1
/ge;

open(my $writeFile, '>', $file);

print $writeFile $text;

close($writeFile) or die "Ошибка при записи в файл: $!\n";

print "Файл $file успешно обработан.\n";