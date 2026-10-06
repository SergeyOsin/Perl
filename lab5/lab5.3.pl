#!/usr/bin/perl

print "Имя каталога: ";
my $nameDir = <STDIN>;
chomp ($nameDir);

if (! -d $nameDir){
   die "Каталога с названием $nameDir не существует";
}

print "Расширение для удаления (без точки): ";
my $choose = <STDIN>;
chomp($choose);

$countDelete = 0;

sub process_directory {
    my ($path, $ext, $countRef) = @_;

    opendir(my $dh, $path);
    my @allFiles = readdir($dh);
    closedir($dh);

    foreach my $file (@allFiles) {
        next if $file eq '.' or $file eq '..';

        my $full_path = "$path/$file";

        if (-d $full_path) {
            process_directory($full_path, $ext, $countRef);
        }
        elsif (-f $full_path) {
            my $ext_length = length($ext) + 1; 
            if (length($file) >= $ext_length) {
                my $ending = substr($file, -$ext_length);
                if ($ending eq ".$ext") {
                    $countDelete++;
                    unlink($full_path);
                }
            }
        }
    }
}

process_directory($nameDir, $choose, \$countDelete);

print "Удалено $countDelete файлов с расширением $choose\n";


