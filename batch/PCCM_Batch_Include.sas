/********************************************************************;
2) X Rename
將每日下檔之 PCCM 的 dat 檔尾巴加上 header_date
註: JCEXTRACT_SRC因無 header_date，故日期等同 JCEXTRACT 的 header_date
********************************************************************/
/*OPTIONS NOMPRINT NOSOURCE NOSOURCE2 NOMLOGICNEST NOMLOGIC NOSYMBOLGEN NOSTIMER NOFULLSTIMER;*/
%macro ss(fd,ori);
%if %sysfunc(fileexist("&fd.\&ori..dat")) %then %do;

Data _NULL_;
INFILE  "&fd.\&ori..dat"   recfm=f lrecl=907 firstobs=1 obs=1 end=_eof_;
INPUT
@193 header_date $CHAR8.
;
call symput('yyyymmdd',header_date);
run;

x "rename &fd.\&ori..dat &ori._&yyyymmdd..dat";  
%put rename &fd.\&ori..dat &ori._&yyyymmdd..dat;

    %if &ori.=JCEXTRACT %then %do;
        x "rename &fd.\JCEXTRACT_SRC.dat JCEXTRACT_SRC_&yyyymmdd..dat"; 
        %put rename &fd.\JCEXTRACT_SRC.dat JCEXTRACT_SRC_&yyyymmdd..dat;
    %end;

%end;
%mend;

%macro RM();
data _null_;
call symput('YYYYMMDD',put(today(),yymmddn8.));
run;
%put YYYYMMDD=&YYYYMMDD.;
    %let fd=E:\MFTP_RawData\PCCM\&yyyymmdd.;
    %put fd=&fd.;
    %SS(fd=&fd.,ori=CCEXTRACTC);
    %SS(fd=&fd.,ori=CCEXTRACTD);
    %SS(fd=&fd.,ori=CCEXTRACTM);
    %SS(fd=&fd.,ori=CUEXTRACT);
    %SS(fd=&fd.,ori=LNEXTRACT);
    %SS(fd=&fd.,ori=SAEXTRACT);
    %SS(fd=&fd.,ori=JCEXTRACT);
%mend;
%RM;
/********************************************************************;
END 2) X Rename
********************************************************************/

/********************************************************************;
3) X cmd COPY
********************************************************************/
%macro copyfile();
%let CC_C    =P:\PCCM_Extract_dat\CCEXTRACTC;
%let CC_D    =P:\PCCM_Extract_dat\CCEXTRACTD;
%let CC_M    =P:\PCCM_Extract_dat\CCEXTRACTM;
%let CU        =P:\PCCM_Extract_dat\CUEXTRACT;
%let JC        =P:\PCCM_Extract_dat\JCEXTRACT;
%let LN        =P:\PCCM_Extract_dat\LNEXTRACT;
%let SA        =P:\PCCM_Extract_dat\SAEXTRACT;

%let CC_C_gz    =P:\PCCM_PROD_tar_gz\CYC;
%let CC_D_gz    =P:\PCCM_PROD_tar_gz\DAILY;
%let M_gz        =P:\PCCM_PROD_tar_gz\MONTHLY;

data _null_;
call symput('YYYYMMDD',put(today(),yymmddn8.));
run;
%put YYYYMMDD=&YYYYMMDD.;

%let from    =E:\MFTP_RawData\PCCM\&yyyymmdd.;

%put &from.;

x "copy E:\MFTP_RawData\PCCM\&yyyymmdd.\*_CYC.tar.gz P:\PCCM_PROD_tar_gz\CYC\";
x "copy E:\MFTP_RawData\PCCM\&yyyymmdd.\*_DAILY.tar.gz P:\PCCM_PROD_tar_gz\DAILY\";
x "copy E:\MFTP_RawData\PCCM\&yyyymmdd.\*_MONTHLY.tar.gz P:\PCCM_PROD_tar_gz\MONTHLY\";

