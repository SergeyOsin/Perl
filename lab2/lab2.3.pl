#!/usr/bin/perl

print "Введите элементы первого массива: \n";
@arrayFirst = <STDIN>;

print "Введите элементы второго массива: \n";
@arraySecond = <STDIN>;

@arrayResult = ();

for ($i=0;$i<$#arrayFirst + $#arraySecond+2; $i+=2){
     $arrayResult[$i]=$arrayFirst[$i];
     $arrayResult[$i+1]=$arraySecond[$i+1];
}

print @arrayResult;