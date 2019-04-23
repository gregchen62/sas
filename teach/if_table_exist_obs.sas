%let yymm=1409;

*檢查檔案是否存在，以及筆數 &更新日期;

%macro es(_tb);
TABLE="&_tb.";
%if %sysfunc(exist(&_tb.))=0 %then  %do;
           EXIST="NO";%end;%else %do;EXIST="YES";%end;
%let  dsid=%sysfunc(open(&_tb.));
%let NOBS=%sysfunc(attrn(&dsid,NOBS),comma32.);NOBS=input("&NOBS.",comma32.);
%let modte=%sysfunc(attrn(&dsid,modte),datetime20.);modte="&modte.";
%let  RC=%sysfunc(close(&dsid.));/*add to fix lock data*/
output;
%mend;

data exis;
format  TABLE $UPCASE50. EXIST $3. NOBS comma32. MODTE $20.;
%es(_tb=RXBasel.BASEL_EL_CC_M_&yymm.);
%es(_tb=RXBASEL.BASEL_CREDIT_CARD_&yymm.);
%es(_tb=RXBASEL.BASEL_RB_IMMATERIAL_ACCT_&YYMM. );

run;
proc print;run;
