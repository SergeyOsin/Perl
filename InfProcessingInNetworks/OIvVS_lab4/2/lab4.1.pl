#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

use IO::Socket::INET;
use Encode qw(decode FB_DEFAULT);
use URI;

my $server_url   = shift @ARGV || 'http://localhost/';
my $resource_url = shift @ARGV || 'http://localhost/cgi-bin/test.cgi';

sub parse_url {
    my ($url) = @_;
    my $u    = URI->new($url);
    my $host = $u->host || 'localhost';
    my $port = $u->port || 80;
    my $path = $u->path || '/';
    $path .= '?' . $u->query if defined $u->query;
    return ($host, $port, $path);
}

sub decode_chunked {
    my ($data) = @_;
    my $out = '';
    my $pos = 0;
    while ($pos < length $data) {
        my $eol = index($data, "\r\n", $pos);
        last if $eol < 0;
        my $size_line = substr($data, $pos, $eol - $pos);
        $size_line =~ s/;.*//;          # отбросить расширения chunk
        my $size = hex($size_line);
        last if $size == 0;
        $pos = $eol + 2;
        $out .= substr($data, $pos, $size);
        $pos += $size + 2;              # пропустить CRLF после чанка
    }
    return $out;
}

sub raw_options {
    my ($host, $port, $target, $label) = @_;

    my $sock = IO::Socket::INET->new(
        PeerHost => $host,
        PeerPort => $port,
        Proto    => 'tcp',
        Timeout  => 10,
    ) or die "Не удалось подключиться к $host:$port: $!\n";

    my $host_header = ($port == 80) ? $host : "$host:$port";

    my $request =
          "OPTIONS $target HTTP/1.1\r\n"
        . "Host: $host_header\r\n"
        . "User-Agent: Lab4-OPTIONS-Client/1.0\r\n"
        . "Connection: close\r\n"
        . "\r\n";
    print $sock $request;

    my $status_line = <$sock>;
    my %headers;
    my @raw_headers;

    while (my $line = <$sock>) {
        $line =~ s/\r?\n\z//;
        last if $line eq '';
        push @raw_headers, $line;
        if ($line =~ /^([^:]+):\s*(.*)$/) {
            $headers{lc $1} = $2;
        }
    }

    my $body = do { local $/; <$sock> };
    close $sock;

    if (defined $body && lc($headers{'transfer-encoding'} // '') eq 'chunked') {
        $body = decode_chunked($body);
    }

    print "=" x 60, "\n";
    print "$label\n";
    print "Строка запроса: OPTIONS $target HTTP/1.1\n";
    print "Хост: $host_header\n";
    print "=" x 60, "\n";

    print "Статус: ", ($status_line // "(ответ не получен)\n");
    print "Allow: ", ($headers{allow} // 'заголовок отсутствует'), "\n";

    print "\n--- Заголовки ответа ---\n";
    print "$_\n" for @raw_headers;

    print "\n--- Тело ответа ---\n";
    if (defined $body && length $body) {
        print decode('UTF-8', $body, FB_DEFAULT);
        print "\n" unless $body =~ /\n\z/;
    } else {
        print "(тело пустое)\n";
    }
    print "\n";
}

my ($shost, $sport) = parse_url($server_url);
raw_options($shost, $sport, '*', 'ОПЦИИ СЕРВЕРА');

my ($rhost, $rport, $rpath) = parse_url($resource_url);
raw_options($rhost, $rport, $rpath, 'ОПЦИИ РЕСУРСА');