%if %sysfunc(fileexist("&from.\*_CYC.tar.gz"))        %then %do;    x "copy &from.\*_CYC.tar.gz &CC_C_gz.\";    %end;
%if %sysfunc(fileexist("&from.\*_DAILY.tar.gz"))    %then %do;    x "copy &from.\*_DAILY.tar.gz &CC_D_gz.\";    %end;
%if %sysfunc(fileexist("&from.\*_MONTHLY.tar.gz"))    %then %do;    x "copy &from.\*_MONTHLY.tar.gz &M_gz.\";    %end;
%if %sysfunc(fileexist("&from.\CCEXTRACTC*.dat"))    %then %do;    x "copy &from.\CCEXTRACTC*.dat &CC_C.\";    %end;
%if %sysfunc(fileexist("&from.\CCEXTRACTD*.dat"))    %then %do;    x "copy &from.\CCEXTRACTD*.dat &CC_D.\";    %end;
%if %sysfunc(fileexist("&from.\CCEXTRACTM*.dat"))    %then %do;    x "copy &from.\CCEXTRACTM*.dat &CC_M.\";    %end;
%if %sysfunc(fileexist("&from.\CUEXTRACT*.dat"))    %then %do;    x "copy &from.\CUEXTRACT*.dat &CU.\";        %end;
%if %sysfunc(fileexist("&from.\JCEXTRACT*.dat"))    %then %do;    x "copy &from.\JCEXTRACT*.dat &JC.\";        %end;
%if %sysfunc(fileexist("&from.\LNEXTRACT*.dat"))    %then %do;    x "copy &from.\LNEXTRACT*.dat &LN.\";        %end;
%if %sysfunc(fileexist("&from.\SAEXTRACT*.dat"))    %then %do;    x "copy &from.\SAEXTRACT*.dat &SA.\";        %end;
%mend;
%copyfile;
/********************************************************************;
END 3) X cmd COPY
********************************************************************/

/********************************************************************;
4) Enc Macro
********************************************************************/
/*OPTIONS NOMPRINT NOSOURCE NOSOURCE2 NOMLOGICNEST NOMLOGIC NOSYMBOLGEN NOSTIMER NOFULLSTIMER;*/
%include "D:\PCCM\CODE\varfmt.sas";
/*OPTIONS NOMPRINT NOSOURCE NOSOURCE2 NOMLOGICNEST NOMLOGIC NOSYMBOLGEN NOSTIMER NOFULLSTIMER;*/
%include "D:\PCCM\CODE\pccm_packer.sas";
/*OPTIONS NOMPRINT NOSOURCE NOSOURCE2 NOMLOGICNEST NOMLOGIC NOSYMBOLGEN NOSTIMER NOFULLSTIMER;*/
%include "D:\PCCM\CODE\pccm_output_impfmt.sas";
/*OPTIONS NOMPRINT NOSOURCE NOSOURCE2 NOMLOGICNEST NOMLOGIC NOSYMBOLGEN NOSTIMER NOFULLSTIMER;*/
%include "D:\PCCM\CODE\JCEX_SRC_Imp.sas";
/*OPTIONS NOMPRINT NOSOURCE NOSOURCE2 NOMLOGICNEST NOMLOGIC NOSYMBOLGEN NOSTIMER NOFULLSTIMER;*/
/*%include "J:\CTCB_4\S\NewSASscript\S001_Environment.sas";*/
%include "D:\PCCM\CODE\S001_Environment.sas";
/*OPTIONS NOMPRINT NOSOURCE NOSOURCE2 NOMLOGICNEST NOMLOGIC NOSYMBOLGEN NOSTIMER NOFULLSTIMER;*/
/********************************************************************;
END 4) Enc Macro
********************************************************************/


/********************************************************************;
5) Import Daily & Cycle Extract&Result
********************************************************************/
options compress=yes;
libname CC_D "P:\PCCM_CC_D\";
libname CC_C "P:\PCCM_CC_C\";
libname JCEXD 'P:\PCCM_JC_D\JCEXTRACT_D';
libname JCSRC 'P:\PCCM_JC_D\JCEXTRACT_SRC';

data _null_;
call symput('YYMMDD',put(INTNX('DAY',today(),-0),yymmddn8.));
call symput('GetDT',put(INTNX('DAY',today(),-0),yymmddn8.));
call symput('Yesterday',put(INTNX('DAY',today(),-1),yymmddn8.));
run;

%let Local_file_Path = E:\MFTP_RawData\PCCM\&YYMMDD.;
%let pool=&Local_file_Path.;

%put &YYMMDD. &GetDT. &Yesterday.;
%put &Local_file_Path.;

%LET CODE = D:\PCCM\CODE\;            *Store SAS macro;

*Daily;
OPTIONS COMPRESS=YES;
libname pool "&Local_file_Path.";

