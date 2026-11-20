#!/usr/bin/perl
use Socket;

our $PORT = 1027;
our $RemoteHost = "localhost";
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
    socket(my $client, PF_INET, SOCK_STREAM, getprotobyname("tcp"));
    my $internet_addr = inet_aton($RemoteHost);
    connect($client, sockaddr_in($PORT, $internet_addr));
    while (1){
        print "Введите сообщение: ";
        my $message = <STDIN>;
        chomp($message);

        print $client "$message\n";
        print "Сообщение - $message - отправлено.\n\n";
    }
    close($client);
}


sub internet_udp {
    socket(my $client, PF_INET, SOCK_DGRAM, getprotobyname("udp"));
    while (1){
        print "Введите сообщение: ";
        my $message = <STDIN>;
        chomp($message);
        send($client, $message, 0,sockaddr_in($PORT, inet_aton($RemoteHost)));
        print "Сообщение отправлено.\n\n";
    }
    close($client);
}


sub unix_tcp {
    socket(my $client, PF_UNIX, SOCK_STREAM, 0);
    connect($client, sockaddr_un('tmp.tmp'));
    while (1){
        print "Введите сообщение: ";
        my $message = <STDIN>;
        chomp($message);

        send($client, $message, 0);

        print "Сообщение отправлено.\n\n";
    }
    close($client);
}


sub unix_udp {
    socket(my $client, PF_UNIX, SOCK_DGRAM, 0);
    while (1){
        print "Введите сообщение: ";
        my $message = <STDIN>;
        chomp($message);  
        send($client, $message, 0, sockaddr_un('tmp.tmp'));
        print "Сообщение отправлено.\n\n";
    }
    close($client);
}