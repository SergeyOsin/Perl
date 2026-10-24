#!/usr/bin/perl

print "Файл (с расширением): ";
my $file = <STDIN>;
chomp($file);

if (!-f $file) {
    die "Файла с названием $file не существует\n";
}

print "Выберите кодировку:\n";
print "1 - DOS866 -> KOI8-R\n";
print "2 - DOS866 -> Windows-1251\n";
print "Ваш выбор: ";

my $choice = <STDIN>;
chomp($choice);

open(my $readFile, '<:raw', $file)
    or die "Ошибка открытия файла: $!\n";

local $/;
my $text = <$readFile>;
close($readFile);

if ($choice eq '1') {
    $text =~ tr/\x80-\x9F\xA0-\xAF\xE0-\xEF\xF0-\xF1/\xE1\xE2\xF7\xE7\xE4\xE5\xF6\xFA\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF2\xF3\xF4\xF5\xE6\xE8\xE3\xFE\xFB\xFD\xFF\xF9\xF8\xFC\xE0\xF1\xC1\xC2\xD7\xC7\xC4\xC5\xD6\xDA\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD2\xD3\xD4\xD5\xC6\xC8\xC3\xDE\xDB\xDD\xDF\xD9\xD8\xDC\xC0\xD1\xB3\xA3/;
}

elsif ($choice eq '2') {
    $text =~ tr/\x80-\x9F\xA0-\xAF\xE0-\xEF\xF0-\xF1/\xC0-\xDF\xE0-\xEF\xF0-\xFF\xA8\xB8/;
}

else {
    die "Неверный выбор\n";
}

open(my $writeFile, '>:raw', $file)
    or die "Ошибка записи файла: $!\n";

print {$writeFile} $text;
close($writeFile);

print "Преобразование выполнено для файла $file\n";