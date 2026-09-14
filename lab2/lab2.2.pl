#!/usr/bin/perl

print "Введите элементы массива: \n";
@array = <STDIN>;
chomp @array;

for ($i=0;$i<$#array;$i+=2){
     @array[$i,$i+1]=@array[$i+1,$i];
}

print "Итоговый массив: ", "@array";
