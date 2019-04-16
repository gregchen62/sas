/****************************************************
Batch Code: FTP_PCCM.sas 
Update    : 2018/10/31
****************************************************/
%let SASBATCH_HOME  =  E:\MFTP;

data _null_;
call symput('YYMMDD',put(today(),yymmddn8.));
run;
%put YYMMDD=&YYMMDD.;

data _null_;
call system("mkdir E:\MFTP_RawData\PCCM\&YYMMDD.");
run;

%let Local_file_Path = E:\MFTP_RawData\PCCM\&YYMMDD.;
libname funclib "&SASBATCH_HOME.\sasmacros";
options noxwait cmplib=funclib.funcs validvarname=any mautosource sasautos=("&SASBATCH_HOME.\sasmacros",sasautos);

%global GetDT;

%macro get_ftp_connection(ftp_code=)  ;
   data _null_;
    infile "&SASBATCH_HOME.\setup\ftp_config_PCCM.txt" pad missover lrecl=32767 firstobs=2;
    length ftp_code $20  host $30 port $2 cd $100 connect_id $40 pw $100 password $500;
    input string $1000.;
    ftp_code=strip(scan(string,2,','));
    host=scan(string,3,',');
    port=scan(string,5,',');
    connect_id=scan(string,6,',');
    pw=strip(scan(string,7,','));   
    cd=scan(string,8,',');   
    if upcase(ftp_code)=upcase(strip("&ftp_code"));
    if upcase(substr(pw,1,5)) = '{SAS}' then password=decrypt(substr(pw,6));
    call symputx('server',strip(host));
    call symputx('port',strip(port));
    call symputx('cd',strip(cd));    
    call symputx('user',strip(connect_id));
    call symputx('password',strip(password));    
  run;  %put server=&server port=&port cd=&cd user=&user password=&password;
%mend;

%macro ftp_GetData_PCCM;
%let  server =; %let cd=; %let  port=; %let user=; %let password=; 
%get_ftp_connection(ftp_code=connect1) ;
   filename foo temp;
         data _null_;
           file foo;
            put "open &server"; 
          put "&user";
          put "&password";
           put "cd ""&cd"" ";   
           put "dir ";               
            put 'disconnect';
          put 'bye';
         run;    
        %let log = %sysfunc(pathname(foo)).log;
        systask command "&SASBATCH_HOME.\ftp_cmd.bat ""%sysfunc(pathname(foo))""" wait status=ftp_rc;
        waitfor _all_;
        %let rc=%sysfunc(fdelete(foo));
        filename foo clear;
        filename foo "&log";
        data _null_;
          infile foo;
          input;
          put _infile_;
        run; 
   
     data work.ftp_list_all;
      infile foo end=eof ignoredOsEof;
      length filename $80 ftp_size 8 ftp_file_dt 8 log_msg $200;
      drop lastchar;
      input ;   
      lastchar=substr(_infile_,length(_infile_),1);      
      if lastchar='0D'x then do;
         _infile_=substr(_infile_,1,length(_infile_)-1);
      end;      
      filename = scan(_infile_,-1,' ');    
      ftp_size = input(scan(_infile_,5,' '),16.);    
      if ftp_size ne .;     
      if find(scan(_infile_,8,' '),':') = 0 then do;
        ftp_file_dt=input(scan(_infile_,7,' ')||scan(_infile_,6,' ')||scan(_infile_,8,' ')||':00:00:00',datetime19.);
      end;
      else do;
        ftp_file_dt=input(scan(_infile_,7,' ')||scan(_infile_,6,' ')||put(year(today()),4.)||':'||scan(_infile_,8,' ')||':00',datetime19.);
        if month(datepart(ftp_file_dt)) > month(today()) then ftp_file_dt=intnx('dtyear',ftp_file_dt,-1,'S');
      end;   
      format ftp_file_dt e8601dt22.0;
      log_msg=_infile_;

    run;

   data _null_;
      call symput('GetDT',put(today(),yymmddn8.));
      call symput('Yesterday',put(INTNX('DAY',today(),-1),yymmddn8.));
   run;
   %put GetDT=&GetDT.;

    data  work.download_list;
      set work.ftp_list_all(where=(filename in ("CCEXTRACTD.dat","CCEXTRACTC.dat","CCEXTRACTM.dat","JCEXTRACT.dat","JCEXTRACT_SRC.dat","LNEXTRACT.dat","CUEXTRACT.dat","SAEXTRACT.dat","pccm_&Yesterday._DAILY.tar.gz","pccm_&GetDT._DAILY.tar.gz","pccm_&Yesterday._CYC.tar.gz","pccm_&GetDT._CYC.tar.gz","pccm_&Yesterday._MONTHLY.tar.gz","CMS.csv")));
