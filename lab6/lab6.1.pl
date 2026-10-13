#!/usr/bin/perl

print "Имя корневого каталога: ";
$root_dir = <STDIN>;
chomp($root_dir);

if (!-d $root_dir) {
    die "Каталог с именем $root_dir не найден!\n";
}

print "Последовательность символов: ";
$symbols = <STDIN>;
chomp($symbols);

if ($symbols eq '') {
    die "Последовательность не должна быть пустой!\n";
}

print "Режим поиска:\n";
print "1. С учётом регистра символов\n";
print "2. Без учёта регистра символов\n";
print "Любой другой символ - завершение\n";

print "Ваш выбор: ";
$choose = <STDIN>;
chomp($choose);

if ($choose ne '1' && $choose ne '2') {
    exit;
}

$search_symbols = $symbols;

if ($choose eq '2') {
    $search_symbols = lc($search_symbols);
}

print "\nКорневой каталог: $root_dir\n";
print "Искомая последовательность: $symbols\n";

if ($choose eq '1') {
    print "Режим: с учётом регистра\n\n";
} else {
    print "Режим: без учёта регистра\n\n";
}

$files_found = 0;

sub search_tree {
    my ($path) = @_;

    opendir(my $dh, $path);

    my @items = readdir($dh);
    closedir($dh);

    foreach my $item (@items) {
        next if $item eq '.' || $item eq '..';

        my $full_path = "$path/$item";

        next if -l $full_path;

        if (-d $full_path) {
            search_tree($full_path);
        }
        elsif (-f $full_path) {
            search_file($full_path);
        }
    }
}




sub search_file {
    my ($file_path) = @_;

    open($file, '<', $file_path);

    local $/;
    my $content = <$file>;
    close($file);

    return if !defined($content);

    my $text = $content;

    if ($choose eq '2') {
        $text = lc($text);
    }

    $pattern = $search_symbols;
    $pattern =~ s/([.^\$|()\\[\]{}*+?])/\\$1/g;

    $count = 0;

    while ($text =~ /$pattern/g) {
        $count++;
    }

    if ($count > 0) {
        print "Файл: $file_path\n";
        print "Количество вхождений: $count\n\n";
        $files_found++;
    }
}

search_tree($root_dir);

print "Всего файлов с совпадениями: $files_found\n";


