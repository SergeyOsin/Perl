#!/usr/bin/perl

sub insert {
    my ($head, $student) = @_;

    if (!defined $head || $student->{recordbook} < $head->{recordbook}) {
        $student->{next} = $head;
        return $student;
    }

    if ($student->{recordbook} == $head->{recordbook}) {
        print "Студент с таким номером зачетной книжки уже существует!\n";
        return $head;
    }

    $head->{next} = insert($head->{next}, $student);
    return $head;
}


sub delete_student {
    my ($head, $key) = @_;

    return undef unless defined $head;

    if ($head->{recordbook} == $key) {
        return $head->{next};
    }

    if ($head->{recordbook} > $key) {
        return $head;
    }

    $head->{next} = delete_student($head->{next}, $key);

    return $head;
}

sub print_list {
    my ($head) = @_;

    if ($head == 0){
        print "Список пустой\n\n";
        return;
    }

    print "\nСписок студентов:\n\n";
    
    local $~ = "HEADER";
    write;
    while (defined $head) {

        $student = $head;

        local $~ = "STUDENT";
        write;

        $head = $head->{next};
    }
}

format HEADER =
+--------------------------+-----------------+------------+--------------------------+--------------+
| ФИО                      | Зачетная книжка | Группа     | Специальность            | Год рождения |
+--------------------------+-----------------+------------+--------------------------+--------------+
.

format STUDENT =
| @<<<<<<<<<<<<<<<<<<<<<<< | @<<<<<<<<<<<<<< | @<<<<<<<<< | @<<<<<<<<<<<<<<<<<<<<<<< | @<<<<<<<<<<<< |
$student->{name},            $student->{recordbook}, $student->{group}, $student->{specialty}, $student->{birth_year}
+--------------------------+-----------------+------------+--------------------------+--------------+
.

print "Выберите один из пунктов: \n";
print "1. Добавить студента \n";
print "2. Удалить студента\n";
print "3. Вывести список студентов\n";
print "Любой другой выбор - завершение программы \n";
print "Выбор: ";

$choose = <STDIN>;

while ($choose > 0 && $choose <4){
    if ($choose == 1){
        print "Введите ФИО: ";
        $name = <STDIN>;
        chomp($name);

        print "Введите номер зачетной книжки: ";
        $recordbook = <STDIN>;
        chomp($recordbook);

        print "Введите группу: ";
        $group = <STDIN>;
        chomp($group);

        print "Введите специальность: ";
        $specialty = <STDIN>;
        chomp($specialty);

        print "Введите год рождения: ";
        $birth_year = <STDIN>;
        chomp($birth_year);

        my $student = {
            name       => $name,
            recordbook => $recordbook,
            group      => $group,
            specialty  => $specialty,
            birth_year => $birth_year,
            next       => undef
        };
        $head = insert($head, $student);

        print "\n\n";
    }
    elsif ($choose == 2) {
        print "\nВведите номер зачетной книжки студента: ";
        my $key = <STDIN>;
        chomp($key);

        my $old_head = $head;

        $head = delete_student($head, $key);
        
        ($head == $old_head)?
            print "Студент с номером зачетной книжки $key не найден.\n\n":
            print "Студент с номером зачетной книжки $key удален из списка.\n\n";
    }
    elsif ($choose == 3) {
        print_list($head);
    }
    print "Выбор: ";
    $choose = <STDIN>;
}




