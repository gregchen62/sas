 /****************************************************************/
 /*                                                              */
 /*    NAME: R2CMS                                               */
 /*   TITLE: PROGRAM 'R2CMS', A PART OF 'COB2SAS, RELEASE 2'     */
 /* PRODUCT: SAS VERSION 8 AND ABOVE                             */
 /*  SYSTEM: CMS                                                 */
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

  DATA SWITCHES;
     LENGTH TRACEPRS  TRACESTK  ATTR_ERR  SEVERAL
            DEL_FLLR  USE_AT    MAKE_LBL $1 ;

     /* TRACE PARSE DETERMINES THE TYPE OF TRACING INFORMATION   */
     /* PRODUCED WHILE PARSING.                                  */
     /*                                                          */
     /* TRACEPRS = '0': NO PARSE TRACE INFORMATION PRODUCED.     */
     /* TRACEPRS = '4': SHOW DIVISIONS, ENTRY TYPES AND PROGRAM  */
     /*                 STATEMENTS.                              */
     /* TRACEPRS = '5': SHOW PARSING VARIABLES.                  */
     /* TRACEPRS = '6': SHOW DIVISIONS, ENTRY TYPES, PROGRAM     */
     /*                 STATEMENTS AND PARSING VARIABLES.        */
     /* TRACEPRS = '9': DO NOTHING BUT SHOW THE ACTION OF THE    */
     /*                 LOOK AHEAD BUFFER AND THE VALUE OF EOF.  */
     /*                 (IT ALWAYS SHOWS EOF=1 TWICE BECAUSE IT  */
     /*                 IS LOOKING ONE LINE AHEAD AND RECOGNIZES */
     /*                 THE LAST LINE IN THE FILE TWICE.)        */
     TRACEPRS='0';

     /* TRACE STACK DETERMINES THE TYPE OF TRACING INFORMATION   */
     /* PRODUCED BY THE STACK ROUTINES.                          */
     /*                                                          */
     /* TRACESTK = '0': NO STACK TRACE INFORMATION PRODUCED.     */
     /* TRACESTK = '1': SHOW INFORMATION USED BY ROUTINES:       */
     /*                 STKUSAGE, STKGROUP, STKREDEF, STKOFFST.  */
     /* TRACESTK = '2': SHOW INFORMATION USED BY ROUTINE:        */
     /*                 STKUSAGE.                                */
     /* TRACESTK = '3': SHOW INFORMATION USED BY ROUTINE:        */
     /*                 STKGROUP.                                */
     /* TRACESTK = '4': SHOW INFORMATION USED BY ROUTINE:        */
     /*                 STKREDEF.                                */
     /* TRACESTK = '5': SHOW INFORMATION USED BY ROUTINE:        */
     /*                 STKOFFST.                                */
     /* TRACESTK = '6': SHOW INFORMATION USED BY ROUTINES:       */
     /*                 STKGROUP, STKREDEF.                      */
     /* TRACESTK = '7': SHOW INFORMATION USED BY ROUTINES:       */
     /*                 STKGROUP, STKREDEF, STKOFFST.            */
     TRACESTK='0';

     /* SET ATTR_ERR TO 'Y' IF YOU WISH TO FLAG UNRECOGNIZED     */
     /* ATTRIBUTES.                                              */
     /* SET ATTR_ERR TO 'N' IF YOU WISH TO PROCESS UNRECOGNIZED  */
     /* ATTRIBUTES.                                              */
     ATTR_ERR='N';

     /* SET SEVERAL TO  'Y' IF YOU WISH TO PROCESS MORE THAN     */
     /* ONE COBOL SOURCE PROGRAM OR COPY MEMBERS.                */
     /* SET SEVERAL TO  'N' IF YOU WISH TO PROCESS ONLY ONE      */
     /* COBOL SOURCE PROGRAM OR COPY MEMBER.                     */
     SEVERAL='N';

     /* SET DEL_FLLR TO 'Y' IF YOU WISH TO EXCLUDE ENTRIES, FROM */
     /* THE INPUT STATEMENTS PRODUCED, THAT HAVE 'FILLER' IN THE */
     /* DATA NAME.                                               */
     /* SET DEL_FLLR TO 'N' IF YOU WISH TO INCLUDE ENTRIES, IN   */
     /* THE INPUT STATEMENTS PRODUCED, THAT HAVE 'FILLER' IN THE */
     /* DATA NAME.                                               */
     DEL_FLLR = 'Y';

     /* SET USE_AT TO 'Y' IF YOU WISH TO HAVE THE @ COLUMN       */
     /* POINTER IN INPUT STATEMENTS PRODUCED.                    */
     /* SET USE_AT TO 'N' IF YOU WISH TO HAVE NO @ COLUMN        */
     /* POINTER IN INPUT STATEMENTS PRODUCED.                    */
     USE_AT = 'Y';

     /* SET MAKE_LBL TO 'Y' IF YOU WISH TO HAVE LABEL            */
     /* STATEMENTS PRODUCED.                                     */
     /* SET MAKE_LBL TO 'N' IF YOU WISH TO HAVE NO LABEL         */
     /* STATEMENTS PRODUCED.                                     */
     MAKE_LBL = 'Y';
  RUN;  /* DATA SWITCHES */

  /* CREATE THE FORMATS USED WHILE PARSING THE COBOL STATEMENTS. */
  %INCLUDE COB2SAS(R2COB1);
  RUN;

  /*                                                             */
  /* ESTABLISH THE INFILE AND FILE STATEMENTS.                   */
  /*                                                             */
  /* => TO POINT COB2SAS TO THE FLAT FILE THAT HAS THE COBOL     */
  /*    LANGUAGE STATEMENTS, PROVIDE APPROPRIATE OPERATING       */
  /*    SYSTEM DEPENDENT STATEMENTS THAT ASSOCIATE THE FILEREF   */
  /*    IN THE %LET INFILE = STATEMENT WITH THAT FLAT FILE.      */
  /*                                                             */
  /*    NOTE: THE VALUE OF THE FILEREF IS INCOBOL, THIS IS       */
  /*          THE DDNAME THAT YOU WILL DEFINE TO THE OPERATING   */
  /*          SYSTEM.                                            */
  /*                                                             */
  /* => WHEN TRACEPRS OR TRACESTK ARE SET TO VALUES OTHER THAN   */
  /*    0, TRACE INFORMATION IS WRITTEN TO THE FILE ESTABLISHED  */
  /*    IN THE MACRO VARIABLE &FILE. BY SETTING THIS FILEREF TO  */
  /*    LOG, THE TRACE INFORMATION WILL BE WRITTEN TO THE SAS    */
  /*    LOG.                                                     */
  /*                                                             */
  %LET INFILE = INFILE INCOBOL END=EOF EOF=EODDSCTN;
  %LET FILE = FILE LOG;
  %LET LIBREF = ;
  RUN;

  /*                                                             */
  /* PARSE THE COBOL STATEMENTS.                                 */
  /* CREATE THE DATA DICTIONARY.                                 */
  /* CREATE THE GROUP DATA SET.                                  */
  /*                                                             */
  /* NOTE: THE MACRO VARIABLES &INFILE AND &FILE RESOLVE         */
  /*       IN THE R2COB2 DATA STEP.                              */
  /*                                                             */
  %INCLUDE COB2SAS(R2COB2);
  RUN;

  /* COMBINE THE DATA DICTIONARY AND THE GROUP DATA SET.         */
  %INCLUDE COB2SAS(R2COB3);
  RUN;

  /* COMPRESS THE COBOL DATA NAMES TO NO MORE THAN 8 CHARACTERS. */
  /*-------------------------------------------------------------*/
  /* THIS ROUTINE IS NO LONGER NEEDED IN V8 DUE TO LONG VARIABLE */
  /* NAME SUPPORT.  THE DATA STEP IS NEEDED TO MOVE THE PARSED   */
  /* DATA NAME INTO THE SAS VARIABLE NAME. - MARC HOWELL         */
  /*-------------------------------------------------------------*/
 * %INCLUDE COB2SAS(R2COB4);
  DATA DICTNRY;
    LENGTH NEWNAME $30;
    SET DICTNRY;
    NEWNAME=TRANSLATE(DATANAME,'_','-');
  RUN;


  /* OPTIONALLY EXPAND TABLES.                                   */
  /*    1) ONLY 1 DIMENSIONAL TABLES ARE EXPANDED.               */
  /*    2) ITEMS OCCURRING MORE THAN 999 TIMES ARE NOT EXPANDED. */
  /*                                                             */
    %INCLUDE COB2SAS(R2COB5);
  RUN;

  /*                                                             */
  /* => TO SAVE THE SAS LANGUAGE STATEMENTS IN A PERMANENT FLAT  */
  /*    FILE, UNCOMMENT THE %LET FILE = STATEMENT AND PROVIDE    */
  /*    APPROPRIATE OPERATING SYSTEM DEPENDENT STATEMENTS TO     */
  /*    PROVIDE A PLACE FOR THAT FLAT FILE TO RESIDE.            */
  /*                                                             */
  /*    NOTE: THE VALUE OF THE FILEREF IS OUTSAS, THIS IS THE    */
  /*          DDNAME THAT YOU WILL DEFINE TO THE OPERATING       */
  /*          SYSTEM.                                            */
  /*                                                             */
  /* => TO SAVE THE DATA DICTIONARY IN A PERMANENT SAS DATA SET, */
  /*    UNCOMMENT THE %LET LIBREF = STATEMENT AND PROVIDE        */
  /*    APPROPRIATE OPERATING SYSTEM DEPENDENT STATEMENTS TO     */
  /*    PROVIDE A PLACE FOR THAT SAS DATA SET TO RESIDE.         */
  /*                                                             */
  /*    NOTE: THE VALUE OF THE LIBREF IS PERM, THIS IS THE       */
  /*          DDNAME THAT YOU WILL DEFINE TO THE OPERATING       */
  /*          SYSTEM.                                            */
  /*                                                             */
  /*    NOTE: THE VALUE OF THE LIBREF IN THE %LET LIBREF =       */
  /*          STATEMENT MUST END WITH A PERIOD. AS SHOWN IN      */
  /*          THE EXAMPLE, THE LIBREF IS PERM AND THAT LIBREF    */
  /*          ENDS WITH THE REQUIRED PERIOD.                     */
  /*                                                             */
    %LET FILE = FILE OUTSAS;
    %LET LIBREF = PERM.;
  RUN;

  /*                                                             */
  /* PRODUCE THE SAS LANGUAGE INPUT STATEMENTS AND, IF DESIRED,  */
  /* SAVE THE DATA DICTIONARY.                                   */
  /*                                                             */
  /* NOTE: THE MACRO VARIABLES, &FILE AND &LIBREF, RESOLVE       */
  /*       IN THE R2COB6 DATA STEP.                              */
  /*                                                             */

  /*-------------------------------------------------------------*/
  /* R2COB6 AND R2COB7 WERE COMBINED INTO 1 PROGRAM TO           */
  /* ELIMINATE THE NEED TO ALLOCATE THE OUTSAS FILEREF WITH A    */
  /* DISPOSITION OF MOD.  THE NEW PROGRAM IS IN R2COB6.  THE     */
  /* OLD PROGRAMS ARE IN R2OLD6 AND R2OLD7 - MARC HOWELL         */
  /*-------------------------------------------------------------*/
  %INCLUDE COB2SAS(R2COB6);

  /*                                                             */
  /* PRODUCE THE SAS LANGUAGE LABEL STATEMENTS.                  */
  /*                                                             */
  /* NOTE: THE MACRO VARIABLE, &FILE, RESOLVES                   */
  /*       IN THE R2COB7 DATA STEP.                              */
  /*-------------------------------------------------------------*/
  /* NOT NEEDED BECAUSE IT WAS COMBINED INTO R2COB6 - MARC HOWELL*/
  /*-------------------------------------------------------------*/
* %INCLUDE COB2SAS(R2COB7);
  RUN;  /* PROGRAM R2MVS */
