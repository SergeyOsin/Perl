#!/usr/bin/perl

print "Файл (с расширением): ";
my $file = <STDIN>;
chomp($file);

if (!-f $file) {
    die "Файла с названием $file не существует\n";
}

@symbols = (
    [10000, 'Xt'],
    [5000,  'Vt'],
    [1000,  'M'],
    [900,   'CM'],
    [500,   'D'],
    [400,   'CD'],
    [100,   'C'],
    [90,    'XC'],
    [50,    'L'],
    [40,    'XL'],
    [10,    'X'],
    [9,     'IX'],
    [5,     'V'],
    [4,     'IV'],
    [1,     'I']
);


open($readFile, '<', $file);
$text = do { local $/; <$readFile> };
close($readFile);

sub to_roman {
    my ($number) = @_;
    my $roman = '';

    for my $symbol (@symbols) {
        my ($value, $numeral) = @$symbol;
        while ($number >= $value) {
            $roman .= $numeral;
            $number -= $value;
            $countChanged++;
        }
    }

    return $roman;
}

$text =~ s/(\d+)/to_roman($1)/ge;

open($writeFile, '>', $file);
print $writeFile $text;
close($writeFile);






