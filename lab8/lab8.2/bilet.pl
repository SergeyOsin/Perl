#!/usr/bin/perl

use utf8;
use FindBin qw($RealBin);
use Encode qw(decode FB_DEFAULT);

binmode(STDOUT, ':encoding(UTF-8)');

sub html_escape {
    my ($s) = @_;
    $s = '' unless defined $s;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/"/&quot;/g;
    $s =~ s/'/&#39;/g;
    return $s;
}

sub read_form {
    my %form;
    my $method = $ENV{'REQUEST_METHOD'} || '';

    if ($method ne 'POST') {
        return %form;
    }

    my $length = $ENV{'CONTENT_LENGTH'} || 0;
    return %form if $length !~ /^\d+$/ || $length > 10000;

    my $body = '';
    read(STDIN, $body, $length) if $length > 0;

    for my $pair (split /&/, $body) {
        my ($key, $value) = split /=/, $pair, 2;
        $key = '' unless defined $key;
        $value = '' unless defined $value;

        for ($key, $value) {
            tr/+/ /;
            s/%([0-9a-fA-F]{2})/chr(hex($1))/eg;
            $_ = decode('UTF-8', $_, FB_DEFAULT);
        }

        $form{$key} = $value;
    }

    return %form;
}

sub page_start {
    my ($title) = @_;

    print "Content-Type: text/html; charset=UTF-8\r\n\r\n";

    print '<!DOCTYPE html><html lang="ru"><head>';
    print '<meta charset="UTF-8">';
    print '<meta name="viewport" content="width=device-width, initial-scale=1">';
    print '<title>' . html_escape($title) . '</title>';
    print <<'CSS';
<style>
body {
    margin: 0;
    padding: 25px 15px;
    font-family: Arial, sans-serif;
    color: #203247;
    background: #eef3f8;
}
main {
    max-width: 800px;
    margin: 20px auto;
    padding: 28px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 3px 12px #18334d12;
}
h1 { color: #123b65; }
table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
}
th, td {
    padding: 11px;
    border: 1px solid #d8e0e9;
    text-align: left;
}
th { background: #e6eff8; }
input {
    max-width: 100%;
    padding: 10px;
    margin: 6px 0;
    box-sizing: border-box;
}
button {
    padding: 12px 18px;
    margin-top: 12px;
    border: 0;
    border-radius: 6px;
    color: white;
    background: #1769aa;
    cursor: pointer;
}
a { color: #1769aa; }
.error { color: #a12626; }
</style>
CSS
    print '</head><body><main>';
}

sub page_end {
    print '<hr>';
    print '<p><a href="index.html">Главная</a> | ';
    print '<a href="bilets.html">Поиск билетов</a> | ';
    print '<a href="client.html">Данные пассажира</a> | ';
    print '<a href="lab8.2.pl">Каталог рейсов</a></p>';
    print '</main></body></html>';
}

sub show_error {
    my ($message) = @_;
    page_start('Ошибка');
    print '<h1>Не удалось выполнить запрос</h1>';
    print '<p class="error">' . html_escape($message) . '</p>';
    page_end();
}

sub get_flights {
    my @flights;
    my $file = "$RealBin/database.txt";

    open(my $fh, '<:encoding(UTF-8)', $file)
        or die "Не удалось открыть базу данных";

    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s/\r$//;
        next if $line =~ /^\s*$/;

        my @fields = split /\|/, $line, -1;
        next unless @fields == 5;

        my ($number, $from, $to, $date, $price) = @fields;

        next unless $number =~ /^[A-Za-z0-9-]{1,15}$/;
        next unless $date =~ /^\d{4}-\d{2}-\d{2}$/;
        next unless $price =~ /^\d+(?:\.\d{1,2})?$/;

        push @flights, {
            number => $number,
            from   => $from,
            to     => $to,
            date   => $date,
            price  => $price
        };
    }

    close($fh);
    return @flights;
}

sub search_flights {
    my (%form) = @_;

    my $from  = $form{'from'}  // '';
    my $to    = $form{'to'}    // '';
    my $date  = $form{'date'}  // '';
    my $count = $form{'count'} // '1';

    if ($from eq '' || $to eq '' || $from eq $to) {
        show_error('Выберите разные города отправления и назначения.');
        return;
    }

    if ($date !~ /^\d{4}-\d{2}-\d{2}$/) {
        show_error('Укажите корректную дату вылета.');
        return;
    }

    if ($count !~ /^\d{1,2}$/ || $count < 1 || $count > 9) {
        show_error('Количество пассажиров должно быть от 1 до 9.');
        return;
    }

    my @flights = get_flights();

    my @found = grep {
        $_->{from} eq $from
        && $_->{to} eq $to
        && $_->{date} eq $date
    } @flights;

    page_start('Результаты поиска');
    print '<h1>Результаты поиска</h1>';

    print '<p>Маршрут: ' . html_escape($from)
        . ' — ' . html_escape($to) . '</p>';

    print '<p>Дата: ' . html_escape($date)
        . ', пассажиров: ' . html_escape($count) . '</p>';

    if (!@found) {
        print '<p>Подходящие рейсы не найдены. '
            . 'Попробуйте изменить дату или маршрут.</p>';
        page_end();
        return;
    }

    print '<table><tr><th>Рейс</th><th>Маршрут</th>'
        . '<th>Дата</th><th>Цена за билет</th></tr>';

    for my $f (@found) {
        print '<tr><td>' . html_escape($f->{number}) . '</td>';
        print '<td>' . html_escape($f->{from}) . ' — '
            . html_escape($f->{to}) . '</td>';
        print '<td>' . html_escape($f->{date}) . '</td>';
        print '<td>' . html_escape($f->{price}) . ' руб.</td></tr>';
    }

    print '</table>';
    print '<h2>Оформление заказа</h2>';

    print '<form method="post" action="bilet.pl">';
    print '<input type="hidden" name="action" value="book">';
    print '<input type="hidden" name="from" value="'
        . html_escape($from) . '">';
    print '<input type="hidden" name="to" value="'
        . html_escape($to) . '">';
    print '<input type="hidden" name="date" value="'
        . html_escape($date) . '">';
    print '<input type="hidden" name="count" value="'
        . html_escape($count) . '">';

    print '<p><label>Выберите рейс: <select name="flight" required>';

    for my $f (@found) {
        print '<option value="' . html_escape($f->{number}) . '">'
            . html_escape($f->{number}) . ' — '
            . html_escape($f->{price}) . ' руб.</option>';
    }

    print '</select></label></p>';

    print '<p><label>Фамилия и имя:<br>'
        . '<input name="fullname" maxlength="100" required></label></p>';

    print '<p><label>Email:<br>'
        . '<input type="email" name="email" maxlength="150" required></label></p>';

    print '<button type="submit">Оформить заказ</button>';
    print '</form>';

    page_end();
}

sub book_ticket {
    my (%form) = @_;

    my $flight = $form{'flight'} // '';
    my $from = $form{'from'} // '';
    my $to = $form{'to'} // '';
    my $date = $form{'date'} // '';
    my $count = $form{'count'} // '';
    my $name = $form{'fullname'} // '';
    my $email = $form{'email'} // '';

    if ($name !~ /\S/ || length($name) > 100
        || $email !~ /^[^\s\@]+\@[^\s\@]+\.[^\s\@]+$/
        || length($email) > 150) {
        show_error('Введите корректные имя и адрес электронной почты.');
        return;
    }

    if ($count !~ /^\d{1,2}$/ || $count < 1 || $count > 9) {
        show_error('Некорректное количество пассажиров.');
        return;
    }

    my @flights = get_flights();

    my ($f) = grep {
        $_->{number} eq $flight
        && $_->{from} eq $from
        && $_->{to} eq $to
        && $_->{date} eq $date
    } @flights;

    if (!$f) {
        show_error('Выбранный рейс не найден в базе данных.');
        return;
    }

    my $total = $f->{price} * $count;

    page_start('Заказ оформлен');

    print '<h1>Заказ успешно оформлен!</h1>';
    print '<p>Спасибо, ' . html_escape($name) . '.</p>';
    print '<p>Номер рейса: ' . html_escape($f->{number}) . '</p>';
    print '<p>Маршрут: ' . html_escape($f->{from}) . ' — '
        . html_escape($f->{to}) . '</p>';
    print '<p>Дата вылета: ' . html_escape($f->{date}) . '</p>';
    print '<p>Количество билетов: ' . html_escape($count) . '</p>';
    print '<p>Стоимость одного билета: '
        . html_escape($f->{price}) . ' руб.</p>';
    print '<h2>Итого: ' . html_escape($total) . ' руб.</h2>';
    print '<p>Контактный email: ' . html_escape($email) . '</p>';
    print '<p>Это подтверждение демонстрационного заказа. '
        . 'Реальная бронь и оплата не выполняются.</p>';

    page_end();
}

sub client_form {
    my (%form) = @_;

    my $name = $form{'fullname'} // '';
    my $email = $form{'email'} // '';
    my $phone = $form{'phone'} // '';
    my $document = $form{'document'} // '';

    if ($name !~ /\S/ || length($name) > 100
        || $email !~ /^[^\s\@]+\@[^\s\@]+\.[^\s\@]+$/
        || length($email) > 150
        || $phone !~ /^[0-9+() -]{5,30}$/
        || $document !~ /^[A-Za-zА-Яа-яЁё0-9 -]{3,30}$/) {
        show_error('Проверьте имя, email, телефон и номер документа.');
        return;
    }

    page_start('Данные пассажира');
    print '<h1>Данные успешно обработаны</h1>';
    print '<p>Фамилия и имя: ' . html_escape($name) . '</p>';
    print '<p>Email: ' . html_escape($email) . '</p>';
    print '<p>Телефон: ' . html_escape($phone) . '</p>';
    print '<p>Номер документа: ' . html_escape($document) . '</p>';
    print '<p>Демонстрационная форма обработана серверной CGI-программой. '
        . 'Введённые персональные данные не сохраняются.</p>';
    page_end();
}

my %form = read_form();
my $action = $form{'action'} // '';

if (($ENV{'REQUEST_METHOD'} || '') ne 'POST') {
    show_error('Откройте сайт и отправьте одну из форм.');
}
elsif ($action eq 'search') {
    search_flights(%form);
}
elsif ($action eq 'book') {
    book_ticket(%form);
}
elsif ($action eq 'client') {
    client_form(%form);
}
else {
    show_error('Неизвестное действие. Вернитесь на главную страницу.');
}
