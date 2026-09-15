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

# if ($#arrayFirst > $minLen) {
#     for ($j = $minLen + 1; $j <= $#arrayFirst; $j+=2) {
#         $arrayResult[$j+$minLen+1] = $arrayFirst[$j];
#         $arrayResult[$j+$minLen+2]=" ";
#     }
# } elsif ($#arraySecond > $minLen) {
#     for ($j = $minLen + 1; $j <= $#arraySecond; $j+=2) {
#         $arrayResult[$j+$minLen+1]=" ";
#         $arrayResult[$j+$minLen+2] = $arraySecond[$j];
#     }
# }

print "Итоговый массив: ", "@arrayResult";
