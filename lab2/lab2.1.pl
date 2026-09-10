#!/usr/bin/perl

print "Введите элементы первого массива:\n";
@firstArray = <STDIN>;

print "Введите элементы второго массива:\n";
@secondArray = <STDIN>;

if ($#firstArray != $#secondArray) {
     print "Длина массивов разная!";
} else {
     print "Выберите операцию: \n";
     print "1. Объединение\n";
     print "2. Пересечение\n";
     print "3. Разность\n";
     print "4. Симметричная разность\n";

     print "Ваш выбор: ";
     $chose = <STDIN>;

     if ($chose == 1){
          
     } elsif ($chose == 2){

     } elsif ($chose == 3){

     } elsif ($chose == 4){

     } else {

     }
}