%macro ex();
    %if %sysfunc(fileexist("&Local_file_Path.\CCEXTRACTD_&Yesterday..dat")) %then %do;
        %pccm_packer("&Local_file_Path.\CCEXTRACTD_&Yesterday..dat",pool.PCCM_CC_EXTRACT_D_&Yesterday., &varfmt_ccex., mode=r, yyyymmdd=);
        %EencryptDS(pool, PCCM_CC_EXTRACT_D_&Yesterday. , CCEX_Group_Id CCEX_Customer_Id CCEX_Account_Id); 
        proc copy in=pool out=CC_D MEMTYPE=data; select PCCM_CC_EXTRACT_D_&Yesterday.;run;
    %end;

    %if %sysfunc(fileexist("&Local_file_Path.\CCEXTRACTC_&Yesterday..dat")) %then %do;
        %pccm_packer("&Local_file_Path.\CCEXTRACTC_&Yesterday..dat",pool.PCCM_CC_EXTRACT_C_&Yesterday., &varfmt_ccex., mode=r, yyyymmdd=);
        %EencryptDS(pool, PCCM_CC_EXTRACT_C_&Yesterday. , CCEX_Group_Id CCEX_Customer_Id CCEX_Account_Id);
        proc copy in=pool out=CC_C MEMTYPE=data; select PCCM_CC_EXTRACT_C_&Yesterday.;run;
    %end;

    %if %sysfunc(fileexist("&Local_file_Path.\JCEXTRACT_&Yesterday..dat")) %then %do;
        %pccm_packer("&Local_file_Path.\JCEXTRACT_&Yesterday..dat",pool.JCEXTRACT_&Yesterday., &varfmt_jcex3., mode=r, yyyymmdd=);
        %EencryptDS(pool, JCEXTRACT_&Yesterday. , JCEX_Group_Id JCEX_Customer_Id);
        proc copy in=pool out=JCEXD MEMTYPE=data; select JCEXTRACT_&Yesterday.;run;
    %end;

    %if %sysfunc(fileexist("&Local_file_Path.\JCEXTRACT_SRC_&Yesterday..dat")) %then %do;
        %JCSRC("&Local_file_Path.\JCEXTRACT_SRC_&Yesterday..dat",pool.JCEXTRACT_SRC_&Yesterday.);
        %EencryptDS(pool, JCEXTRACT_SRC_&Yesterday. ,JCEX_Customer_Id);
        proc copy in=pool out=JCSRC MEMTYPE=data; select JCEXTRACT_SRC_&Yesterday.;run;
    %end;


%mend;
%ex;

%macro DDOUT();

%if %sysfunc(fileexist("&Local_file_Path.\pccm_&YYMMDD._DAILY")) %then %do;
    %DEFER(FNAME=pool.Daily_OTDEFERS,source=&Local_file_Path.\pccm_&YYMMDD._DAILY);
    %CCREST("&Local_file_Path.\pccm_&YYMMDD._DAILY\DAILY_OTCCREST.dat",pool.Daily_OTCCREST);
    %LNREST("&Local_file_Path.\pccm_&YYMMDD._DAILY\Daily_OTLNREST.dat",pool.Daily_OTLNREST);
    %CUREST("&Local_file_Path.\pccm_&YYMMDD._DAILY\Daily_OTCUREST.dat",pool.Daily_OTCUREST);
    %CCDCIN("&Local_file_Path.\pccm_&YYMMDD._DAILY\Daily_OTCCDCIN.dat",pool.Daily_OTCCDCIN);
    %CUDCIN("&Local_file_Path.\pccm_&YYMMDD._DAILY\Daily_OTCUDCIN.dat",pool.Daily_OTCUDCIN);
    %LNDCIN("&Local_file_Path.\pccm_&YYMMDD._DAILY\Daily_OTLNDCIN.dat",pool.Daily_OTLNDCIN);
    %FDCC("&Local_file_Path.\pccm_&YYMMDD._DAILY\Daily_OTFDCARD.dat",pool.Daily_OTFDCARD);
%end;
%else %if %sysfunc(fileexist("&Local_file_Path.\pccm_&Yesterday._DAILY")) %then %do;
    %DEFER(FNAME=pool.Daily_OTDEFERS,source=&Local_file_Path.\pccm_&Yesterday._DAILY);
    %CCREST("&Local_file_Path.\pccm_&Yesterday._DAILY\DAILY_OTCCREST.dat",pool.Daily_OTCCREST);
    %LNREST("&Local_file_Path.\pccm_&Yesterday._DAILY\Daily_OTLNREST.dat",pool.Daily_OTLNREST);
    %CUREST("&Local_file_Path.\pccm_&Yesterday._DAILY\Daily_OTCUREST.dat",pool.Daily_OTCUREST);
    %CCDCIN("&Local_file_Path.\pccm_&Yesterday._DAILY\Daily_OTCCDCIN.dat",pool.Daily_OTCCDCIN);
    %CUDCIN("&Local_file_Path.\pccm_&Yesterday._DAILY\Daily_OTCUDCIN.dat",pool.Daily_OTCUDCIN);
    %LNDCIN("&Local_file_Path.\pccm_&Yesterday._DAILY\Daily_OTLNDCIN.dat",pool.Daily_OTLNDCIN);
    %FDCC("&Local_file_Path.\pccm_&Yesterday._DAILY\Daily_OTFDCARD.dat",pool.Daily_OTFDCARD);
