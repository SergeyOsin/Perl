#!/usr/bin/perl
use Socket;

my $PORT = 5001;

sub internet_tcp_server {
    socket(my $server, PF_INET, SOCK_STREAM, getprotobyname("tcp"))
        or die "socket: $!";

    setsockopt($server, SOL_SOCKET, SO_REUSEADDR, pack("l", 1))
        or die "setsockopt: $!";

    bind($server, sockaddr_in($PORT, INADDR_ANY))
        or die "bind: $!";

    listen($server, SOMAXCONN)
        or die "listen: $!";

    print "Сервер на порту $PORT начал работу...\n";

    while (1) {
        my $client_addr = accept(my $client, $server);
        next unless $client_addr;

        recv($client, $message, 1024, 0);

        print "Получено сообщение: $message\n";
        
        my $revData = reverse split //, $message;
        
        send($client, $revData, 0);
        print "Инвертированное сообщение - $revData - отправлено клиенту\n\n";

        close($client);
    }
    close($server);
}

internet_tcp_server();