/*      if substr(lowcase(filename),1,5) = 'list_';
      last_mon=intnx('day',today(),-(weekday(today())+5) );
      last_sun=last_mon+6;
      last_month=intnx('month',today(),-1,'S' );
      put last_mon  date9. last_sun  date9. last_month  date9.;
      if length( scan(scan(filename,1,'.'),2,'_'))= 6 then do;
           if scan(scan(filename,1,'.'),2,'_')  =put(today(),yymmn6.) or scan(scan(filename,1,'.'),2,'_')  = put(last_month,yymmn6.) then output;
      end;else
      if length( scan(scan(filename,1,'.'),2,'_'))= 8 then do;
        file_yyyymmdd=input(scan(scan(filename,1,'.'),2,'_'),yymmdd8.);
        format file_yyyymmdd yymmdd8.;
        if last_mon <= file_yyyymmdd <=last_sun then output;
      end;*/
    run;
    
   proc sql noprint;
      select count(distinct filename) into: N
      from work.download_list  
   ;
   %if &N > 0 %then %do;
      select distinct filename into: file1- :file%left(&n)
      from work.download_list   
   ;
   %end;
   quit;
    
    %do i = 1 %to &n;
     %put Ftp download &i : &&file&i ;
         
         filename foo temp;
         data _null_;
           file foo;
            put "open &server"; 
          put "&user";
          put "&password";
           put "cd ""&cd"" ";   
            put "lcd ""&Local_file_Path"" ";              
          put "binary";
            put 'prompt';    
            put "get ""&&file&i""";             
            put 'disconnect';
          put 'bye';
         run;    
          %let log = %sysfunc(pathname(foo)).log;
        systask command "&SASBATCH_HOME.\ftp_cmd.bat ""%sysfunc(pathname(foo))""" wait status=ftp_rc;
        waitfor _all_;
        %let rc=%sysfunc(fdelete(foo));
        filename foo clear;
        filename foo "&log";
        data _null_;
          infile foo;
          input;
          put _infile_;
        run;     
    %end;
    
   filename foodir pipe "dir/a:-d/-c/t:w/4 &Local_file_Path.\*.* ";
 
   data work.local_list;
      infile foodir firstobs=6;
      length filename $80 local_size 8 local_file_dt 8 ;
      input;
      if prxmatch('/^\d{1,}/',_infile_) > 0;          
      yymmdd = input(scan(_infile_,1,' '),anydtdte10.);
      time  = input(scan(_infile_,3,' '),hhmmss.);
      if scan(_infile_,2,' ') = '下午' then time = time + hms(12,0,0);
      local_file_dt = input(put(yymmdd, yymmdd10.)||' '||put(time,time8.),anydtdtm.);
      local_size = input(scan(_infile_,-2,' '), best16.);
      filename = scan(_infile_,-1,' ');
      format local_file_dt e8601dt22.0 yymmdd yymmdd10.;
      keep filename local_size local_file_dt;
   run;  
   %let filetxt_nobs = ;
   %let filetxt_nobs = %get_attrn(work.local_list, nlobs);   
   %put filetxt_nobs=&filetxt_nobs;
   proc sort data=work.local_list; by filename;run;
   proc sort data=work.download_list; by filename;run;
   
   data work.download_Y work.download_N;
      merge work.local_list(in=a)  work.download_list(in=b);
      length size_diff $1;
      by filename;
      if a and b then do;
         if local_size ne ftp_size then size_diff='X';else size_diff='Y';
         output work.download_Y;
      end;
      if not a and  b then output work.download_N;
    run;

    data work.local_dir;
      infile foodir;
      length log_msg $200;
      input;
      log_msg=_infile_;
    run;
    data work.ftp_dir;
      set work.download_list(keep=log_msg);
    run;
    
    filename outbox email "ba.sasmm@ctbcbank.com"; 
    data _null_;
       file outbox
       to=("brenda.chen@ctbcbank.com" "greg.chen@ctbcbank.com")
       cc=()
      
       subject="&syshostname 從 Ftp &server. 下載 PCCM 檔案"
       
      /* attach=()*/
       ;
      set work.download_Y(in=a) work.download_N(in=b)  work.local_dir(in=c) work.ftp_dir(in=d) ;
        if _n_ = 1 then do;
          put 'Hi,';
          put ' ';
          put ' ';
          put "已下載檔案";     
        end;
        if a then put '檔名:' filename '  更新日: ' ftp_file_dt  ' 檔案大小: ' local_size ' FTP檔案大小: ' ftp_size  '下載後檔案大小一致: ' size_diff ;
        else if b then do;
          i+1;
          if i = 1 then do;
             put ' ';
             put ' ';
             put 'FTP Server上 下載失敗檔案';
          end;
          put '檔名: ' filename  '檔案大小: ' local_size;
        end;  
        if c then do;
          j+1;
          if j=1 then do;
             put ' ';
             put ' ';
             put "&syshostname local 檔案清單";
          end;
          put log_msg;
        end;
        if d then do;
          k+1;
          if k=1 then do;
            put ' ';
            put ' ';
            put "Ftp Server 檔案清單";
          end;    
          put log_msg;        
        end;
    run;
        
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\pccm_&GetDT._DAILY.tar.gz -y -o&Local_file_Path.";
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\pccm_&GetDT._DAILY.tar -y -o&Local_file_Path.";
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\pccm_&Yesterday._DAILY.tar.gz -y -o&Local_file_Path.";
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\pccm_&Yesterday._DAILY.tar -y -o&Local_file_Path.";

    x "c:\progra~2\7-zip\7z x &Local_file_Path.\pccm_&GetDT._CYC.tar.gz -y -o&Local_file_Path.";
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\pccm_&GetDT._CYC.tar -y -o&Local_file_Path.";
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\pccm_&Yesterday._CYC.tar.gz -y -o&Local_file_Path.";
    x "c:\progra~2\7-zip\7z x &Local_file_Path.\pccm_&Yesterday._CYC.tar -y -o&Local_file_Path.";

%mend ftp_GetData_PCCM;
%ftp_GetData_PCCM;

%include "D:\PCCM\CODE\PCCM_Batch_Include.sas";
