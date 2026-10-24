#!/usr/bin/perl
use Socket;

my $PORT = 5001;

sub internet_tcp_client {
    socket(my $client, PF_INET, SOCK_STREAM, getprotobyname("tcp"))
        or die "socket: $!";
    connect($client, sockaddr_in($PORT, inet_aton("127.0.0.1")))
        or die "connect: $!";

    while (1){
      print "Введите сообщение: ";
      my $message = <STDIN>;
      chomp($message);

      send($client, $message, 0);
         
      print "Сообщение отправлено.\n\n";

      recv($client, $revData, 1024, 0);

      print "Ответ от сервера: $revData\n";
    }
    close($client);
}

internet_tcp_client();