*8.欄位相加減用SUM函數(若缺值仍能運算);
data a;
x1=.;
x2=5;
x3=x1+x2;
x4=sum(x1,x2);
A1=x2;
run;
