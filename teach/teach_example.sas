*8.欄位相加減用SUM函數(若缺值仍能運算);
data a;
x1=.;
x2=5;
x3=x1+x2;
x4=sum(x1,x2);
A1=x2;
run;

*9.多個名稱類似欄位取和;
data b;
x1=3;
x2=5;
x3=6;
x5=SUM(OF x1-x4);
A1=x2;
run;

*6.保留(去除)整批名稱開頭相同之欄位;
data b;
set a;
drop x:;
run;

*7.保留(去除)多個類似名稱欄位;
data b;
set a;
keep x1-x3;
run;

*10.合併欄位;
data c;
x1=3;
x2=5;
x5=CATS(OF X1-X2);
x6=CATS( X1-X2);
run;

*11.合併欄位(要加分隔符號);
data c;
x1='          3          ';
x2='5';
x3='abc';
x4='def';
x5=x1 || x2 || x3 || x4;
x6=CAT(OF X1-X4);
x7=CATT(OF X1-X4);
x8=CATX('_', OF X1-X4);
x9=CATX(';', OF X1-X4);
run;

*12.文字比對先轉成大寫再比對;
data a;
V1='taipei';
V2=UPCASE(v1);
if V1='Taipei' then x1=1;else x1=0; 
if UPCASE(V1)='TAIPEI' then x2=1;else x2=0;
run;

*13.文字比對先轉成大寫再比對2;
data a;
V1='taipei';*output會強迫直接出去;
V2='Taipei';
if UPCASE(V1)=UPCASE(V2) then x1=1;else x1=0;
run;


*14.選某日期;
data a;
format dt2 yymmdd10.;
dt2='01JAN2015'd;output;
dt2='01FEB2015'd;output;
run;
data b;
set a;
if dt2 >'01JAN2015'd;
run;

*14.format格式;
data a;
format X1 $2.  dt2 yymmdd10. V3 5.2;
x1='';  dt2='01JAN2015'd;output;
x1='21'; dt2='01FEB2015'd;output;
x1='';  dt2=.;  V3=555120.33;  V4=V3;output;
run;

*15.選空值(文字/數字型欄位皆可);
data b;
set a;
where x1^='';*eq where missing(x1)=0;
where dt2^=.;*eq where missing(dt2)=0;
where MISSING(x1)=1;
where MISSING(dt2)=0;
run;


*yymmdd為2015-02-08;
data a;
format dt2 yymmdd10.;
dt2='01JAN2015'd;output;
dt2='01FEB2015'd;output;
run;
data b;
format dt2 date9.;
dt2='01JAN2015'd;output;
dt2='01FEB2015'd;output;
run;


*18事前條件(較快);
data a;
format dt2 yymmdd10.;
dt2='01JAN2015'd;output;
dt2='01FEB2015'd;output;
run;
data b;
set a;
dt2=dt2+1;
if dt2 >'01JAN2015'd;
run;
data c;
set a;
dt2=dt2+1;
where dt2 >'01JAN2015'd;
run;
