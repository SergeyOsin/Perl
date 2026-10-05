#!/usr/bin/perl

use strict;
use warnings;

print "Имя каталога для перемещения: ";
my $nameCurrentDir = <STDIN>;
chomp($nameCurrentDir);

if (!-d $nameCurrentDir) {
    die "Ошибка: исходный каталог $nameCurrentDir не существует.\n";
}


print "Имя каталога, в которую переместится: ";
my $nameMovingDir = <STDIN>;
chomp($nameMovingDir);

$nameCurrentDir =~ s{/$}{};
$nameMovingDir =~ s{/$}{};

my $destination = "$nameMovingDir/" . (split('/', $nameCurrentDir))[-1];
if (index($destination, $nameCurrentDir) == 0) {
    die "Ошибка: нельзя переместить папку саму в себя.\n";
}

copy_directory($nameCurrentDir, $destination);

if (-d $destination) {
    delete_directory($nameCurrentDir);
    print "Перемещение завершено. Папка находится в: $destination\n";
}

sub copy_directory {
    my ($from, $to) = @_;
    
    mkdir $to or die "Не могу создать папку $to: $!"; 
    
    opendir(my $dh, $from) or die "Не могу открыть $from: $!";
    my @items = readdir($dh);
    closedir($dh);

    foreach my $item (@items) {
        next if $item eq '.' or $item eq '..';
        
        my $source = "$from/$item";
        my $dest = "$to/$item";

        if (-d $source) {
            copy_directory($source, $dest);
        } else {
            open(my $in, '<', $source) or die "Не могу прочитать $source: $!";
            open(my $out, '>', $dest) or die "Не могу записать в $dest: $!";
            
            binmode $in;  
            binmode $out;
            
            while (my $line = <$in>) {
                print $out $line;
            }
            close $in;
            close $out;
        }
    }
}

sub delete_directory {
    my ($dir) = @_;
    
    opendir(my $dh, $dir) or return;
    my @items = readdir($dh);
    closedir($dh);

    foreach my $item (@items) {
        next if $item eq '.' or $item eq '..';
        
        my $path = "$dir/$item";
        
        if (-d $path) {
            delete_directory($path); 
            rmdir $path;         
        } else {
            unlink $path;           
        }
    }
    
    rmdir $dir;
}