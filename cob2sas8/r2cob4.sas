 /****************************************************************/
 /*                                                              */
 /*    NAME: R2COB4                                              */
 /*   TITLE: PROGRAM 'R2COB4', A PART OF 'COB2SAS, RELEASE 2'    */
 /* PRODUCT: SAS                                                 */
 /*  SYSTEM: CMS MVS                                             */
 /*    DATA: COB2SAS, RELEASE 2                                  */
 /*                                                              */
 /*  AUTHOR: GREG HESTER                                         */
 /* SUPPORT: TOM ZACK                    UPDATE: 22JUL90         */
 /*     REF: COB2SAS, RELEASE 2 DOCUMENTATION                    */
 /*    MISC: WHEN USING, INVOKE SAS WITH THE SYSTEM OPTIONS:     */
 /*                      'DQUOTE MACRO'                          */
 /*                                                              */
 /* PURPOSE: THIS ROUTINE CONVERTS COBOL DATA NAMES TO VALID     */
 /*          SAS LANGUAGE VARIABLE NAMES.                        */
 /*                                                              */
 /****************************************************************/

 /* THE CHARCODE OPTION IS SET SO THAT THE STRINGS, '?/?/',      */
 /* '?(', AND '?)' ARE PROPERLY INTERPRETED.                     */
 OPTIONS CHARCODE;


 /****************************************************************/
 /* READ IN THE OUTPUT FILE CREATED BY COB2.                     */
 /****************************************************************/
 DATA NAMES;
    SET DICTNRY;
    __RECNO + 1;
    KEEP FILENAME LEVEL NST_DPTH DATANAME USAGE PICTURE INFMT
         OCR_BASE ITM_DISP ATBYTE BYTES OCR_VAL RDF_NAME __RECNO;
 RUN;  /* DATA NAMES */

 /****************************************************************/
 /* CONVERT A COBOL-LIKE DATA DESCRIPTOR TO 8 CHARS OR LESS.     */
 /****************************************************************/
 DATA NEWNAMES;
    SET NAMES;
    KEEP FILENAME LEVEL NST_DPTH DATANAME NEWNAME USAGE PICTURE
         INFMT OCR_BASE ITM_DISP ATBYTE BYTES OCR_VAL RDF_NAME
         __RECNO;

    LENGTH TEMPNAME $30 NEWNAME $8;

    /* THE CHARCODE OPTION IS SET SO THAT THE STRINGS, '?/?/',   */
    /* '?(', AND '?)' ARE PROPERLY INTERPRETED.                  */

    /* DO NOT ALTER 'FILLER'.                                    */
    IF DATANAME = 'FILLER' THEN DO;
       NEWNAME = 'FILLER';
       RETURN;
    END;  /* IF DATANAME = 'FILLER' */

    TEMPNAME=TRANSLATE(DATANAME,'_','-');
    LEN=LENGTH(TEMPNAME);
    IF LEN <=8 THEN DO;
       NEWNAME=TEMPNAME;
       RETURN;
       END;
    ELSE DO;
       LINK CNT_UND;
       IF UND=0 THEN LINK NO_UND;
       ELSE LINK UND;
       END;
 RETURN;

 /* PROCESS NAMES THAT HAVE NO DASHES                            */
 NO_UND:
       PIECE=TEMPNAME;
       LINK VOW_STRP;
       LEN=LENGTH(PIECE);
       IF LEN <=8 THEN DO;
          NEWNAME=PIECE;
          RETURN;
          END;

       /*   IF NAME HAS LEN 9 OR 10 GET RID OF MIDDLE 2 CHARS    */
       IF LEN=9 THEN
          NEWNAME=TRIM(SUBSTR(PIECE,1,4))?/?/SUBSTR(PIECE,6,4);
       ELSE IF LEN=10 THEN
          NEWNAME=TRIM(SUBSTR(PIECE,1,4))?/?/SUBSTR(PIECE,7,4);
       ELSE DO;
          MID=INT(LEN/2);
          NEWNAME=TRIM(SUBSTR(PIECE,1,2))?/?/
                  TRIM(SUBSTR(PIECE,MID-1,2))?/?/
                  TRIM(SUBSTR(PIECE,MID+1,2))?/?/
                  SUBSTR(PIECE,LEN-1,2);
          END;
       RETURN;

 /* PROCESS NAMES THAT HAVE ONE OR MORE DASHES                   */
 UND:
       /* DETERMINE IF STRIPING THE UNDERSCORES WOULD FIX IT     */
       IF (LEN-UND) <= 8 THEN DO;
          NEWNAME=COMPRESS(TEMPNAME,'_');
          RETURN;
          END;

       /* TAKE VOWELS OUT OF EACH PIECE                          */
       DO I=1 TO UND+1;
         PIECE=SCAN(TEMPNAME,I,'_');
         LINK VOW_STRP;
         IF I=1 THEN  TNAME=PIECE;
         ELSE TNAME=TRIM(TNAME)?/?/'_'?/?/PIECE;
         END;

       /* IF LESS THAN 8 THEN RETURN                             */
       LEN=LENGTH(TNAME);
       IF LEN <= 8 THEN DO;
          NEWNAME=TNAME;
          RETURN;
          END;

       /* DETERMINE IF STRIPING THE UNDERSCORES WILL FIX IT      */
       IF (LEN-UND) <= 8 THEN DO;
          NEWNAME=COMPRESS(TNAME,'_');
          RETURN;
          END;

       /* OTHERWISE, SUBSTR BASED ON NUMBER OF UNDERSCORES       */
       /*   ALSO, GET RID OF UNDERSCORES                         */

       IF UND=1 THEN DO;
          PIECE1=SCAN(TNAME,1,'_');
          PIECE2=SCAN(TNAME,2,'_');
          IF LENGTH(PIECE1) > 4 THEN
             PIECE1=SUBSTR(PIECE1,1,4);
          IF LENGTH(PIECE2) > 4 THEN
             PIECE2=TRIM(SUBSTR(PIECE2,1,2))?/?/
                    SUBSTR(PIECE2,LENGTH(PIECE2)-1,2);
          NEWNAME=TRIM(PIECE1)?/?/PIECE2;
          END;
       ELSE IF UND = 2 THEN DO;
          PIECE1=SCAN(TNAME,1,'_');
          PIECE2=SCAN(TNAME,2,'_');
          PIECE3=SCAN(TNAME,3,'_');
          IF LENGTH(PIECE1) > 3 THEN
             PIECE1=SUBSTR(PIECE1,1,3);
          IF LENGTH(PIECE2) > 2 THEN
             PIECE2=SUBSTR(PIECE2,1,2);
          IF LENGTH(PIECE3) > 3 THEN
             PIECE3=TRIM(SUBSTR(PIECE3,1,1))?/?/
                    SUBSTR(PIECE3,LENGTH(PIECE3)-1,2);
          NEWNAME=TRIM(PIECE1)?/?/TRIM(PIECE2)?/?/PIECE3;
          END;
       ELSE IF UND = 3 THEN DO;
          PIECE1=SCAN(TNAME,1,'_');
          PIECE2=SCAN(TNAME,2,'_');
          PIECE3=SCAN(TNAME,3,'_');
          PIECE4=SCAN(TNAME,4,'_');
          IF LENGTH(PIECE1) > 2 THEN
             PIECE1=SUBSTR(PIECE1,1,2);
          IF LENGTH(PIECE2) > 2 THEN
             PIECE2=TRIM(SUBSTR(PIECE2,1,2));
          IF LENGTH(PIECE3) > 2 THEN
             PIECE3=SUBSTR(PIECE3,1,2);
          IF LENGTH(PIECE4) > 2 THEN
             PIECE4=SUBSTR(PIECE4,LENGTH(PIECE4)-1,2);
          NEWNAME=TRIM(PIECE1)?/?/TRIM(PIECE2)?/?/
                  TRIM(PIECE3)?/?/PIECE4;
          END;
       ELSE IF UND >= 4 THEN DO;
          PIECE1=SCAN(TNAME,1,'_');
          PIECE2=SCAN(TNAME,UND+1,'_');
          IF LENGTH(PIECE1) > 4 THEN
             PIECE1=SUBSTR(PIECE1,1,4);
          IF LENGTH(PIECE2) > 4 THEN
             PIECE2=TRIM(SUBSTR(PIECE2,1,2))?/?/
                    SUBSTR(PIECE2,LENGTH(PIECE2)-1,2);
          NEWNAME=TRIM(PIECE1)?/?/PIECE2;
          END;
       RETURN;

 /* COUNT THE NUMBER OF UNDERSCORES IN THE NAME IF ANY           */
 CNT_UND:
       /* COUNT THE NUMBER OF UNDERSCORES                        */
       UND=0;
       DO I=1 TO LEN;
          IF SUBSTR(TEMPNAME,I,1)='_' THEN UND+1;
       END;
       RETURN;

 /* STRIP OUT ALL OF THE VOWELS FROM A PIECE.    HOWEVER, IF A   */
 /* VOWEL APPEARS IN POSITION 1, DO NOT GET RID OF IT.           */
 VOW_STRP:
      PLEN=LENGTH(PIECE);
      IF PLEN > 1 THEN DO;
         TPIECE=COMPRESS(SUBSTR(PIECE,2,PLEN-1),'AEIOU');
         PIECE=TRIM(SUBSTR(PIECE,1,1))?/?/TRIM(TPIECE);
         END;
      RETURN;
 RUN;  /* DATA NEWNAMES */

 /****************************************************************/
 /* INSURE THAT NONE OF THE NEWNAMES ARE DUPLICATES.             */
 /****************************************************************/
 PROC SORT DATA=NEWNAMES;
    BY NEWNAME;
 RUN;  /* PROC SORT DATA=NEWNAMES */

 DATA NODUP;
    KEEP FILENAME LEVEL NST_DPTH DATANAME NEWNAME USAGE PICTURE
         INFMT OCR_BASE ITM_DISP ATBYTE BYTES OCR_VAL RDF_NAME
         __RECNO;
    SET NEWNAMES;
       BY NEWNAME;

    /* DO NOT ALTER 'FILLER'.                                    */
    IF NEWNAME = 'FILLER' THEN
       RETURN;

    LIST=REVERSE('_ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    IF FIRST.NEWNAME AND LAST.NEWNAME THEN DO;
       I=1;
       RETURN;
       END;
    ELSE DO;
       IF LENGTH(NEWNAME) < 8 THEN
          REP=LENGTH(NEWNAME)+1;
       ELSE
          REP=6;

       IF FIRST.NEWNAME THEN
          I = 1;
       SUBSTR(NEWNAME,REP,1)=SUBSTR(LIST,I,1);
       IF I LT 27 THEN
          I+1;
       END;
 RUN;  /* DATA NODUP */

 PROC SORT DATA=NODUP OUT=DICTNRY;
    BY __RECNO;
 RUN;  /* PROC SORT DATA=NODUP */

 /* THE NOCHARCODE OPTION IS SET SO THAT STRINGS LIKE, '?)', ARE */
 /* NOT MISINTERPRETED.                                          */
 OPTIONS NOCHARCODE;
 RUN;  /* PROGRAM R2COB4 */
