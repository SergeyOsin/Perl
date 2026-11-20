#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

use IO::Socket::INET;
use Encode qw(decode FB_DEFAULT);
use URI;
use File::Path qw(make_path);
use File::Spec;

# Аргументы:
my $url    = shift @ARGV || 'http://localhost/';
my $outdir = shift @ARGV || 'output';
make_path($outdir) unless -d $outdir;

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
        $size_line =~ s/;.*//;
        my $size = hex($size_line);
        last if $size == 0;
        $pos = $eol + 2;
        $out .= substr($data, $pos, $size);
        $pos += $size + 2;
    }
    return $out;
}

sub read_body {
    my ($sock, $headers, $is_head) = @_;
    return '' if $is_head;                       # у HEAD тела нет

    my $te = lc($headers->{'transfer-encoding'} // '');
    if ($te eq 'chunked') {
        my $raw = do { local $/; <$sock> };
        return decode_chunked($raw // '');
    }

    my $cl = $headers->{'content-length'};
    if (defined $cl && $cl =~ /^\d+$/) {
        my $body = '';
        while (length($body) < $cl) {
            my $chunk = '';
            my $n = read($sock, $chunk, $cl - length($body));
            last unless $n;
            $body .= $chunk;
        }
        return $body;
    }

    my $body = do { local $/; <$sock> };
    return $body // '';
}

sub http_request {
    my (%args) = @_;
    my $method = $args{method};
    my $host   = $args{host};
    my $port   = $args{port};
    my $path   = $args{path};
    my $body   = $args{body} // '';
    my $extra  = $args{headers} // {};

    my $sock = IO::Socket::INET->new(
        PeerHost => $host,
        PeerPort => $port,
        Proto    => 'tcp',
        Timeout  => 10,
    ) or die "Не удалось подключиться к $host:$port: $!\n";

    my $host_header = ($port == 80) ? $host : "$host:$port";

    my $request = "$method $path HTTP/1.1\r\n"
                . "Host: $host_header\r\n"
                . "User-Agent: Lab4-HTTP-Client/1.0\r\n"
                . "Connection: close\r\n"
                . "Accept: */*\r\n";

    for my $name (keys %$extra) {
        $request .= "$name: $extra->{$name}\r\n";
    }

    if (length $body && !exists $extra->{'Content-Length'}) {
        $request .= "Content-Length: " . length($body) . "\r\n";
    }

    $request .= "\r\n";
    $request .= $body if length $body;
    print $sock $request;

    # Статус
    my $status_line = <$sock>;

    # Заголовки
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

    # Тело
    my $is_head  = ($method eq 'HEAD');
    my $resp_body = read_body($sock, \%headers, $is_head);
    close $sock;

    return {
        method      => $method,
        status_line => $status_line // '',
        headers     => \%headers,
        raw_headers => \@raw_headers,
        body        => $resp_body,
    };
}

sub html_escape {
    my ($s) = @_;
    $s = '' unless defined $s;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    $s =~ s/"/&quot;/g;
    return $s;
}

sub save_result {
    my ($outdir, $resp) = @_;
    my $method = $resp->{method};
    my $base   = lc($method);

    my $headers_file = File::Spec->catfile($outdir, "${base}_headers.html");
    open my $fh, '>:encoding(UTF-8)', $headers_file or die "Не могу открыть $headers_file: $!";

    print $fh "<!DOCTYPE html>\n<html>\n<head>\n";
    print $fh "<meta charset=\"UTF-8\">\n";
    print $fh "<title>HTTP Response Headers - $method</title>\n";
    print $fh "</head>\n<body>\n";
    print $fh "<h1>HTTP-ответ на запрос $method</h1>\n";
    print $fh "<p><strong>Статус:</strong> ", html_escape($resp->{status_line}), "</p>\n";
    print $fh "<h2>Заголовки ответа</h2>\n<pre>\n";
    for my $h (@{ $resp->{raw_headers} }) { print $fh html_escape($h), "\n"; }
    print $fh "</pre>\n</body>\n</html>\n";
    close $fh;

    my $body_file = File::Spec->catfile($outdir, "${base}_body.html");
    open my $bfh, '>:raw', $body_file
        or die "Не могу открыть $body_file: $!";
    print $bfh $resp->{body};
    close $bfh;

    print "  -> $headers_file\n";
    print "  -> $body_file (", length($resp->{body}), " байт)\n";
}

my ($host, $port, $path) = parse_url($url);

print "Цель: $url\n";
print "  host=$host port=$port path=$path\n";
print "Каталог вывода: $outdir\n\n";

# GET
print "[GET]\n";
my $resp = http_request(
    method => 'GET', host => $host, port => $port, path => $path,
);
print "  ", $resp->{status_line};
save_result($outdir, $resp);

# POST
print "\n[POST]\n";
$resp = http_request(
    method  => 'POST',
    host    => $host,
    port    => $port,
    path    => $path,
    body    => 'name=value&test=1',
    headers => { 'Content-Type' => 'application/x-www-form-urlencoded' },
);
print "  ", $resp->{status_line};
save_result($outdir, $resp);

# HEAD
print "\n[HEAD]\n";
$resp = http_request(
    method => 'HEAD', host => $host, port => $port, path => $path,
);
print "  ", $resp->{status_line};
print "  (тело для HEAD не передаётся)\n";
save_result($outdir, $resp);

print "\nГотово.\n";