#!/usr/bin/perl

print "Как Ваше имя?\n";
$name= <STDIN>;
print "Сколько Вам лет?\n";
$age =<STDIN>;
$~=SALUT_FORMAT;
$^=SALUT_FORMAT_TOP;
write;

format SALUT_FORMAT_TOP= 
*******Пеpвый сценарий на Perl******* 
.

format SALUT_FORMAT= 
Поздравляем Вас, ^<<<<<<<<<<<<<!
$name
Сегодня в возpасте @###.## лет 
$age 
Вы написали свою пеpвую Perl-пpогpамму !
.

