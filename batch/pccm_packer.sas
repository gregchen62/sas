%macro pccm_packer(fname, dname, varfmts, mode=r, yyyymmdd=20151005);
%*mode=r|w;
%*yyyymmdd must not null if mode=w;
%*varfmts defines [variable-name variable-format] sequentially, seperated by blanks;

%*This packer is based on schema defined by MicroFocus, a java-to-cobol midware vendor;
%*Any detail could be referred to the official documentation:;
%*http://documentation.microfocus.com/help/topic/com.microfocus.eclipse.infocenter.studee60ux/GUID-D7E4E289-5C4F-4987-90ED-25E2657AA72A.html;

%*Compute the record length first;
%local reclen i;
%let i = 1;
%do %while(%qscan(&varfmts.,&i.,%str( )) ne);
    %if not %sysfunc(mod(&i.,2)) %then
        %let reclen = %eval(&reclen. + %sysfunc(prxchange(%str(s/(\$char|s370fpd)(\d+)(\.)(\d*)/$2/), 1, %qlowcase(%scan(&varfmts.,&i.,%str( ))))));
    %let i = %eval(&i. + 1);
%end;

%*In this version, as of 2016.11.23, the output layout is slightly different from the input one.
%*The differences occur on record header and record trailer.;
%if %lowcase(&mode.) = w %then %do;
    %local dsid nobs;
    %let dsid = %sysfunc(open(&dname.));
    %if &dsid. %then %let nobs = %sysfunc(attrn(&dsid., nobs));
    %let dsid = %sysfunc(close(&dsid.));

    %*File header;
    data _null_;
    file &fname. recfm=n;
    put "3000007c"x 2*"00"x 2*"00"x
        "%substr(&yyyymmdd.,3)" "%sysfunc(compress(%sysfunc(time(),e8601tm15.2),:.))"
        14*"00"x "003e"x "00"x "01"x "00"x "00"x "00"x "00"x 4*"00"x "01"x 5*"00"x
        "00007fff"x "00000001"x 46*"00"x 4*"00"x 16*"00"x;
    run;

    %*Record header;
    data _null_;
    file &fname. recfm=n mod;
    put "40"x "%sysfunc(abs(20+20+20+12+2),hex6.)"x
        20*"00"x 20*"00"x 20*"00"x "&yyyymmdd.0000" "0d0a"x
        %if %sysfunc(mod(20+20+20+12+2,4)) %then %eval(4-%sysfunc(mod(20+20+20+12+2,4)))*"00"x;;
    run;

    %*Contents;
    %if &nobs. %then %do;
    data _null_;
    set &dname. end=_end_;
    file &fname. recfm=n mod;
    put "40"x "%sysfunc(abs(&reclen.),hex6.)"x
        &varfmts.
        %if %sysfunc(mod(&reclen.,4)) %then %eval(4-%sysfunc(mod(&reclen.,4)))*"00"x;;
    run;
    %end;

    %*Trailer;
    data _null_;
    file &fname. recfm=n mod;
    put "40"x "%sysfunc(abs(20+20+20+12),hex6.)"x
        20*"ff"x 20*"ff"x 20*"ff"x "%sysfunc(abs(&nobs.), z12.)";
    run;
%end;
%else %if %lowcase(&mode.) = r %then %do;
    data &dname.;
    infile &fname. recfm=n;

    %*Set a flag to denote if it goes to end;
    %*This is bcz the file trailer varies as well;
    retain _endflag_ 0;

    if _n_ = 1 then do;
        input _fileheader_ $char128.;

        input _recordheader_ $char4.;
        input _keys_ $char60.
            _filedate_ yymmdd8.
            _filetime_ hhmmss4.
            _newline_ $char2.
            +(input(substr(put(_recordheader_, $hex8.), 2), hex.) - (60 + 8 + 4 + 2));

        length _padding_ $4;
        %*Suppress reading padding for the length vary;
        if mod(input(substr(put(_recordheader_, $hex8.), 2), hex.), 4) then input +(4 - mod(input(substr(put(_recordheader_, $hex8.), 2), hex.), 4));;
    end;
    else do;
        input _recordheader_ $char4. _keys_ $char60.;
        if _keys_ ^= translate(put("", $60.), "ff"x, "20"x) and not _endflag_ then do;
            input +(-60)
                &varfmts.
                %if %sysfunc(mod(&reclen.,4)) %then _padding_ $char%eval(4-%sysfunc(mod(&reclen.,4))).;;
            output;
        end;
        else _endflag_ = 1;
    end;

    drop _endflag_ -- _padding_;
    run;
%end;
%exit:
%mend pccm_packer;
