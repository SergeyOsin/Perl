#!/usr/bin/perl

print "Какой сегодня день?\n";
$day = <STDIN>;

print "Месяц:\n";
$month = <STDIN>;

print "Год:\n";
$year = <STDIN>;

$firstauthor = "Осин С.М.";
$secondauthor = "Петровский В.П.";
$checker = "Проверяющий: Кольчугина Е.А.";

$~=SALUT_FORMAT;
$^=SALUT_FORMAT_TOP;
$= = 2;
write;

format SALUT_FORMAT_TOP =
>>>>>>>>>>Начало новой страницы<<<<<<<<<<
.

format SALUT_FORMAT =
Сегодня @##/@##/@####
$day, $month, $year
Лабораторная работа выполнена:
Студентами группы 23ВП2
^<<<<<<<<<<<<<<<<<<<<<<<<
$firstauthor
^>>>>>>>>>>>>>>>>>>>>>>>>
$secondauthor
^||||||||||||||||||||||||||||||||||||||||||||||||||||||||
$checker
.








