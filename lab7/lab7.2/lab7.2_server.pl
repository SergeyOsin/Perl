#!/usr/bin/perl

use IO::Socket::INET;
use IO::Socket::UNIX;

my $PORT = 5050;
my $UNIX_PATH = 'tmp.tmp';

print "Домены и протоколы (СЕРВЕР):\n";
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

print "\nЗапуск сервера...\n";

if ($domain eq "1" && $protocol eq "1") {
    internet_tcp();
}
elsif ($domain eq "1" && $protocol eq "2") {
    internet_udp();
}
elsif ($domain eq "2" && $protocol eq "1") {
    unix_tcp();
}
else {
    unix_udp();
}

sub internet_tcp {
    my $server = IO::Socket::INET->new(
        LocalAddr => '0.0.0.0',
        LocalPort => $PORT,
        Proto     => 'tcp',
        Listen    => 20,
        ReuseAddr => 1,
    ) or die "Невозможно использовать порт: $PORT\n";

    print "TCP-сервер ожидает соединение на порту $PORT...\n";

    while (my $client = $server->accept()) {
        my $message = <$client>;
        if (defined $message) {
            chomp($message);
            print "Получено сообщение: $message\n";
        }
        close($client);
    }
    close($server);
}

sub internet_udp {
    my $server = IO::Socket::INET->new(
        LocalAddr => '0.0.0.0',
        LocalPort => $PORT,
        Proto     => 'udp',
        ReuseAddr => 1,
    ) or die "Ошибка создания UDP-сервера: $!\n";

    print "UDP-сервер ожидает сообщение на порту $PORT...\n";

    while (1) {
        my $data = '';
        $server->recv($data, 1024);
        print "Получено сообщение: $data\n";
    }
    close($server);
}

sub unix_tcp {
    unlink($UNIX_PATH);

    my $server = IO::Socket::UNIX->new(
        Type   => SOCK_STREAM,
        Local  => $UNIX_PATH,
        Listen => 20,
    ) or die "Ошибка создания UNIX TCP-сервера: $!\n";

    print "UNIX TCP-сервер ожидает соединение...\n";

    while (my $client = $server->accept()) {
        my $message = <$client>;
        if (defined $message) {
            chomp($message);
            print "Получено сообщение: $message\n";
        }
        close($client);
    }
    close($server);
    unlink($UNIX_PATH);
}

sub unix_udp {
    unlink($UNIX_PATH);

    my $server = IO::Socket::UNIX->new(
        Type  => SOCK_DGRAM,
        Local => $UNIX_PATH,
    ) or die "Ошибка создания UNIX UDP-сервера: $!\n";

    print "UNIX UDP-сервер ожидает сообщение...\n";

    while (1) {
        my $data = '';
        $server->recv($data, 1024);
        print "Получено сообщение: $data\n";
    }
    close($server);
    unlink($UNIX_PATH);
}