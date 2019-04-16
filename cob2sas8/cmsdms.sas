/************************************************************/
/* CMSDMS                                                   */
/*                                                          */
/* INVOKES COB2SAS IN INTERACTIVE MODE.  TO BE USED WITH    */
/* DISPLAY MANAGER AND WHEN REMOTE SUBMITTING TO CMS VIA    */
/* SAS/CONNECT                                              */
/*                                                          */
/************************************************************/

/*  THE INCOBOL FILREF POINTS TO YOUR COPYBOOK.             */
FILENAME INCOBOL 'filename filetype filemode';

/*  THE OUTSAS FILEREF POINTS TO A FLAT FILE.               */
/*  THE INPUT AND LABEL STATEMENT IS WRITTEN HERE.          */
FILENAME OUTSAS  'filename filetype filemode';

/*  THE PERM LIBREF POINTS TO A PERMANENT SAS DATA LIBRARY. */
/*  THE DATA DICTIONARY IS WRITTEN HERE.                    */
LIBNAME  PERM    'filemode';

  OPTIONS NOTES NOSOURCE NOSOURCE2 LINESIZE=75 COMPRESS=NO;

  %INCLUDE COB2SAS(R2CMS);
  RUN;

  PROC PRINT DATA=DICTNRY;
     BY FILENAME NOTSORTED;
     FORMAT RDF_NAME $8.;
     ID LEVEL;
     VAR NST_DPTH NEWNAME USAGE PICTURE INFMT ATBYTE BYTES
         OCR_VAL RDF_NAME;
  RUN;
