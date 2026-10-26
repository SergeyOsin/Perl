#!/usr/bin/perl
use Socket;

our $PORT = 1027;
our $BUFFER_SIZE = 1024;

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

if ($domen + $protocol eq "11") {
    internet_tcp();
}
elsif ($domen eq "1") {
    internet_udp();
}
elsif ($domen + $protocol eq "21") {
    unix_tcp();
}
else {
    unix_udp();
}


sub internet_tcp {
   socket(my $server, PF_INET, SOCK_STREAM, getprotobyname("tcp"));
   setsockopt($server, SOL_SOCKET, SO_REUSEADDR, pack("l", 1));
   bind($server, sockaddr_in($PORT, INADDR_ANY));
   listen($server, SOMAXCONN);
   print "Internet TCP-сервер ожидает соединение на порту $PORT...\n";
   for(;accept(my $client, $server); close($client)){
      while (defined(my $message = <$client>)){
            print "Получено сообщение: $message\n";
      }
   }
   close($server);
}


sub internet_udp {
    socket(my $server, PF_INET, SOCK_DGRAM, getprotobyname("udp"));
    bind($server, sockaddr_in($PORT, INADDR_ANY));
    print "Internet UDP-сервер ожидает сообщение на порту $PORT...\n";

    while (1){
        my $data = "";
        my $sender = recv($server, $data, $BUFFER_SIZE, 0);
        print "Получено сообщение: $data\n";
    }
    close($server);
}


sub unix_tcp {
    socket(my $server, PF_UNIX, SOCK_STREAM, 0);
    bind($server, sockaddr_un('tmp.tmp'));
    listen($server, SOMAXCONN);

    print "UNIX TCP-сервер ожидает соединение...\n";
    for (;accept($client, $server); close ($client)){
        recv($client, $message, $BUFFER_SIZE, 0);
        print "Получено сообщение: $message\n";
    }
    close($server);
}

sub unix_udp {
    socket(my $server, PF_UNIX, SOCK_DGRAM, 0);
    setsockopt ($server, SOL_SOCKET, SO_REUSEADDR, 1); 
    unlink 'tmp.tmp';
    bind ($server, sockaddr_un('tmp.tmp'));
    print "UNIX UDP-сервер ожидает сообщение...\n";
    while (1){
        if (defined (recv ($server, $message, 100, 0 ))){
            print "Получено сообщение: $message\n";
        }
    }    
    close($server);
}
