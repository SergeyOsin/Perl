#!/usr/bin/perl
use Socket qw(
    PF_INET
    SOCK_STREAM
    SOCK_DGRAM
    sockaddr_in
    inet_aton
    INADDR_ANY
);

$PORT = 5001;
$UNIX_PATH = "/tmp/perl_socket_app.sock";
$BUFFER_SIZE = 1024;

print "Режим: \n";
print "1. Сервер\n";
print "2. Клиент\n";

print "Выбор: ";
$choose = <STDIN>;
chomp ($choose);

sub internet_tcp {
    my ($mode) = @_;
    if ($mode eq "1") {
        socket($server, PF_INET, SOCK_STREAM, getprotobyname("tcp"));

        setsockopt($server, SOL_SOCKET, SO_REUSEADDR, pack("l", 1));

        bind($server, sockaddr_in($PORT, INADDR_ANY));

        listen($server, SOMAXCONN);

        print "TCP-сервер ожидает соединение на порту $PORT...\n";

        while (1){
            accept(my $client, $server);

            $data = "";
            recv($client, $data, $BUFFER_SIZE, 0);

            print "Получено сообщение: $data\n";
            $revData = reverse split //, $data;
            
            send ($client, $revData, 0);

            print "Инвертированное сообщение отправлено клиенту\n\n";
        }
        close($client);
        close($server);
    }
    else {
        print "Введите сообщение: ";
        $message = <STDIN>;
        chomp($message);

        socket($client, PF_INET, SOCK_STREAM, getprotobyname("tcp"));
        connect($client, sockaddr_in($PORT, inet_aton("127.0.0.1")));
        send($client, $message, 0);
        print "Сообщение отправлено.\n\n";
        recv($client, $revData, $BUFFER_SIZE, 0);

        print "Ответ от сервера: $revData \n";
        close($client);
    }
}

internet_tcp($choose);