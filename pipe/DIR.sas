%macro read_data;
data dirlist;
  infile dirlist missover pad;
  input filename $255.;
run;
proc print;run;
%mend;

/*filename dirlist PIPE 'wmic logicaldisk get DeviceID,size,FreeSpace';
%read_data;*/


filename dirlist PIPE 'dir R:\ /q/s/-c';
%read_data;