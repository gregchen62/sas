*LOOP;
%macro loopA();
%do i=201601 %to 201612;
    %LET YYMM=%SUBSTR(&I.,3,4);
    data work.table_&yymm.;
	YYMM="&yymm.";
	run;
%end;
%do i=201701 %to 201712;
    %LET YYMM=%SUBSTR(&I.,3,4);
    data work.table_&yymm.;
	YYMM="&yymm.";
	run;
%end;
%mend loopA;
%loopA();


%macro loopB();
%do i=201601 %to 201712;
    %LET YYMM=%SUBSTR(&I.,3,4);
    %if %sysfunc(exist(work.table_&yymm.)) %then %do;
		proc append base=apend data=work.table_&yymm. force;run;
	%end;
%end;
%mend loopB;
%loopB();