%end;
%else %RETURN;
    %EencryptDS(pool, Daily_OTDEFERS ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, Daily_OTCCREST ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, Daily_OTLNREST ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, Daily_OTCUREST ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, Daily_OTCCDCIN ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, Daily_OTCUDCIN ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, Daily_OTLNDCIN ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, Daily_OTFDCARD ,Group_Id Customer_Id Account_Id);

    
    proc sql noprint;
     select R0006_EXTRACT__00005
    into :ExtractDate
    from pool.Daily_OTCCDCIN;
    %put &ExtractDate;

    proc datasets library=pool;
    change 
    Daily_OTCCDCIN=Daily_OTCCDCIN_&ExtractDate.
    Daily_OTCUDCIN=Daily_OTCUDCIN_&ExtractDate.
    Daily_OTCUREST=Daily_OTCUREST_&ExtractDate.
    Daily_OTLNDCIN=Daily_OTLNDCIN_&ExtractDate.
    Daily_OTLNREST=Daily_OTLNREST_&ExtractDate.
    Daily_OTCCREST=Daily_OTCCREST_&ExtractDate.
    Daily_OTFDCARD=Daily_OTFDCARD_&ExtractDate.
    Daily_OTDEFERS=Daily_OTDEFERS_&ExtractDate.
    ;
    run;

    proc copy in=pool out=CC_D MEMTYPE=data;
    select 
        Daily_OTCCDCIN_&ExtractDate.
        Daily_OTCUDCIN_&ExtractDate.
        Daily_OTCUREST_&ExtractDate.
        Daily_OTLNDCIN_&ExtractDate.
        Daily_OTLNREST_&ExtractDate.
        Daily_OTCCREST_&ExtractDate.
        Daily_OTFDCARD_&ExtractDate.
        Daily_OTDEFERS_&ExtractDate.
    ;
    run;

%mend;
%DDOUT;


%macro CYCOUT();
OPTIONS COMPRESS=YES;
libname pool "&Local_file_Path.";
%if %sysfunc(fileexist("&Local_file_Path.\pccm_&YYMMDD._CYC")) %then %do;
    %DEFER(FNAME=pool.CYC_OTDEFERS,source=&Local_file_Path.\pccm_&YYMMDD._CYC);
    %CCREST("&Local_file_Path.\pccm_&YYMMDD._CYC\CYC_OTCCREST.dat",pool.CYC_OTCCREST);
    %LNREST("&Local_file_Path.\pccm_&YYMMDD._CYC\CYC_OTLNREST.dat",pool.CYC_OTLNREST);
    %CUREST("&Local_file_Path.\pccm_&YYMMDD._CYC\CYC_OTCUREST.dat",pool.CYC_OTCUREST);
    %CCDCIN("&Local_file_Path.\pccm_&YYMMDD._CYC\CYC_OTCCDCIN.dat",pool.CYC_OTCCDCIN);
    %CUDCIN("&Local_file_Path.\pccm_&YYMMDD._CYC\CYC_OTCUDCIN.dat",pool.CYC_OTCUDCIN);
    %LNDCIN("&Local_file_Path.\pccm_&YYMMDD._CYC\CYC_OTLNDCIN.dat",pool.CYC_OTLNDCIN);
    %FDCC("&Local_file_Path.\pccm_&YYMMDD._CYC\CYC_OTFDCARD.dat",pool.CYC_OTFDCARD);
%end;
%else %if %sysfunc(fileexist("&Local_file_Path.\pccm_&Yesterday._CYC")) %then %do;
    %DEFER(FNAME=pool.CYC_OTDEFERS,source=&Local_file_Path.\pccm_&Yesterday._CYC);
    %CCREST("&Local_file_Path.\pccm_&Yesterday._CYC\CYC_OTCCREST.dat",pool.CYC_OTCCREST);
    %LNREST("&Local_file_Path.\pccm_&Yesterday._CYC\CYC_OTLNREST.dat",pool.CYC_OTLNREST);
    %CUREST("&Local_file_Path.\pccm_&Yesterday._CYC\CYC_OTCUREST.dat",pool.CYC_OTCUREST);
    %CCDCIN("&Local_file_Path.\pccm_&Yesterday._CYC\CYC_OTCCDCIN.dat",pool.CYC_OTCCDCIN);
    %CUDCIN("&Local_file_Path.\pccm_&Yesterday._CYC\CYC_OTCUDCIN.dat",pool.CYC_OTCUDCIN);
    %LNDCIN("&Local_file_Path.\pccm_&Yesterday._CYC\CYC_OTLNDCIN.dat",pool.CYC_OTLNDCIN);
    %FDCC("&Local_file_Path.\pccm_&Yesterday._CYC\CYC_OTFDCARD.dat",pool.CYC_OTFDCARD);
