 /****************************************************************/
 /*                                                              */
 /*    NAME: R2COB3                                              */
 /*   TITLE: PROGRAM 'R2COB3', A PART OF 'COB2SAS, RELEASE 2'    */
 /* PRODUCT: SAS VERSION 8 AND ABOVE                             */
 /*  SYSTEM: CMS MVS                                             */
 /*    DATA: COB2SAS, RELEASE 2                                  */
 /*                                                              */
 /*  AUTHOR: TOM ZACK                                            */
 /* SUPPORT: MARC HOWELL                                         */
 /*     REF: COB2SAS, RELEASE 2 DOCUMENTATION                    */
 /*    MISC: WHEN USING, INVOKE SAS WITH THE SYSTEM OPTIONS:     */
 /*                      'DQUOTE MACRO'                          */
 /*                                                              */
 /****************************************************************/

 OPTIONS CHARCODE;

 /* DEBUG: BEGIN  */
 %LET CMT = *;
 &CMT OPTIONS NOTES SOURCE SOURCE2;

 &CMT PROC PRINT DATA=DICTNRY NOOBS;
 &CMT    BY FILENAME NOTSORTED;
 &CMT    VAR D_GRPID LEVEL NST_DPTH DATANAME USAGE PICTURE INFMT
 &CMT        OCR_BASE ITM_DISP ATBYTE BYTES OCR_VAL RDF_NAME;
 &CMT RUN;

 &CMT PROC PRINT DATA=GROUP;
 &CMT    VAR G_GRPID G_LVL G_NST G_NAM G_TYP G_AT G_LEN
 &CMT        G_OCR G_RDF;
 &CMT RUN;
 /* DEBUG: END    */


 /***************************************************************/
 /* UPDATE DICTIONARY WITH INFORMATION IN THE GROUP DATA SET.   */
 /***************************************************************/
 PROC SORT DATA=GROUP;
    BY G_GRPID;

 DATA DICTNRY
    (KEEP=FILENAME LEVEL NST_DPTH DATANAME USAGE PICTURE INFMT
          OCR_BASE ITM_DISP ATBYTE BYTES OCR_VAL RDF_NAME);

    RETAIN DNOBS 1 GNOBS 1;
    GPTR = 1;
    DO DPTR = 1 TO DNOBS;
       SET DICTNRY POINT=DPTR NOBS=DNOBS;
       SET GROUP POINT=GPTR NOBS=GNOBS;
       IF D_GRPID = G_GRPID THEN DO;
          BYTES = G_LEN;
          GPTR + 1;
          END;  /* IF D_GRPID = G_GRPID */
       IF DATANAME NE '__##DUMMY_LEVEL_01__##DUMMY___' THEN
          OUTPUT;
       IF GPTR GT GNOBS THEN
          GPTR = GPTR - 1;
       END;  /* DO I = 1 TO DNOBS */
    STOP;

 /* DEBUG: BEGIN  */
 &CMT PROC PRINT DATA=DICTNRY;
 &CMT    BY FILENAME NOTSORTED;
 &CMT    ID LEVEL;
 &CMT    VAR LEVEL NST_DPTH DATANAME USAGE PICTURE INFMT OCR_BASE
 &CMT        ITM_DISP ATBYTE BYTES OCR_VAL RDF_NAME;
 &CMT RUN;
 &CMT OPTIONS NONOTES NOSOURCE NOSOURCE2;
 /* DEBUG: END    */

 OPTIONS NOCHARCODE;

 RUN;  /* PROGRAM R2COB3 */
