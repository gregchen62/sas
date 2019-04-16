 /****************************************************************/
 /* NEW VERSION OF R2COB2                                        */
 /****************************************************************/
 /*                                                              */
 /*    NAME: R2COB2                                              */
 /*   TITLE: PROGRAM 'R2COB2', A PART OF 'COB2SAS, RELEASE 2'    */
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

 /*                                                              */
 /* NOTE: THE FOLLOWING ARE NOT YET IMPLEMENTED.                 */
 /*                                                              */
 /* 1) DOES NOT YET USE THE CONTINUE FLAG. HOWEVER IT DOES       */
 /*    APPROPRIATELY ASSIGN VALUES TO THE CONTINUE FLAG.         */
 /*                                                              */
 /* 2) DOES NOT YET PARSE PSEUDO-TEXT IN COPY STATEMENTS.        */
 /*                                                              */
 /* 3) DOES NOT HANDLE OCCURRENCES OF THE OPERATIONAL CHARACTER  */
 /*    P IN PICTURE STRINGS.                                     */
 /*                                                              */

 /* THE CHARCODE OPTION IS SET SO THAT THE STRINGS, '?/?/',      */
 /* '?(', AND '?)' ARE PROPERLY INTERPRETED.                     */
 OPTIONS CHARCODE;

 DATA
    DICTNRY(KEEP=D_GRPID FILENAME LEVEL NST_DPTH DATANAME USAGE
                 PICTURE INFMT OCR_BASE ITM_DISP ATBYTE BYTES
                 OCR_VAL RDF_NAME)

    GROUP(KEEP=G_GRPID G_LVL G_NST G_NAM G_TYP G_AT G_LEN
               G_OCR G_RDF);
    /*                                                           */
    /* THE CHARCODE OPTION IS SET SO THAT THE STRINGS, '?/?/',   */
    /* '?(', AND '?)' ARE PROPERLY INTERPRETED.                  */

    /*                                                           */
    /*   DECLARATION OF SOME OF THE VARIABLES.                   */
    /*                                                           */

    /* DIVISION AND PREVIOUS DIVISION                            */
    LENGTH DIVISION $30 PREV_DIV $30;
    RETAIN DIVISION 'UNDEFINED' PREV_DIV 'UNDEFINED';

    /* SECTION AND PREVIOUS SECTION                              */
    LENGTH SECTION $30 PREVSCTN $30;
    RETAIN SECTION 'UNDEFINED' PREVSCTN 'UNDEFINED';

    /* ENTRY TYPE AND PREVIOUS ENTRY TYPE                        */
    LENGTH NTRYTYPE $30 PREVTYPE $30;
    RETAIN NTRYTYPE 'UNDEFINED' PREVTYPE 'UNDEFINED';

    /* FIRST TOKEN IS GIVEN VALUES FORMATTED WITH $DDICFMT.      */
    LENGTH FIRSTOKE $18;

    /* PARSE MODE                                                */
    LENGTH PRS_MODE $8;
    RETAIN PRS_MODE 'IDN_CLS';

    /* CLAUSE MODE                                               */
    LENGTH CLS_MODE $18;
    RETAIN CLS_MODE 'SIMPLE_CLAUSE';

    /* TOKEN ID IS GIVEN VALUES FORMATTED WITH $DDTFMT.          */
    LENGTH TKN_ID $8;

    /* TOKEN VECTOR                                              */
    LENGTH TKN_VCTR $200;
    RETAIN TKN_VCTR ' ';

    /* CLAUSE ID IS GIVEN VALUES FORMATTED WITH $DDCFMT.         */
    LENGTH CLS_ID $30;

    /* ATTRIBUTE VECTOR SUM                                      */
    LENGTH AV_SUM 8;
    RETAIN AV_SUM 0;

    /* DATA DESCRIPTION ATTRIBUTES IS GIVEN A VALUE BY           */
    /* FORMATTING AV_SUM WITH DDAVFMT                            */
    LENGTH DD_ATTRS $42;

    /* CLAUSE STRING USED TO HOLD THE CURRENT CLAUSE.            */
    LENGTH CLS_STR $200;
    RETAIN CLS_STR ' ';

    /* FILE DESCRIPTION FOUND                                    */
    RETAIN FD_FND 0;

    /* INTEGER PART, FRACTIONAL PART OF PICTURE VALUES           */
    /* WIDTH, DECIMAL USED IN INFORMATS                          */
    RETAIN INT 0 FRACT 0;
    LENGTH WIDTH $12 DECIMAL $12;

    /* BLANK WHEN ZERO FLAG                                      */
    LENGTH BWZ_FLAG $1;
    RETAIN BWZ_FLAG 'N';

    /* FILE NAME                                                 */
    LENGTH FILENAME $30;
    RETAIN FILENAME ' ';

    /* LEVEL NUMBER, LEVEL NESTING DEPTH                         */
    LENGTH LEVEL $2  NST_DPTH $2;
    RETAIN LEVEL ' ' NST_DPTH ' ';

    /* DATA NAME, USAGE, PICTURE                                 */
    LENGTH DATANAME $30  USAGE $8  PICTURE $18;
    RETAIN DATANAME ' '  USAGE ' ' PICTURE ' ';

    /* OCCURS BASE, ITEM DISPLACEMENT                            */
    LENGTH OCR_BASE 8  ITM_DISP 8;
    RETAIN OCR_BASE 1  ITM_DISP 0;

    /* INFORMAT                                                  */
    LENGTH INFMT $30;
    RETAIN INFMT ' ';

    /* ATBYTE, BYTES                                             */
    LENGTH ATBYTE 8  BYTES 8;
    RETAIN ATBYTE 0  BYTES 0;

    /* OCCURS VALUE, REDEFINES NAME                              */
    LENGTH OCR_VAL $8  RDF_NAME $30;
    RETAIN OCR_VAL ' ' RDF_NAME ' ';

    /* LEVEL, LAST LEVEL                                         */
    RETAIN LVL 0 LASTLVL 0;

    /* VARIABLES USED TO TRACK USAGE AND DEPTH OF LEVEL NESTING. */
    /*                                                           */
    /* USAGE-STACK INDEX, USAGE-STACK LEVEL, USAGE-STACK USAGE   */
    /*                                                           */
    /* NOTE: THE VARIABLE UK_NDX IS USED TO TRACK THE DEPTH      */
    /*       OF LEVEL NESTING.                                   */
    /*                                                           */
    RETAIN UK_NDX 0;
    RETAIN UK_LVL1-UK_LVL49;
    RETAIN UK_USG1-UK_USG49;
    ARRAY UK_LVL?(49?)     UK_LVL1-UK_LVL49;
    ARRAY UK_USG?(49?) $12 UK_USG1-UK_USG49;

    /* VARIABLES USED TO TRACK GROUPS.                           */
    /*                                                           */
    /* GROUP ID, DICTNRY-GROUP ID, GROUP-GROUP ID                */
    /*                                                           */
    RETAIN GRPID 1 D_GRPID 0 G_GRPID 0;

    /* GROUP-STACK INDEX, GROUP-STACK ID, GROUP-STACK LEVEL      */
    /* GROUP-STACK NESTING DEPTH, GROUP-STACK DATA NAME,         */
    /* GROUP-STACK GROUP TYPE, GROUP-STACK AT BYTE,              */
    /* GROUP-STACK GROUP LENGTH, GROUP-STACK OCCURS VALUE,       */
    /* GROUP-STACK REDEFINES NAME                                */
    /*                                                           */
    RETAIN GK_NDX 0;
    RETAIN GK_ID1-GK_ID49;
    RETAIN GK_LVL1-GK_LVL49;
    RETAIN GK_NST1-GK_NST49;
    RETAIN GK_NAM1-GK_NAM49;
    RETAIN GK_TYP1-GK_TYP49;
    RETAIN GK_AT1-GK_AT49;
    RETAIN GK_LEN1-GK_LEN49;
    RETAIN GK_OCR1-GK_OCR49;
    RETAIN GK_RDF1-GK_RDF49;
    ARRAY GK_ID?(49?)      GK_ID1-GK_ID49;
    ARRAY GK_LVL?(49?)     GK_LVL1-GK_LVL49;
    ARRAY GK_NST?(49?)     GK_NST1-GK_NST49;
    ARRAY GK_NAM?(49?) $30 GK_NAM1-GK_NAM49;
    ARRAY GK_TYP?(49?) $9  GK_TYP1-GK_TYP49;
    ARRAY GK_AT?(49?)      GK_AT1-GK_AT49;
    ARRAY GK_LEN?(49?)     GK_LEN1-GK_LEN49;
    ARRAY GK_OCR?(49?) $8  GK_OCR1-GK_OCR49;
    ARRAY GK_RDF?(49?) $30 GK_RDF1-GK_RDF49;

    /* GROUP-DATASET LEVEL, GROUP-DATASET NESTING DEPTH,         */
    /* GROUP-DATASET DATA NAME, GROUP-DATASET GROUP TYPE,        */
    /* GROUP-DATASET AT BYTE, GROUP-DATASET GROUP LENGTH,        */
    /* GROUP-DATASET OCCURS VALUE, GROUP-DATASET REDEFINES NAME  */
    /*                                                           */
    LENGTH G_LVL 8;
    LENGTH G_NST 8;
    LENGTH G_NAM $30;
    LENGTH G_TYP $9;
    LENGTH G_AT 8;
    LENGTH G_LEN 8;
    LENGTH G_OCR $8;
    LENGTH G_RDF $30;

    /* GROUP TYPE                                                */
    LENGTH GRP_TYPE $9;

    /* VARIABLES USED TO KEEP TRACK OF THE BEGINNING BYTE OF     */
    /* REDEFINED ITEMS.                                          */
    /*                                                           */
    /* REDEFINES-STACK INDEX, REDEFINES-STACK LEVEL,             */
    /* REDEFINES-STACK AT BYTE, REDEFINES-STACK DISPLACEMENT     */
    /* REDEFINES-STACK GROUP TYPE, REDEFINES-STACK GROUP LENGTH  */
    /* REDEFINES-STACK REDEFINES NAME                            */
    /*                                                           */
    RETAIN RK_NDX 0;
    RETAIN RK_LVL1-RK_LVL49;
    RETAIN RK_AT1-RK_AT49;
    RETAIN RK_DSP1-RK_DSP49;
    RETAIN RK_TYP1-RK_TYP49;
    RETAIN RK_LEN1-RK_LEN49;
    RETAIN RK_RNM1-RK_RNM49;
    ARRAY RK_LVL?(49?)     RK_LVL1-RK_LVL49;
    ARRAY RK_AT?(49?)      RK_AT1-RK_AT49;
    ARRAY RK_DSP?(49?)     RK_DSP1-RK_DSP49;
    ARRAY RK_TYP?(49?) $9  RK_TYP1-RK_TYP49;
    ARRAY RK_LEN?(49?)     RK_LEN1-RK_LEN49;
    ARRAY RK_RNM?(49?) $30 RK_RNM1-RK_RNM49;

    /* VARIABLES USED TO TRACK DISPLACEMENTS OF ITEMS WITHIN     */
    /* GROUPS.                                                   */
    /*                                                           */
    /* OFFSET-STACK INDEX, OFFSET-STACK LEVEL                    */
    /* OFFSET-STACK BASE, OFFSET-STACK DISPLACEMENT              */
    /* OFFSET-STACK LENGTH                                       */
    /*                                                           */
    RETAIN OK_NDX 0;
    RETAIN OK_LVL1-OK_LVL49;
    RETAIN OK_BSE1-OK_BSE49;
    RETAIN OK_DSP1-OK_DSP49;
    RETAIN OK_LEN1-OK_LEN49;
    ARRAY OK_LVL?(49?)     OK_LVL1-OK_LVL49;
    ARRAY OK_BSE?(49?)     OK_BSE1-OK_BSE49;
    ARRAY OK_DSP?(49?)     OK_DSP1-OK_DSP49;
    ARRAY OK_LEN?(49?)     OK_LEN1-OK_LEN49;

    /* NEXT LINE AND TEMP LINE ARE USED TO IMPLEMENT THE LOOK    */
    /* AHEAD BUFFER.                                             */
    LENGTH NXT_LINE $72 TMP_LINE $72;
    RETAIN NXT_LINE;

    /* SINCE A LOOK AHEAD BUFFER IS IMPLEMENTED, THE VARIABLE    */
    /* 'EOF', WHICH IS ASSIGNED VALUES VIA THE END= OPTION OF    */
    /* THE INFILE STATEMENT, EQUALS 1 TWICE. ON THE OTHER HAND,  */
    /* TRUE_EOF EQUALS 1 ONLY ONCE.                              */
    RETAIN TRUE_EOF -1;

    /* BLANK IS USED AS A DELIMITER IN THE SCAN FUNCTION.        */
    RETAIN BLANK ' ';

    /* A_LINE, A_WORD AND PREVWORD ARE USED WHILE PARSING.       */
    LENGTH A_LINE $72 A_WORD $30 PREVWORD $30;

    /* TRACE PARSE, TRACE STACK, ATTR_ERR, SEVERAL               */
    LENGTH TRACEPRS $1 TRACESTK $1 ATTR_ERR $1 SEVERAL $1;
    RETAIN TRACEPRS TRACESTK ATTR_ERR SEVERAL;

    /* GET VALUES FOR TRACEPRS, TRACESTK AND SEVERAL.            */
    IF _N_ = 1 THEN DO;
       SET SWITCHES;
       END;  /* IF _N_ = 1 */

    /*                                                           */
    /*   GET ONE LINE FROM THE INPUT FILE AND IMPLEMENT A 'LOOK  */
    /* AHEAD' BUFFER IN ORDER TO INSPECT COLUMN 7 OF THE NEXT    */
    /* LINE FOR A CONTINUATION INDICATOR.                        */
    /*                                                           */
    /*    WHEN AN INPUT STATEMENT ENDS WITH AN @, THE CURRENT    */
    /* LINE FROM THE INPUT FILE IS HELD IN THE INPUT BUFFER      */
    /* DURING THE CURRENT ITERATION OF THE DATA STEP.            */
    /*    IF ALL INPUT STATEMENTS END WITH AN @, THE CURRENT     */
    /* LINE IS RELEASED AT THE START OF THE NEXT ITERATION OF    */
    /* THE DATA STEP, MAKING THE NEXT LINE AVAILABLE FOR INPUT.  */
    /* ON THE OTHER HAND, IF AN INPUT STATEMENT THAT DOES NOT    */
    /* END WITH AN @ IS EXECUTED WITHIN THE CURRENT ITERATION    */
    /* OF THE DATA STEP, THEN THE NEXT LINE IS AVAILABLE FOR     */
    /* INPUT AT THAT TIME.                                       */
    /*    WHEN AN INPUT STATEMENT ENDS WITH AN @@, THE CURRENT   */
    /* LINE FROM THE INPUT FILE IS HELD IN THE INPUT BUFFER      */
    /* THROUGH SUCCESSIVE ITERATIONS OF THE DATA STEP. THE NEXT  */
    /* LINE IS AVAILABLE FOR INPUT EITHER WHEN READING PASSED    */
    /* THE END OF THE INPUT BUFFER OR WHEN AN INPUT STATEMENT    */
    /* ENDING WITH NEITHER AN @ NOR AN @@ IS EXECUTED.           */
    /*                                                           */
    &INFILE;

    CONTINUE = 0;
    INPUT @1 TMP_LINE $CHAR72. @;
    IF NOT EOF THEN DO;
       IF _N_ = 1 THEN DO;
          INPUT;
          INPUT @1 NXT_LINE $CHAR72. @@;
          /* INSPECT THE NEXT LINE FOR CONTINUATION INDICATOR.   */
          INDICATR = SUBSTR(NXT_LINE,7,1);
          INDICATR = TRIM(LEFT(INDICATR));
          INDICATR = UPCASE(INDICATR);
          IF INDICATR = '-' THEN
             CONTINUE = 1;
          END;  /* IF _N_ = 1 */
       ELSE DO;
          TMP_LINE = NXT_LINE;
          INPUT;
          INPUT @1 NXT_LINE $CHAR72. @@;
          /* INSPECT THE NEXT LINE FOR CONTINUATION INDICATOR.   */
          INDICATR = SUBSTR(NXT_LINE,7,1);
          INDICATR = TRIM(LEFT(INDICATR));
          INDICATR = UPCASE(INDICATR);
          IF INDICATR = '-' THEN
             CONTINUE = 1;
          END;  /* ELSE DO */
       END;

    /* TRUE_EOF EQUALS 1 WHEN THE LAST LINE OF THE INPUT FILE    */
    /* HAS BEEN READ.                                            */
    IF EOF THEN
       TRUE_EOF = TRUE_EOF + 1;

    IF TRACEPRS = '9' THEN DO;
       IF _N_ = 1 THEN DO;
          PUT;
          PUT '&INFILE= ' "&INFILE";
          PUT '  &FILE= ' "&FILE";
          PUT;
          END;  /* IF _N_ = 1 */
       PUT;
       PUT @1 'RULE' @;
       PUT @6 '----+-IA---B--+----2----+----3----+----4----+' @;
       PUT @51 '----5----+----6----+----7--';
       PUT @1 'TMP=' @6 TMP_LINE $CHAR72.;
       PUT @1 'NXT=' @6 NXT_LINE $CHAR72.;
       PUT;
       PUT @3 CONTINUE= @17 EOF= @25 TRUE_EOF=;
       PUT;
       RETURN;  /* TO TOP OF DATA STEP */
       END;  /* IF TRACEPRS = '9' */

    /* SKIP BLANK LINES.                                         */
    IF TMP_LINE = ' ' THEN RETURN;  /* TO TOP OF DATA STEP */

    IF DIVISION NE 'UNDEFINED' THEN DO;
       /* INSPECT INDICATOR AREA.                                */
       INDICATR = SUBSTR(TMP_LINE,7,1);
       INDICATR = TRIM(LEFT(INDICATR));
       INDICATR = UPCASE(INDICATR);

       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN DO;
          IF INDICATR = '-' THEN DO;
             PUT @1 'CONTINUE' @23 '-' @;
             END;  /* IF INDICATR = '-' */
          ELSE IF (INDICATR = '*') OR (INDICATR = '/') THEN DO;
             A_LINE = SUBSTR(TMP_LINE,8,65);
             A_LINE = UPCASE(A_LINE);
             PUT @1 'COMMENT ' @23 INDICATR @24 A_LINE $CHAR54.;
             END;  /* IF (INDICATR = '*') OR (INDICATR = '/') */
          ELSE IF (INDICATR = 'D') THEN DO;
             A_LINE = SUBSTR(TMP_LINE,8,65);
             A_LINE = UPCASE(A_LINE);
             PUT @1 'DEBUG_LN' @23 INDICATR @24 A_LINE $CHAR54.;
             END;  /* IF (INDICATR = 'D') */
          END;  /* IF (TRACEPRS = '4') OR (TRACEPRS = '6') */

       /* SKIP LINES WITH ANYTHING EXCEPT A HYPHEN IN COLUMN 7.  */
       IF ((INDICATR NE ' ') AND (INDICATR NE '-')) THEN
          RETURN;  /* TO TOP OF DATA STEP */
       END;  /* IF DIVISION NE 'UNDEFINED' */

    A_LINE = SUBSTR(TMP_LINE,8,65);
    A_LINE = TRIM(LEFT(A_LINE));
    A_LINE = UPCASE(A_LINE);


    /*                                                           */
    /*   WHICH DIVISION IN THE PROGRAM ?                         */
    /*                                                           */
    IF INDEX(A_LINE,'IDENTIFICATION DIVISION') THEN DO;
       DIVISION = 'IDEN_DIV';
       END;
    ELSE IF INDEX(A_LINE,'ENVIRONMENT DIVISION') THEN DO;
       DIVISION = 'ENVR_DIV';
       END;
    ELSE IF INDEX(A_LINE,'DATA DIVISION') OR
            INDEX(A_LINE,'FILE SECTION') THEN DO;
       DIVISION = 'DATA_DIV';
       END;
    ELSE IF INDEX(A_LINE,'PROCEDURE DIVISION') THEN DO;
       /*                                                        */
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       /*                                                        */
       LINK EODDSCTN;

       /*                                                        */
       /*    IF YOU WISH TO PROCESS SEVERAL COBOL PROGRAMS,      */
       /* DO NOT STOP HERE.                                      */
       /*                                                        */
       IF SEVERAL = 'Y' THEN DO;
          AV_SUM = 0;
          CLS_STR = ' ';
          DIVISION = 'UNDEFINED';
          PREV_DIV = 'UNDEFINED';
          SECTION  = 'UNDEFINED';
          PREVSCTN = 'UNDEFINED';
          NTRYTYPE = 'UNDEFINED';
          PREVTYPE = 'UNDEFINED';
          END;  /* IF SEVERAL = 'Y' */
       ELSE DO;
          STOP;
          END;  /* ELSE DO */
       END;  /* ELSE IF 'PROCEDURE DIVISION' */

    IF DIVISION = 'UNDEFINED' THEN DO;
       /*                                                        */
       /* THE CHECKS DONE HERE ALLOW PROCESSING OF COPY MEMBERS. */
       /*                                                        */

       /*                                                        */
       /* WARNING:  ALTHOUGH IT IS UNLIKELY THAT THIS WOULD      */
       /*           HAPPEN, BE AWARE OF THE POSSIBILITY IN CASE  */
       /*           PROBLEMS ARISE.                              */
       /*                                                        */
       /*    IF YOU PROCESS SEVERAL COBOL PROGRAMS IN A SINGLE   */
       /* EXECUTION OF COB2SAS, YOU MAY NEED TO COMMENT OUT THIS */
       /* SECTION OF CODE SO THAT AN FD, 01, CD, RD, SD OR ANY   */
       /* TOKEN THAT INITIATES A CLAUSE IN A DATA DESCRIPTION    */
       /* ENTRY OCCURRING IN SOME DIVISION OTHER THAN THE DATA   */
       /* DIVISION DOES NOT SET PROCESSING AWRY.                 */
       /*                                                        */

       /*                                                        */
       /*    IGNORING LINES WITH ANYTHING IN COLUMN 7 ELIMINATES */
       /* THE POSSIBILITY OF JCL BEING TREATED AS A LEVEL 1.     */
       /*                                                        */
       INDICATR = SUBSTR(TMP_LINE,7,1);
       INDICATR = TRIM(LEFT(INDICATR));
       INDICATR = UPCASE(INDICATR);
       IF INDICATR NE ' ' THEN RETURN;  /* TO TOP OF DATA STEP */

       /*                                                        */
       /*   CHECK FOR 'FD', '01', 'CD', 'RD' OR 'SD' WITHIN      */
       /* COLUMNS 8 THROUGH 11.                                  */
       /*                                                        */
       LINK LVL_IN_A;
          /* RETURNS FD_IN_A, DD_IN_A,                           */
          /*         CD_IN_A, RD_IN_A AND SD_IN_A                */
       IF FD_IN_A OR DD_IN_A OR
          CD_IN_A OR RD_IN_A OR SD_IN_A THEN DO;
          DIVISION = 'DATA_DIV';
          PREV_DIV = 'DATA_DIV';
          END;

       IF FD_IN_A OR DD_IN_A OR SD_IN_A THEN DO;
          SECTION = 'FILE SECTION';
          PREVSCTN = 'FILE SECTION';
          END;
       ELSE IF CD_IN_A THEN DO;
          SECTION = 'COMMUNICATION SECTION';
          PREVSCTN = 'COMMUNICATION SECTION';
          END;
       ELSE IF RD_IN_A THEN DO;
          SECTION = 'REPORT SECTION';
          PREVSCTN = 'REPORT SECTION';
          END;
       /*                                                        */
       /*    IF NO 'FD', '01', 'CD', 'RD' OR 'SD' IS FOUND,      */
       /* CHECK THE FIRST TOKEN, WITHIN COLUMNS 8 THROUGH 72,    */
       /* TO DETERMINE IF IT INITIATES ANY CLAUSE IN A DATA      */
       /* DESCRIPTION ENTRY.                                     */
       /*                                                        */
       IF DIVISION = 'UNDEFINED' THEN DO;
          LINK COPY_MEM;  /* RETURNS CPY_MEM */
          IF CPY_MEM THEN DO;
             DIVISION = 'DATA_DIV';
             PREV_DIV = 'DATA_DIV';
             SECTION  = 'FILE SECTION';
             PREVSCTN = 'FILE SECTION';
             NTRYTYPE = 'IN_DD';
             PREVTYPE = 'IN_DD';
             END;  /* IF CPY_MEM */
          END;  /* IF DIVISION = 'UNDEFINED' */
       END;  /* IF DIVISION = 'UNDEFINED' */

    &FILE;
    SELECT (DIVISION);
    WHEN ('IDEN_DIV') DO;
       LINK IDEN_DIV;
       END;  /* WHEN 'IDEN_DIV' */
    WHEN ('ENVR_DIV') DO;
       LINK ENVR_DIV;
       END;  /* WHEN 'ENVR_DIV' */
    WHEN ('DATA_DIV') DO;
       LINK DATA_DIV;
       END;  /* WHEN DATA_DIV */
    WHEN ('UNDEFINED') DO;
       /* DO NOTHING */
       END;  /* WHEN UNDEFINED */
    END;  /* SELECT DIVISION */
 RETURN;  /* TO TOP OF DATA STEP */

 IDEN_DIV:
    /*                                                           */
    /* IDEN_DIV:                                                 */
    /*    IDENTIFICATION DIVISON                                 */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    AS LONG AS DIVISION HAS THE VALUE 'IDEN_DIV', THIS     */
    /* CODE IS INVOKED AFTER READING A LINE FROM THE INPUT FILE. */
    /* THE CURRENT ENTRY IN THE IDENTIFICATION DIVISION CAN BE   */
    /* EVALUATED HERE.                                           */
    /*                                                           */

    /* FINISH ANY PENDING PROCESSING.                            */
    IF PREV_DIV NE DIVISION THEN DO;
       /* IF MORE THAN 1 COBOL PROGRAM IS PROCESSED DURING A     */
       /* SINGLE EXECUTION OF COB2SAS, THE LAST DIVISION THAT    */
       /* COB2SAS WOULD PROCESS IS THE DATA DIVISION.            */
       /*                                                        */
       /* THE LAST STATEMENT IN THE DATA DIVISION SHOULD         */
       /* NOW BE PROCESSED.                                      */
       LINK EODDSCTN;

       PREV_DIV = DIVISION;
       AV_SUM = 0;
       CLS_STR = ' ';
       SECTION  = 'UNDEFINED';
       PREVSCTN = 'UNDEFINED';
       NTRYTYPE = 'UNDEFINED';
       PREVTYPE = 'UNDEFINED';
       END;  /* IF PREV_DIV NE DIVISION */

    IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN DO;
       PUT @1 'IDEN_DIV' @24 A_LINE $CHAR54.;
       END;  /* IF (TRACEPRS = '4') OR (TRACEPRS = '6') */
 RETURN;  /* FROM IDEN_DIV */

 ENVR_DIV:
    /*                                                           */
    /* ENVR_DIV:                                                 */
    /*    ENVIRONMENT DIVISION                                   */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    AS LONG AS DIVISION HAS THE VALUE 'ENVR_DIV', THIS     */
    /* CODE IS INVOKED AFTER READING A LINE FROM THE INPUT FILE. */
    /* THE CURRENT ENTRY IN THE ENVIRONMENT DIVISION CAN BE      */
    /* EVALUATED HERE.                                           */
    /*                                                           */

    /* FINISH ANY PENDING PROCESSING.                            */
    IF PREV_DIV NE DIVISION THEN DO;
       /* THE LAST STATEMENT IN THE IDENTIFICATION DIVISION      */
       /* SHOULD NOW BE PROCESSED.                               */

       PREV_DIV = DIVISION;
       AV_SUM = 0;
       CLS_STR = ' ';
       SECTION  = 'UNDEFINED';
       PREVSCTN = 'UNDEFINED';
       NTRYTYPE = 'UNDEFINED';
       PREVTYPE = 'UNDEFINED';
       END;  /* IF PREV_DIV NE DIVISION */

    IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN DO;
       PUT @1 'ENVR_DIV' @24 A_LINE $CHAR54.;
       END;  /* IF (TRACEPRS = '4') OR (TRACEPRS = '6') */
 RETURN;  /* FROM ENVR_DIV */

 DATA_DIV:
    /*                                                           */
    /* DATA_DIV:                                                 */
    /*    DATA DIVISION                                          */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    AS LONG AS DIVISION HAS THE VALUE 'DATA_DIV', THIS     */
    /* CODE IS INVOKED AFTER READING A LINE FROM THE INPUT FILE. */
    /* THE CURRENT ENTRY IN THE DATA DIVISION IS EVALUATED HERE. */
    /*                                                           */

    /* FINISH ANY PENDING PROCESSING.                            */
    IF PREV_DIV NE DIVISION THEN DO;
       /* THE LAST STATEMENT IN THE ENVIRONMENT DIVISION         */
       /* SHOULD NOW BE PROCESSED.                               */

       PREV_DIV = DIVISION;
       AV_SUM = 0;
       CLS_STR = ' ';
       SECTION  = 'UNDEFINED';
       PREVSCTN = 'UNDEFINED';
       NTRYTYPE = 'UNDEFINED';
       PREVTYPE = 'UNDEFINED';
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN DO;
          PUT @1 'DATA_DIV' @24 A_LINE $CHAR54.;
          END;  /* IF (TRACEPRS = '4') OR (TRACEPRS = '6') */
       END;  /* IF PREV_DIV NE DIVISION */

    IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN DO;
       IF (TRACEPRS = '6') AND (NTRYTYPE = 'IN_DD') THEN
          PUT;
       PUT @1 'DATA_DIV' @24 A_LINE $CHAR54. @;
       END;  /* IF (TRACEPRS = '4') OR (TRACEPRS = '6') */

    /*                                                           */
    /*   WHICH SECTION WITHIN THE DATA DIVISION ?                */
    /*                                                           */
    IF INDEX(A_LINE,'FILE SECTION') THEN DO;
       /* FINISH ANY PENDING PROCESSING.                         */
       /*                                                        */
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       SECTION = 'FILE SECTION';
       END;  /* IF 'WORKING-STORAGE SECTION' */
    ELSE IF INDEX(A_LINE,'WORKING-STORAGE SECTION') THEN DO;
       /* FINISH ANY PENDING PROCESSING.                         */
       /*                                                        */
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       SECTION = 'WORKING-STORAGE SECTION';
       END;  /* ELSE IF 'WORKING-STORAGE SECTION' */
    ELSE IF INDEX(A_LINE,'LINKAGE SECTION') THEN DO;
       /* FINISH ANY PENDING PROCESSING.                         */
       /*                                                        */
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       SECTION = 'LINKAGE SECTION';
       END;  /* ELSE IF 'LINKAGE SECTION' */
    ELSE IF INDEX(A_LINE,'COMMUNICATION SECTION') THEN DO;
       /* FINISH ANY PENDING PROCESSING.                         */
       /*                                                        */
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       SECTION = 'COMMUNICATION SECTION';
       END;  /* ELSE IF 'COMMUNICATION SECTION' */
    ELSE IF INDEX(A_LINE,'REPORT SECTION') THEN DO;
       /* FINISH ANY PENDING PROCESSING.                         */
       /*                                                        */
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       SECTION = 'REPORT SECTION';
       END;  /* ELSE IF 'REPORT SECTION' */
    ELSE IF INDEX(A_LINE,'SCREEN SECTION') THEN DO;
       /* FINISH ANY PENDING PROCESSING.                         */
       /*                                                        */
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       SECTION = 'SCREEN SECTION';
       END;  /* ELSE IF 'SCREEN SECTION' */

    SELECT (SECTION);
    WHEN ('FILE SECTION') DO;
       LINK FILESCTN;
       END;  /* WHEN FILE SECTION */
    WHEN ('WORKING-STORAGE SECTION') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT @11 'IN_WS';
       * LINK WRKGSCTN;
       END;  /* WHEN WORKING-STORAGE SECTION */
    WHEN ('LINKAGE SECTION') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT @11 'IN_LS';
       * LINK LNKGSCTN;
       END;  /* WHEN LINKAGE SECTION */
    WHEN ('COMMUNICATION SECTION') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT @11 'IN_CS';
       * LINK COMNSCTN;
       END;  /* WHEN COMMUNICATION SECTION' */
    WHEN ('REPORT SECTION') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT @11 'IN_RS';
       * LINK RPRTSCTN;
       END;  /* WHEN REPORT SECTION */
    WHEN ('SCREEN SECTION') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT @11 'IN_SS';
       * LINK SCRNSCTN;
       END;  /* WHEN SCREEN SECTION */
    WHEN ('UNDEFINED') DO;
       /* DO NOTHING */
       END;  /* WHEN UNDEFINED */
    END;  /* SELECT SECTION */
 RETURN;  /* FROM DATA_DIV */

 FILESCTN:
    /*                                                           */
    /* FILESCTN:                                                 */
    /*    FILE SECTION                                           */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    AS LONG AS SECTION HAS THE VALUE 'FILE SECTION', THIS  */
    /* CODE IS INVOKED AFTER READING A LINE FROM THE INPUT FILE. */
    /* ENTRIES IN THE FILE SECTION CAN BE EVALUATED HERE.        */
    /*                                                           */

    IF PREVSCTN NE SECTION THEN DO;
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       PREVSCTN = SECTION;
       AV_SUM = 0;
       CLS_STR = ' ';
       END;  /* IF PREVSCTN NE SECTION */

    /*                                                           */
    /*   WHICH ENTRY TYPE WITHIN THE FILE SECTION ?              */
    /*                                                           */
    LINK LVL_IN_A;
       /* RETURNS FD_IN_A, DD_IN_A,                              */
       /*         CD_IN_A, RD_IN_A  AND SD_IN_A                  */
    IF DD_IN_A THEN
       NTRYTYPE = 'IN_DD';
    ELSE IF FD_IN_A THEN
       NTRYTYPE = 'IN_FD';
    ELSE IF SD_IN_A THEN
       NTRYTYPE = 'IN_SD';

    SELECT (NTRYTYPE);
    WHEN ('IN_DD') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT @11 'IN_DD';
       LINK IN_DD;
       END;  /* WHEN IN_DD */
    WHEN ('IN_FD') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT @11 'IN_FD';
       LINK IN_FD;
       END;  /* WHEN IN_FD */
    WHEN ('IN_SD') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT @11 'IN_SD';
       LINK IN_SD;
       END;  /* WHEN IN_SD */
    WHEN ('UNDEFINED') DO;
       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN
          PUT;
       /* DO NOTHING */
       END;  /* WHEN UNDEFINED */
    END;  /* SELECT NTRYTYPE */
 RETURN;  /* FROM FILESCTN */

 IN_FD:
    /*                                                           */
    /* IN_FD:                                                    */
    /*    IN FILE DESCRIPTION                                    */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    AS LONG AS NTRYTYPE HAS THE VALUE 'IN_FD', THIS CODE   */
    /* IS INVOKED AFTER READING A LINE FROM THE INPUT FILE.      */
    /* ENTRIES IN THE FILE DESCRIPTION CAN BE EVALUATED HERE.    */
    /*                                                           */
    /* OUTPUT:                                                   */
    /*    FILENAME     - THE TOKEN THAT IS AFTER 'FD'.           */
    /*                                                           */

    /* FINISH ANY PENDING PROCESSING.                            */
    IF PREVTYPE NE NTRYTYPE THEN DO;
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       PREVTYPE = NTRYTYPE;
       AV_SUM = 0;
       CLS_STR = ' ';
       FD_FND = 0;
       END;  /* IF PREVTYPE NE NTRYTYPE */

    /*    ASSUME THAT THE FILE NAME IS THE SECOND TOKEN OF THE   */
    /* FIRST LINE OF THE FILE DESCRIPTION SECTION. AFTER GETTING */
    /* THE FILE NAME, IGNORE THE REST OF THE FILE DESCRIPTION.   */
    /*                                                           */
    IF NOT FD_FND THEN DO;
       FILENAME = SCAN(A_LINE,2,BLANK);
       FILENAME = TRIM(LEFT(FILENAME));
       IF (INDEX(FILENAME,'.') = LENGTH(FILENAME)) THEN
          FILENAME = SUBSTR(FILENAME,1,LENGTH(FILENAME)-1);
       ELSE IF (INDEX(FILENAME,',') = LENGTH(FILENAME)) THEN
          FILENAME = SUBSTR(FILENAME,1,LENGTH(FILENAME)-1);
       ELSE IF (INDEX(FILENAME,';') = LENGTH(FILENAME)) THEN
          FILENAME = SUBSTR(FILENAME,1,LENGTH(FILENAME)-1);
       FD_FND = 1;
       END;  /* IF NOT FD_FND */
 RETURN;  /* FROM IN_FD */


 IN_SD:
    /*                                                           */
    /* IN_SD:                                                    */
    /*    IN SORT-MERGE DESCRIPTION                              */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    AS LONG AS NTRYTYPE HAS THE VALUE 'IN_SD', THIS CODE   */
    /* IS INVOKED AFTER READING A LINE FROM THE INPUT FILE.      */
    /* ENTRIES IN THE SORT-MERGE FILE DESCRIPTION CAN BE         */
    /* EVALUATED HERE.                                           */
    /*                                                           */
    /* OUTPUT:                                                   */
    /*    FILENAME     - THE TOKEN THAT IS AFTER 'SD'.           */
    /*                                                           */

    IF PREVTYPE NE NTRYTYPE THEN DO;
       /* FINISH PROCESSING ANY DATA DESCRIPTION BEING BUILT.    */
       LINK EODDSCTN;
       PREVTYPE = NTRYTYPE;
       AV_SUM = 0;
       CLS_STR = ' ';
       FD_FND = 0;
       END;  /* IF PREVTYPE NE NTRYTYPE */

    /*    ASSUME THAT THE FILE NAME IS THE SECOND TOKEN OF THE   */
    /* FIRST LINE OF THE SORT-MERGE DESCRIPTION SECTION. AFTER   */
    /* GETTING THE FILE NAME, IGNORE THE REST OF THE SORT-MERGE  */
    /* FILE DESCRIPTION.                                         */
    /*                                                           */
    IF NOT FD_FND THEN DO;
       FILENAME = SCAN(A_LINE,2,BLANK);
       FILENAME = TRIM(LEFT(FILENAME));
       IF (INDEX(FILENAME,'.') = LENGTH(FILENAME)) THEN
          FILENAME = SUBSTR(FILENAME,1,LENGTH(FILENAME)-1);
       ELSE IF (INDEX(FILENAME,',') = LENGTH(FILENAME)) THEN
          FILENAME = SUBSTR(FILENAME,1,LENGTH(FILENAME)-1);
       ELSE IF (INDEX(FILENAME,';') = LENGTH(FILENAME)) THEN
          FILENAME = SUBSTR(FILENAME,1,LENGTH(FILENAME)-1);
       FD_FND = 1;
       END;  /* IF NOT FD_FND */
 RETURN;  /* FROM IN_SD */

 IN_DD:
    /*                                                           */
    /* IN_DD:                                                    */
    /*    IN DATA DESCRIPTION                                    */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    AS LONG AS NTRYTYPE HAS THE VALUE 'IN_DD', THIS CODE   */
    /* IS INVOKED AFTER READING A LINE FROM THE INPUT FILE.      */
    /* ENTRIES IN THE DATA DESCRIPTION CAN BE EVALUATED HERE.    */
    /*                                                           */

    /* FINISH ANY PENDING PROCESSING.                            */
    /*                                                           */
    /*    IF THE PREVIOUS ENTRY TYPE IS IN_FD, THEN THE LAST     */
    /* STATEMENT IN THE FILE DESCRIPTION IS INCOMPLETE.          */
    /*    IF THE PREVIOUS ENTRY TYPE IS IN_SD, THEN THE          */
    /* LAST STATEMENT IN THE SORT-MERGE FILE DESCRIPTION         */
    /* IS INCOMPLETE.                                            */
    /*                                                           */
    IF PREVTYPE NE NTRYTYPE THEN DO;
       SELECT (PREVTYPE);
          WHEN ('IN_DD') DO;
             /* THE PROGRAM SHOULD NEVER GET HERE. */
             IF AV_SUM NE 0 THEN
                LINK EODDNTRY;
             END;  /* WHEN IN_DD */
          WHEN ('IN_FD') DO;
             * LINK EOFDNTRY;
             END;  /* WHEN IN_FD */
          WHEN ('IN_SD') DO;
             * LINK EOSDNTRY;
             END;  /* WHEN IN_SD */
          WHEN ('UNDEFINED') DO;
             /* DO NOTHING */
             END;  /* WHEN UNDEFINED */
          END;  /* SELECT PREVTYPE  */

       PREVTYPE = NTRYTYPE;
       AV_SUM = 0;
       CLS_STR = ' ';
       END;  /* IF PREVTYPE NE NTRYTYPE */

    WRD_NDX = 1;
    A_WORD = SCAN(A_LINE,WRD_NDX,BLANK);
    A_WORD = TRIM(LEFT(A_WORD));
    /* SINCE PERIODS, COMMAS AND SEMICOLONS ARE PUNCTUATION,     */
    /* IGNORE THEM.                                              */
    DO WHILE((A_WORD = '.') OR (A_WORD = ',') OR (A_WORD = ';'));
       WRD_NDX = WRD_NDX + 1;
       A_WORD = SCAN(A_LINE,WRD_NDX,BLANK);
       A_WORD = TRIM(LEFT(A_WORD));
       END; /* DO WHILE */

    IF (INDEX(A_WORD,'.') = LENGTH(A_WORD)) THEN
       A_WORD = SUBSTR(A_WORD,1,LENGTH(A_WORD)-1);
    ELSE IF (INDEX(A_WORD,',') = LENGTH(A_WORD)) THEN
       A_WORD = SUBSTR(A_WORD,1,LENGTH(A_WORD)-1);
    ELSE IF (INDEX(A_WORD,';') = LENGTH(A_WORD)) THEN
       A_WORD = SUBSTR(A_WORD,1,LENGTH(A_WORD)-1);

    /* CHANGE '1' THRU '9' TO '01' THRU '09'.                    */
    IF LENGTH(A_WORD) = 1 THEN DO;
       IF (A_WORD GE '1') AND (A_WORD LE '9') THEN DO;
          A_WORD = '0'?/?/TRIM(LEFT(A_WORD));
          A_WORD = TRIM(LEFT(A_WORD));
          END;  /* IF (A_WORD GE '1') ETC. */
       END;  /* IF LENGTH(A_WORD) = 1 */

    DO WHILE(A_WORD GT ' ');
       IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
          IF TRACEPRS = '3' THEN PUT;
          PUT @3  PRS_MODE= @;
          END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
       SELECT (PRS_MODE);
          WHEN ('IDN_CLS') DO;
             FIRSTOKE = PUT(A_WORD,$DDICFMT.);
             IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
                PUT @24  FIRSTOKE= @;
                END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
             SELECT (FIRSTOKE);
                WHEN ('PICTURE') DO;
                   CLS_MODE = 'PIC_CLAUSE';
                   PRS_MODE = 'BLD_CLS';
                   CLS_STR = 'PICTURE';
                   TKN_ID = ' ';
                   TKN_VCTR = ' ';
                   CLS_ID = 'UNDEFINED';
                   END;  /* WHEN PICTURE */
                WHEN ('VALUE') DO;
                   CLS_MODE = 'VALUE_CLAUSE';
                   PRS_MODE = 'BLD_CLS';
                   CLS_STR = 'VALUE';
                   TKN_ID = ' ';
                   TKN_VCTR = ' ';
                   CLS_ID = 'UNDEFINED';
                   END;  /* WHEN VALUE */
                WHEN ('OCCURS') DO;
                   CLS_MODE = 'OCCURS_CLAUSE';
                   PRS_MODE = 'BLD_CLS';
                   CLS_STR = 'OCCURS';
                   TKN_ID = ' ';
                   TKN_VCTR = ' ';
                   CLS_ID = 'UNDEFINED';
                   END;  /* WHEN OCCURS */
                WHEN ('66') DO;
                   /*                                            */
                   /* THIS MARKS THE END OF THE PREVIOUS DATA    */
                   /* DESCRIPTION. FINISH PROCESSING THAT DATA   */
                   /* DESCRIPTION.                               */
                   /*                                            */
                   IF AV_SUM NE 0 THEN
                      LINK EODDNTRY;
                   AV_SUM = 0;
                   CLS_MODE = '66_CLAUSE';
                   PRS_MODE = 'BLD_CLS';
                   CLS_STR = '66';
                   TKN_ID = ' ';
                   TKN_VCTR = ' ';
                   CLS_ID = 'UNDEFINED';
                   END;  /* WHEN 66 */
                WHEN ('88') DO;
                   /*                                            */
                   /* THIS MARKS THE END OF THE PREVIOUS DATA    */
                   /* DESCRIPTION. FINISH PROCESSING THAT DATA   */
                   /* DESCRIPTION.                               */
                   /*                                            */
                   IF AV_SUM NE 0 THEN
                      LINK EODDNTRY;
                   AV_SUM = 0;
                   CLS_MODE = '88_CLAUSE';
                   PRS_MODE = 'BLD_CLS';
                   CLS_STR = '88';
                   TKN_ID = ' ';
                   TKN_VCTR = ' ';
                   CLS_ID = 'UNDEFINED';
                   END;  /* WHEN 88 */
                WHEN ('COPY') DO;
                   CLS_MODE = 'COPY_CLAUSE';
                   PRS_MODE = 'BLD_CLS';
                   CLS_STR = 'COPY';
                   TKN_ID = ' ';
                   TKN_VCTR = ' ';
                   CLS_ID = 'UNDEFINED';
                   END;  /* WHEN COPY */
                WHEN('LEVEL NUMBER') DO;
                   /*                                            */
                   /* THIS MARKS THE END OF THE PREVIOUS DATA    */
                   /* DESCRIPTION. FINISH PROCESSING THAT DATA   */
                   /* DESCRIPTION.                               */
                   /*                                            */
                   /* IF THIS LEVEL NUMBER IS '01', THEN CALL    */
                   /* EODDSCTN TO HANDLE THE POSSIBILITY OF      */
                   /* IMPLICIT REDEFINITION.                     */
                   /*                                            */
                   A_WORD = TRIM(LEFT(A_WORD));
                   IF INPUT(A_WORD,12.) EQ 1 THEN
                      LINK EODDSCTN;
                   ELSE IF AV_SUM NE 0 THEN
                      LINK EODDNTRY;
                   AV_SUM = 0;
                   CLS_MODE = 'LEVEL_CLAUSE';
                   PRS_MODE = 'BLD_CLS';
                   CLS_STR = TRIM(LEFT(A_WORD));
                   TKN_ID = PUT(A_WORD,$DDTFMT.);
                   TKN_VCTR = TRIM(LEFT(TKN_ID));
                   CLS_ID = PUT(TKN_VCTR,$DDCFMT.);
                   END;  /* WHEN LEVEL NUMBER */
                WHEN ('IDENTIFIED') DO;
                   CLS_MODE = 'SIMPLE_CLAUSE';
                   PRS_MODE = 'BLD_CLS';
                   A_WORD = TRIM(LEFT(A_WORD));
                   IF LENGTH(CLS_STR) < 200 THEN
                      CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '
                                ?/?/A_WORD;
                   ELSE
                      PUT 'CLAUSE STRING OVERFLOW';
                   TKN_ID = PUT(A_WORD,$DDTFMT.);
                   TKN_VCTR = TRIM(LEFT(TKN_ID));
                   CLS_ID = PUT(TKN_VCTR,$DDCFMT.);
                   IF CLS_ID NE 'UNDEFINED' THEN DO;
                      PRS_MODE = 'IDN_CLS';
                      END;  /* IF CLS_ID NE UNDEFINED */
                   END;  /* WHEN IDENTIFIED */
                OTHERWISE DO;
                   CLS_STR = ' ';
                   TKN_ID = ' ';
                   TKN_VCTR = ' ';
                   CLS_ID = 'UNDEFINED';
                   END;  /* OTHERWISE */
                END;  /* SELECT FIRSTOKE  */
             END;  /* WHEN IDN_CLS */
          WHEN ('BLD_CLS') DO;
             SELECT (CLS_MODE);
                WHEN ('PIC_CLAUSE') DO;
                   /*                                            */
                   /*    WHEN THE PICTURE CLAUSE IS BUILT,       */
                   /* SET PRS_MODE BACK TO 'IDN_CLS' AND         */
                   /* SET CLS_ID TO '6'.                         */
                   LINK BLD_PIC;
                   END;  /* WHEN PIC_CLAUSE */
                WHEN ('VALUE_CLAUSE') DO;
                   /*                                            */
                   /*    WHEN THE VALUE CLAUSE IS BUILT,         */
                   /* SET PRS_MODE BACK TO 'IDN_CLS' AND         */
                   /* SET CLS_ID TO '12'.                        */
                   LINK BLD_VAL;
                   END;  /* WHEN VALUE_CLAUSE */
                WHEN ('OCCURS_CLAUSE') DO;
                   /*                                            */
                   /*    WHEN THE OCCURS CLAUSE IS BUILT,        */
                   /* SET PRS_MODE BACK TO 'IDN_CLS' AND         */
                   /* SET CLS_ID TO '13'.                        */
                   LINK BLD_OCUR;
                   END;  /* WHEN OCCURS_CLAUSE */
                WHEN ('66_CLAUSE') DO;
                   /*                                            */
                   /*    WHEN THE 66 CLAUSE HAS BEEN BUILT,      */
                   /* SET PRS_MODE BACK TO 'IDN_CLS' AND         */
                   /* SET CLS_ID TO '14'.                        */
                   LINK BLD_66;
                   END;  /* WHEN 66_CLAUSE */
                WHEN ('88_CLAUSE') DO;
                   /*                                            */
                   /*    WHEN THE 88 CLAUSE HAS BEEN BUILT,      */
                   /* SET PRS_MODE BACK TO 'IDN_CLS' AND         */
                   /* SET CLS_ID TO '15'.                        */
                   LINK BLD_88;
                   END;  /* WHEN 88_CLAUSE */
                WHEN ('COPY_CLAUSE') DO;
                   /*                                            */
                   /*    WHEN THE COPY CLAUSE IS BUILT,          */
                   /* SET PRS_MODE BACK TO 'IDN_CLS' AND         */
                   /* SET CLS_ID TO '16'.                        */
                   LINK BLD_COPY;
                   END;  /* WHEN COPY_CLAUSE */
                WHEN ('LEVEL_CLAUSE') DO;
                   A_WORD = TRIM(LEFT(A_WORD));
                   FIRSTOKE = PUT(A_WORD,$DDICFMT.);
                   IF (FIRSTOKE NE 'UNIDENTIFIED') THEN DO;
                      /* NEITHER A DATANAME NOR FILLER FOLLOWS   */
                      /* THE LEVEL NUMBER. SUPPLY FILLER HERE.   */
                      A_WORD = 'FILLER';
                      WRD_NDX = WRD_NDX - 1;
                      END;  /* IF (FIRSTOKE NE 'UNIDENTIFIED') */
                   IF LENGTH(CLS_STR) < 200 THEN
                      CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '
                                ?/?/A_WORD;
                   ELSE
                      PUT 'CLAUSE STRING OVERFLOW';
                   TKN_ID = PUT(A_WORD,$DDTFMT.);
                   TKN_ID = TRIM(LEFT(TKN_ID));
                   TKN_VCTR = TRIM(LEFT(TKN_VCTR))?/?/TKN_ID;
                   CLS_ID = PUT(TKN_VCTR,$DDCFMT.);
                   IF CLS_ID NE 'UNDEFINED' THEN DO;
                      PRS_MODE = 'IDN_CLS';
                      END;  /* IF CLS_ID NE UNDEFINED */
                   END;  /* WHEN LEVEL_CLAUSE */
                WHEN ('SIMPLE_CLAUSE') DO;
                   A_WORD = TRIM(LEFT(A_WORD));
                   IF LENGTH(CLS_STR) < 200 THEN
                      CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '
                                ?/?/A_WORD;
                   ELSE
                      PUT 'CLAUSE STRING OVERFLOW';
                   TKN_ID = PUT(A_WORD,$DDTFMT.);
                   TKN_ID = TRIM(LEFT(TKN_ID));
                   TKN_VCTR = TRIM(LEFT(TKN_VCTR))?/?/TKN_ID;
                   CLS_ID = PUT(TKN_VCTR,$DDCFMT.);
                   IF CLS_ID NE 'UNDEFINED' THEN DO;
                      PRS_MODE = 'IDN_CLS';
                      END;  /* IF CLS_ID NE UNDEFINED */
                   END;  /* WHEN SIMPLE_CLAUSE */
                END;  /* SELECT CLS_MODE */
             END;  /* WHEN BLD_CLS */
          END;  /* SELECT PRS_MODE */

       /*                                                        */
       /* IF A COMPLETE CLAUSE IS IN THE CLAUSE STRING, EXTRACT  */
       /* WHATEVER INFORMATION IS NEEDED FROM THE CLAUSE STRING. */
       /* THE INFORMATION THUS ACQUIRED IS USED WHEN THE END OF  */
       /* THE DATA DESCRIPTION IS ENCOUNTERED.                   */
       /*                                                        */
       /* ALSO SET A BIT IN THE ATTRIBUTE VECTOR BY RAISING 2 TO */
       /* THE VALUE IN CLS_ID AND ADDING THAT VALUE TO AV_SUM.   */
       /*                                                        */
       /* NOTE:                                                  */
       /*    THE DEFAULT VALUE OF ATTR_ERR IS 'N'. THIS ALLOWS   */
       /*    THE PROGRAM TO PROCESS THOSE ENTRIES THAT ARE NOT   */
       /*    DEFINED TO THE DDAVFMT FORMAT IN R2COB1.            */
       /*                                                        */
       /*    WHEN ATTR_ERR HAS VALUE 'Y', ALL CLAUSES SET A      */
       /*    BIT IN THE ATTRIBUTE VECTOR. IN THIS CASE, WHEN     */
       /*    THE ATTRIBUTE VECTOR IS EVALUATED, THE PROGRAM      */
       /*    WILL BE UNABLE TO PROCESS ENTRIES THAT HAVE NOT     */
       /*    BEEN DEFINED TO THE DDAVFMT FORMAT IN R2COB1.       */
       /*                                                        */
       IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
          PUT @48 CLS_MODE=;
          PUT @3 CLS_STR= ;
          PUT @3 TKN_ID= @24 TKN_VCTR= @48 CLS_ID=;
          END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */

       IF CLS_ID = '1' THEN DO;
          /*                                                     */
          /* LEVEL 01 AND A DATANAME/FILLER IS IN CLS_STR.       */
          LINK LK_01;
          AV_SUM = AV_SUM + (2**1);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '1' */
       ELSE IF CLS_ID = '2' THEN DO;
          /*                                                     */
          /* A LEVEL NUMBER AND A DATANAME/FILLER IS IN CLS_STR. */
          LINK LK_LVL;
          AV_SUM = AV_SUM + (2**2);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '2' */
       ELSE IF CLS_ID = '3' THEN DO;
          /*                                                     */
          /* REDEFINES DATANAME/FILLER IS IN CLS_STR.            */
          LINK LK_RDFN;
          AV_SUM = AV_SUM + (2**3);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '3' */
       ELSE IF CLS_ID = '4' THEN DO;
          /*                                                     */
          /* 'IS EXTERNAL' IS IN CLS_STR.                        */
          * LINK LK_XTRN;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**4);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '4' */
       ELSE IF CLS_ID = '5' THEN DO;
          /*                                                     */
          /* 'IS GLOBAL' IS IN CLS_STR.                          */
          * LINK LK_GLBL;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**5);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '5' */
       ELSE IF CLS_ID = '6' THEN DO;
          /*                                                     */
          /* A COMPLETE PICTURE CLAUSE IS IN CLS_STR.            */
          LINK LK_PIC;
          AV_SUM = AV_SUM + (2**6);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '6' */
       ELSE IF CLS_ID = '7' THEN DO;
          /*                                                     */
          /* A COMPLETE USAGE CLAUSE IS IN CLS_STR.              */
          LINK LK_USAGE;
          AV_SUM = AV_SUM + (2**7);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '7' */
       ELSE IF CLS_ID = '8' THEN DO;
          /*                                                     */
          /* A COMPLETE SIGN CLAUSE IS IN CLS_STR.               */
          * LINK LK_SIGN;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**8);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '8' */
       ELSE IF CLS_ID = '9' THEN DO;
          /*                                                     */
          /* A COMPLETE SYNCHRONIZED CLAUSE IS IN CLS_STR.       */
          * LINK LK_SYNC;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**9);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '9' */
       ELSE IF CLS_ID = '10' THEN DO;
          /*                                                     */
          /* A COMPLETE JUSTIFIED CLAUSE IS IN CLS_STR.          */
          * LINK LK_JUST;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**10);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '10' */
       ELSE IF CLS_ID = '11' THEN DO;
          /*                                                     */
          /* A COMPLETE 'BLANK WHEN ZERO' CLAUSE IS IN CLS_STR.  */
          BWZ_FLAG = 'Y';
          AV_SUM = AV_SUM + (2**11);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '11' */
       ELSE IF CLS_ID = '12' THEN DO;
          /*                                                     */
          /* A COMPLETE VALUE CLAUSE IS IN CLS_STR.              */

          /*                                                     */
          /* ALTHOUGH THE VALUE CLAUSE IS NOT VALID IN THE FILE  */
          /* SECTION EXCEPT ON THE 88 LEVEL, HANDLE IT HERE.     */
          /*                                                     */
          * LINK LK_VAL;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**12);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '12' */
       ELSE IF CLS_ID = '13' THEN DO;
          /*                                                     */
          /* A COMPLETE OCCURS CLAUSE IN CLS_STR.                */
          LINK LK_OCUR;
          AV_SUM = AV_SUM + (2**13);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '13' */
       ELSE IF CLS_ID = '14' THEN DO;
          /*                                                     */
          /* A COMPLETE 66 CLAUSE IS IN CLS_STR.                 */
          * LINK LK_66;
          AV_SUM = AV_SUM + (2**14);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '14' */
       ELSE IF CLS_ID = '15' THEN DO;
          /*                                                     */
          /* A COMPLETE 88 CLAUSE IS IN CLS_STR.                 */
          * LINK LK_88;
          AV_SUM = AV_SUM + (2**15);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '15' */
       ELSE IF CLS_ID = '16' THEN DO;
          /*                                                     */
          /* A COMPLETE COPY CLAUSE IS IN CLS_STR.               */
          * LINK LK_COPY;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**16);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_ID = '16' */
       ELSE IF CLS_ID = 'UNDEFINED' THEN DO;
          /* NOTHING */
          END;  /* IF CLS_ID = 'UNDEFINED' */

       WRD_NDX + 1;
       A_WORD = SCAN(A_LINE,WRD_NDX,BLANK);
       A_WORD = TRIM(LEFT(A_WORD));
       /* SINCE PERIODS, COMMAS AND SEMICOLONS ARE PUNCTUATION,  */
       /* IGNORE THEM.                                           */
       DO WHILE
          ((A_WORD = '.') OR (A_WORD = ',') OR (A_WORD = ';'));
          WRD_NDX = WRD_NDX + 1;
          A_WORD = SCAN(A_LINE,WRD_NDX,BLANK);
          A_WORD = TRIM(LEFT(A_WORD));
          END; /* DO WHILE */

       IF (INDEX(A_WORD,'.') = LENGTH(A_WORD)) THEN
          A_WORD = SUBSTR(A_WORD,1,LENGTH(A_WORD)-1);
       ELSE IF (INDEX(A_WORD,',') = LENGTH(A_WORD)) THEN
          A_WORD = SUBSTR(A_WORD,1,LENGTH(A_WORD)-1);
       ELSE IF (INDEX(A_WORD,';') = LENGTH(A_WORD)) THEN
          A_WORD = SUBSTR(A_WORD,1,LENGTH(A_WORD)-1);

       /* CHANGE '1' THRU '9' TO '01' THRU '09'.                 */
       IF LENGTH(A_WORD) = 1 THEN DO;
          IF (A_WORD GE '1') AND (A_WORD LE '9') THEN DO;
             A_WORD = '0'?/?/TRIM(LEFT(A_WORD));
             A_WORD = TRIM(LEFT(A_WORD));
             END;  /* IF (A_WORD GE '1') ETC. */
          END;  /* IF LENGTH(A_WORD) = 1 */
       END;  /* DO WHILE(A_WORD GT ' ') */
 RETURN;  /* FROM IN_DD */

 BLD_PIC:
    /*                                                           */
    /* BLD_PIC:                                                  */
    /*    BUILD PICTURE CLAUSE                                   */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    FINISH PARSING PICTURE CLAUSE.                         */
    /*                                                           */
    IF TRIM(LEFT(A_WORD)) = 'IS' THEN
       CLS_STR = 'PICTURE IS';
    ELSE DO;
       /* SINCE ALL OCCURRENCES OF '1' THRU '9' ARE CHANGED TO   */
       /* '01' THRU '09', CHANGE '09' BACK TO '9'.               */
       IF TRIM(LEFT(A_WORD)) = '09' THEN
          A_WORD = '9';
       CLS_STR = TRIM(LEFT(CLS_STR))?/?/' '?/?/TRIM(LEFT(A_WORD));
       PRS_MODE = 'IDN_CLS';
       CLS_ID = '6';
       END;
 RETURN;  /* FROM BLD_PIC */

 BLD_VAL:
    /*                                                           */
    /* BLD_VAL:                                                  */
    /*    BUILD VALUE CLAUSE                                     */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    FINISH PARSING VALUE CLAUSE.                           */
    /*                                                           */
    IF TRIM(LEFT(A_WORD)) = 'IS' THEN
       CLS_STR = 'VALUE IS';
    ELSE DO;
       CLS_STR = TRIM(LEFT(CLS_STR))?/?/' '?/?/TRIM(LEFT(A_WORD));
       PRS_MODE = 'IDN_CLS';
       CLS_ID = '12';
       END;
 RETURN;  /* FROM BLD_VAL */

 BLD_OCUR:
    /*                                                           */
    /* BLD_OCUR:                                                 */
    /*    BUILD OCCURS CLAUSE                                    */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    FINISH PARSING OCCURS CLAUSE.                          */
    /*                                                           */
    IF CLS_STR = 'OCCURS' THEN
       NUMOFTKN = 1;
    ELSE
       NUMOFTKN + 1;
    A_WORD = TRIM(LEFT(A_WORD));
    FIRSTOKE = PUT(A_WORD,$DDICFMT.);
    IF FIRSTOKE = 'UNIDENTIFIED' THEN DO;
       IF LENGTH(CLS_STR) < 200 THEN
          CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '?/?/A_WORD;
       ELSE
          PUT 'CLAUSE STRING OVERFLOW';
       END;  /* IF FIRSTOKE = 'UNIDENTIFIED' */
    ELSE IF FIRSTOKE = 'LEVEL NUMBER' THEN DO;
       /* IS THIS NUMBER REALLY THE NEXT LEVEL NUMBER OR IS IT   */
       /* PART OF THE OCCURS CLAUSE ?                            */
       PREVWORD = SCAN(CLS_STR,NUMOFTKN,BLANK);
       PREVWORD = TRIM(LEFT(PREVWORD));
       IF TRACEPRS = '5' THEN
          PUT @24 PREVWORD=;
       IF (PREVWORD EQ 'OCCURS') OR (PREVWORD EQ 'TO') THEN DO;
          IF LENGTH(CLS_STR) < 200 THEN
             CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '?/?/A_WORD;
          ELSE
             PUT 'CLAUSE STRING OVERFLOW';
          END;  /* IF (PREVWORD EQ 'OCCURS') ETC. */
       ELSE DO;
          WRD_NDX = WRD_NDX - 1;
          PRS_MODE = 'IDN_CLS';
          CLS_ID = '13';
          END;  /* ELSE DO */
       END;  /* IF FIRSTOKE = 'LEVEL NUMBER' */
    ELSE DO;
       WRD_NDX = WRD_NDX - 1;
       PRS_MODE = 'IDN_CLS';
       CLS_ID = '13';
       END;  /* ELSE DO */
 RETURN;  /* FROM BLD_OCUR */

 BLD_66:
    /*                                                           */
    /* BLD_66:                                                   */
    /*    BUILD 66 CLAUSE                                        */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    FINISH PARSING LEVEL 66 CLAUSE.                        */
    /*                                                           */
    A_WORD = TRIM(LEFT(A_WORD));
    FIRSTOKE = PUT(A_WORD,$DDICFMT.);
    IF FIRSTOKE = 'UNIDENTIFIED' THEN DO;
       IF LENGTH(CLS_STR) < 200 THEN
          CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '?/?/A_WORD;
       ELSE
          PUT 'CLAUSE STRING OVERFLOW';
       END;  /* IF FIRSTOKE = 'UNIDENTIFIED' */
    ELSE DO;
       WRD_NDX = WRD_NDX - 1;
       PRS_MODE = 'IDN_CLS';
       CLS_ID = '14';
       END;  /* ELSE DO */
 RETURN;  /* FROM BLD_66 */

 BLD_88:
    /*                                                           */
    /* BLD_88:                                                   */
    /*    BUILD 88 CLAUSE                                        */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    FINISH PARSING LEVEL 88 CLAUSE.                        */
    /*                                                           */
    IF CLS_STR = '88' THEN
       NUMOFTKN = 1;
    ELSE
       NUMOFTKN + 1;
    A_WORD = TRIM(LEFT(A_WORD));
    FIRSTOKE = PUT(A_WORD,$DDICFMT.);
    IF FIRSTOKE = 'UNIDENTIFIED' THEN DO;
       IF LENGTH(CLS_STR) < 200 THEN
          CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '?/?/A_WORD;
       ELSE
          PUT 'CLAUSE STRING OVERFLOW';
       END;  /* IF FIRSTOKE = 'UNIDENTIFIED' */
    ELSE IF FIRSTOKE = 'LEVEL NUMBER' THEN DO;
       /* IS THIS NUMBER REALLY THE NEXT LEVEL NUMBER OR IS IT   */
       /* PART OF THE 88 CLAUSE ?                                */
       PREVWORD = SCAN(CLS_STR,NUMOFTKN,BLANK);
       PREVWORD = TRIM(LEFT(PREVWORD));
       IF TRACEPRS = '5' THEN
          PUT @24 PREVWORD=;
       IF (PREVWORD EQ 'VALUE') OR (PREVWORD EQ 'VALUES')
          OR (PREVWORD EQ 'IS') OR (PREVWORD EQ 'ARE')
          OR (PREVWORD EQ 'THROUGH') OR (PREVWORD EQ 'THRU') THEN DO;
          IF LENGTH(CLS_STR) < 200 THEN
             CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '?/?/A_WORD;
          ELSE
             PUT 'CLAUSE STRING OVERFLOW';
          END;  /* IF (PREVWORD EQ 'VALUE') ETC. */
       ELSE DO;
          WRD_NDX = WRD_NDX - 1;
          PRS_MODE = 'IDN_CLS';
          CLS_ID = '15';
          END;  /* ELSE DO */
       END;  /* IF FIRSTOKE = 'LEVEL NUMBER' */
    ELSE DO;
       WRD_NDX = WRD_NDX - 1;
       PRS_MODE = 'IDN_CLS';
       CLS_ID = '15';
       END;  /* ELSE DO */
 RETURN;  /* FROM BLD_88 */

 BLD_COPY:
    /*                                                           */
    /* BLD_COPY:                                                 */
    /*    BUILD COPY CLAUSE                                      */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    FINISH PARSING COPY CLAUSE.                            */
    /*                                                           */
    IF CLS_STR = 'COPY' THEN
       NUMOFTKN = 1;
    ELSE
       NUMOFTKN + 1;
    A_WORD = TRIM(LEFT(A_WORD));
    FIRSTOKE = PUT(A_WORD,$DDICFMT.);
    IF FIRSTOKE = 'UNIDENTIFIED' THEN DO;
       IF LENGTH(CLS_STR) < 200 THEN
          CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '?/?/A_WORD;
       ELSE
          PUT 'CLAUSE STRING OVERFLOW';
       END;  /* IF FIRSTOKE = 'UNIDENTIFIED' */
    ELSE IF FIRSTOKE = 'LEVEL NUMBER' THEN DO;
       /* IS THIS NUMBER REALLY THE NEXT LEVEL NUMBER OR IS IT   */
       /* PART OF THE COPY CLAUSE ?                              */
       PREVWORD = SCAN(CLS_STR,NUMOFTKN,BLANK);
       PREVWORD = TRIM(LEFT(PREVWORD));
       IF TRACEPRS = '5' THEN
          PUT @24 PREVWORD=;
       IF (PREVWORD EQ 'REPLACING') OR (PREVWORD EQ 'BY') THEN DO;
          IF LENGTH(CLS_STR) < 200 THEN
             CLS_STR = TRIM(LEFT(CLS_STR)) ?/?/' '?/?/A_WORD;
          ELSE
             PUT 'CLAUSE STRING OVERFLOW';
          END;  /* IF (PREVWORD EQ 'REPLACING') ETC. */
       ELSE DO;
          WRD_NDX = WRD_NDX - 1;
          PRS_MODE = 'IDN_CLS';
          CLS_ID = '16';
          END;  /* ELSE DO */
       END;  /* IF FIRSTOKE = 'LEVEL NUMBER' */
    ELSE DO;
       WRD_NDX = WRD_NDX - 1;
       PRS_MODE = 'IDN_CLS';
       CLS_ID = '16';
       END;  /* ELSE DO */
 RETURN;  /* FROM BLD_COPY */

 LK_01:
    /*                                                           */
    /* LK_01:                                                    */
    /*    LINK LEVEL 01 CLAUSE                                   */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    INITIALIZE VARIABLES DUE TO NEW RECORD.                */
    /*                                                           */

    LEVEL = '01';
    LVL = 1;
    DATANAME = SCAN(CLS_STR,2,BLANK);
    DATANAME = TRIM(LEFT(DATANAME));
    PICTURE = ' ';
    USAGE = ' ';
    OCR_VAL = ' ';
    RDF_NAME = ' ';
    INT = 0;
    FRACT = 0;
    INFMT = ' ';
    BWZ_FLAG = 'N';
    ATBYTE = 1;
 RETURN;  /* FROM LK_01 */

 LK_LVL:
    /*                                                           */
    /* LK_LVL:                                                   */
    /*    LINK LEVEL 02-49 CLAUSE                                */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    INITIALIZE VARIABLES DUE TO NEW LEVEL.                 */
    /*                                                           */
    LASTLVL = INPUT(LEVEL,12.);
    LEVEL = SCAN(CLS_STR,1,BLANK);
    LEVEL = TRIM(LEFT(LEVEL));
    LVL = INPUT(LEVEL,12.);
    DATANAME = SCAN(CLS_STR,2,BLANK);
    DATANAME = TRIM(LEFT(DATANAME));
    PICTURE = ' ';
    USAGE = ' ';
    OCR_VAL = ' ';
    RDF_NAME = ' ';
    INT = 0;
    FRACT = 0;
    INFMT = ' ';
    BWZ_FLAG = 'N';
 RETURN;  /* FROM LK_LVL */

 LK_RDFN:
    /*                                                           */
    /* LK_RDFN:                                                  */
    /*    LINK REDEFINES CLAUSE                                  */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    MAKE THE VALUE IN THE REDEFINES STATEMENT IN THE       */
    /* CLAUSE STRING AVAILABLE FOR FURTHER PROCESSING.           */
    /*                                                           */
    RDF_NAME = SCAN(CLS_STR,2,BLANK);
    RDF_NAME = TRIM(LEFT(RDF_NAME));
 RETURN;  /* FROM LK_RDFN */

 LK_PIC:
    /*                                                           */
    /* LK_PIC:                                                   */
    /*    LINK PICTURE CLAUSE                                    */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    MAKE THE VALUE OF PICTURE IN THE CLAUSE STRING         */
    /* AVAILABLE FOR FURTHER PROCESSING.                         */
    /*                                                           */
    TMP_I = 2;
    A_WORD = SCAN(CLS_STR,TMP_I,BLANK);
    A_WORD = TRIM(LEFT(A_WORD));
    IF A_WORD = 'IS' THEN DO;
       /*   SKIP OVER THE WORD 'IS'.                             */
       TMP_I + 1;
       A_WORD = SCAN(CLS_STR,TMP_I,BLANK);
       A_WORD = TRIM(LEFT(A_WORD));
       END;  /* IF A_WORD = 'IS' */

    /*                                                           */
    /* ROUTINE FIX_PIC TAKES 'A_WORD' AND RETURNS 'PICTURE',     */
    /* 'INT', AND 'FRACT'.                                       */
    /*                                                           */
    LINK FIX_PIC;
 RETURN;  /* FROM LK_PIC */

 LK_USAGE:
    /*                                                           */
    /* LK_USAGE:                                                 */
    /*    LINK USAGE CLAUSE                                      */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    MAKE THE VALUE OF USAGE IN THE CLAUSE STRING AVAILABLE */
    /* FOR FURTHER PROCESSING.                                   */
    /*                                                           */
    TMP_I = 1;
    A_WORD = SCAN(CLS_STR,TMP_I,BLANK);
    A_WORD = TRIM(LEFT(A_WORD));
    DO WHILE(A_WORD GT ' ');
       IF A_WORD = 'USAGE' THEN DO;
          TMP_I + 1;
          A_WORD = SCAN(CLS_STR,TMP_I,BLANK);
          A_WORD = TRIM(LEFT(A_WORD));
          IF A_WORD NE 'IS' THEN
             TMP_I = TMP_I - 1;
          END;  /* IF A_WORD = USAGE */
       ELSE IF (A_WORD = 'BINARY') THEN DO;
          USAGE = 'BINARY';
          END;  /* IF A_WORD = BINARY */
       ELSE IF (A_WORD = 'COMPUTATIONAL'
             OR A_WORD = 'COMP') THEN DO;
          USAGE = 'COMP';
          END;  /* IF A_WORD = COMP */
       ELSE IF (A_WORD = 'COMPUTATIONAL-1'
             OR A_WORD = 'COMP-1') THEN DO;
          USAGE = 'COMP-1';
          END;  /* IF A_WORD = COMP-1 */
       ELSE IF (A_WORD = 'COMPUTATIONAL-2'
             OR A_WORD = 'COMP-2') THEN DO;
          USAGE = 'COMP-2';
          END;  /* IF A_WORD = COMP-2 */
       ELSE IF (A_WORD = 'COMPUTATIONAL-3'
             OR A_WORD = 'COMP-3') THEN DO;
          USAGE = 'COMP-3';
          END;  /* IF A_WORD = COMP-3 */
       ELSE IF (A_WORD = 'COMPUTATIONAL-4'
             OR A_WORD = 'COMP-4') THEN DO;
          USAGE = 'COMP-4';
          END;  /* IF A_WORD = COMP-4 */
       ELSE IF A_WORD = 'DISPLAY' THEN DO;
          USAGE = 'DISPLAY';
          END;  /* IF A_WORD = DISPLAY */
       ELSE IF (A_WORD = 'INDEX') THEN DO;
          USAGE = 'INDEX';
          END;  /* IF A_WORD = INDEX */
       ELSE IF (A_WORD = 'PACKED-DECIMAL') THEN DO;
          USAGE = 'PCKDCML';
          END;  /* IF A_WORD = PACKED-DECIMAL */
       TMP_I + 1;
       A_WORD = SCAN(CLS_STR,TMP_I,BLANK);
       A_WORD = TRIM(LEFT(A_WORD));
       END;  /* DO WHILE (A_WORD GT ' ') */
 RETURN;  /* FROM LK_USAGE */

 LK_OCUR:
    /*                                                           */
    /* LK_OCUR:                                                  */
    /*    LINK OCCURS CLAUSE                                     */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    MAKE THE VALUE OF OCCURS IN THE CLAUSE STRING          */
    /* AVAILABLE FOR FURTHER PROCESSING.                         */
    /*                                                           */
    IF INDEX(CLS_STR,'TO') THEN DO;
       OCR_VAL = SCAN(CLS_STR,4,BLANK);
       OCR_VAL = TRIM(LEFT(OCR_VAL));
       END;  /* IF INDEX(CLS_STR,'TO') */
    ELSE DO;
       OCR_VAL = SCAN(CLS_STR,2,BLANK);
       OCR_VAL = TRIM(LEFT(OCR_VAL));
       END;  /* ELSE DO */
    /* SINCE ALL OCCURRENCES OF '1' THRU '9' ARE CHANGED TO      */
    /* '01' THRU '09', CHANGE THEM BACK TO '1' THRU '9'.         */
    IF LENGTH(OCR_VAL) = 2 THEN DO;
       IF SUBSTR(OCR_VAL,1,1) = '0' THEN DO;
          OCR_VAL = SUBSTR(OCR_VAL,2,1);
          OCR_VAL = TRIM(LEFT(OCR_VAL));
          END;  /* IF SUBSTR(OCR_VAL,1,1) = '0' */
       END;  /* IF LENGTH(OCR_VAL) = 2 */
 RETURN;  /* FROM LK_OCUR */

 LK_66:
    /*                                                           */
    /* LK_66:                                                    */
    /*    LINK 66 CLAUSE                                         */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    MAKE THE VALUES IN THE LEVEL 66 STATEMENT IN THE       */
    /* CLAUSE STRING AVAILABLE FOR FURTHER PROCESSING.           */
    /*                                                           */

 RETURN;  /* FROM LK_66 */

 LK_88:
    /*                                                           */
    /* LK_88:                                                    */
    /*    LINK 88 CLAUSE                                         */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    MAKE THE VALUES IN THE LEVEL 88 STATEMENT IN THE       */
    /* CLAUSE STRING AVAILABLE FOR FURTHER PROCESSING.           */
    /*                                                           */

 RETURN;  /* FROM LK_88 */

 LK_COPY:
    /*                                                           */
    /* LK_COPY:                                                  */
    /*    LINK COPY CLAUSE                                       */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    MAKE THE VALUES IN THE COPY STATEMENT IN THE CLAUSE    */
    /* STRING AVAILABLE FOR FURTHER PROCESSING.                  */
    /*                                                           */

 RETURN;  /* FROM LK_COPY */

 LVL_IN_A:
    /*                                                           */
    /* LVL_IN_A:                                                 */
    /*    LEVEL INDICATOR IN AREA A                              */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    INSPECT COLUMNS 8 THRU 11 FOR THESE LEVEL INDICATORS:  */
    /*                                                           */
    /*       'FD', '01', 'CD', 'RD', 'SD'                        */
    /*                                                           */
    A_AREA = SUBSTR(TMP_LINE,8,4);
    A_AREA = TRIM(LEFT(A_AREA));
    A_AREA = UPCASE(A_AREA);
    FD_IN_A=0; DD_IN_A=0;
    CD_IN_A=0; RD_IN_A=0; SD_IN_A=0;
    IF LENGTH(A_AREA) = 2 THEN DO;
       FD_IN_A = INDEX(A_AREA,'FD');
       DD_IN_A = INDEX(A_AREA,'01');
       CD_IN_A = INDEX(A_AREA,'CD');
       RD_IN_A = INDEX(A_AREA,'RD');
       SD_IN_A = INDEX(A_AREA,'SD');
       END;
    ELSE IF LENGTH(A_AREA) = 1 THEN
       DD_IN_A = INDEX(A_AREA,'1');

    /* CHECK FOR A FILE NAME OR A DATA NAME IN AREA A.           */
    IF (FD_IN_A = 0) AND (DD_IN_A = 0) AND
       (CD_IN_A = 0) AND (RD_IN_A = 0) AND (SD_IN_A = 0) THEN DO;
       A_WORD = SCAN(A_AREA,1,BLANK);
       A_WORD = TRIM(LEFT(A_WORD));
       IF LENGTH(A_WORD) = 2 THEN DO;
          FD_IN_A = INDEX(A_WORD,'FD');
          DD_IN_A = INDEX(A_WORD,'01');
          CD_IN_A = INDEX(A_WORD,'CD');
          RD_IN_A = INDEX(A_WORD,'RD');
          SD_IN_A = INDEX(A_WORD,'SD');
          END;
       ELSE IF LENGTH(A_AREA) = 1 THEN
          DD_IN_A = INDEX(A_WORD,'1');

       IF (TRACEPRS = '4') OR (TRACEPRS = '6') THEN DO;
          IF (FD_IN_A OR CD_IN_A OR RD_IN_A OR SD_IN_A) THEN
             PUT 'WARNING: FILE NAME FOUND IN COLUMNS 8 THRU 11.';
          ELSE IF DD_IN_A THEN
             PUT 'WARNING: DATA NAME FOUND IN COLUMNS 8 THRU 11.';
          END; /* IF FD_IN_A, DD_IN_A,                 */
               /* CD_IN_A, RD_IN_A AND SD_IN_A ARE 0   */
          END;  /* IF (TRACEPRS = '4') OR (TRACEPRS = '6') */
 RETURN;  /* FROM LVL_IN_A */

 COPY_MEM:
    /*                                                           */
    /* COPY_MEM:                                                 */
    /*    COPY MEMBER                                            */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    EVALUATE THE FIRST TOKEN, IN COLUMNS 8 THRU 72, FOR    */
    /* ONE THAT INITIATES A DATA DESCRIPTION ENTRY.              */
    /*                                                           */
    A_WORD = SCAN(A_LINE,1,BLANK);
    A_WORD = TRIM(LEFT(A_WORD));
    FIRSTOKE = PUT(A_WORD,$DDICFMT.);
    IF FIRSTOKE = 'UNIDENTIFIED' THEN
       CPY_MEM = 0;
    ELSE
       CPY_MEM = 1;

    /*                                                           */
    /* BUILD A DUMMY LEVEL 01. THIS SETS INITIAL VALUES THAT ARE */
    /* ASSUMED BY THE STACK PROCESSING ROUTINES.                 */
    /*                                                           */
    IF CPY_MEM THEN DO;
       FILENAME = ' ';
       LEVEL = '01';
       LVL = 1;
       DATANAME = '__##DUMMY_LEVEL_01__##DUMMY___';
       PICTURE = ' ';
       USAGE = ' ';
       LINK STKUSAGE;
       USAGE = 'GROUP';
       OCR_VAL = ' ';
       RDF_NAME = ' ';
       INT = 0;
       FRACT = 0;
       INFMT = ' ';
       BWZ_FLAG = 'N';
       ATBYTE = 1;
       BYTES = 0;
       D_GRPID = 0;
       LINK STKGROUP;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       END;  /* IF CPY_MEM */
 RETURN;  /* FROM COPY_MEM */

 FIX_PIC:
    /*                                                           */
    /* FIX_PIC:                                                  */
    /*    FIX PICTURE                                            */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    RETURN ALL PICTURES IN A STANDARD FORMAT.              */
    /*                                                           */
    /* INPUT:                                                    */
    /*    A_WORD    - A SINGLE TOKEN FROM THE CLAUSE STRING.     */
    /*                                                           */
    /* OUTPUT:                                                   */
    /*    INT       - NUMBER OF BYTES IN THE INTEGER PART.       */
    /*    FRACT     - NUMBER OF BYTES IN THE FRACTIONAL PART.    */
    /*    PICTURE   - STRING FORMATTED AS EITHER X(INT), A(INT)  */
    /*                OR 9(INT)V9(FRACT);                        */
    /*                WHERE INT AND FRACT ARE NUMBERS OF BYTES.  */

    /*   GET AND CLASSIFY THE FIRST CHARACTER.                   */
    INT = 0;
    FRACT = 0;
    CHAR_COL = 1;
    WORD_LEN = LENGTH(A_WORD);
    CHAR = SUBSTR(A_WORD,CHAR_COL,1);
    IF (CHAR = 'A') OR (CHAR = 'X') THEN DO;
          /* ALPHABETIC OR ALPHANUMERIC                          */
          CHARTYPE = CHAR;
          INT = 1;
          CHAR_COL + 1;
          DO WHILE(CHAR_COL LE WORD_LEN);
             CHAR = SUBSTR(A_WORD,CHAR_COL,1);
             IF CHAR = CHARTYPE THEN
                INT + 1;
             ELSE IF CHAR = '(' THEN DO;
                INT = INT - 1;
                TMP_WORD = SUBSTR(A_WORD,CHAR_COL+1);
                TMP_WORD = SCAN(TMP_WORD,1,')');
                TMP_WORD = TRIM(LEFT(TMP_WORD));
                /* ASSUME THAT A VALID NUMBER HAS BEEN FOUND.    */
                INT = INT + INPUT(TMP_WORD,12.);
                CHAR_COL = CHAR_COL + LENGTH(TMP_WORD) + 1;
                END;  /* CHAR = '(' */
             ELSE
                ERROR = 1;
             CHAR_COL + 1;
             END;  /* DO WHILE CHAR_COL LE WORD_LEN */
          W = PUT(INT,12.);
          PICTURE = TRIM(LEFT(CHARTYPE))?/?/'('
                    ?/?/TRIM(LEFT(W))?/?/')';
          END;  /* IF (CHAR = 'A') OR (CHAR = 'X') */

       /* FOLLOWING ADDED TO HANDLE -9 PIC      RHA-05/13/2014*/
       ELSE IF (CHAR = 'S') OR (CHAR = '9') OR (CHAR = '-') THEN DO;
          /* SIGNED OR NUMERIC                                   */
       /* FOLLOWING ADDED TO HANDLE -9 PIC      RHA-05/13/2014*/
          IF CHAR = 'S' OR CHAR = '-' THEN
             /* ASSUME THE NEXT CHARACTER IS A '9' OR A 'V'.     */
             CHAR_COL + 1;
          IF SUBSTR(A_WORD,CHAR_COL,1) = 'V' THEN DO;
             INT = 0;
             V_FOUND = 1;
             END;
          ELSE DO;
             INT = 1;
             V_FOUND = 0;
             END;
          FRACT = 0;
          CHAR_COL + 1;
       /* FOLLOWING ADDED TO HANDLE -9 PIC      RHA-06/06/2014*/
          IF CHAR = '-' THEN
           DO;
            INT+1;                 /* ADD 1 FOR SIGN          */
            MINUS='-';             /* REMEMBER WE HAD - NOT S */
           END;
          ELSE
           MINUS=' ';              /* ALWAYS NEED A VALUE     */
          DO WHILE(CHAR_COL LE WORD_LEN);
             CHAR = SUBSTR(A_WORD,CHAR_COL,1);
             IF CHAR = '9' THEN DO;
                IF V_FOUND THEN
                   FRACT + 1;
                ELSE
                   INT + 1;
                END;  /* CHAR = '9' */
             ELSE IF CHAR = '(' THEN DO;
                IF V_FOUND THEN
                   FRACT = FRACT - 1;
                ELSE
                   INT = INT - 1;
                TMP_WORD = SUBSTR(A_WORD,CHAR_COL+1);
                TMP_WORD = SCAN(TMP_WORD,1,')');
                TMP_WORD = TRIM(LEFT(TMP_WORD));
                /* ASSUME THAT A VALID NUMBER HAS BEEN FOUND.    */
                IF V_FOUND THEN
                 DO;
       /* FOLLOWING ADDED TO HANDLE -9 PIC      RHA-06/06/2014*/
                  IF MINUS = '-' THEN
                   INT+1;          /* ADD 1 FOR DECIMAL       */
                  FRACT = FRACT + INPUT(TMP_WORD,12.);
                 END;
                ELSE
                   INT = INT + INPUT(TMP_WORD,12.);
                CHAR_COL = CHAR_COL + LENGTH(TMP_WORD) + 1;
                END;  /* CHAR = '(' */
       /* FOLLOWING ADDED TO HANDLE -9 PIC      RHA-06/06/2014*/
             ELSE IF CHAR = 'V' OR CHAR = '.' THEN DO;
                V_FOUND = 1;
                END;  /* CHAR = 'V' */
             ELSE
                ERROR = 1;
             CHAR_COL + 1;
             END;  /* DO WHILE CHAR_COL LE WORD_LEN */
          IF NOT V_FOUND THEN
             FRACT = 0;
          W = PUT(INT,12.);
          D = PUT(FRACT,12.);
          PICTURE = '9('?/?/TRIM(LEFT(W))?/?/')V9('
                    ?/?/TRIM(LEFT(D))?/?/')';
          END;  /* ELSE IF (CHAR = 'S') OR (CHAR = '9')  */

       ELSE IF CHAR = 'V' THEN DO;
          /* IMPLIED DECIMAL POINT                               */
          FRACT = 0;
          CHAR_COL + 1;
          DO WHILE(CHAR_COL LE WORD_LEN);
             CHAR = SUBSTR(A_WORD,CHAR_COL,1);
             IF CHAR = '9' THEN DO;
                FRACT + 1;
                END;  /* CHAR = '9' */
             ELSE IF CHAR = '(' THEN DO;
                FRACT = FRACT - 1;
                TMP_WORD = SUBSTR(A_WORD,CHAR_COL+1);
                TMP_WORD = SCAN(TMP_WORD,1,')');
                TMP_WORD = TRIM(LEFT(TMP_WORD));
                /* ASSUME THAT A VALID NUMBER HAS BEEN FOUND.    */
                FRACT = FRACT + INPUT(TMP_WORD,12.);
                CHAR_COL = CHAR_COL + LENGTH(TMP_WORD) + 1;
                END;  /* CHAR = '(' */
             ELSE
                ERROR = 1;
             CHAR_COL + 1;
             END;  /* DO WHILE CHAR_COL LE WORD_LEN */
          D = PUT(FRACT,12.);
          PICTURE = '9(0)V9('?/?/TRIM(LEFT(D))?/?/')';
          END;  /* ELSE IF CHAR = 'V' */
       ELSE DO;
          /* UNRECOGNIZED SYNTAX IN THE PICTURE STRING.          */
          END;  /* ELSE DO */
 RETURN; /* FROM FIXPIC */

 GETINFMT:
    /*                                                           */
    /* GETINFMT:                                                 */
    /*    GET INFORMAT                                           */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    CONVERT THE USAGE AND PICTURE INTO AN INFORMAT.        */
    /*                                                           */
    /* INPUT:                                                    */
    /*    USAGE      - DESCRIBES THE DATA'S REPRESENTATION.      */
    /*    INT        - THE NUMBER OF CHARACTERS TO THE LEFT OF   */
    /*                 THE DECIMAL POINT. THIS IS RETURNED FROM  */
    /*                 FIXPIC.                                   */
    /*    FRACT      - THE NUMBER OF CHARACTERS TO THE RIGHT OF  */
    /*                 THE DECIMAL POINT. THIS IS RETURNED FROM  */
    /*                 FIXPIC.                                   */
    /*                                                           */
    /* OUTPUT:                                                   */
    /*    INFMT      - THE INFORMAT.                             */
    /*                                                           */

    /*                                                           */
    /* (1) WHEN USAGE IS 'DISPLAY':                              */
    /*     1.A) WHEN PICTURE IS 'A' OR 'X', THEN                 */
    /*            THE INFORMAT IS '$CHAR'                        */
    /*                                                           */
    /*     1.B) WHEN PICTURE IS '9', THEN                        */
    /*            IF BWZ_FLAG = 'Y' THEN                         */
    /*               THE INFORMAT IS 'ZDB'                       */
    /*            OTHERWISE                                      */
    /*               THE INFORMAT IS 'ZD'                        */
    /*                                                           */
    /* (2) WHEN USAGE IS 'COMP' OR 'COMP-4':                     */
    /*       THE PICTURE SHOULD BE '9'                           */
    /*       AND THE INFORMAT IS 'IB'                            */
    /*                                                           */
    /* (3) WHEN USAGE IS 'COMP-1':                               */
    /*       THE PICTURE SHOULD BE ' '                           */
    /*       AND THE INFORMAT IS 'RB4.'                          */
    /*                                                           */
    /* (4) WHEN USAGE IS 'COMP-2' OR 'BINARY':                   */
    /*       THE PICTURE SHOULD BE ' '                           */
    /*       AND THE INFORMAT IS 'RB8.'                          */
    /*                                                           */
    /* (5) WHEN USAGE IS 'COMP-3' OR 'PCKDCML':                  */
    /*       THE PICTURE SHOULD BE '9'                           */
    /*       AND THE INFORMAT IS 'PD'                            */
    /*                                                           */
    /* (6) WHEN USAGE IS 'INDEX':                                */
    /*       THE PICTURE SHOULD BE ' '                           */
    /*       AND THE INFORMAT IS 'IB4.'                          */
    /*                                                           */

    IF (USAGE = 'DISPLAY') THEN DO;
       IF SUBSTR(PICTURE,1,1) = 'A' OR
          SUBSTR(PICTURE,1,1) = 'X' THEN DO;
          WIDTH = PUT(INT,12.);
          INFMT = '$CHAR'?/?/TRIM(LEFT(WIDTH))?/?/'.';
          END;  /* PICTURE IS 'A' OR 'X' */
       ELSE IF SUBSTR(PICTURE,1,1) = '9' THEN DO;
          NUM_DIG = INT + FRACT;
          WIDTH = PUT(NUM_DIG,12.);
          DECIMAL = PUT(FRACT,12.);
          IF BWZ_FLAG= 'Y' THEN
             INFMT = 'ZDB'?/?/TRIM(LEFT(WIDTH))?/?/'.'
                     ?/?/TRIM(LEFT(DECIMAL));
          ELSE
             INFMT = 'ZD'?/?/TRIM(LEFT(WIDTH))?/?/'.'
                     ?/?/TRIM(LEFT(DECIMAL));
          END;  /* PICTURE IS '9' */
       ELSE DO;
          /* UNRECOGNIZED SYNTAX */
          END;
       END;  /* IF (USAGE='DISPLAY') */
    ELSE IF (USAGE = 'COMP') OR (USAGE = 'COMP-4') THEN DO;
       IF SUBSTR(PICTURE,1,1) = '9' THEN DO;
          NUM_DIG = INT + FRACT;
          IF (NUM_DIG GE 1) AND (NUM_DIG LE 4) THEN
             WIDTH = '2';
          ELSE IF (NUM_DIG GE 5) AND (NUM_DIG LE 9) THEN
             WIDTH = '4';
          ELSE IF (NUM_DIG GE 10) AND (NUM_DIG LE 18) THEN
             WIDTH = '8';

          DECIMAL = PUT(FRACT,12.);
          INFMT = 'IB'?/?/TRIM(LEFT(WIDTH))?/?/'.'
                  ?/?/TRIM(LEFT(DECIMAL));
          END;  /* PICTURE IS '9' */
       ELSE DO;
          /* UNRECOGNIZED SYNTAX */
          END;
       END;  /* ELSE IF (USAGE='COMP') OR (USAGE='COMP-4') */
    ELSE IF (USAGE = 'COMP-1') THEN DO;
       INFMT = 'RB4.';
       END;  /* ELSE IF (USAGE='COMP-1') */
    ELSE IF (USAGE = 'COMP-2') OR (USAGE = 'BINARY') THEN DO;
       INFMT = 'RB8.';
       END;  /* ELSE IF (USAGE='COMP-2') OR (USAGE='BINARY') */
    ELSE IF (USAGE = 'COMP-3') OR (USAGE = 'PCKDCML') THEN DO;
       /*                                                        */
       /*   THE NUMBER OF BYTES IS EQUAL TO:                     */
       /*                                                        */
       /*     CEIL((# OF DIGITS STORED + 1) / 2)                 */
       /*                                                        */
       IF SUBSTR(PICTURE,1,1) = '9' THEN DO;
          NUM_BYTE = CEIL((INT + FRACT + 1) / 2);
          WIDTH = PUT(NUM_BYTE,12.);
          DECIMAL = PUT(FRACT,12.);
          INFMT = 'PD'?/?/TRIM(LEFT(WIDTH))?/?/'.'
                  ?/?/TRIM(LEFT(DECIMAL));
          END;  /* PICTURE IS '9' */
       ELSE DO;
          /* UNRECOGNIZED SYNTAX */
          END;
       END;  /* ELSE IF (USAGE='COMP-3') OR (USAGE='PCKDCML') */
    ELSE IF (USAGE = 'INDEX') THEN DO;
       INFMT = 'IB4.';
       END;  /* ELSE IF (USAGE='INDEX') */
    ELSE DO;
       INFMT = ' ';
       END;  /* ELSE DO */
 RETURN;  /* FROM GETINFMT */

 GETBYTES:
    /*                                                           */
    /* GETBYTES:                                                 */
    /*    GET BYTES                                              */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    RETURN THE NUMBER OF BYTES IN A DATA ITEM.             */
    /*                                                           */
    /* INPUT:                                                    */
    /*    USAGE      - DESCRIBES THE DATA'S REPRESENTATION.      */
    /*    INT        - THE NUMBER OF CHARACTERS TO THE LEFT OF   */
    /*                 THE DECIMAL POINT. THIS IS RETURNED FROM  */
    /*                 FIXPIC.                                   */
    /*    FRACT      - THE NUMBER OF CHARACTERS TO THE RIGHT OF  */
    /*                 THE DECIMAL POINT. THIS IS RETURNED FROM  */
    /*                 FIXPIC.                                   */
    /*                                                           */
    /* OUTPUT:                                                   */
    /*    BYTES      - NUMBER OF BYTES IN THIS ITEM.             */
    /*                                                           */
    SELECT (USAGE);
       WHEN ('BINARY') DO;
          /* EQUIVALENT TO COMP-2.                               */
          BYTES = 8;
          END;  /* WHEN 'BINARY' */
       WHEN ('COMP') DO;
          IF (1 LE (INT + FRACT)) AND
             ((INT + FRACT) LE 4) THEN DO;
             BYTES = 2;
             END;  /* IF (1 LE (INT + FRACT)) ETC. */
          ELSE IF (5 LE (INT+FRACT)) AND
                  ((INT+FRACT) LE 9) THEN DO;
             BYTES = 4;
             END;   /* ELSE IF (5 LE (INT+FRACT)) ETC. */
          ELSE IF (10 LE (INT+FRACT)) AND
                  ((INT+FRACT) LE 18) THEN DO;
             BYTES = 8;
             END;  /* ELSE IF (10 LE (INT+FRACT)) ETC. */
          END;  /* WHEN 'COMP' */
       WHEN ('COMP-1') DO;
          BYTES = 4;
          END;  /* WHEN 'COMP-1' */
       WHEN ('COMP-2') DO;
          BYTES = 8;
          END;  /* WHEN 'COMP-2' */
       WHEN ('COMP-3') DO;
          BYTES = CEIL((INT + FRACT + 1)/2);
          END;  /* WHEN 'COMP-3' */
       WHEN ('COMP-4') DO;
          /* EQUIVALENT TO COMP.                                 */
          IF (1 LE (INT + FRACT)) AND
             ((INT + FRACT) LE 4) THEN DO;
             BYTES = 2;
             END;  /* IF (1 LE (INT + FRACT)) ETC. */
          ELSE IF (5 LE (INT+FRACT)) AND
                  ((INT+FRACT) LE 9) THEN DO;
             BYTES = 4;
             END;   /* ELSE IF (5 LE (INT+FRACT)) ETC. */
          ELSE IF (10 LE (INT+FRACT)) AND
                  ((INT+FRACT) LE 18) THEN DO;
             BYTES = 8;
             END;  /* ELSE IF (10 LE (INT+FRACT)) ETC. */
          END;  /* WHEN 'COMP-4' */
       WHEN ('DISPLAY') DO;
          BYTES = INT + FRACT;
          END;  /* WHEN 'DISPLAY' */
       WHEN ('INDEX') DO;
          /* INDEX IS A 4 BYTE ELEMENTARY ITEM.                  */
          BYTES = 4;
          END;  /* WHEN 'INDEX' */
       WHEN ('PCKDCML') DO;
          /* EQUIVALENT TO COMP-3.                               */
          BYTES = CEIL((INT + FRACT + 1)/2);
          END;  /* WHEN 'PACKED-DECIMAL' */
       OTHERWISE DO;
          BYTES = 0;
          END;  /* OTHERWISE */
       END;  /* SELECT USAGE */
 RETURN;  /* FROM GETBYTES */

 STKUSAGE:
    /*                                                           */
    /* STKUSAGE:                                                 */
    /*    STACK USAGE                                            */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    TRACK THE USAGE ASSIGNED TO EACH LEVEL.                */
    /*                                                           */
    /*                                                           */
    /* GLOBAL VARIABLES:                                         */
    /*                                                           */
    /*    NOT ALTERED BY THIS PROCEDURE:                         */
    /*       DATANAME                                            */
    /*       LASTLVL                                             */
    /*       LVL                                                 */
    /*       TRACESTK                                            */
    /*                                                           */
    /*    ALTERED BY THIS PROCEDURE:                             */
    /*       NST_DPTH                                            */
    /*       UK_NDX                                              */
    /*       USAGE                                               */
    /*                                                           */
    /* LOCAL VARIABLES:                                          */
    /*    I                                                      */
    /*    UK_LVL1 - UK_LVL49                                     */
    /*    UK_USG1 - UK_USG49                                     */
    /*                                                           */
    /* NOTES:                                                    */
    /*    UK_NDX IS READ IN ROUTINE STKGROUP TO GET THE LEVEL    */
    /* OF NESTING.                                               */
    /*                                                           */
    /*    THERE MUST ALWAYS BE AT LEAST 1 ITEM ON THE USAGE      */
    /* STACK. FOR THIS REASON, UK_NDX MAY BECOME NO LESS THAN 1. */
    /*                                                           */

    IF (TRACESTK = '1') OR (TRACESTK = '2') THEN DO;
       PUT;
       PUT '====================================================';
       PUT ':' @3 'AT ENTRY INTO STKUSAGE:';
       PUT ':' @6 DATANAME=;
       PUT ':' @6 LVL= @15 LASTLVL= @28 USAGE= @43 UK_NDX=;
       PUT ':';
       END;  /* IF (TRACESTK = '1') OR (TRACESTK = '2') */

    IF LVL = 1 THEN DO;
       /* PUSH THE FIRST ITEM ONTO THE USAGE STACK.              */
       UK_NDX = 1;
       IF USAGE = ' ' THEN DO;
          UK_USG?(UK_NDX?) = 'DISPLAY';
          USAGE = 'DISPLAY';
          END;
       ELSE
          UK_USG?(UK_NDX?) = USAGE;
       UK_LVL?(UK_NDX?) = 1;
       END;  /* IF LVL = 1 */
    ELSE IF LVL LT LASTLVL THEN DO;

       IF (TRACESTK = '1') OR (TRACESTK = '2') THEN DO;
          PUT ':';
          PUT ':' @6 'LVL IS LESS THAN LASTLVL.';
          PUT ':' @6 'THE STATE OF THE USAGE STACK IS:';
          IF UK_NDX GT 0 THEN DO;
             DO I = 1 TO UK_NDX;
                PUT ':' @10 UK_LVL?(I?)= @23 UK_USG?(I?)=;
                END;  /* DO I = 1 TO UK_NDX */
             END;  /* IF UK_NDX GT 0 */
          PUT ':';
          END;  /* IF (TRACESTK = '1') OR (TRACESTK = '2') */

       /* POP ENTRIES OFF OF THE USAGE STACK.                    */
       DO WHILE(LVL LT UK_LVL?(UK_NDX?) AND (UK_NDX GT 1));
          UK_NDX = UK_NDX - 1;
          END;  /* DO WHILE */

       IF UK_NDX = 1 THEN DO;
          /* PUSH THE FIRST ITEM ONTO THE USAGE STACK.           */
          IF LVL = 1 THEN DO;
             IF USAGE = ' ' THEN DO;
                UK_USG?(UK_NDX?) = 'DISPLAY';
                USAGE = 'DISPLAY';
                UK_LVL?(UK_NDX?) = 1;
                END;  /* IF USAGE = ' ' */
             ELSE DO;
                UK_USG?(UK_NDX?) = USAGE;
                UK_LVL?(UK_NDX?) = 1;
                END;
             END;  /* IF LVL = 1 */
          ELSE IF LVL NE 1 THEN DO;
             IF USAGE = ' ' THEN DO;
                USAGE = UK_USG?(UK_NDX?);
                END;  /* IF USAGE = ' ' */
             UK_NDX + 1;
             UK_USG?(UK_NDX?) = USAGE;
             UK_LVL?(UK_NDX?) = LVL;
             END;  /* ELSE IF LVL NE 1 */
          END;  /* IF UK_NDX = 1 */
       ELSE IF USAGE = ' ' THEN DO;
          USAGE = UK_USG?(UK_NDX - 1?);
          UK_USG?(UK_NDX?) = USAGE;
          UK_LVL?(UK_NDX?) = LVL;
          END;  /* ELSE IF USAGE = ' ' */
       ELSE DO;
          UK_USG?(UK_NDX?) = USAGE;
          UK_LVL?(UK_NDX?) = LVL;
          END;
       END;  /* ELSE IF LVL LT LASTLVL */
    ELSE IF LVL EQ LASTLVL THEN DO;
       IF USAGE = ' ' THEN DO;
          USAGE = UK_USG?(UK_NDX - 1?);
          UK_USG?(UK_NDX?) = USAGE;
          END;
       ELSE DO;
          UK_USG?(UK_NDX?) = USAGE;
          END;
       END;  /* ELSE IF LVL EQ LASTLVL */
    ELSE IF LVL GT LASTLVL THEN DO;
       /* PUSH THE NEXT ITEM ONTO THE USAGE STACK.            */
       IF USAGE = ' ' THEN DO;
          USAGE = UK_USG?(UK_NDX?);
          UK_NDX + 1;
          UK_USG?(UK_NDX?) = USAGE;
          END;
       ELSE DO;
          UK_NDX + 1;
          UK_USG?(UK_NDX?) = USAGE;
          END;
       UK_LVL?(UK_NDX?) = LVL;
       END;  /* ELSE IF LVL GT LASTLVL */

    /*                                                           */
    /* SINCE THE VALUE IN UK_NDX IS REALLY THE DEPTH OF LEVEL    */
    /* NESTING, THIS IS THE NORMALIZED LEVEL NUMBER.             */
    /*                                                           */
    NST_DPTH = PUT(UK_NDX,2.);
    NST_DPTH = TRIM(LEFT(NST_DPTH));
    IF LENGTH(NST_DPTH) = 1 THEN
       NST_DPTH = '0'?/?/TRIM(LEFT(NST_DPTH));

    IF (TRACESTK = '1') OR (TRACESTK = '2') THEN DO;
       PUT ':';
       PUT ':' @3 'AT EXIT FROM STKUSAGE:';
       PUT ':' @6 LVL= @15 LASTLVL= @28 USAGE= @43 UK_NDX=;
       PUT ':';
       PUT ':' @6 'THE STATE OF THE USAGE STACK IS:';
       IF UK_NDX GT 0 THEN DO;
          DO I = 1 TO UK_NDX;
             PUT ':' @10 UK_LVL?(I?)= @23 UK_USG?(I?)=;
             END;  /* DO I = 1 TO UK_NDX */
          END;  /* IF UK_NDX GT 0 */
       PUT ':';
       PUT '====================================================';
       PUT;
       END;  /* IF (TRACESTK = '1') OR (TRACESTK = '2') */
 RETURN;  /* FROM STKUSAGE */

 STKGROUP:
    /*                                                           */
    /* STKGROUP:                                                 */
    /*    STACK GROUP                                            */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    TRACK GROUPS OF ELEMENTARY ITEMS.                      */
    /*                                                           */
    /*                                                           */
    /* GLOBAL VARIABLES:                                         */
    /*                                                           */
    /*    NOT ALTERED BY THIS PROCEDURE:                         */
    /*       BYTES                                               */
    /*       DATANAME                                            */
    /*       GRP_TYPE                                            */
    /*       LVL                                                 */
    /*       OCR_VAL                                             */
    /*       RDF_NAME                                            */
    /*       TRACESTK                                            */
    /*       UK_NDX                                              */
    /*       USAGE                                               */
    /*                                                           */
    /*    ALTERED BY THIS PROCEDURE:                             */
    /*       ATBYTE                                              */
    /*       GRPID                                               */
    /*       G_AT                                                */
    /*       G_GRPID                                             */
    /*       G_LEN                                               */
    /*       G_LVL                                               */
    /*       G_OCR                                               */
    /*       G_NAM                                               */
    /*       G_NST                                               */
    /*       G_RDF                                               */
    /*       G_TYP                                               */
    /*                                                           */
    /* LOCAL VARIABLES:                                          */
    /*    DONE                                                   */
    /*    I                                                      */
    /*    GK_NDX                                                 */
    /*    GK_AT1  - GK_AT49                                      */
    /*    GK_ID1 -  GK_ID49                                      */
    /*    GK_LEN1 - GK_LEN49                                     */
    /*    GK_LVL1 - GK_LVL49                                     */
    /*    GK_NAM1 - GK_NAM49                                     */
    /*    GK_NST1 - GK_NST49                                     */
    /*    GK_OCR1 - GK_OCR49                                     */
    /*    GK_RDF1 - GK_RDF49                                     */
    /*    GK_TYP1 - GK_TYP49                                     */
    /*                                                           */
    /* NOTES:                                                    */
    /*    ALL OF THE LOCAL VARIABLES (EXCEPT I AND DONE) MAY BE  */
    /* USED IN ROUTINE EODDSCTN. WHEN EODDSCTN IS CALLED, AND IF */
    /* GK_NDX IS GREATER THAN 1, THEN ALL ITEMS ON THE GROUP     */
    /* STACK ARE UPDATED AND POPPED OFF OF THE STACK.            */
    /*                                                           */
    /*    IF THERE ARE NO GROUPS, THERE WILL NEVER BE ANY ITEMS  */
    /* ON THE GROUP STACK. FOR THIS REASON, GK_NDX MAY BECOME 0. */
    /*                                                           */

    IF (TRACESTK = '1') OR (TRACESTK = '3') OR
       (TRACESTK = '6') OR (TRACESTK = '7') THEN DO;
       PUT;
       PUT '====================================================';
       PUT ':' @3 'AT ENTRY INTO STKGROUP:';
       PUT ':' @6 DATANAME=;
       PUT ':' @6 LVL= @34 GK_NDX= @;
       IF GK_NDX GT 0 THEN
          PUT @16 GK_LVL?(GK_NDX?)=;
       ELSE
          PUT;
       PUT ':' @6 USAGE= @22 GRP_TYPE=;
       PUT ':' @6 ATBYTE= @22 BYTES= @38 GRPID= @52 D_GRPID=;
       PUT ':';
       END;  /* IF (TRACESTK = '1') ETC. */

    IF LVL = 1 THEN
       GK_NDX = 0;

    IF GK_NDX = 0 THEN DO;
       IF USAGE = 'GROUP' THEN DO;
          /* PUSH THE FIRST ITEM ONTO THE GROUP STACK.           */
          GK_NDX = 1;
          GK_ID?(GK_NDX?) = GRPID;
          GK_LVL?(GK_NDX?) = LVL;
          GK_NST?(GK_NDX?) = UK_NDX;
          GK_NAM?(GK_NDX?) = DATANAME;
          GK_TYP?(GK_NDX?) = GRP_TYPE;
          GK_AT?(GK_NDX?)  = ATBYTE;
          GK_LEN?(GK_NDX?) = 0;
          GK_OCR?(GK_NDX?) = OCR_VAL;
          GK_RDF?(GK_NDX?) = RDF_NAME;
          D_GRPID = GRPID;
          GRPID + 1;
          END;  /* IF USAGE = 'GROUP' */
       END;  /* IF GK_NDX = 0 */
    ELSE IF LVL LE GK_LVL?(GK_NDX?) THEN DO;
       IF (TRACESTK = '1') OR (TRACESTK = '3') OR
          (TRACESTK = '6') OR (TRACESTK = '7') THEN DO;
          PUT ':';
          PUT ':' @6 'LVL IS LESS THAN OR EQUAL TO GK_LVL(GK_NDX)';
          PUT ':' @6 'THE STATE OF THE GROUP STACK IS:';
          IF GK_NDX GT 0 THEN DO;
             DO I = 1 TO GK_NDX;
                PUT ':' @10 GK_ID?(I?)=  @30 GK_TYP?(I?)=;
                PUT ':' @10 GK_LVL?(I?)= @30 GK_NAM?(I?)=;
                PUT ':' @10 GK_AT?(I?)=  @30 GK_LEN?(I?)=;
                PUT ':' @10 GK_OCR?(I?)= @30 GK_RDF?(I?)=;
                PUT ':';
                END;  /* DO I = 1 TO UK_NDX */
             END;  /* IF GK_NDX GT 0 */
          PUT ':';
          END;  /* IF (TRACESTK = '1') ETC. */

       /* POP ITEMS OFF OF THE GROUP STACK.                      */
       DONE = 0;
       DO WHILE(NOT DONE);

          IF GK_TYP?(GK_NDX?) = 'OCCURS' THEN DO;
             /*                                                  */
             /* 1) SUBTRACT THE CONTRIBUTION OF EACH ELEMENTARY  */
             /*    ITEM IN THE GROUP JUST ENDED FROM THE LENGTH  */
             /*    OF EVERY OTHER GROUP ON THE GROUP-STACK.      */
             /* 2) CALCULATE THE ACTUAL CONTRIBUTION OF          */
             /*    ENTIRE GROUP JUST ENDED.                      */
             /* 3) ADD THE CONTRIBUTION OF THE GROUP JUST ENDED  */
             /*    TO THE LENGTH OF EVERY OTHER GROUP ON THE     */
             /*    GROUP-STACK.                                  */
             /*                                                  */
             DO I = 1 TO GK_NDX - 1;
                GK_LEN?(I?) = GK_LEN?(I?) - GK_LEN?(GK_NDX?);
                END;  /* DO I = 1 TO GK_NDX - 1 */
             GK_LEN?(GK_NDX?) = GK_LEN?(GK_NDX?) *
                                INPUT(GK_OCR?(GK_NDX?),12.);
             DO I = 1 TO GK_NDX - 1;
                GK_LEN?(I?) = GK_LEN?(I?) + GK_LEN?(GK_NDX?);
                END;  /* DO I = 1 TO GK_NDX - 1 */
             END;  /* IF G_TYP?(GK_NDX?) = 'OCCURS' */
          ELSE IF GK_TYP?(GK_NDX?) = 'REDEFINES' THEN DO;
             /*                                                  */
             /* SUBTRACT THE CONTRIBUTION OF EACH ELEMENTARY     */
             /* ITEM IN THE GROUP JUST ENDED FROM THE LENGTH     */
             /* OF EVERY OTHER GROUP ON THE GROUP-STACK.         */
             /*                                                  */
             DO I = 1 TO GK_NDX - 1;
                GK_LEN?(I?) = GK_LEN?(I?) - GK_LEN?(GK_NDX?);
                END;  /* DO I = 1 TO GK_NDX - 1 */
             END;  /* ELSE IF GK_TYP?(GK_NDX?) = 'REDEFINES' */

          G_GRPID = GK_ID?(GK_NDX?);
          G_LVL = GK_LVL?(GK_NDX?);
          G_NST = GK_NST?(GK_NDX?);
          G_NAM = GK_NAM?(GK_NDX?);
          G_TYP = GK_TYP?(GK_NDX?);
          G_AT  = GK_AT?(GK_NDX?);
          G_LEN = GK_LEN?(GK_NDX?);
          G_OCR = GK_OCR?(GK_NDX?);
          G_RDF = GK_RDF?(GK_NDX?);
          OUTPUT GROUP;
          GK_NDX = GK_NDX - 1;
          IF GK_NDX = 0 THEN
             DONE = 1;
          ELSE IF LVL GT GK_LVL?(GK_NDX?) THEN
             DONE = 1;
          END;  /* DO WHILE */

       /*                                                        */
       /* UPDATE ATBYTE BASED UPON THE STARTING BYTE AND THE     */
       /* TOTAL LENGTH OF THE GROUP JUST ENDED.                  */
       /*                                                        */

 /* 14FEB94 TWZ **************************************************/
       IF GK_NDX LE 0 THEN
          ATBYTE = GK_AT?(1?) + GK_LEN?(1?);
       ELSE IF GRP_TYPE EQ 'REDEFINES' THEN
          ATBYTE = GK_AT?(GK_NDX?);
       ELSE
          ATBYTE = GK_AT?(GK_NDX?) + GK_LEN?(GK_NDX?);
 /****************************************************************/

       IF USAGE = 'GROUP' THEN DO;
          /* PUSH THE FIRST ITEM ONTO THE GROUP STACK.           */
          GK_NDX = GK_NDX + 1;
          GK_ID?(GK_NDX?) = GRPID;
          GK_LVL?(GK_NDX?) = LVL;
          GK_NST?(GK_NDX?) = UK_NDX;
          GK_NAM?(GK_NDX?) = DATANAME;
          GK_TYP?(GK_NDX?) = GRP_TYPE;
          GK_AT?(GK_NDX?)  = ATBYTE;
          GK_LEN?(GK_NDX?) = 0;
          GK_OCR?(GK_NDX?) = OCR_VAL;
          GK_RDF?(GK_NDX?) = RDF_NAME;
          D_GRPID = GRPID;
          GRPID + 1;
          END;  /* IF USAGE = 'GROUP' */
       END;  /* ELSE IF LVL LE GK_LVL?(GK_NDX?) */
    ELSE IF LVL GT GK_LVL?(GK_NDX?) THEN DO;
       IF USAGE = 'GROUP' THEN DO;
          /* PUSH THE NEXT ITEM ONTO THE GROUP STACK.            */
          GK_NDX = GK_NDX + 1;
          GK_ID?(GK_NDX?) = GRPID;
          GK_LVL?(GK_NDX?) = LVL;
          GK_NST?(GK_NDX?) = UK_NDX;
          GK_NAM?(GK_NDX?) = DATANAME;
          GK_TYP?(GK_NDX?) = GRP_TYPE;
          GK_AT?(GK_NDX?)  = ATBYTE;
          GK_LEN?(GK_NDX?) = 0;
          GK_OCR?(GK_NDX?) = OCR_VAL;
          GK_RDF?(GK_NDX?) = RDF_NAME;
          D_GRPID = GRPID;
          GRPID + 1;
          END;  /* IF USAGE = 'GROUP' */
       END;  /* ELSE IF LVL GT GK_LVL?(GK_NDX?) */

    /*                                                           */
    /* ADD THE CONTRIBUTION OF EACH ELEMENTARY ITEM TO THE       */
    /* LENGTH OF EVERY GROUP ON THE GROUP-STACK.                 */
    /*                                                           */
    DO I = 1 TO GK_NDX;
       GK_LEN?(I?) = GK_LEN?(I?) + BYTES;
       END;  /* DO I = 1 TO GK_NDX */

    IF (TRACESTK = '1') OR (TRACESTK = '3') OR
       (TRACESTK = '6') OR (TRACESTK = '7') THEN DO;
       PUT ':';
       PUT ':' @3 'AT EXIT FROM STKGROUP:';
       PUT ':' @6 LVL= @34 GK_NDX= @;
       IF GK_NDX GT 0 THEN
          PUT @16 GK_LVL?(GK_NDX?)=;
       ELSE
          PUT;
       PUT ':' @6 USAGE= @22 GRP_TYPE=;
       PUT ':' @6 ATBYTE= @22 BYTES= @38 GRPID= @52 D_GRPID=;
       PUT ':';
       PUT ':' @6 'THE STATE OF THE GROUP STACK IS:';
       IF GK_NDX GT 0 THEN DO;
          DO I = 1 TO GK_NDX;
             PUT ':' @10 GK_ID?(I?)=  @30 GK_TYP?(I?)=;
             PUT ':' @10 GK_LVL?(I?)= @30 GK_NAM?(I?)=;
             PUT ':' @10 GK_AT?(I?)=  @30 GK_LEN?(I?)=;
             PUT ':' @10 GK_OCR?(I?)= @30 GK_RDF?(I?)=;
             PUT ':';
             END;  /* DO I = 1 TO UK_NDX */
          END;  /* IF GK_NDX GT 0 */
       PUT ':';
       PUT '====================================================';
       PUT;
       END;  /* IF (TRACESTK = '1') ETC. */
 RETURN;  /* FROM STKGROUP */

 STKREDEF:
    /*                                                           */
    /* STKREDEF:                                                 */
    /*    STACK REDEFINES                                        */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    KEEP TRACK OF THE STARTING BYTE OF THE LAST ITEM/GROUP */
    /* FOR USE IN THE EVENT THAT ITEM/GROUP IS REDEFINED.        */
    /*                                                           */
    /* GLOBAL VARIABLES:                                         */
    /*                                                           */
    /*    NOT ALTERED BY THIS PROCEDURE:                         */
    /*       BYTES                                               */
    /*       DATANAME                                            */
    /*       GRP_TYPE                                            */
    /*       LASTLVL                                             */
    /*       LVL                                                 */
    /*       RDF_NAME                                            */
    /*       TRACESTK                                            */
    /*                                                           */
    /*    ALTERED BY THIS PROCEDURE:                             */
    /*       ATBYTE                                              */
    /*       ITM_DISP                                            */
    /*                                                           */
    /* LOCAL VARIABLES:                                          */
    /*    I                                                      */
    /*    RK_NDX                                                 */
    /*    RK_AT1  - RK_AT49                                      */
    /*    RK_DSP1 - RK_DSP49                                     */
    /*    RK_LEN1 - RK_LEN49                                     */
    /*    RK_LVL1 - RK_LVL49                                     */
    /*    RK_TYP1 - RK_TYP49                                     */
    /*    RK_RNM1 - RK_RNM49                                     */
    /*                                                           */
    /* NOTES:                                                    */
    /*    THERE MUST ALWAYS BE AT LEAST 1 ITEM ON THE REDEFINES  */
    /* STACK. FOR THIS REASON, RK_NDX MAY BECOME NO LESS THAN 1. */
    /*                                                           */

    IF (TRACESTK = '1') OR (TRACESTK = '4') OR
       (TRACESTK = '6') OR (TRACESTK = '7') THEN DO;
       PUT;
       PUT '====================================================';
       PUT ':' @3 'AT ENTRY INTO STKREDEF:';
       PUT ':' @6 DATANAME=;
       PUT ':' @6 LVL= @16 LASTLVL= @34 RK_NDX=;
       PUT ':' @6 ATBYTE= @22 ITM_DISP= @40 RDF_NAME=;
       PUT ':';
       END;  /* IF (TRACESTK = '1') ETC. */

    IF LVL = 1 THEN DO;
       /* PUSH THE FIRST ITEM ONTO THE REDEFINES STACK.          */
       RK_NDX = 1;
       RK_LVL?(RK_NDX?) = 1;
       RK_LEN?(RK_NDX?) = BYTES;
       RK_RNM?(RK_NDX?) = ' ';
       RK_TYP?(RK_NDX?) = GRP_TYPE;
       RK_AT?(RK_NDX?) = 1;
       RK_DSP?(RK_NDX?) = 0;
       END;  /* IF LVL = 1 */
    ELSE IF LVL LT LASTLVL THEN DO;

       IF (TRACESTK = '1') OR (TRACESTK = '4') OR
          (TRACESTK = '6') OR (TRACESTK = '7') THEN DO;
          PUT ':';
          PUT ':' @6 'LVL IS LESS THAN LASTLVL.';
          PUT ':' @6 'THE STATE OF THE REDEFINES STACK IS:';
          IF RK_NDX GT 0 THEN DO;
             DO I = 1 TO RK_NDX;
                PUT ':' @10 RK_LVL?(I?)=;
                PUT ':' @10 RK_LEN?(I?)= @30 RK_RNM?(I?)=;
                PUT ':' @10 RK_TYP?(I?)=;
                PUT ':' @10 RK_AT?(I?)=  @30 RK_DSP?(I?)=;
                PUT ':' ;
                END;  /* DO I = 1 TO RK_NDX */
             END;  /* IF RK_NDX GT 0 */
          PUT ':';
          END;  /* IF (TRACESTK = '1') ETC. */

       /* POP ITEMS OFF OF THE REDEFINES STACK.                  */
       DO WHILE(LVL LT RK_LVL?(RK_NDX?) AND (RK_NDX GT 1));
          RK_NDX = RK_NDX - 1;
          END;  /* DO WHILE */

       IF RK_NDX = 1 THEN DO;
          /* PUSH THE FIRST ITEM ONTO THE REDEFINES STACK.       */
          RK_LVL?(RK_NDX?) = 1;
          RK_LEN?(RK_NDX?) = BYTES;
          RK_RNM?(RK_NDX?) = ' ';
          RK_TYP?(RK_NDX?) = GRP_TYPE;
          RK_AT?(RK_NDX?) = 1;
          RK_DSP?(RK_NDX?) = 0;
          END;  /* IF RK_NDX = 1 */
       ELSE IF LVL EQ RK_LVL?(RK_NDX?) THEN DO;
          IF RDF_NAME EQ ' ' THEN DO;
             /* NO REDEFINITION                                  */
             IF RK_RNM?(RK_NDX?) EQ ' ' THEN DO;
                /* PREVIOUS ENTRY WAS NOT A REDEFINING ENTRY.    */
                RK_LEN?(RK_NDX?) = BYTES;
                RK_RNM?(RK_NDX?) = ' ';
                RK_TYP?(RK_NDX?) = GRP_TYPE;
                RK_AT?(RK_NDX?) = ATBYTE;
                RK_DSP?(RK_NDX?) = ITM_DISP;
                END;  /* IF RK_RNM?(RK_NDX?) EQ ' ' */
             ELSE DO;
                /* PREVIOUS ENTRY WAS A REDEFINING ENTRY.        */
                RK_AT?(RK_NDX?) = RK_AT?(RK_NDX?)
                                  + RK_LEN?(RK_NDX?);
                RK_DSP?(RK_NDX?) = RK_DSP?(RK_NDX?)
                                   + RK_LEN?(RK_NDX?);

 /* 14FEB94 TWZ **************************************************/
                IF GRP_TYPE = 'ITEM' THEN DO;
                   RK_AT?(RK_NDX?) = ATBYTE;
                   RK_DSP?(RK_NDX?) = ITM_DISP;
                END;  /* IF GRP_TYPE = 'ITEM' */
                ELSE DO;
                   ATBYTE = RK_AT?(RK_NDX?);
                   ITM_DISP = RK_DSP?(RK_NDX?);
                END;  /* ELSE DO */
 /****************************************************************/

                /* SINCE THE CURRENT ENTRY IS NOT A REDEFINING   */
                /* ENTRY, UPDATE THE REDEFINES-STACK LENGTH.     */
                RK_LEN?(RK_NDX?) = BYTES;
                RK_RNM?(RK_NDX?) = ' ';
                RK_TYP?(RK_NDX?) = GRP_TYPE;
                END;  /* ELSE DO */
             END;  /* IF RDF_NAME EQ ' ' */
          ELSE DO;
             IF RK_RNM?(RK_NDX?) = ' ' THEN DO;
                /* THE FIRST REDEFINITION                        */
                /*                                               */
                /* AT THE FIRST REDEFINITION, CALCULATE THE      */
                /* REDEFINED AREA'S LENGTH AND MAINTAIN A COPY   */
                /* OF IT IN THE REDEFINES-STACK LENGTH FIELD.    */

 /* 14FEB94 TWZ **************************************************/
                IF (ATBYTE - RK_AT?(RK_NDX?)) LE 0 THEN
                   RK_LEN?(RK_NDX?) = 0;
                ELSE
                   RK_LEN?(RK_NDX?) = ATBYTE - RK_AT?(RK_NDX?);
 /****************************************************************/

                END;  /* IF RK_RNM?(RK_NDX?) = ' ' */
             ELSE DO;
                /* MULTIPLE REDEFINITION                         */
                /*                                               */
                /* DO NOT ALTER THE REDEFINES-STACK LENGTH FIELD */
                /* FOR MULTIPLE REDEFINITION.                    */
                /*                                               */
                /* MULTIPLE REDEFINITION IS OF THE FORM:         */
                /*    B REDEFINES A                              */
                /*    C REDEFINES A                              */
                /*                                               */
                /* MULTIPLE REDEFINITION IS NOT OF THE FORM:     */
                /*    B REDEFINES A                              */
                /*    C REDEFINES B                              */
                /*                                               */
                END;  /* ELSE DO */
             RK_RNM?(RK_NDX?) = RDF_NAME;
             RK_TYP?(RK_NDX?) = GRP_TYPE;
             ATBYTE = RK_AT?(RK_NDX?);
             ITM_DISP = RK_DSP?(RK_NDX?);
             END;  /* ELSE DO */
          END;  /* ELSE IF LVL EQ RK_LVL?(RK_NDX?) */
       ELSE DO;
          /* PUSH THE NEXT ITEM ONTO THE REDEFINES STACK.        */
          RK_NDX + 1;
          RK_LVL?(RK_NDX?) = LVL;
          RK_LEN?(RK_NDX?) = BYTES;
          RK_RNM?(RK_NDX?) = RDF_NAME;
          RK_TYP?(RK_NDX?) = GRP_TYPE;
          RK_AT?(RK_NDX?) = ATBYTE;
          RK_DSP?(RK_NDX?) = ITM_DISP;
          END;  /* ELSE DO */
       END;  /* ELSE IF LVL LT LASTLVL */
    ELSE IF LVL EQ LASTLVL THEN DO;
       IF RDF_NAME EQ ' ' THEN DO;
          /* NO REDEFINITION                                     */
          IF RK_RNM?(RK_NDX?) EQ ' ' THEN DO;
             /* PREVIOUS ENTRY WAS NOT A REDEFINING ENTRY.       */
             RK_LEN?(RK_NDX?) = BYTES;
             RK_RNM?(RK_NDX?) = ' ';
             RK_TYP?(RK_NDX?) = GRP_TYPE;
             RK_AT?(RK_NDX?) = ATBYTE;
             RK_DSP?(RK_NDX?) = ITM_DISP;
             END;  /* IF RK_RNM?(RK_NDX?) EQ ' ' */
          ELSE DO;
             /* PREVIOUS ENTRY WAS A REDEFINING ENTRY.           */
             RK_AT?(RK_NDX?) = RK_AT?(RK_NDX?) + RK_LEN?(RK_NDX?);
             RK_DSP?(RK_NDX?) = RK_DSP?(RK_NDX?)
                                + RK_LEN?(RK_NDX?);
             ATBYTE = RK_AT?(RK_NDX?);
             ITM_DISP = RK_DSP?(RK_NDX?);
             RK_LEN?(RK_NDX?) = BYTES;
             RK_RNM?(RK_NDX?) = ' ';
             RK_TYP?(RK_NDX?) = GRP_TYPE;
             END;  /* ELSE DO */
          END;  /* IF RDF_NAME EQ ' ' */
       ELSE DO;
          IF RK_RNM?(RK_NDX?) = ' ' THEN DO;
             /* THE FIRST REDEFINITION                           */

 /* 14FEB94 TWZ **************************************************/
             IF (ATBYTE - RK_AT?(RK_NDX?)) LE 0 THEN
                RK_LEN?(RK_NDX?) = 0;
             ELSE
                RK_LEN?(RK_NDX?) = ATBYTE - RK_AT?(RK_NDX?);
 /****************************************************************/

             END;  /* IF RK_RNM?(RK_NDX?) = ' ' */
          ELSE DO;
             /* MULTIPLE REDEFINITION                            */
             END;  /* ELSE DO */
          RK_RNM?(RK_NDX?) = RDF_NAME;
          RK_TYP?(RK_NDX?) = GRP_TYPE;
          ATBYTE = RK_AT?(RK_NDX?);
          ITM_DISP = RK_DSP?(RK_NDX?);
          END;  /* ELSE DO */
       END;  /* ELSE IF LVL EQ LASTLVL */
    ELSE IF LVL GT LASTLVL THEN DO;
       /* PUSH THE NEXT ITEM ONTO THE REDEFINES STACK.           */
       RK_NDX + 1;
       RK_LVL?(RK_NDX?) = LVL;
       RK_LEN?(RK_NDX?) = BYTES;
       RK_RNM?(RK_NDX?) = RDF_NAME;
       RK_TYP?(RK_NDX?) = GRP_TYPE;
       RK_AT?(RK_NDX?) = ATBYTE;
       RK_DSP?(RK_NDX?) = ITM_DISP;
       END;  /* ELSE IF LVL GT LASTLVL */

    IF (TRACESTK = '1') OR (TRACESTK = '4') OR
       (TRACESTK = '6') OR (TRACESTK = '7') THEN DO;
       PUT ':';
       PUT ':' @3 'AT EXIT FROM STKREDEF:';
       PUT ':' @6 LVL= @16 LASTLVL= @34 RK_NDX=;
       PUT ':' @6 ATBYTE= @22 ITM_DISP= @40 RDF_NAME=;
       PUT ':';
       PUT ':' @6 'THE STATE OF THE REDEFINES STACK IS:';
       IF RK_NDX GT 0 THEN DO;
          DO I = 1 TO RK_NDX;
             PUT ':' @10 RK_LVL?(I?)=;
             PUT ':' @10 RK_LEN?(I?)= @30 RK_RNM?(I?)=;
             PUT ':' @10 RK_TYP?(I?)=;
             PUT ':' @10 RK_AT?(I?)=  @30 RK_DSP?(I?)=;
             PUT ':' ;
             END;  /* DO I = 1 TO RK_NDX */
          END;  /* IF RK_NDX GT 0 */
       PUT ':';
       PUT '====================================================';
       PUT;
       END;  /* IF (TRACESTK = '1') ETC. */
 RETURN;  /* FROM STKREDEF */

 STKOFFST:
    /*                                                           */
    /* STKOFFST:                                                 */
    /*    STACK OFFSET                                           */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    TRACK THE BYTE AT WHICH EACH ITEM/GROUP THAT OCCURS    */
    /* MORE THAN ONCE BEGINS AND THE OFFSET OF EACH ITEM WITHIN  */
    /* THAT GROUP. THIS INFORMATION IS USED WHEN EXPANDING       */
    /* MULTIPLE OCCURRENCES OF ITEMS/GROUPS.                     */
    /*                                                           */
    /* GLOBAL VARIABLES:                                         */
    /*                                                           */
    /*   NOT ALTERED BY THIS PROCEDURE:                          */
    /*       ATBYTE                                              */
    /*       BYTES                                               */
    /*       DATANAME                                            */
    /*       LVL                                                 */
    /*       OCR_VAL                                             */
    /*       TRACESTK                                            */
    /*                                                           */
    /*    ALTERED BY THIS PROCEDURE:                             */
    /*       OCR_BASE                                            */
    /*       ITM_DISP                                            */
    /*                                                           */
    /* LOCAL VARIABLES:                                          */
    /*    DONE                                                   */
    /*    I                                                      */
    /*    J                                                      */
    /*    OK_NDX                                                 */
    /*    OK_BSE1 - OK_BSE49                                     */
    /*    OK_DSP1 - OK_DSP49                                     */
    /*    OK_LVL1 - OK_LVL49                                     */
    /*                                                           */
    /* NOTES:                                                    */
    /*    IF THERE ARE NO ITEMS/GROUPS THAT OCCUR MORE THAN      */
    /* ONCE, THERE WILL NEVER BE ANY ITEMS ON THE OFFSET STACK.  */
    /* FOR THIS REASON, OK_NDX MAY BECOME 0.                     */
    /*                                                           */

    IF (TRACESTK = '1') OR
       (TRACESTK = '5') OR (TRACESTK = '7') THEN DO;
       PUT;
       PUT '====================================================';
       PUT ':' @3 'AT ENTRY INTO STKOFFST:';
       PUT ':' @6 DATANAME=;
       PUT ':' @6 LVL= @34 OK_NDX= @;
       IF OK_NDX GT 0 THEN
          PUT @16 OK_LVL?(OK_NDX?)=;
       ELSE
          PUT;
       PUT ':' @6 OCR_VAL= ;
       PUT ':' @6 ATBYTE= @22 BYTES= @38 OCR_BASE= @57 ITM_DISP=;
       PUT ':';
       END;  /* IF (TRACESTK = '1') ETC. */

    IF LVL = 1 THEN DO;
       OK_NDX = 0;
       OCR_BASE = 0;
       ITM_DISP = 0;
       END;  /* IF LVL = 1 */

    IF OK_NDX = 0 THEN DO;
       IF OCR_VAL NE ' ' THEN DO;
          /* PUSH THE FIRST ITEM ONTO THE OFFSET STACK.          */
          OK_NDX = 1;
          OK_LVL?(OK_NDX?) = LVL;
          OK_BSE?(OK_NDX?) = ATBYTE;
          OK_DSP?(OK_NDX?) = 0;
          OCR_BASE = ATBYTE;
          ITM_DISP = 0;
          END;  /* IF OCR_VAL NE ' ' */
       END;  /* IF OK_NDX = 0 */
    ELSE IF LVL LE OK_LVL?(OK_NDX?) THEN DO;
       IF (TRACESTK = '1') OR
          (TRACESTK = '5') OR (TRACESTK = '7') THEN DO;
          PUT ':';
          PUT ':' @6 'LVL IS LESS THAN OR EQUAL TO OK_LVL(OK_NDX)';
          PUT ':' @6 'THE STATE OF THE OFFSET STACK IS:';
          IF OK_NDX GT 0 THEN DO;
             DO I = 1 TO OK_NDX;
                PUT ':' @10 OK_LVL?(I?)= @25 OK_BSE?(I?)=
                        @45 OK_DSP?(I?)=;
                END;  /* DO I = 1 TO UK_NDX */
             END;  /* IF OK_NDX GT 0 */
          PUT ':';
          END;  /* IF (TRACESTK = '1') ETC. */

       /* POP ITEMS OFF OF THE OFFSET STACK.                     */
       DONE = 0;
       DO WHILE(NOT DONE);
          OK_NDX = OK_NDX - 1;
          IF OK_NDX = 0 THEN
             DONE = 1;
          ELSE IF LVL GT OK_LVL?(OK_NDX?) THEN
             DONE = 1;
          END;  /* DO WHILE */

       IF OK_NDX GT 0 THEN DO;
          OCR_BASE = OK_BSE?(OK_NDX?);
          ITM_DISP = ATBYTE - OK_BSE?(OK_NDX?);
          END;  /* IF OK_NDX = 0 */
       ELSE DO;
          IF OCR_VAL NE ' ' THEN DO;
             /* PUSH THE FIRST ITEM ONTO THE OFFSET STACK.       */
             OK_NDX = 1;
             OK_LVL?(OK_NDX?) = LVL;
             OK_BSE?(OK_NDX?) = ATBYTE;
             OK_DSP?(OK_NDX?) = 0;
             OCR_BASE = ATBYTE;
             ITM_DISP = 0;
             END;  /* IF OCR_VAL NE ' ' */
          ELSE DO;
             OCR_BASE = 0;
             ITM_DISP = 0;
             END;  /* ELSE DO */
          END;  /* ELSE DO */
       END;  /* ELSE IF LVL LE LASTLVL */
    ELSE IF LVL GT OK_LVL?(OK_NDX?) THEN DO;
       IF OCR_VAL NE ' ' THEN DO;
          /* PUSH THE NEXT ITEM ONTO THE OFFSET STACK.           */
          OK_NDX + 1;
          OK_LVL?(OK_NDX?) = LVL;
          OK_BSE?(OK_NDX?) = ATBYTE;
          OK_DSP?(OK_NDX?) = 0;
          OCR_BASE = ATBYTE;
          ITM_DISP = 0;
          END;  /* IF OCR_VAL NE ' ' */
       END;  /* ELSE IF LVL GT LASTLVL */

    IF (TRACESTK = '1') OR
       (TRACESTK = '5') OR (TRACESTK = '7') THEN DO;
       PUT ':';
       PUT ':' @3 'AT EXIT FROM STKOFFST:';
       PUT ':' @6 LVL= @34 OK_NDX= @;
       IF OK_NDX GT 0 THEN
          PUT @16 OK_LVL?(OK_NDX?)=;
       ELSE
          PUT;
       PUT ':' @6 OCR_VAL= ;
       PUT ':' @6 ATBYTE= @22 BYTES= @38 OCR_BASE= @57 ITM_DISP=;
       PUT ':';
       PUT ':' @6 'THE STATE OF THE OFFSET STACK IS:';
       IF OK_NDX GT 0 THEN DO;
          DO I = 1 TO OK_NDX;
             PUT ':' @10 OK_LVL?(I?)= @25 OK_BSE?(I?)=
                     @45 OK_DSP?(I?)=;
             END;  /* DO I = 1 TO UK_NDX */
          END;  /* IF OK_NDX GT 0 */
       PUT ':';
       PUT '====================================================';
       PUT;
       END;  /* IF (TRACESTK = '1') ETC. */
 RETURN;  /* FROM STKOFFST */

 EODDNTRY:
    /*                                                           */
    /* EODDNTRY:                                                 */
    /*    END OF DATA DESCRIPTION ENTRY                          */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    EVALUATE THE DATA DESCRIPTION ENTRY JUST TERMINATED.   */
    /*                                                           */
    /*    THIS PROCEDURE IS CALLED WHEN THE BEGINNING OF A DATA  */
    /* DESCRIPTION ENTRY IS ENCOUNTERED BECAUSE THE BEGINNING OF */
    /* A DATA DESCRIPTION ENTRY IS USED AS THE DELIMITER FOR THE */
    /* PREVIOUS DATA DESCRIPTION ENTRY.                          */
    /*                                                           */
    /*    THIS PROCEDURE IS ALSO CALLED BY EODDSCTN WHEN THE END */
    /* OF THE DATA SECTION IS ENCOUNTERED.                       */
    /*                                                           */

    DD_ATTRS = PUT(AV_SUM,DDAVFMT.);
    DD_ATTRS = TRIM(LEFT(DD_ATTRS));
    IF TRACEPRS = '5' THEN DO;
       PUT;
       PUT 'AT END OF PREVIOUS DATA DESCRIPTOR: ' AV_SUM= DD_ATTRS=;
       END;  /* IF TRACEPRS = '5' */

    IF (DD_ATTRS = '1.') THEN DO;
       /* 01 CLAUSE                                              */
       LINK STKUSAGE;
       USAGE = 'GROUP';
       GRP_TYPE = 'RECORD';
       D_GRPID = 0;
       BYTES = 0;
       LINK STKGROUP;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       END;  /* IF (DD_ATTRS = '1.') */
    ELSE IF (DD_ATTRS = '2.') THEN DO;
       /* 02-49 CLAUSE                                           */
       LINK STKUSAGE;
       IF (USAGE = 'COMP-1') OR (USAGE = 'COMP-2') THEN DO;
          LINK GETINFMT;
          GRP_TYPE = 'ITEM';
          D_GRPID = 0;
          LINK GETBYTES;
          LINK STKGROUP;
          LINK STKREDEF;
          LINK STKOFFST;
          OUTPUT DICTNRY;
          ATBYTE = ATBYTE + BYTES;
          ITM_DISP = ITM_DISP + BYTES;
          END;  /* IF (USAGE = 'COMP-1') OR (USAGE = 'COMP-2') */
       ELSE DO;
          USAGE = 'GROUP';
          GRP_TYPE = 'RECORD';
          D_GRPID = 0;
          BYTES = 0;
          LINK STKGROUP;
          LINK STKREDEF;
          LINK STKOFFST;
          OUTPUT DICTNRY;
          END;  /* ELSE DO */
       END;  /* ELSE IF (DD_ATTRS = '2.')  */
    ELSE IF (DD_ATTRS = '2.3.') THEN DO;
       /* 02-49 CLAUSE REDEFINES CLAUSE                          */
       LINK STKUSAGE;
       USAGE = 'GROUP';
       GRP_TYPE = 'REDEFINES';
       D_GRPID = 0;
       BYTES = 0;
       LINK STKGROUP;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       END;  /* ELSE IF (DD_ATTRS = '2.3.') */
    ELSE IF (DD_ATTRS = '2.3.6.')
            OR (DD_ATTRS = '2.3.6.11.') THEN DO;
       /* 02-49 CLAUSE REDEFINES CLAUSE PICTURE CLAUSE           */
       /*    OR                                                  */
       /* 02-49 CLAUSE REDEFINES CLAUSE PICTURE CLAUSE           */
       /*              B.W.Z. CLAUSE                             */
       LINK STKUSAGE;
       LINK GETINFMT;
       GRP_TYPE = 'ITEM';
       D_GRPID = 0;
       BYTES = 0;
       LINK STKGROUP;
       LINK GETBYTES;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       ATBYTE = ATBYTE + BYTES;
       ITM_DISP = ITM_DISP + BYTES;
       END;  /* ELSE IF (DD_ATTRS = '2.3.6.') ETC. */
    ELSE IF (DD_ATTRS = '2.3.7.') THEN DO;
       /* 02-49 CLAUSE REDEFINES CLAUSE USAGE CLAUSE             */
       LINK STKUSAGE;
       IF (USAGE = 'COMP-1') OR (USAGE = 'COMP-2') THEN DO;
          LINK GETINFMT;
          GRP_TYPE = 'ITEM';
          D_GRPID = 0;
          BYTES = 0;
          LINK STKGROUP;
          LINK GETBYTES;
          LINK STKREDEF;
          LINK STKOFFST;
          OUTPUT DICTNRY;
          ATBYTE = ATBYTE + BYTES;
          ITM_DISP = ITM_DISP + BYTES;
          END;  /* IF (USAGE = 'COMP-1') OR (USAGE = 'COMP-2') */
       ELSE DO;
          USAGE = 'GROUP';
          GRP_TYPE = 'REDEFINES';
          D_GRPID = 0;
          BYTES = 0;
          LINK STKGROUP;
          LINK STKREDEF;
          LINK STKOFFST;
          OUTPUT DICTNRY;
          END;  /* ELSE DO */
       END;  /* ELSE IF (DD_ATTRS = '2.3.7.') */
    ELSE IF (DD_ATTRS = '2.3.6.7.')
            OR (DD_ATTRS = '2.3.6.7.11.') THEN DO;
       /* 02-49 CLAUSE REDEFINES CLAUSE PICTURE CLAUSE           */
       /*              USAGE CLAUSE                              */
       /*    OR                                                  */
       /* 02-49 CLAUSE REDEFINES CLAUSE PICTURE CLAUSE           */
       /*              USAGE CLAUSE B.W.Z. CLAUSE                */
       LINK STKUSAGE;
       LINK GETINFMT;
       GRP_TYPE = 'ITEM';
       D_GRPID = 0;
       BYTES = 0;
       LINK STKGROUP;
       LINK GETBYTES;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       ATBYTE = ATBYTE + BYTES;
       ITM_DISP = ITM_DISP + BYTES;
       END;  /* ELSE IF (DD_ATTRS = '2.3.6.7.') ETC. */
    ELSE IF (DD_ATTRS = '1.6.')
            OR (DD_ATTRS = '2.6.')
            OR (DD_ATTRS = '1.6.11.')
            OR (DD_ATTRS = '2.6.11.') THEN DO;
       /* 01 CLAUSE PICTURE CLAUSE                               */
       /*    OR                                                  */
       /* 02-49 CLAUSE PICTURE CLAUSE                            */
       /*    OR                                                  */
       /* 01 CLAUSE PICTURE CLAUSE B.W.Z. CLAUSE                 */
       /*    OR                                                  */
       /* 02-49 CLAUSE PICTURE CLAUSE B.W.Z. CLAUSE              */
       LINK STKUSAGE;
       LINK GETINFMT;
       GRP_TYPE = 'ITEM';
       D_GRPID = 0;
       LINK GETBYTES;
       LINK STKGROUP;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       ATBYTE = ATBYTE + BYTES;
       ITM_DISP = ITM_DISP + BYTES;
       END;  /* ELSE IF (DD_ATTRS = '1.6.') ETC. */
    ELSE IF (DD_ATTRS = '1.7.') OR (DD_ATTRS = '2.7.') THEN DO;
       /* 01 CLAUSE USAGE CLAUSE                                 */
       /*    OR                                                  */
       /* 02-49 CLAUSE USAGE CLAUSE                              */
       LINK STKUSAGE;
       IF (USAGE = 'COMP-1') OR (USAGE = 'COMP-2') THEN DO;
          LINK GETINFMT;
          GRP_TYPE = 'ITEM';
          D_GRPID = 0;
          LINK GETBYTES;
          LINK STKGROUP;
          LINK STKREDEF;
          LINK STKOFFST;
          OUTPUT DICTNRY;
          ATBYTE = ATBYTE + BYTES;
          ITM_DISP = ITM_DISP + BYTES;
          END;  /* IF (USAGE = 'COMP-1') OR (USAGE = 'COMP-2') */
       ELSE DO;
          USAGE = 'GROUP';
          GRP_TYPE = 'RECORD';
          D_GRPID = 0;
          BYTES = 0;
          LINK STKGROUP;
          LINK STKREDEF;
          LINK STKOFFST;
          OUTPUT DICTNRY;
          END;  /* ELSE DO */
       END;  /* ELSE IF (DD_ATTRS = '1.7.') ETC. */
    ELSE IF (DD_ATTRS = '1.6.7.')
            OR (DD_ATTRS = '2.6.7.')
            OR (DD_ATTRS = '1.6.7.11.')
            OR (DD_ATTRS = '2.6.7.11.') THEN DO;
       /* 01 CLAUSE PICTURE CLAUSE USAGE CLAUSE                  */
       /*    OR                                                  */
       /* 02-49 CLAUSE PICTURE CLAUSE USAGE CLAUSE               */
       /*    OR                                                  */
       /* 01 CLAUSE PICTURE CLAUSE USAGE CLAUSE B.W.Z. CLAUSE    */
       /*    OR                                                  */
       /* 02-49 CLAUSE PICTURE CLAUSE USAGE CLAUSE B.W.Z. CLAUSE */
       LINK STKUSAGE;
       LINK GETINFMT;
       GRP_TYPE = 'ITEM';
       D_GRPID = 0;
       LINK GETBYTES;
       LINK STKGROUP;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       ATBYTE = ATBYTE + BYTES;
       ITM_DISP = ITM_DISP + BYTES;
       END;  /* ELSE IF (DD_ATTRS = '1.6.7.') ETC. */
    ELSE IF (DD_ATTRS = '2.13.') THEN DO;
       /* 02-49 CLAUSE OCCURS CLAUSE                             */
       LINK STKUSAGE;
       USAGE = 'GROUP';
       GRP_TYPE = 'OCCURS';
       D_GRPID = 0;
       BYTES = 0;
       LINK STKGROUP;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       END;  /* ELSE IF (DD_ATTRS = '2.13.') */
    ELSE IF (DD_ATTRS = '2.6.13.')
            OR (DD_ATTRS = '2.6.11.13.') THEN DO;
       /* 02-49 CLAUSE PICTURE CLAUSE OCCURS CLAUSE              */
       /*    OR                                                  */
       /* 02-49 CLAUSE PICTURE CLAUSE B.W.Z. CLAUSE              */
       /*              OCCURS CLAUSE                             */
       LINK STKUSAGE;
       LINK GETINFMT;
       GRP_TYPE = 'ITEM';
       D_GRPID = 0;
       LINK GETBYTES;
       BYTES = BYTES * INPUT(OCR_VAL,12.);
       LINK STKGROUP;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       ATBYTE = ATBYTE + BYTES;
       ITM_DISP = ITM_DISP + BYTES;
       END;  /* ELSE IF (DD_ATTRS = '2.6.13.') ETC. */
    ELSE IF (DD_ATTRS = '2.7.13.') THEN DO;
       /* 02-49 CLAUSE USAGE CLAUSE OCCURS CLAUSE                */
       LINK STKUSAGE;
       IF (USAGE = 'COMP-1') OR (USAGE = 'COMP-2') THEN DO;
          LINK GETINFMT;
          GRP_TYPE = 'ITEM';
          D_GRPID = 0;
          LINK GETBYTES;
          BYTES = BYTES * INPUT(OCR_VAL,12.);
          LINK STKGROUP;
          LINK STKREDEF;
          LINK STKOFFST;
          OUTPUT DICTNRY;
          ATBYTE = ATBYTE + BYTES;
          ITM_DISP = ITM_DISP + BYTES;
          END;  /* IF (USAGE = 'COMP-1') OR (USAGE = 'COMP-2') */
       ELSE DO;
          USAGE = 'GROUP';
          GRP_TYPE = 'OCCURS';
          D_GRPID = 0;
          BYTES = 0;
          LINK STKGROUP;
          LINK STKREDEF;
          LINK STKOFFST;
          OUTPUT DICTNRY;
          END;  /* ELSE DO */
       END;  /* ELSE IF (DD_ATTRS = '2.7.13.') */
    ELSE IF (DD_ATTRS = '2.6.7.13.')
            OR (DD_ATTRS = '2.6.7.11.13.') THEN DO;
       /* 02-49 CLAUSE PICTURE CLAUSE USAGE CLAUSE OCCURS CLAUSE */
       /*    OR                                                  */
       /* 02-49 CLAUSE PICTURE CLAUSE USAGE CLAUSE B.W.Z. CLAUSE */
       /*              OCCURS CLAUSE                             */
       LINK STKUSAGE;
       LINK GETINFMT;
       GRP_TYPE = 'ITEM';
       D_GRPID = 0;
       LINK GETBYTES;
       BYTES = BYTES * INPUT(OCR_VAL,12.);
       LINK STKGROUP;
       LINK STKREDEF;
       LINK STKOFFST;
       OUTPUT DICTNRY;
       ATBYTE = ATBYTE + BYTES;
       ITM_DISP = ITM_DISP + BYTES;
       END;  /* ELSE IF (DD_ATTRS = '2.6.7.13.') ETC. */
    ELSE IF (DD_ATTRS = '14.') THEN DO;
       /* 66 CLAUSE                                              */
       END;  /* ELSE IF (DD_ATTRS = '14.') */
    ELSE IF (DD_ATTRS = '15.') THEN DO;
       /* 88 CLAUSE                                              */
       END;  /* ELSE IF (DD_ATTRS = '15.') */
    ELSE DO;
       PUT;
       PUT @3 'UNRECOGNIZED ATTRIBUTES IN DATA DESCRIPTION';
       LINK SHO_CLS;
       END;  /* ELSE DO */
 RETURN;  /* FROM EODDNTRY */

 SHO_CLS:
    /*                                                           */
    /* SHO_CLS:                                                  */
    /*    SHOW CLAUSE                                            */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    SHOW EACH CLAUSE THAT IS IN ANY UNRECOGNIZED ENTRY.    */
    /*                                                           */
    IF (TRACEPRS='5') OR (TRACEPRS='6') THEN
       PUT @3 AV_SUM=;
    PUT @3 'THE DATA DESCRIPTION HAS THESE CLAUSES:';
    TMPAVSUM = AV_SUM;
    EXPOF2 = 0;
    DO UNTIL(TMPAVSUM LE 0);
       Q = INT(TMPAVSUM/2);
       R = MOD(TMPAVSUM,2);
       IF R NE 0 THEN DO;
          CLAUSE = PUT(EXPOF2,DDSHOFMT.);
          PUT @6 CLAUSE;
          END;  /* IF R NE 0 */
       EXPOF2 + 1;
       TMPAVSUM = Q;
       END;
 RETURN;  /* FROM SHO_CLS */

 EODDSCTN:
    /*                                                           */
    /* EODDSCTN:                                                 */
    /*    END OF DATA DESCRIPTION ENTRY                          */
    /*                                                           */
    /* PURPOSE:                                                  */
    /*    FINISH ANY PENDING PROCESSING.                         */
    /*                                                           */

    /* FINISH ANY DATA DESCRIPTION BEING BUILT.                  */
    IF PRS_MODE = 'BLD_CLS' THEN DO;
       /* FINISH ANY CLAUSE OTHER THAT A 'SIMPLE CLAUSE'.        */
       IF CLS_MODE = 'PIC_CLAUSE' THEN DO;
          CLS_ID = '6';
          PRS_MODE = 'IDN_CLS';
          /*                                                     */
          /* A COMPLETE PICTURE CLAUSE HAS BEEN PARSED.          */
          LINK LK_PIC;
          AV_SUM = AV_SUM + (2**6);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* IF CLS_MODE = 'PIC_CLAUSE' */
       ELSE IF CLS_MODE = 'VALUE_CLAUSE' THEN DO;
          CLS_ID = '12';
          PRS_MODE = 'IDN_CLS';
          /*                                                     */
          /* A COMPLETE VALUE CLAUSE HAS BEEN PARSED.            */

          /*                                                     */
          /* ALTHOUGH THE VALUE CLAUSE IS NOT VALID IN THE FILE  */
          /* SECTION EXCEPT ON THE 88 LEVEL, HANDLE IT HERE.     */
          /*                                                     */
          * LINK LK_VAL;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**12);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* ELSE IF CLS_MODE = 'VALUE_CLAUSE' */
       ELSE IF CLS_MODE = 'OCCURS_CLAUSE' THEN DO;
          CLS_ID = '13';
          PRS_MODE = 'IDN_CLS';
          /*                                                     */
          /* A COMPLETE OCCURS CLAUSE HAS BEEN PARSED.           */
          LINK LK_OCUR;
          AV_SUM = AV_SUM + (2**13);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* ELSE IF CLS_MODE = 'OCCURS_CLAUSE' */
       ELSE IF CLS_MODE = '66_CLAUSE' THEN DO;
          CLS_ID = '14';
          PRS_MODE = 'IDN_CLS';
          /*                                                     */
          /* A COMPLETE 66 CLAUSE HAS BEEN PARSED.               */
          LINK LK_66;
          AV_SUM = AV_SUM + (2**14);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* ELSE IF CLS_MODE = '66_CLAUSE' */
       ELSE IF CLS_MODE = '88_CLAUSE' THEN DO;
          CLS_ID = '15';
          PRS_MODE = 'IDN_CLS';
          /*                                                     */
          /* A COMPLETE 88 CLAUSE HAS BEEN PARSED.               */
          LINK LK_88;
          AV_SUM = AV_SUM + (2**15);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* ELSE IF CLS_MODE = '88_CLAUSE' */
       ELSE IF CLS_MODE = 'COPY_CLAUSE' THEN DO;
          CLS_ID = '16';
          PRS_MODE = 'IDN_CLS';
          /*                                                     */
          /* A COMPLETE COPY CLAUSE HAS BEEN PARSED.             */
          LINK LK_COPY;
          IF ATTR_ERR = 'Y' THEN
             AV_SUM = AV_SUM + (2**16);
          TKN_VCTR = ' ';
          CLS_STR = ' ';
          IF (TRACEPRS = '5') OR (TRACEPRS = '6') THEN DO;
             PUT @3 AV_SUM=; PUT;
             END;  /* IF (TRACEPRS = '5') OR (TRACEPRS = '6') */
          END;  /* ELSE IF CLS_MODE = 'COPY_CLAUSE' */
       ELSE DO;
          /* NOTHING */
         END;  /* ELSE DO */
       END;  /* IF PRS_MODE = 'BLD_CLS' */

    IF TKN_VCTR NE ' ' THEN DO;
       /* UNRECOGNIZED SYNTAX IN THE PREVIOUS STATEMENT.         */
       TKN_VCTR = ' ';
       PRS_MODE = 'IDN_CLS';
       END;  /* IF TKN_VCTR NE ' ' */

    IF AV_SUM NE 0 THEN DO;
       LINK EODDNTRY;
       AV_SUM = 0;
       CLS_STR = ' ';
       END;  /* IF AV_SUM NE 0 */

    DO WHILE(GK_NDX GE 1);

       IF GK_TYP?(GK_NDX?) = 'OCCURS' THEN DO;
          /*                                                     */
          /* 1) SUBTRACT THE CONTRIBUTION OF EACH ELEMENTARY     */
          /*    ITEM IN THE GROUP JUST ENDED FROM THE LENGTH     */
          /*    OF EVERY OTHER GROUP ON THE GROUP-STACK.         */
          /* 2) CALCULATE THE ACTUAL CONTRIBUTION OF             */
          /*    ENTIRE GROUP JUST ENDED.                         */
          /* 3) ADD THE CONTRIBUTION OF THE GROUP JUST ENDED     */
          /*    TO THE LENGTH OF EVERY OTHER GROUP ON THE        */
          /*    GROUP-STACK.                                     */
          /*                                                     */
          DO I = 1 TO GK_NDX - 1;
             GK_LEN?(I?) = GK_LEN?(I?) - GK_LEN?(GK_NDX?);
             END;  /* DO I = 1 TO GK_NDX - 1 */
          GK_LEN?(GK_NDX?) = GK_LEN?(GK_NDX?) *
                             INPUT(GK_OCR?(GK_NDX?),12.);
          DO I = 1 TO GK_NDX - 1;
             GK_LEN?(I?) = GK_LEN?(I?) + GK_LEN?(GK_NDX?);
             END;  /* DO I = 1 TO GK_NDX - 1 */
          END;  /* IF G_TYP?(GK_NDX?) = 'OCCURS' */
       ELSE IF GK_TYP?(GK_NDX?) = 'REDEFINES' THEN DO;
          /*                                                     */
          /* SUBTRACT THE CONTRIBUTION OF EACH ELEMENTARY        */
          /* ITEM IN THE GROUP JUST ENDED FROM THE LENGTH        */
          /* OF EVERY OTHER GROUP ON THE GROUP-STACK.            */
          /*                                                     */
          DO I = 1 TO GK_NDX - 1;
             GK_LEN?(I?) = GK_LEN?(I?) - GK_LEN?(GK_NDX?);
             END;  /* DO I = 1 TO GK_NDX - 1 */
          END;  /* ELSE IF GK_TYP?(GK_NDX?) = 'REDEFINES' */

       G_GRPID = GK_ID?(GK_NDX?);
       G_LVL = GK_LVL?(GK_NDX?);
       G_NST = GK_NST?(GK_NDX?);
       G_NAM = GK_NAM?(GK_NDX?);
       G_TYP = GK_TYP?(GK_NDX?);
       G_AT  = GK_AT?(GK_NDX?);
       G_LEN = GK_LEN?(GK_NDX?);
       G_OCR = GK_OCR?(GK_NDX?);
       G_RDF = GK_RDF?(GK_NDX?);
       OUTPUT GROUP;
       GK_NDX = GK_NDX - 1;
       END;  /* DO WHILE(GK_NDX GE 1) */
 RETURN;  /* FROM EODDSCTN */

 /*                                                              */
 /* IF YOU WISH TO MAKE USE OF THE STORED PROGRAM FACILITY THAT  */
 /* IS AVAILABLE IN RELEASE 6.06 OF THE SAS SYSTEM, THEN ALLOW   */
 /* THE SAS SYSTEM TO COMPILE THIS DATA STEP BY COMMENTING THE   */
 /* RUN STATEMENT AND UNCOMMENTING THE RUN PGM=C2SCAT.R2COB2     */
 /* STATEMENT. THIS STORES THE COMPILED PROGRAM IN MEMBER R2COB2 */
 /* IN THE CATALOG C2SCAT.                                       */
 /*                                                              */
 /* NOTE THAT THE DATA STEP DOES NOT EXECUTE AFTER COMPILATION.  */
 /* IN ORDER TO EXECUTE THE DATA STEP, YOU MUST EXECUTE THE      */
 /* STATEMENT:                                                   */
 /*                                                              */
 /*     DATA PGM=C2SCAT.R2COB2; RUN;                             */
 /*                                                              */

   RUN;  /* R2COB2 DATA STEP */
 * RUN PGM=C2SCAT.R2COB2;  /* R2COB2 DATA STEP */

 /* THE NOCHARCODE OPTION IS SET SO THAT STRINGS LIKE, '?)', ARE */
 /* NOT MISINTERPRETED.                                          */
 OPTIONS NOCHARCODE;
 RUN;  /* PROGRAM R2COB2 */