%end;
%else %RETURN;
    %EencryptDS(pool, CYC_OTDEFERS ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, CYC_OTCCREST ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, CYC_OTLNREST ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, CYC_OTCUREST ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, CYC_OTCCDCIN ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, CYC_OTCUDCIN ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, CYC_OTLNDCIN ,Group_Id Customer_Id Account_Id);
    %EencryptDS(pool, CYC_OTFDCARD ,Group_Id Customer_Id Account_Id);

    
    proc sql noprint;
     select R0006_EXTRACT__00005
    into :ExtractDate
    from pool.CYC_OTCCDCIN;
    %put &ExtractDate;

    proc datasets library=pool;
    change 
    CYC_OTCCDCIN=CYC_OTCCDCIN_&ExtractDate.
    CYC_OTCUDCIN=CYC_OTCUDCIN_&ExtractDate.
    CYC_OTCUREST=CYC_OTCUREST_&ExtractDate.
    CYC_OTLNDCIN=CYC_OTLNDCIN_&ExtractDate.
    CYC_OTLNREST=CYC_OTLNREST_&ExtractDate.
    CYC_OTCCREST=CYC_OTCCREST_&ExtractDate.
    CYC_OTFDCARD=CYC_OTFDCARD_&ExtractDate.
    CYC_OTDEFERS=CYC_OTDEFERS_&ExtractDate.
    ;
    run;

    proc copy in=pool out=CC_C MEMTYPE=data;
    select 
     CYC_OTCCDCIN_&ExtractDate.
     CYC_OTCUDCIN_&ExtractDate.
     CYC_OTCUREST_&ExtractDate.
     CYC_OTLNDCIN_&ExtractDate.
     CYC_OTLNREST_&ExtractDate.
     CYC_OTCCREST_&ExtractDate.
     CYC_OTFDCARD_&ExtractDate.
     CYC_OTDEFERS_&ExtractDate.
     ;
    run;

%mend;
%CYCOUT;

********HouseKeeping**************;
proc datasets lib=pool kill; run; quit;

x "del /Q /S &Local_file_Path.\pccm_&YYMMDD._DAILY.tar";
x "rmdir /Q /S &Local_file_Path.\pccm_&YYMMDD._DAILY";

x "del /Q /S &Local_file_Path.\pccm_&YYMMDD._CYC.tar";
x "rmdir /Q /S &Local_file_Path.\pccm_&YYMMDD._CYC";

x "del /Q /S &Local_file_Path.\pccm_&Yesterday._DAILY.tar";
x "rmdir /Q /S &Local_file_Path.\pccm_&Yesterday._DAILY";

x "del /Q /S &Local_file_Path.\pccm_&Yesterday._CYC.tar";
x "rmdir /Q /S &Local_file_Path.\pccm_&Yesterday._CYC";

********END HouseKeeping**************;
/********************************************************************;
END 5) Import Daily & Cycle Extract&Result
********************************************************************/

/********************************************************************;
6) Import Monthly Extract&Result
********************************************************************/
options compress=yes NOMPRINT;
libname EXMON "P:\PCCM_Extract_Mon\";
libname CCM 'P:\PCCM_CC_M\';
libname CUM 'P:\PCCM_CU_M\';
libname LNM 'P:\PCCM_LN_M\';

data _null_;
call symput('YYMMDD',put(INTNX('DAY',today(),-0),yymmddn8.));
call symput('GetDT',put(INTNX('DAY',today(),-0),yymmddn8.));
call symput('Yesterday',put(INTNX('DAY',today(),-1),yymmddn8.));
call symput('YYMM_L1',put(INTNX('Month',today(),-1),yymmn6.));
run;

%let Local_file_Path = E:\MFTP_RawData\PCCM\&YYMMDD.;
%let pool=&Local_file_Path.;

%put &YYMMDD. &GetDT. &Yesterday.;
%put &Local_file_Path.;
%put &YYMM_L1.;

%LET CODE = D:\PCCM\CODE\;            *Store SAS macro;

OPTIONS COMPRESS=YES;
libname pool "&Local_file_Path.";

%macro read_data();
filename dirlist PIPE "dir &Local_file_Path.\*.*";
*dir *dat filename;
data dirlist;
  infile dirlist missover pad;
          length filename $80 ;
      drop lastchar;
      input ;   
      lastchar=substr(_infile_,length(_infile_),1);      
      if lastchar='0D'x then do;
         _infile_=substr(_infile_,1,length(_infile_)-1);
      end;      
      filename = scan(_infile_,-1,' '); 
