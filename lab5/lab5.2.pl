#!/usr/bin/perl

my $output_to_file = 0;
my $output_handle = *STDOUT;

if (@ARGV > 0 && $ARGV[0] eq '--file') {
    $output_to_file = 1;
}

print "Имя корневого каталога: ";
my $root_dir = <STDIN>;
chomp($root_dir);

if ($output_to_file) {
    open(my $fh, '>', 'output5.2.txt') or die "Не могу создать файл: $!";
    $output_handle = $fh;
}

print $output_handle "Дерево каталогов для: $root_dir\n";
print $output_handle "=" x 50 . "\n";

print_tree($root_dir, $output_handle, 0);

close($output_handle) if $output_to_file;

print "Готово.\n";

sub print_tree {
    my ($path, $handle, $level) = @_;

    opendir(my $dh, $path);

    my @items = sort readdir($dh);
    closedir($dh);

    foreach my $item (@items) {
        next if $item eq '.' or $item eq '..';

        my $full_path = "$path/$item";
        my $indent = "    " x $level;

        if (-d $full_path) {
            print $handle $indent . "$item/ (ПАПКА)\n";
            print_tree($full_path, $handle, $level + 1);
        } 
        elsif (-f $full_path) {
            my $size = -s $full_path // 0;
            my $mod_time = localtime(time - (-M $full_path) * 86400);
            my $readable = (-r $full_path) ? "Да" : "Нет";
            my $writable = (-w $full_path) ? "Да" : "Нет";

            my $info = sprintf(
                "%s%s [Размер: %d байт] [Изменен: %s] [Чтение: %s] [Запись: %s]", 
                $indent, $item, $size, $mod_time, $readable, $writable
            );
            
            print $handle $info . "\n";
        }
    }
}