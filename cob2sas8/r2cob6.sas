 /****************************************************************/
 /*                                                              */
 /* REPLACEMENT FOR THE OLD R2COB6 AND R2COB7.  IT WRITES BOTH   */
 /* THE INPUT AND LABEL STATEMENT IN 1 DATA STEP.  THIS          */
 /* ELIMINATES THE NEED FOR ALLOCATING OUTSAS WITH DISP=MOD.     */
 /* MARC HOWELL                                                  */
 /*                                                              */
 /****************************************************************/
 /*                                                              */
 /*    NAME: R2COB6                                              */
 /*   TITLE: PROGRAM 'R2COB6', A PART OF 'COB2SAS, RELEASE 2'    */
 /* PRODUCT: SAS VERSION 8 AND ABOVE                             */
 /*  SYSTEM: CMS MVS                                             */
 /*    DATA: COB2SAS, RELEASE 2                                  */
 /*                                                              */
 /*  AUTHOR: TOM ZACK                                            */
 /*  UPDATE: MARC HOWELL (MODIFIED TO RUN UNDER VERSION 8)       */
 /* SUPPORT: MARC HOWELL                                         */
 /*     REF: COB2SAS, RELEASE 2 DOCUMENTATION                    */
 /*    MISC: WHEN USING, INVOKE SAS WITH THE SYSTEM OPTIONS:     */
 /*                      'DQUOTE MACRO'                          */
 /*                                                              */
 /****************************************************************/

 /* THE CHARCODE OPTION IS SET SO THAT THE STRINGS, '?/?/',      */
 /* '?(', AND '?)' ARE PROPERLY INTERPRETED.                     */

 OPTIONS CHARCODE;

 /*                                                              */
 /* SAVE THE DATA DICTIONARY IN A PERMANENT SAS DATA SET.        */
 /*    NOTE: THIS IS DONE ONLY WHEN &LIBREF RESOLVES TO          */
 /*          A VALUE OTHER THAN A BLANK.                         */
 /*                                                              */
 /* PRODUCE SAS LANGUAGE INPUT STATEMENTS.                       */
 /*                                                              */
 DATA &LIBREF.DICTNRY
    (KEEP=FILENAME LEVEL NST_DPTH DATANAME NEWNAME USAGE PICTURE
          INFMT OCR_BASE ITM_DISP ATBYTE BYTES OCR_VAL RDF_NAME);
    set dictnry;
 run;

data _null_;
    /*                                                           */
    /* THE CHARCODE OPTION IS SET SO THAT THE STRINGS, '?/?/',   */
    /* '?(', AND '?)' ARE PROPERLY INTERPRETED.                  */
    /*                                                           */
  blabla=_n_;

*********** R2COB6 ****************;
  do abc=1 to numobs;
    if abc=numobs then eof=1; else eof=0;
    if abc=1 then do;
       fllr_cnt=0;
       firstime=1;
    end;

    /* FILLER COUNT AND FILLER STRING                            */
*   RETAIN FLLR_CNT 0;
    LENGTH FLLR_STR $4;

    IF abc = 1 THEN
       SET SWITCHES;

*   RETAIN FIRSTIME 1;
*   SET DICTNRY END=EOF;
    SET DICTNRY point=abc nobs=numobs;

    &FILE;

    IF (LEVEL = '01') OR (abc = 1) THEN DO;
       /*   BEGIN A NEW SAS INPUT STATEMENT.                     */
       IF FIRSTIME THEN DO;
          FIRSTIME = 0;
          PUT; PUT;
          END;  /* FIRST TIME */
       ELSE DO;  /* NOT FIRST TIME */
          PUT @6 ';'; PUT;
          END;  /* NOT FIRST TIME */
       PUT @3 '/* INFILE ' FILENAME ' */';
       PUT @3 'INPUT';
       END;  /* AT LEVEL 01 */
    ELSE DO; /* NOT AT LEVEL 01 */
       /*   STILL BUILDING THE CURRENT SAS INPUT STATEMENT.  */
       END;  /* NOT AT LEVEL 01 */

    /* IGNORE ENTRIES WITH USAGE EQUAL TO GROUP.              */
    IF (USAGE = 'GROUP') THEN DO;
       IF EOF THEN
          PUT @6 ';';
          continue;