run;

*import sequence;
 %global MFolder;
 %global N;
proc sql noprint;
      select count(distinct filename) format 1. into: N
      from work.dirlist
      where filename CONTAINS 'MONTHLY.tar.gz';
   ;
   %put N=&N.; 
   %if &N > 0 %then %do;
      select distinct compress(filename) into: CCEXTRACTM from dirlist where filename CONTAINS 'CCEXTRACTM';
      select distinct compress(filename) into: CUEXTRACT from dirlist where filename CONTAINS 'CUEXTRACT';
      select distinct compress(filename) into: LNEXTRACT from dirlist where filename CONTAINS 'LNEXTRACT';
      select distinct compress(filename) into: SAEXTRACT from dirlist where filename CONTAINS 'SAEXTRACT';
      select distinct compress(filename) into: Mtargz from dirlist where filename CONTAINS 'MONTHLY.tar.gz';
      select distinct substr(compress(filename),1,25) format=$25. into: Mtar from dirlist where filename CONTAINS 'MONTHLY.tar.gz';
      select distinct substr(compress(filename),1,21) format=$21. into: MFolder from dirlist where filename CONTAINS 'MONTHLY.tar.gz';
   %end;
   %else %RETURN;
quit;
    
%put &CCEXTRACTM. &CUEXTRACT. &LNEXTRACT. &SAEXTRACT. &Mtargz. &Mtar. &MFolder.; 

    %put MONTHLY.tar.gz EXIST;
*CCEXTRACTM;
    %pccm_packer("&Local_file_Path.\&CCEXTRACTM.",pool.CCEXTRACTM_&YYMM_L1., &varfmt_ccex., mode=r, yyyymmdd=);
    %EencryptDS(pool, CCEXTRACTM_&YYMM_L1. , CCEX_Group_Id CCEX_Customer_Id CCEX_Account_Id); 
    proc copy in=pool out=EXMON MEMTYPE=data; select CCEXTRACTM_&YYMM_L1.;run;
*CUEXTRACT;
    %pccm_packer("&Local_file_Path.\&CUEXTRACT.",pool.CUEXTRACT_&YYMM_L1., &varfmt_cuex., mode=r, yyyymmdd=);
    %EencryptDS(pool, CUEXTRACT_&YYMM_L1. , CUEX_Group_Id CUEX_Customer_Id); 
    proc copy in=pool out=EXMON MEMTYPE=data; select CUEXTRACT_&YYMM_L1.;run;
*LNEXTRACT;
    %pccm_packer("&Local_file_Path.\&LNEXTRACT.",pool.LNEXTRACT_&YYMM_L1., &varfmt_lnex., mode=r, yyyymmdd=);
    %EencryptDS(pool, LNEXTRACT_&YYMM_L1. , LNEX_Group_Id LNEX_Customer_Id LNEX_Account_Id); 
    proc copy in=pool out=EXMON MEMTYPE=data; select LNEXTRACT_&YYMM_L1.;run;
*SAEXTRACT;
    %pccm_packer("&Local_file_Path.\&SAEXTRACT.",pool.SAEXTRACT_&YYMM_L1., &varfmt_saex., mode=r, yyyymmdd=);
    %EencryptDS(pool, SAEXTRACT_&YYMM_L1. , SAEX_Group_Id SAEX_Customer_Id SAEX_Account_Id); 
    proc copy in=pool out=EXMON MEMTYPE=data; select SAEXTRACT_&YYMM_L1.;run;
*MONTHLY.tar.gz;
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\&Mtargz. -y -o&Local_file_Path.";
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\&Mtar. -y -o&Local_file_Path.";
%mend;
%read_data;
%put MFolder=&MFolder.;
%put N=&N.;

