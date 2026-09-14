#!/usr/bin/perl

print "Введите элементы первого массива: \n";
@arrayFirst = <STDIN>;
chomp @arrayFirst;

print "Введите элементы второго массива: \n";
@arraySecond = <STDIN>;
chomp @arraySecond;

@arrayResult = ();

$minLen = $#arrayFirst < $#arraySecond ? $#arrayFirst: $#arraySecond;

for ($i=0;$i <= $minLen; $i++){
     $arrayResult[$i*2]=$arrayFirst[$i];
     $arrayResult[$i*2+1]=$arraySecond[$i];
}

if ($#arrayFirst > $minLen) {
    for ($j = $minLen + 1; $j <= $#arrayFirst; $j++) {
        $arrayResult[$j + $minLen + 1] = $arrayFirst[$j];
    }
} elsif ($#arraySecond > $minLen) {
    for ($j = $minLen + 1; $j <= $#arraySecond; $j++) {
        $arrayResult[$j + $minLen + 1] = $arraySecond[$j];
    }
}

print "Итоговый массив: ", "@arrayResult";
