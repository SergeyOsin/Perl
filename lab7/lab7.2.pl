#!/usr/bin/perl

use IO::Socket::INET;
use IO::Socket::UNIX;
use Socket qw(SOCK_STREAM SOCK_DGRAM SOMAXCONN);

my $PORT = 5050;
my $UNIX_PATH = "/tmp/perl_socket_app.sock";
my $BUFFER_SIZE = 1024;

print "Домены и протоколы:\n";
print "1. Internet\n";
print "\t1. TCP\n";
print "\t2. UDP\n";
print "2. UNIX\n";
print "\t1. TCP\n";
print "\t2. UDP\n";

print "Домен (1 или 2): ";
chomp(my $domain = <STDIN>);

print "Протокол (1 или 2): ";
chomp(my $protocol = <STDIN>);

print "\nВыберите режим:\n";
print "1. Сервер\n";
print "2. Клиент\n";
print "Ваш выбор: ";
chomp(my $mode = <STDIN>);

die "Неверный домен\n"
    unless $domain eq "1" || $domain eq "2";

die "Неверный протокол\n"
    unless $protocol eq "1" || $protocol eq "2";

die "Неверный режим\n"
    unless $mode eq "1" || $mode eq "2";

if ($domain eq "1" && $protocol eq "1") {
    internet_tcp($mode);
}
elsif ($domain eq "1" && $protocol eq "2") {
    internet_udp($mode);
}
elsif ($domain eq "2" && $protocol eq "1") {
    unix_tcp($mode);
}
else {
    unix_udp($mode);
}

sub internet_tcp {
    my ($mode) = @_;

    if ($mode eq "1") {
        my $server = IO::Socket::INET->new(
            LocalAddr => '0.0.0.0',
            LocalPort => $PORT,
            Proto     => 'tcp',
            Listen    => SOMAXCONN,
            ReuseAddr => 1,
        ) or die "Ошибка создания TCP-сервера: $!\n";

        print "TCP-сервер ожидает соединение на порту $PORT...\n";

        my $client = $server->accept()
            or die "Ошибка accept: $!\n";

        my $data = '';
        $client->recv($data, $BUFFER_SIZE);

        print "Получено сообщение: $data\n";

        close($client);
        close($server);
    }
    else {
        my $message = read_message();

        my $client = IO::Socket::INET->new(
            PeerAddr => '127.0.0.1',
            PeerPort => $PORT,
            Proto    => 'tcp',
        ) or die "Ошибка подключения TCP-клиента: $!\n";

        $client->send($message)
            or die "Ошибка отправки: $!\n";

        print "Сообщение отправлено.\n";
        close($client);
    }
}

sub internet_udp {
    my ($mode) = @_;

    if ($mode eq "1") {
        my $server = IO::Socket::INET->new(
            LocalAddr => '0.0.0.0',
            LocalPort => $PORT,
            Proto     => 'udp',
            ReuseAddr => 1,
        ) or die "Ошибка создания UDP-сервера: $!\n";

        print "UDP-сервер ожидает сообщение на порту $PORT...\n";

        my $data = '';
        $server->recv($data, $BUFFER_SIZE)
            or die "Ошибка получения сообщения: $!\n";

        print "Получено сообщение: $data\n";
        close($server);
    }
    else {
        my $message = read_message();

        my $client = IO::Socket::INET->new(
            PeerAddr => '127.0.0.1',
            PeerPort => $PORT,
            Proto    => 'udp',
        ) or die "Ошибка создания UDP-клиента: $!\n";

        $client->send($message)
            or die "Ошибка отправки: $!\n";

        print "Сообщение отправлено.\n";
        close($client);
    }
}

sub unix_tcp {
    my ($mode) = @_;

    if ($mode eq "1") {
        unlink($UNIX_PATH);

        my $server = IO::Socket::UNIX->new(
            Type   => SOCK_STREAM,
            Local  => $UNIX_PATH,
            Listen => SOMAXCONN,
        ) or die "Ошибка создания UNIX TCP-сервера: $!\n";

        print "UNIX TCP-сервер ожидает соединение...\n";

        my $client = $server->accept()
            or die "Ошибка accept: $!\n";

        my $data = '';
        $client->recv($data, $BUFFER_SIZE)
            or die "Ошибка получения сообщения: $!\n";

        print "Получено сообщение: $data\n";

        close($client);
        close($server);
        unlink($UNIX_PATH);
    }
    else {
        my $message = read_message();

        my $client = IO::Socket::UNIX->new(
            Type => SOCK_STREAM,
            Peer => $UNIX_PATH,
        ) or die "Ошибка подключения UNIX TCP-клиента: $!\n";

        $client->send($message)
            or die "Ошибка отправки: $!\n";

        print "Сообщение отправлено.\n";
        close($client);
    }
}

sub unix_udp {
    my ($mode) = @_;

    if ($mode eq "1") {
        unlink($UNIX_PATH);

        my $server = IO::Socket::UNIX->new(
            Type  => SOCK_DGRAM,
            Local => $UNIX_PATH,
        ) or die "Ошибка создания UNIX UDP-сервера: $!\n";

        print "UNIX UDP-сервер ожидает сообщение...\n";

        my $data = '';
        $server->recv($data, $BUFFER_SIZE)
            or die "Ошибка получения сообщения: $!\n";

        print "Получено сообщение: $data\n";

        close($server);
        unlink($UNIX_PATH);
    }
    else {
        my $message = read_message();

        my $client_path = "/tmp/perl_socket_client_$$.sock";
        unlink($client_path);

        my $client = IO::Socket::UNIX->new(
            Type  => SOCK_DGRAM,
            Local => $client_path,
        ) or die "Ошибка создания UNIX UDP-клиента: $!\n";

        $client->send($message, 0, $UNIX_PATH)
            or die "Ошибка отправки: $!\n";

        print "Сообщение отправлено.\n";

        close($client);
        unlink($client_path);
    }
}

sub read_message {
    print "Введите сообщение: ";
    my $message = <STDIN>;
    defined($message) or die "Не удалось прочитать сообщение\n";
    chomp($message);
    return $message;
}