%macro MONOUT();
OPTIONS COMPRESS=YES;
libname pool "&Local_file_Path.";
libname CCM 'P:\PCCM_CC_M\';
libname CUM 'P:\PCCM_CU_M\';
libname LNM 'P:\PCCM_LN_M\';
%if &N > 0 %then %do;
    %DEFER(FNAME=CUM.Monthly_OTDEFERS_&yymm_L1.,source=&Local_file_Path.\&MFolder.);
    %CCREST("&Local_file_Path.\&MFolder.\Monthly_OTCCREST.dat",CCM.Monthly_OTCCREST_&yymm_L1.);
    %LNREST("&Local_file_Path.\&MFolder.\Monthly_OTLNREST.dat",LNM.Monthly_OTLNREST_&yymm_L1.);
    %CUREST("&Local_file_Path.\&MFolder.\Monthly_OTCUREST.dat",CUM.Monthly_OTCUREST_&yymm_L1.);
    %CCDCIN("&Local_file_Path.\&MFolder.\Monthly_OTCCDCIN.dat",CCM.Monthly_OTCCDCIN_&yymm_L1.);
    %CUDCIN("&Local_file_Path.\&MFolder.\Monthly_OTCUDCIN.dat",CUM.Monthly_OTCUDCIN_&yymm_L1.);
    %LNDCIN("&Local_file_Path.\&MFolder.\Monthly_OTLNDCIN.dat",LNM.Monthly_OTLNDCIN_&yymm_L1.);
    %FDCC("&Local_file_Path.\&MFolder.\Monthly_OTFDCARD.dat",CCM.Monthly_OTFDCARD_&yymm_L1.);
    %FDCU("&Local_file_Path.\&MFolder.\Monthly_OTFDCUST.dat",CUM.MONTHLY_OTFDCUST_&yymm_L1.);
    %FDLN("&Local_file_Path.\&MFolder.\MONTHLY_OTFDLOAN.dat",LNM.MONTHLY_OTFDLOAN_&yymm_L1.);
