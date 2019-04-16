/************************************************************/
/* MVSDMS                                                   */
/*                                                          */
/* INVOKES COB2SAS IN INTERACTIVE MODE.  TO BE USED WITH    */
/* DISPLAY MANAGER AND WHEN REMOTE SUBMITTING TO MVS VIA    */
/* SAS/CONNECT.                                             */
/*                                                          */
/************************************************************/

/*  THE COB2SAS FILEREF POINTS TO YOUR COB2SAS PDS.         */
FILENAME COB2SAS 'your.cob2sas.programs';

/*  THE INCOBOL FILREFER POINTS TO YOUR COPYBOOK.           */
FILENAME INCOBOL 'your.copy.book';

/*  THE OUTSAS FILEREF POINTS TO A FLAT FILE OR PDS MEMBER. */
/*  THE INPUT AND LABEL STATEMENT IS WRITTEN HERE.          */
/*  IF THE FILE DOES NOT EXIST, ADD DISP=NEW TO THE         */
/*     FILENAME STATEMENT BEFORE THE SEMICOLON.             */
FILENAME OUTSAS  'your.output.flat.file';

/*  THE PERM LIBREF POINTS TO A PERMANENT SAS DATA LIBRARY. */
/*  THE DATA DICTIONARY IS WRITTEN HERE.                    */
/*  IF THE FILE DOES NOT EXIST, ADD DISP=NEW TO THE         */
/*     LIBNAME STATEMENT BEFORE THE SEMICOLON.              */
LIBNAME  PERM    'your.output.sas.data.library';

  OPTIONS NOTES NOSOURCE NOSOURCE2 LINESIZE=75 COMPRESS=NO;

  %INCLUDE COB2SAS(R2MVS);
  RUN;

  PROC PRINT DATA=DICTNRY;
     BY FILENAME NOTSORTED;
     FORMAT RDF_NAME $8.;
     ID LEVEL;
     VAR NST_DPTH NEWNAME USAGE PICTURE INFMT ATBYTE BYTES
         OCR_VAL RDF_NAME;
  RUN;
