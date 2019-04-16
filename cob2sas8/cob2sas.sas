/************************************************************/
/* WINDMS                                                   */
/*                                                          */
/* INVOKES COB2SAS IN INTERACTIVE MODE.  TO BE USED WITH    */
/* DISPLAY MANAGER                                          */
/*                                                          */
/************************************************************/

/*  THE COB2SAS FILEREF POINTS TO YOUR COB2SAS DIRECTORY    */
FILENAME COB2SAS 'C:\cob2sas8\';

/*  THE INCOBOL FILREF POINTS TO YOUR COPYBOOK.             */
FILENAME INCOBOL ftp "'sasmsh.cob2sas.copybook(mulgrew2)'" 
  user='sasmsh' host='mvs.sas.com' pass='asdf007';
*FILENAME INCOBOL 'c:\!!mycrap\temp.txt';

/*  THE OUTSAS FILEREF POINTS TO A FLAT FILE.               */
/*  THE INPUT AND LABEL STATEMENT IS WRITTEN HERE.          */
FILENAME OUTSAS  'C:\!!mycrap\outsas.txt';

/*  THE PERM LIBREF POINTS TO A PERMANENT SAS DATA LIBRARY. */
/*  THE DATA DICTIONARY IS WRITTEN HERE.                    */
LIBNAME  PERM    'C:\cob2sas8\perm';

  OPTIONS NOTES NOSOURCE NOSOURCE2 LINESIZE=75 COMPRESS=NO;

  %INCLUDE COB2SAS(R2WIN);
  RUN;

  PROC PRINT DATA=DICTNRY;
     BY FILENAME NOTSORTED;
     FORMAT RDF_NAME $8.;
     ID LEVEL;
     VAR NST_DPTH NEWNAME USAGE PICTURE INFMT ATBYTE BYTES
         OCR_VAL RDF_NAME;
  RUN;

  data _null_;
    file print; infile outsas;
	input; put _infile_;
  run;