%end;
%else %RETURN;
    %EencryptDS(CUM, Monthly_OTDEFERS_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(CCM, Monthly_OTCCREST_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(LNM, Monthly_OTLNREST_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(CUM, Monthly_OTCUREST_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(CCM, Monthly_OTCCDCIN_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(CUM, Monthly_OTCUDCIN_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(LNM, Monthly_OTLNDCIN_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(CCM, Monthly_OTFDCARD_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(CUM, Monthly_OTFDCUST_&yymm_L1. ,Group_Id Customer_Id Account_Id);
    %EencryptDS(LNM, MONTHLY_OTFDLOAN_&yymm_L1. ,Group_Id Customer_Id Account_Id);
********HouseKeeping**************;
proc datasets lib=pool kill; run; quit;

x "del /Q /S &Local_file_Path.\&MFolder..tar";
x "rmdir /Q /S &Local_file_Path.\&MFolder.";
********END HouseKeeping**************;
%mend;
%MONOUT;


********CYC CC APPEND*****************;
*options compress=yes;
libname CC_C "P:\PCCM_CC_C\";
proc sql ;
  create table mytables as
  select *
  from dictionary.tables
  where libname = 'CC_C'
  order by memname ;
quit ;

%macro cc2(CYCNAME);
%if &N > 0 %then %do;
proc sql noprint;
      select count(distinct memname) into: M
      from work.mytables
      where memname contains "&CYCNAME." and length(memname) in (21,26)
   ;
   %if &M > 0 %then %do;
      select distinct memname into: file1- :file%left(&M)
      from mytables
      where memname contains "&CYCNAME." and length(memname) in (21,26)
   ;
   %end;
   quit;

    %do i = 1 %to &M;
   %put CC_C.&&file&i.;
    %end;


   data CC_C.&CYCNAME.;
   set
    %do i = 1 %to &M;
        CC_C.&&file&i.
    %end;
   ;
    run; 
%end;
%mend;
%cc2(CYCNAME=PCCM_CC_EXTRACT_C_&YYMM_L1.);
%cc2(CYCNAME=CYC_OTCCDCIN_&YYMM_L1.);
%cc2(CYCNAME=CYC_OTCCREST_&YYMM_L1.);
%cc2(CYCNAME=CYC_OTCUDCIN_&YYMM_L1.);
%cc2(CYCNAME=CYC_OTCUREST_&YYMM_L1.);
%cc2(CYCNAME=CYC_OTLNDCIN_&YYMM_L1.);
%cc2(CYCNAME=CYC_OTLNREST_&YYMM_L1.);
/********************************************************************;
END 6) Import Monthly Extract&Result
********************************************************************/

/********************************************************************;
7) dat bz2 and del
********************************************************************/
data _null_;
call symput('YYMMDD',put(INTNX('DAY',today(),-0),yymmddn8.));
call symput('GetDT',put(INTNX('DAY',today(),-0),yymmddn8.));
call symput('Yesterday',put(INTNX('DAY',today(),-1),yymmddn8.));
run;

%let Local_file_Path = E:\MFTP_RawData\PCCM\&YYMMDD.;
%let pool=&Local_file_Path.;

%put &YYMMDD. &GetDT. &Yesterday.;
%put &Local_file_Path.;

%macro bz2();
filename dirlist PIPE "dir &Local_file_Path.\*.dat";
*dir *dat filename;
data dirlist;
  infile dirlist missover pad;
          length filename $80 ;
      drop lastchar;
      input ;   
      lastchar=substr(_infile_,length(_infile_),1);      
      if lastchar='0D'x then do;
         _infile_=substr(_infile_,1,length(_infile_)-1);
      end;      
      filename = scan(_infile_,-1,' '); 
format R4t $4.; 
filename=compress(filename);
      R4t=substr(filename,max(1,length(filename)-3));
if R4t='.dat';
run;

*bz2 sequence;
proc sql noprint;
      select count(distinct filename) into: N
      from work.dirlist
   ;
   %if &N > 0 %then %do;
      select distinct filename into: file1- :file%left(&n)
      from dirlist 
   ;
   %end;
   quit;
    
    %do i = 1 %to &n;
     systask command "c:\progra~2\7-zip\7z a -tbzip2 &Local_file_Path.\&&file&i...bz2 &Local_file_Path.\&&file&i" wait status=bz2;
     %if %sysfunc(fileexist("&Local_file_Path.\&&file&i...bz2")) %then %do;
         systask command "del /Q /S &Local_file_Path.\&&file&i." wait status=clear;
     %end;
    %put &&file&i.;
    %end;
         
%mend;
%bz2;
/********************************************************************;
END 7) dat bz2 and del
********************************************************************/

/********************************************************************;
8) PCCM_RMS
********************************************************************/
data _null_;
call symput('YYMMDD',put(INTNX('DAY',today(),-0),yymmddn8.));
call symput('GetDT',put(INTNX('DAY',today(),-0),yymmddn8.));
call symput('Yesterday',put(INTNX('DAY',today(),-1),yymmddn8.));
run;

/*%let Local_file_Path = E:\MFTP_RawData\PCCM\&YYMMDD.;*/
%let Local_file_Path = E:\MFTP_RawData\PCCM\&Yesterday.;
%let pool=&Local_file_Path.;

%put &YYMMDD. &GetDT. &Yesterday.;
%put &Local_file_Path.;

%LET CODE = D:\PCCM\CODE\;            *Store SAS macro;

%macro chkMdata();
filename dirlist PIPE "dir &Local_file_Path.\*.*";
*dir *dat filename;
data dirlist;
  infile dirlist missover pad;
          length filename $80 ;
      drop lastchar;
      input ;   
      lastchar=substr(_infile_,length(_infile_),1);      
      if lastchar='0D'x then do;
         _infile_=substr(_infile_,1,length(_infile_)-1);
      end;      
      filename = scan(_infile_,-1,' '); 
run;

*import sequence;
 %global MFolder;
 %global N;
proc sql noprint;
      select count(distinct filename) into: N
      from work.dirlist
      where filename CONTAINS 'MONTHLY.tar.gz';
   ;
quit;
  
%mend;
%chkMdata;
%put MFolder=&MFolder.;
%put N=&N.;

%macro RMS();
%if &N > 0 %then %do;

LIBNAME PCCM 'P:\PCCM_RMS\';
%SelData(3,vp_bns_mcif,SCOR_ACCT_BEHAVIOR_&L1M_YYMMN4.,PCCM,SCOR_ACCT_BEHAVIOR_&L1M_YYMMN4.,Account_Nbr Customer_Id); 
%SelData(3,vp_bns_mcif,SCOR_CUST_BEHAVIOR_MUE_&L1M_YYMMN4.,PCCM,SCOR_CUST_BEHAVIOR_MUE_&L1M_YYMMN4.,Customer_Id);  
%SelData(3,vp_bns_mcif,SCOR_CUST_BEHAVIOR_&L1M_YYMMN4.,PCCM,SCOR_CUST_BEHAVIOR_&L1M_YYMMN4.,Customer_Id); 
%SelData(3,vp_crd_mcif,SCOR_CUST_LIABILITY,PCCM,SCOR_CUST_LIABILITY_&L1M_YYMMN4.,Customer_Cpc_Id); 
%SelData(3,vp_crd_mcif,SCOR_CUST_DEMOGRAPHIC  ,PCCM,SCOR_CUST_DEMOGRAPHIC_&L1M_YYMMN4.,Customer_Cpc_Id);
%SelData(3,vp_crd_mcif,SCOR_CUST_BEHAVIOR_SCORE_&L1M_YYMMN4. ,PCCM,SCOR_CUST_SCORE_&L1M_YYMMN4.,Customer_Cpc_Id Customer_Id);
%end;

%mend;
%RMS;
/********************************************************************;
END 8) PCCM_RMS
********************************************************************/
*20181227 add /20190103 no Need;
/*%include "D:\PCCM\CODE\Pilot_Download.sas";*/
*END 20181227 add;
