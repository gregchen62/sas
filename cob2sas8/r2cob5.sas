 /****************************************************************/
 /*                                                              */
 /*    NAME: R2COB5                                              */
 /*   TITLE: PROGRAM 'R2COB5', A PART OF 'COB2SAS, RELEASE 2'    */
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
 /* EXPAND OCCURS VARIABLES.                                     */
 /*                                                              */
 DATA DICTNRY;
    KEEP FILENAME LEVEL NST_DPTH DATANAME NEWNAME USAGE PICTURE
         INFMT OCR_BASE ITM_DISP ATBYTE BYTES OCR_VAL RDF_NAME;


    /* EXPAND MODE                                               */
    RETAIN XPNDMODE 'NOT EXPANDING';

    /* OCCURS-STACK INDEX                                        */
    /* OCCURS-STACK LEVEL, OCCURS-STACK NUMERIC LEVEL            */
    /* OCCURS-STACK ATBYTE, OCCURS-STACK BYTES                   */
    /* OCCURS-STACK OCCURS VALUE                                 */
    RETAIN OK_NDX 0;
    RETAIN OK_LVL1-OK_LVL49 0;
    RETAIN OK_BSE1-OK_BSE49 0;
    RETAIN OK_BYT1-OK_BYT49 0;
    RETAIN OK_USG1-OK_USG49 ' ';
    RETAIN OK_OCR1-OK_OCR49 0;
    ARRAY OK_LVL?(49?)     OK_LVL1-OK_LVL49;
    ARRAY OK_BSE?(49?)     OK_BSE1-OK_BSE49;
    ARRAY OK_BYT?(49?)     OK_BYT1-OK_BYT49;
    ARRAY OK_USG?(49?) $8  OK_USG1-OK_USG49;
    ARRAY OK_OCR?(49?)     OK_OCR1-OK_OCR49;

    /* OCCURS STRING, TEMP OCCURS, TEMP NAME                     */
    /*-----------------------------------------------------------*/
    /* MODIFIED THE LENGTH OF TEMPNAME FROM 8 BYTES TO 30 BYTES  */
    /* TO SUPPORT LONG VARIABLE NAMES.  MARC HOWELL              */
    /*-----------------------------------------------------------*/
    LENGTH OCR_STR $12 TEMP_OCR 8 TEMPNAME $30;

 SET DICTNRY;
 LVL = INPUT(LEVEL,12.);
 IF LVL = 1 THEN DO;
    OK_NDX = 0;
    XPNDMODE = 'NOT EXPANDING';
    END;  /* IF LVL = 1 */

 IF OK_NDX = 0 THEN DO;
    IF OCR_VAL NE ' ' THEN DO;
       /* PUSH THE FIRST ITEM ONTO THE STACK.                    */
       OK_NDX = 1;
       OK_LVL?(OK_NDX?) = LVL;
       OK_BSE?(OK_NDX?) = OCR_BASE;
       OK_BYT?(OK_NDX?) = BYTES;
       OK_USG?(OK_NDX?) = USAGE;
       OK_OCR?(OK_NDX?) = INPUT(OCR_VAL,12.);
       XPNDMODE = 'EXPANDING';
       END;  /* IF OCR_VAL NE ' ' */
    END;  /* IF OK_NDX = 0 */
 ELSE IF LVL LE OK_LVL?(OK_NDX?) THEN DO;
    DONE = 0;
    DO WHILE(NOT DONE);
       /* POP ITEMS OFF OF THE STACK.                            */
       OK_NDX = OK_NDX - 1;
       IF OK_NDX = 0 THEN DO;
          DONE = 1;
          XPNDMODE = 'NOT EXPANDING';
          END;  /* IF OK_NDX = 0 */
       ELSE IF LVL GT OK_LVL?(OK_NDX?) THEN
          DONE = 1;
       END;  /* DO WHILE */

    IF OK_NDX = 0 THEN DO;
       IF OCR_VAL NE ' ' THEN DO;
          /* PUSH THE FIRST ITEM ONTO THE STACK.                 */
          OK_NDX = 1;
          OK_LVL?(OK_NDX?) = LVL;
          OK_BSE?(OK_NDX?) = OCR_BASE;
          OK_BYT?(OK_NDX?) = BYTES;
          OK_USG?(OK_NDX?) = USAGE;
          OK_OCR?(OK_NDX?) = INPUT(OCR_VAL,12.);
          XPNDMODE = 'EXPANDING';
          END;  /* IF OCR_VAL NE ' ' */
       END;  /* IF OK_NDX = 0 */
    END;  /* ELSE IF LVL LE OK_LVL?(OK_NDX?) */
 ELSE IF LVL GT OK_LVL?(OK_NDX?) THEN DO;
    IF OCR_VAL NE ' ' THEN DO;
       /* PUSH AN ITEM ONTO THE STACK.                           */
       OK_NDX + 1;
       OK_LVL?(OK_NDX?) = LVL;
       OK_BSE?(OK_NDX?) = OCR_BASE;
       OK_BYT?(OK_NDX?) = BYTES;
       OK_USG?(OK_NDX?) = USAGE;
       OK_OCR?(OK_NDX?) = INPUT(OCR_VAL,12.);
       END;  /* IF OCR_VAL NE ' ' */
    END;  /* ELSE IF LVL GT OK_LVL?(OK_NDX?) */

 SELECT (XPNDMODE);
    WHEN ('EXPANDING') DO;
       IF OK_NDX EQ 1 THEN DO;
          TEMPBASE = OK_BSE?(OK_NDX?);
          OCR_LEN = OK_BYT?(OK_NDX?)/OK_OCR?(OK_NDX?);
          IF OCR_VAL NE ' ' THEN
             BYTES = OCR_LEN;
          TEMPNAME = TRIM(LEFT(NEWNAME));
          TEMP_OCR = OK_OCR?(OK_NDX?);
          IF TEMP_OCR LE 999 THEN DO;
             DO I = 1 TO OK_OCR?(OK_NDX?);
                ATBYTE = TEMPBASE + ITM_DISP;
                OCR_VAL = '1';
                LINK FIXNAME;
                OUTPUT;
                TEMPBASE = TEMPBASE + OCR_LEN;
                END;  /* DO I = 1 TO OK_OCR?(OK_NDX?) */
             END;  /* IF TEMP_OCR LE 999 */
          ELSE IF TEMP_OCR GT 999 THEN DO;
             PUT 'ERROR: TABLES WITH MORE THAN 999 OCCURRENCES ' @;
             PUT 'ARE NOT EXPANDED.';
             PUT @8 NST_DPTH= DATANAME= ATBYTE=;
             PUT ;
             OUTPUT;
             END;  /* ELSE IF TEMP_OCR GT 999 */
          END;  /* IF OK_NDX EQ 1 */
       ELSE DO;
          PUT 'ERROR: MULTI-DIMENSIONAL TABLES ARE NOT EXPANDED.';
          PUT @8 NST_DPTH= DATANAME= ATBYTE=;
          PUT ;
          OUTPUT;
          END;  /* ELSE DO */
       END;  /* WHEN ('EXPANDING') */
    WHEN ('NOT EXPANDING') DO;
       OUTPUT;
       END;  /* WHEN ('NOT EXPANDING') */
    END; /* SELECT (XPNDMODE) */

 FIXNAME:
    /*                                                           */
    /* FIXNAME:                                                  */
    /*    FIX NAME                                               */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    APPEND AN ORDINAL NUMBER TO THE VALUE IN NEWNAME.      */
    /*                                                           */

    IF NEWNAME = 'FILLER' THEN DO;
       /* NOTHING */
       END;  /* IF NEWNAME = 'FILLER' */
    ELSE IF TEMP_OCR LE 999 THEN DO;
       OCR_STR = PUT(I,12.);
       OCR_STR = TRIM(LEFT(OCR_STR));
       DO J = 1 TO (3 - LENGTH(OCR_STR));
          OCR_STR = '0'?/?/TRIM(LEFT(OCR_STR));
          END;  /* DO J */
       OCR_STR = 'X'?/?/TRIM(LEFT(OCR_STR));
       /*--------------------------------------------------------*/
       /* MODIFIED THE LENGTHS TO SUPPORT LONG VAR NAMES         */
       /* MARC HOWELL                                            */
       /*--------------------------------------------------------*/
       /* ORIGINAL--                                             */
       /*                                                        */
       /* IF LENGTH(TEMPNAME) GT 3 THEN DO;                      */
       /*    NEWNAME = SUBSTR(TEMPNAME,LENGTH(TEMPNAME) - 3, 4); */
       /*    NEWNAME = TRIM(LEFT(OCR_STR))?/?/TRIM(LEFT(NEWNAME)); */
       /*    END;  /8 IF LENGTH(TEMPNAME) GT 3 8/                */
       /* ELSE DO;                                               */
       /*--------------------------------------------------------*/
       IF LENGTH(TEMPNAME) GT 25 THEN DO;
          NEWNAME = SUBSTR(TEMPNAME,LENGTH(TEMPNAME) - 24, 25);
          NEWNAME = TRIM(LEFT(OCR_STR))?/?/TRIM(LEFT(NEWNAME));
          END;  /* IF LENGTH(TEMPNAME) GT 27 */
       ELSE DO;
          NEWNAME = TRIM(LEFT(OCR_STR))?/?/TRIM(LEFT(TEMPNAME));
          END;  /* ELSE DO */
       END; /* ELSE IF TEMP_OCR LE 999 */
    ELSE DO;
       /* NOTHING */
       END;  /* ELSE DO */
 RETURN;  /* FROM FIXNAME */

 RUN;  /* DATA EXPAND */

 /*--------------------------------------------------------------*/
 /* COMMENTED OUT THE PROC SORT IN ORDER TO LEAVE THE VARIABLES  */
 /* IN THE ORDER ENCOUNTERED IN THE COPYBOOK - MARC HOWELL       */
 /*--------------------------------------------------------------*/
 * PROC SORT DATA=DICTNRY OUT=DICTNRY;
 *    BY FILENAME ATBYTE;

 /*----------------------------------------------------------*/
 /* REMOVE THE DUPLICATE NAMES THAT WERE CREATED AS A RESULT */
 /* OF THE EXPANSION - MARC HOWELL                           */
 /*----------------------------------------------------------*/
 DATA ORIG;
   SET DICTNRY;
   ORDER=_N_;
 RUN;

 /*----------------------------------------------------------*/
 /* CHANGED SORT FROM FILENAME TO FILENAME AND NEWNAME SO THE*/
 /* DUPLICATES ARE FROM WITHIN EACH FD.       RHA-04/15/2014 */
 /*----------------------------------------------------------*/
 PROC SORT DATA=ORIG OUT=DUPS;
   BY FILENAME NEWNAME;
 RUN;
 /*----------------------------------------------------------*/
 /* MODIFIED TO EXCLUDE 'FILLER' FROM RENAMES - MARC HOWELL  */
 /*----------------------------------------------------------*/
 /*----------------------------------------------------------*/
 /* FIXED RENAME TECHNIQUE FOR DUPLICATE ENTRIES AND TO BE   */
 /* ONLY FOR WITHIN THE FD.                   RHA-04/15/2014 */
 /*----------------------------------------------------------*/
  DATA DUPS(DROP=COUNT);
   IF _N_=1 THEN COUNT=1;
   SET DUPS;
   BY FILENAME NEWNAME;                  /* RHA-04/15/2014  */
   IF FIRST.NEWNAME AND LAST.NEWNAME THEN DELETE;
   IF NEWNAME = 'FILLER' THEN DO;
     * NOTHING ;
   END;
   ELSE DO;
   IF FIRST.NEWNAME THEN COUNT=1;
      NEWNAME=COMPRESS(SUBSTR(NEWNAME,1,26)||'-R'||
              PUT(COUNT,Z3.));          /* RHA-04/15/2014   */
   COUNT+1;
   END;
 RUN;

 PROC SORT DATA=DUPS;
 BY ORDER;
 RUN;

 DATA DICTNRY(DROP=ORDER);
   MERGE ORIG DUPS;
   BY ORDER;
 RUN;
 /*----------------------------------------------------------*/

 /* THE NOCHARCODE OPTION IS SET SO THAT STRINGS LIKE, '?)', ARE */
 /* NOT MISINTERPRETED.                                          */
 OPTIONS NOCHARCODE;
 RUN;  /* PROGRAM R2COB5 */
