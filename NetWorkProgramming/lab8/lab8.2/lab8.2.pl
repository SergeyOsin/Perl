#!/usr/bin/perl
use utf8;
use FindBin qw($RealBin);

binmode(STDOUT, ':encoding(UTF-8)');

sub escape_html {
    my ($s) = @_;
    $s = '' unless defined $s;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/"/&quot;/g;
    $s =~ s/'/&#39;/g;
    return $s;
}

print "Content-Type: text/html; charset=UTF-8\r\n\r\n";

print <<'HTML';
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Каталог авиарейсов</title>
<style>
body {
    font-family: Arial, sans-serif;
    background: #eef3f8;
    color: #203247;
    padding: 25px 15px;
}
main {
    max-width: 850px;
    margin: auto;
    background: white;
    padding: 25px;
    border-radius: 12px;
}
table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
}
th, td {
    border: 1px solid #d8e0e9;
    padding: 10px;
    text-align: left;
}
th { background: #e6eff8; }
a { color: #1769aa; }
</style>
</head>
<body>
<main>
<h1>Каталог авиарейсов</h1>
<table>
<tr>
<th>Номер рейса</th>
<th>Отправление</th>
<th>Назначение</th>
<th>Дата</th>
<th>Цена</th>
</tr>
HTML

my $file = "$RealBin/database.txt";
my $ok = open(my $fh, '<:encoding(UTF-8)', $file);

if (!$ok) {
    print '<tr><td colspan="5">Не удалось открыть базу данных.</td></tr>';
}
else {
    my $found = 0;

    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/\r$//;
        next if $line =~ /^\s*$/;

        my @fields = split /\|/, $line, -1;
        next unless @fields == 5;

        my ($number, $from, $to, $date, $price) = @fields;
        next unless $date =~ /^\d{4}-\d{2}-\d{2}$/;
        next unless $price =~ /^\d+(?:\.\d{1,2})?$/;

        print '<tr>';
        print '<td>' . escape_html($number) . '</td>';
        print '<td>' . escape_html($from) . '</td>';
        print '<td>' . escape_html($to) . '</td>';
        print '<td>' . escape_html($date) . '</td>';
        print '<td>' . escape_html($price) . ' руб.</td>';
        print '</tr>';

        $found++;
    }

    close($fh);

    if (!$found) {
        print '<tr><td colspan="5">Рейсы не найдены.</td></tr>';
    }
}

print <<'HTML';
</table>
<p><a href="index.html">На главную</a></p>
<p><a href="bilets.html">Найти и заказать билет</a></p>
</main>
</body>
</html>
HTML
