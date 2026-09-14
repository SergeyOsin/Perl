#!/usr/bin/perl

print "Введите элементы первого массива:\n";
@firstArray = <STDIN>;
chomp @firstArray;

print "Введите элементы второго массива:\n";
@secondArray = <STDIN>;
chomp @secondArray;

print "Первый массив: ", "@firstArray", "\n";
print "Второй массив: ", "@secondArray", "\n";

print "\nВыберите операцию: \n";
print "1. Объединение\n";
print "2. Пересечение\n";
print "3. Разность\n";
print "4. Симметричная разность\n";
print "Любое другое число - завершение программы\n";

print "Ваш выбор: ";
$chose = <STDIN>;
chomp $chose;

while ($chose >= 1 && $chose <= 4) {
     if ($chose == 1) {
          %hashArray = ();
          @arrayResult = ();
          $i = 0;
          for ($j = 0; $j <= $#firstArray; $j++) {
               if ($hashArray{$firstArray[$j]}==0) {
                    $hashArray{$firstArray[$j]} = 1;
                    $arrayResult[$i++] = $firstArray[$j];
               }
          }
          for ($j = 0; $j <= $#secondArray; $j++) {
               if ($hashArray{$secondArray[$j]}==0) {
                    $hashArray{$secondArray[$j]} = 1;
                    $arrayResult[$i++] = $secondArray[$j];
               }
          }
          print "Результат объединения: ", "@arrayResult";

     } elsif ($chose == 2) {
          %hashArray = ();
          @arrayResult = ();
          for ($i = 0; $i <= $#firstArray; $i++) {
               $hashArray{$firstArray[$i]} = 1;
          }
          for ($i = 0; $i <= $#secondArray; $i++) {
               if ($hashArray{$secondArray[$i]} == 1) {
                    $arrayResult[$#arrayResult + 1] = $secondArray[$i];
               }
          }
          print "Результат пересечения: ", "@arrayResult";

     } elsif ($chose == 3) {
          %hashArray = ();
          @arrayResult = ();
          
          for ($i = 0; $i <= $#secondArray; $i++) {
               $hashArray{$secondArray[$i]} = 1;
          }
          for ($i = 0; $i <= $#firstArray; $i++) {
               if ($hashArray{$firstArray[$i]}==0) {
                    $arrayResult[$#arrayResult + 1] = $firstArray[$i];
               }
          }

          print "Результат разности: ", "@arrayResult";

     } else {
          %hashArray = ();
          @arrayResult = ();
          for ($i = 0; $i <= $#firstArray; $i++) {
               $hashArray{$firstArray[$i]} = 1;
          }
          for ($i = 0; $i <= $#secondArray; $i++) {
               if ($hashArray{$secondArray[$i]} > 0) {
                    $hashArray{$secondArray[$i]} = 2;
               } else {
                    $hashArray{$secondArray[$i]} = 3;
               }

          }
          for ($i = 0; $i <= $#firstArray; $i++) {
               if ($hashArray{$firstArray[$i]} == 1) {
                    $arrayResult[$#arrayResult + 1] = $firstArray[$i];
                    $hashArray{$firstArray[$i]} = 4;
               }
          }
          for ($i = 0; $i <= $#secondArray; $i++) {
               if ($hashArray{$secondArray[$i]} == 3) {
                    $arrayResult[$#arrayResult + 1] = $secondArray[$i];
                    $hashArray{$secondArray[$i]} = 4;
               }
          }
          print "Результат симметричной разности: ", "@arrayResult";
     }

     print "\n\nВыберите пункт: ";
     $chose = <STDIN>;
     chomp $chose;
}
