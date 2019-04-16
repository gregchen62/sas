%macro read_data;
filename dirlist PIPE 'wmic logicaldisk get DeviceID,size,FreeSpace';
data dirlist;
  infile dirlist missover pad;
  input filename $255.;
if _n_=1 then do ;
    format DeviceID $10. FreeSpace 15. Size 15.;
end;
else do;
    DeviceID    =substr(filename,1,10);
    FreeSpace    =substr(filename,11,15)*1;
    Size        =substr(filename,26,15)*1;
end;

format Usage percent10.2;
Usage =1- FreeSpace/Size;


if _n_>=2 and Size^=.;
drop filename;
run;
proc print;run;
%mend;
%read_data;
