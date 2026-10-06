#!/usr/bin/perl

my $output_to_file = 0;
my $output_handle = *STDOUT;

if (@ARGV > 0 && $ARGV[0] eq 'file') {
    $output_to_file = 1;
}

if ($output_to_file) {
    open(my $fh, '>', 'output5.2.txt');
    $output_handle = $fh;
    print "Ответ будет записан в файл output5.2.txt\n";
}

print "Имя корневого каталога: ";
$root_dir = <STDIN>;
chomp($root_dir);

if (! -d $root_dir){
    die "Не найден каталог $root_dir\n";
}

print $output_handle "Каталог: $root_dir\n\n";

sub print_tree {
    my ($path, $handle, $level) = @_;

    opendir(my $dh, $path);

    my @items = readdir($dh);
    closedir($dh);

    foreach my $item (@items) {
        next if $item eq '.' || $item eq '..';

        my $full_path = "$path/$item";
        my $indent = "    " x $level;

        if (-d $full_path) {
            print $handle "Каталог $item \n";
            print_tree($full_path, $handle, $level + 1);
        } 
        elsif (-f $full_path) {
            my $size = -s $full_path;
            my $mod_time = localtime(time - (-M $full_path) * 86400);
            my $readable = (-r $full_path) ? "Да" : "Нет";
            my $writable = (-w $full_path) ? "Да" : "Нет";

            my $info = sprintf(
                "%s%s [Размер: %d байт] [Изменен: %s] [Чтение: %s] [Запись: %s]", 
                $indent, $item, $size, $mod_time, $readable, $writable
            );
            print $handle "$info\n";
        }
    }
}

print_tree($root_dir, $output_handle, 0);

close($output_handle) if $output_to_file;

