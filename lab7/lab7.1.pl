#!/usr/bin/perl
use Socket qw(sockaddr_in inet_aton);

my $PORT = 5000;
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
my $domen = <STDIN>;
chomp($domen);

print "Протокол (1 или 2): ";
my $protocol = <STDIN>;
chomp($protocol);

print "\nВыберите режим:\n";
print "1. Сервер\n";
print "2. Клиент\n";
print "Ваш выбор: ";

my $mode = <STDIN>;
chomp($mode);

if ($domen eq "1" && $protocol eq "1") {
    internet_tcp($mode);
}

elsif ($domen eq "1" && $protocol eq "2") {
    internet_udp($mode);
}

elsif ($domen eq "2" && $protocol eq "1") {
    unix_tcp($mode);
}

else {
    unix_udp($mode);
}


sub internet_tcp {
    my ($mode) = @_;

    if ($mode eq "1") {
        socket(my $server, PF_INET, SOCK_STREAM, getprotobyname("tcp"));

        setsockopt($server, SOL_SOCKET, SO_REUSEADDR, pack("l", 1));

        bind($server, sockaddr_in($PORT, INADDR_ANY));

        listen($server, SOMAXCONN);

        print "TCP-сервер ожидает соединение на порту $PORT...\n";

        accept(my $client, $server);

        my $data = "";
        recv($client, $data, $BUFFER_SIZE, 0);

        print "Получено сообщение: $data\n";
        close($client);
        close($server);
    }
    else {
        print "Введите сообщение: ";
        my $message = <STDIN>;
        chomp($message);

        socket($client, PF_INET, SOCK_STREAM, getprotobyname("tcp"));
        connect($client, sockaddr_in($PORT, inet_aton("127.0.0.1")));
        send($client, $message, 0);
        print "Сообщение отправлено.\n";
        close($client);
    }
}

sub internet_udp {
    my ($mode) = @_;

    if ($mode eq "1") {
        socket(my $server, PF_INET, SOCK_DGRAM, getprotobyname("udp"));

        bind($server, sockaddr_in($PORT, INADDR_ANY));

        print "UDP-сервер ожидает сообщение на порту $PORT...\n";

        my $data = "";
        my $sender = recv($server, $data, $BUFFER_SIZE, 0);
        defined($sender);

        print "Получено сообщение: $data\n";
        close($server);
    }
    else {
        print "Введите сообщение: ";
        my $message = <STDIN>;
        chomp($message);

        socket(my $client, PF_INET, SOCK_DGRAM, getprotobyname("udp"))
            or die "socket: $!";

        send($client, $message, 0,
             sockaddr_in($PORT, inet_aton("127.0.0.1")))
            or die "send: $!";

        print "Сообщение отправлено.\n";
        close($client);
    }
}


sub unix_tcp {
    my ($mode) = @_;

    if ($mode eq "1") {
        unlink($UNIX_PATH);

        socket(my $server, PF_UNIX, SOCK_STREAM, 0)
            or die "socket: $!";

        bind($server, sockaddr_un($UNIX_PATH))
            or die "bind: $!";

        listen($server, SOMAXCONN)
            or die "listen: $!";

        print "UNIX TCP-сервер ожидает соединение...\n";

        accept(my $client, $server)
            or die "accept: $!";

        my $data = "";
        recv($client, $data, $BUFFER_SIZE, 0)
            or die "recv: $!";

        print "Получено сообщение: $data\n";
        close($client);
        close($server);
        unlink($UNIX_PATH);
    }
    else {
        print "Введите сообщение: ";
        my $message = <STDIN>;
        chomp($message);

        socket(my $client, PF_UNIX, SOCK_STREAM, 0)
            or die "socket: $!";

        connect($client, sockaddr_un($UNIX_PATH))
            or die "connect: $!";

        send($client, $message, 0)
            or die "send: $!";

        print "Сообщение отправлено.\n";
        close($client);
    }
}

sub unix_udp {
    my ($mode) = @_;

    if ($mode eq "1") {
        unlink($UNIX_PATH);

        socket(my $server, PF_UNIX, SOCK_DGRAM, 0)
            or die "socket: $!";

        bind($server, sockaddr_un($UNIX_PATH))
            or die "bind: $!";

        print "UNIX UDP-сервер ожидает сообщение...\n";

        my $data = "";
        my $sender = recv($server, $data, $BUFFER_SIZE, 0);
        defined($sender) or die "recv: $!";

        print "Получено сообщение: $data\n";
        close($server);
        unlink($UNIX_PATH);
    }
    else {
        print "Введите сообщение: ";
        my $message = <STDIN>;
        chomp($message);

        my $client_path = "/tmp/perl_socket_client_$$.sock";
        unlink($client_path);

        socket(my $client, PF_UNIX, SOCK_DGRAM, 0)
            or die "socket: $!";

        bind($client, sockaddr_un($client_path))
            or die "bind: $!";

        send($client, $message, 0, sockaddr_un($UNIX_PATH))
            or die "send: $!";

        print "Сообщение отправлено.\n";
        close($client);
        unlink($client_path);
    }
}
