#!/usr/bin/perl

print "Имя каталога для перемещения: ";
$nameCurrentDir = <STDIN>;
chomp($nameCurrentDir);

if (!-d $nameCurrentDir) {
    die "Исходного каталога $nameCurrentDir не существует.\n";
}

print "Имя каталога, в которую переместится каталог: ";
$nameMovingDir = <STDIN>;
chomp($nameMovingDir);

if (!-d $nameMovingDir){
    die "Целевого каталога $nameMovingDir не существует";
}

if ($nameCurrentDir eq $nameMovingDir) {
    die "Переместить каталог в тот же нельзя!\n";
}

$destination = "$nameMovingDir/" . (split('/', $nameCurrentDir))[-1];

sub copy_directory {
    my ($from, $to) = @_;
    
    mkdir $to;

    opendir(my $dh, $from);
    my @items = readdir($dh);
    closedir($dh);

    foreach my $item (@items) {   
        next if $item eq '.' || $item eq '..';

        my $source = "$from/$item";
        my $dest = "$to/$item";

        if (-d $source) {
            copy_directory($source, $dest);
        } else {
            open(my $in, '<', $source);
            open(my $out, '>', $dest);
            
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

copy_directory($nameCurrentDir, $destination);

if (-d $destination) {
    delete_directory($nameCurrentDir);
    print "Перемещение завершено. Папка находится в: $destination\n";
}