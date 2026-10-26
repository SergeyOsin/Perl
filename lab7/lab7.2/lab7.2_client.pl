#!/usr/bin/perl

use IO::Socket::INET;
use IO::Socket::UNIX;

my $PORT = 5050;
my $UNIX_PATH = 'tmp.tmp';

print "Домены и протоколы (КЛИЕНТ):\n";
print "1. Internet\n";
print "\t1. TCP\n";
print "\t2. UDP\n";
print "2. UNIX\n";
print "\t1. TCP\n";
print "\t2. UDP\n";

print "Домен (1 или 2): ";
$domain = <STDIN>;
chomp($domain);

print "Протокол (1 или 2): ";
$protocol = <STDIN>;
chomp($protocol);


if ($domain + $protocol eq "11") {
    internet_tcp();
}
elsif ($domain eq "1") {
    internet_udp();
}
elsif ($domain + $protocol eq "21") {
    unix_tcp();
}
else {
    unix_udp();
}

sub internet_tcp {
    while (1) {
        my $message = read_message();
        
        my $client = IO::Socket::INET->new(
            PeerAddr => '127.0.0.1',
            PeerPort => $PORT,
            Proto    => 'tcp',
        ) or die "Ошибка подключения TCP-клиента: $!\n";

        print $client $message . "\n";
        print "Сообщение отправлено.\n\n";
        close($client);
    }
}

sub internet_udp {
    my $client = IO::Socket::INET->new(
        PeerAddr => '127.0.0.1',
        PeerPort => $PORT,
        Proto    => 'udp',
    ) or die "Ошибка создания UDP-клиента: $!\n";

    while (1) {
        my $message = read_message();

        $client->send($message)
            or die "Ошибка отправки: $!\n";

        print "Сообщение отправлено.\n\n";
    }
    close($client);
}

sub unix_tcp {
    while (1) {
        my $message = read_message();

        my $client = IO::Socket::UNIX->new(
            Type => SOCK_STREAM,
            Peer => $UNIX_PATH,
        ) or die "Ошибка подключения UNIX TCP-клиента: $!\n";

        print $client $message . "\n";
        print "Сообщение отправлено.\n\n";
        close($client);
    }
}

sub unix_udp {
    my $client_path = "client_tmp_$$.tmp";
    unlink($client_path);

    my $client = IO::Socket::UNIX->new(
        Type  => SOCK_DGRAM,
        Local => $client_path,
    ) or die "Ошибка создания UNIX UDP-клиента: $!\n";

    while (1) {
        my $message = read_message();

        my $address = IO::Socket::UNIX::sockaddr_un($UNIX_PATH);

        $client->send($message, 0, $address)
            or die "Ошибка отправки: $!\n";

        print "Сообщение отправлено.\n\n";
    }

    close($client);
    unlink($client_path);
}

sub read_message {
    print "Введите сообщение: ";
    my $message = <STDIN>;
    defined($message) or die "Не удалось прочитать сообщение\n";
    chomp($message);
    return $message;
}