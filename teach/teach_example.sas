*1.OPEN CODE--壓縮資料;
OPTIONS COMPRESS=YES;

*2.OPEN CODE--清 LOG;
DM'LOG;CLEAR;';

/*3.SYS--快速鍵:F1叫出help，(EG)查 shortcuts, keyboard
			   (SAS)查Keyboard Shortcuts within the Enhanced Editor";*/


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

*20.Show所有欄位。out才會另外存，order照table欄順序;
PROC CONTENTS DATA=rxltp.bns_loan_1508 DETAILS ORDER=VARNUM OUT=var_list;RUN;

*21.Show所有Table;
PROC DATASETS LIB=RXLTP DETAILS;RUN;

*22.數字變文字;
data a;
x1=    81000     ;
format x2 $8.;
x2=STRIP(x1);/*STRIP去空白*/
run;
data b;
x1='    8881    ';
format x2 $8.;
x2=put(x1,8. -L);
x3=put(x1,8. -R);
x4=put(x1,8. -C);
run;

*23.文字變數字;
data a;
x1='11111111110';
x2=input(x1,best12.);
run;

*YYMM轉日期格式;
data e;
x1='1201';
x3=x1||'01';
x4='20'||x1||'01';
format x2 yymmdd10.;
/*x2=input(x1||'01',yymmdd8.);*/
/*x2=input(x3,yymmdd8.);*/
x2=input(x4,yymmdd8.);
format x5 yymmdd6.;
x5=input(x4,yymmdd8.);
x6=put(x5,yymmdd10.);
run;

data a;
x1='1201';
format x2 yymmdd10.;
x2=input(x1||'01',yymmdd8.);
run;

data aa;
x1='1201';
x2='1202';
if x1>x2 then x3=1;else x3=0;
run;

*24.Data step vs. SQL;
data a;
set rxltp.bns_loan_1508;
where Current_Bal>0;
xxxx2=Current_Bal/1000000;
if Current_Bal>10000 then xx3=1;else xx3=0;
run;

proc sql;
create table b as
select 
*
,case when Current_Bal>10000 then 1 else 0 end as xx3
from rxltp.bns_loan_1508
where Current_Bal>0
;quit;

*25.Email result;
data a;
v1=1111;
run;
 
filename outbox email "ba.sasmm@xxxxx.com"; 
data _null_;
file outbox
to=("greg.chen@xxxxx.com")
cc=()
subject="SAS email test"
;
set a;
put v1;
run;