*      RETURN;
       END;  /* IF (USAGE = 'GROUP')  */

    /* IF DEL_FLLR = 'Y', THEN IGNORE ENTRIES WITH 'FILLER'.     */
    /* OTHERWISE, MAKE THE NEWNAME UNIQUE.                       */
    IF (DEL_FLLR = 'Y') AND (DATANAME = 'FILLER') THEN DO;
       IF EOF THEN
          PUT @6 ';';
          continue;
*      RETURN;
       END;  /* IF (DEL_FLLR = 'Y') ETC. */
    ELSE IF (DEL_FLLR NE 'Y') AND (DATANAME = 'FILLER') THEN DO;
       FLLR_CNT + 1;
       FLLR_STR = PUT(FLLR_CNT,4.);
       NEWNAME = 'FLLR'?/?/TRIM(LEFT(FLLR_STR));
       END;  /* ELSE IF (DEL_FLLR NE 'Y') ETC. */

    IF USE_AT = 'Y' THEN
       PUT @6 '@' @7 ATBYTE @18 NEWNAME @58 INFMT;
    ELSE
       PUT @6 NEWNAME @48 INFMT;
    IF EOF THEN
       PUT @6 ';';
 end;

*********** R2COB7 ****************;
 do abc=1 to numobs;
   if abc=numobs then eof=1; else eof=0;
   if abc=1 then do;
       ptr=-1;
       firstime=1;
       set switches;
       if make_lbl ne 'Y' then
          stop;
   end;

    /*                                                           */
    /* THE CHARCODE OPTION IS SET SO THAT THE STRINGS, '?/?/',   */
    /* '?(', AND '?)' ARE PROPERLY INTERPRETED.                  */
    /*                                                           */

    set dictnry point=abc nobs=numobs;

    &FILE;

    IF (LEVEL = '01') OR (abc = 1) THEN DO;
       /*   BEGIN A NEW SAS LABEL STATEMENT.                     */
       IF FIRSTIME THEN DO;
          FIRSTIME = 0;
          PUT; PUT;
          END;  /* FIRST TIME */
       ELSE DO;  /* NOT FIRST TIME */
          PUT @6 ';'; PUT;
          END;  /* NOT FIRST TIME */
       PUT @3 '/* LABEL ' FILENAME ' */';
       PUT @3 'LABEL';
       END;  /* AT LEVEL 01 */
    ELSE DO; /* NOT AT LEVEL 01 */
       /*   STILL BUILDING THE CURRENT SAS LABEL STATEMENT.  */
       END;  /* NOT AT LEVEL 01 */

    /* IGNORE ENTRIES WITH USAGE EQUAL TO GROUP.              */
    IF (USAGE = 'GROUP') THEN DO;
       IF EOF THEN
          PUT @6 ';';
       continue;
       END;  /* IF (USAGE = 'GROUP')  */

    /* IF DEL_FLLR = 'Y', THEN IGNORE ENTRIES WITH 'FILLER'.  */
    IF (DEL_FLLR = 'Y') AND (DATANAME = 'FILLER') THEN DO;
       IF EOF THEN
          PUT @6 ';';
       continue;
       END;  /* IF (DEL_FLLR = 'Y') ETC. */

*   PUT @6 NEWNAME @15 '= ''' @18 DATANAME +PTR '''';
*   PUT @6 NEWNAME @45 '= ''' DATANAME +PTR '''';
    PUT @6 NEWNAME @45 '= ''' @48 DATANAME +PTR '''';
    IF EOF THEN
       PUT @6 ';';
 end;
 RUN;  /* DATA _NULL_ */

 /* THE NOCHARCODE OPTION IS SET SO THAT STRINGS LIKE, '?)', ARE */
 /* NOT MISINTERPRETED.                                          */
 OPTIONS NOCHARCODE;
 RUN;  /* PROGRAM R2COB7 */


