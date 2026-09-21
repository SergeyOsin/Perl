#!/usr/bin/perl

print "Введите элементы первого массива: \n";
@arrayFirst = <STDIN>;
chomp @arrayFirst;

print "Введите элементы второго массива: \n";
@arraySecond = <STDIN>;
chomp @arraySecond;

@arrayResult = ();


for ($i=0;$i <= $#arrayFirst; $i++){
     $arrayResult[$i*2]=$arrayFirst[$i];
}
for ($j=0;$j <= $#arraySecond; $j++){
    $arrayResult[$j*2+1]=$arraySecond[$j];
}

print "Итоговый массив: ", "@arrayResult";
