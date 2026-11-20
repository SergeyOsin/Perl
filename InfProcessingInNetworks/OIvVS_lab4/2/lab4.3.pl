

use utf8;
use open qw(:std :encoding(UTF-8));

# CGI-заголовок — обязателен. Пустая строка отделяет его от тела.
print "Content-Type: text/html; charset=UTF-8\r\n";
print "\r\n";

sub esc {
    my ($s) = @_;
    $s = '' unless defined $s;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/"/&quot;/g;
    return $s;
}

my @keys = sort keys %ENV;

print <<'HTML_HEAD';
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<title>CGI Environment Variables</title>
<style>
    body   { font-family: sans-serif; margin: 2em; }
    table  { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #888; padding: 4px 8px; vertical-align: top; }
    th     { background: #eee; text-align: left; }
    td.k   { white-space: nowrap; font-family: monospace; }
    td.v   { font-family: monospace; word-break: break-all; }
    tr.method td { background: #fff8dc; font-weight: bold; }
</style>
</head>
<body>
HTML_HEAD

print "<h1>Переменные окружения CGI</h1>\n";
print "<p>Всего переменных: <strong>", scalar(@keys), "</strong>. ",
      "Метод запроса: <strong>",
      esc($ENV{REQUEST_METHOD} // '—'), "</strong>.</p>\n";

print "<table>\n<thead>\n<tr><th>Переменная</th><th>Значение</th></tr>\n</thead>\n<tbody>\n";

for my $k (@keys) {
    my $class = ($k eq 'REQUEST_METHOD') ? ' class="method"' : '';
    print "<tr$class>",
          "<td class=\"k\">", esc($k), "</td>",
          "<td class=\"v\">", esc($ENV{$k}), "</td>",
          "</tr>\n";
}

print "</tbody>\n</table>\n";
print "</body>\n</html>\n";