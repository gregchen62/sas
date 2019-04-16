
%macro read_data(yyyymmdd);
%let act=E:\MFTP_RawData\PBSM\201710;
/*%let act=E:\MFTP_RawData\PBSM\201707;*/
/*%let act=E:\MFTP_RawData\PBSM\201612;*/
/*%let act=P:\PCCM_Extract_dat\LNEXTRACT;*/
/*%let act=P:\PCCM_Extract_dat\CUEXTRACT;*/
/*%let act=P:\PCCM_Extract_dat\JCEXTRACT;*/
/*%let act=P:\PCCM_Extract_dat\CCEXTRACTD;*/
/*%let act=P:\PCCM_Extract_dat\CCEXTRACTC;*/
/*%let act=E:\MFTP_RawData\PCCM\&yyyymmdd.;*/
/*filename dirlist PIPE "dir E:\MFTP_RawData\PCCM\&yyyymmdd.\*.dat";*/
/*filename dirlist PIPE "dir &act.\*.dat";*/
filename dirlist PIPE "dir &act.\*.TXT";
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
/*if R4t='.dat';*/
if R4t='.TXT';
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
     systask command "c:\progra~2\7-zip\7z a -tbzip2 &act.\&&file&i...bz2 &act.\&&file&i" wait status=bz2;
     %if %sysfunc(fileexist("&act.\&&file&i...bz2")) %then %do;
         systask command "del /Q /S &act.\&&file&i." wait status=clear;
     %end;
    %put &&file&i.;
    %end;
         
%mend;
%read_data;

%macro bz2loop();
/*%do YYYYMMDD=20161213 %to 20161214;*/
/*%do YYYYMMDD=20170412 %to 20170430;*/
%do YYYYMMDD=20170701 %to 20170731;
    %let Local_file_Path = E:\MFTP_RawData\PCCM\&YYYYMMDD.;
    %if %sysfunc(fileexist("&Local_file_Path.")) %then %do;
        %read_data(yyyymmdd=&YYYYMMDD.);
    %end;
%end;
%mend;
/*%bz2loop();*/