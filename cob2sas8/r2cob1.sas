 /****************************************************************/
 /*                                                              */
 /*    NAME: R2COB1                                              */
 /*   TITLE: PROGRAM 'R2COB1', A PART OF 'COB2SAS, RELEASE 2'    */
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

 PROC FORMAT;
 /* DATA DESCRIPTION TOKEN FORMAT.                               */
 /*                                                              */
 /* THIS IS A LIST OF TOKENS RECOGNIZED WHILE BUILDING CLAUSES.  */
 /*                                                              */
 VALUE $DDTFMT
    '01' = '1.'
    '02' - '49' = '2.'
    OTHER = '3.'
    'FILLER' = '4.'
    'REDEFINES' = '5.'
    'IS' = '6.'
    'EXTERNAL' = '7.'
    'GLOBAL' = '8.'
    'PICTURE','PIC' = '9.'
    'USAGE' = '10.'
    'BINARY',
    'COMPUTATIONAL','COMP',
    'COMPUTATIONAL-1','COMP-1',
    'COMPUTATIONAL-2','COMP-2',
    'COMPUTATIONAL-3','COMP-3',
    'COMPUTATIONAL-4','COMP-4',
    'DISPLAY','INDEX',
    'PACKED-DECIMAL' = '11.'
    'SIGN' = '12.'
    'LEADING','TRAILING' = '13.'
    'SEPARATE' = '14.'
    'CHARACTER' = '15.'
    'SYNCHRONIZED','SYNC' = '16.'
    'JUSTIFIED','JUST' = '17.'
    'LEFT' = '18.'
    'RIGHT' = '19.'
    'BLANK' = '20.'
    'WHEN'  = '21.'
    'ZERO' = '22.'
    'VALUE' = '23.';

 PROC FORMAT;
 /* DATA DESCRIPTION IDENTIFY CLAUSE FORMAT.                     */
 /*                                                              */
 /*    THIS IS A LIST OF ALL THE TOKENS THAT ARE RECOGNIZED      */
 /* WHEN THE PRS_MODE EQUALS IDN_CLS.                            */
 /*    THIS FORMAT IS USED TO IDENTIFY THE NEXT CLAUSE BY        */
 /* IDENTIFYING THE FIRST TOKEN IN THAT CLAUSE.                  */
 /*                                                              */
 VALUE $DDICFMT
    '01' - '49' = 'LEVEL NUMBER'

    'REDEFINES',
    'EXTERNAL','GLOBAL',
    'USAGE',
    'BINARY',
    'COMPUTATIONAL','COMP',
    'COMPUTATIONAL-1','COMP-1',
    'COMPUTATIONAL-2','COMP-2',
    'COMPUTATIONAL-3','COMP-3',
    'COMPUTATIONAL-4','COMP-4',
    'DISPLAY','INDEX',
    'PACKED-DECIMAL',
    'SIGN',
    'LEADING','TRAILING',
    'SYNCHRONIZED','SYNC',
    'JUSTIFIED','JUST',
    'BLANK' = 'IDENTIFIED'

    'PICTURE','PIC' = 'PICTURE'
    'OCCURS' = 'OCCURS'
    '66' = '66'
    '88' = '88'
    'COPY' = 'COPY'
    'VALUE' = 'VALUE'
    OTHER = 'UNIDENTIFIED';

 PROC FORMAT;
 /* DATA DESCRIPTION CLAUSE FORMAT.                              */
 /*                                                              */
 /* 01 DATANAME:                                                 */
 /* 01 FILLER:                                                   */
 /* '1.3.','1.4.' = '1'                                          */
 /*                                                              */
 /* LEVEL-NUMBER DATANAME:                                       */
 /* LEVEL-NUMBER FILLER:                                         */
 /* '2.3.','2.4.' = '2'                                          */
 /*                                                              */
 /* REDEFINES DATANAME:                                          */
 /* REDEFINES FILLER:                                            */
 /* '5.3.','5.4.' = '3'                                          */
 /*                                                              */
 /* EXTERNAL                                                     */
 /* IS EXTERNAL                                                  */
 /* '7.','6.7.' = '4'                                            */
 /*                                                              */
 /* GLOBAL                                                       */
 /* IS GLOBAL                                                    */
 /* '8.','6.8.' = '5'                                            */
 /*                                                              */
 /* USAGE-VALUE:                                                 */
 /* USAGE USAGE-VALUE:                                           */
 /* USAGE IS USAGE-VALUE:                                        */
 /* '11.','10.11.','10.6.11.' = '7'                              */
 /*                                                              */
 /* SIGN-VALUE (LEADING OR TRAILING):                            */
 /* SIGN SIGN-VALUE:                                             */
 /* SIGN IS SIGN-VALUE:                                          */
 /* SIGN-VALUE SEPARATE:                                         */
 /* SIGN-VALUE SEPARATE CHARACTER:                               */
 /* SIGN SIGN-VALUE SEPARATE:                                    */
 /* SIGN IS SIGN-VALUE SEPARATE:                                 */
 /* SIGN SIGN-VALUE SEPARATE CHARACTER:                          */
 /* SIGN IS SIGN-VALUE SEPARATE CHARACTER:                       */
 /* '13.','12.13.','12.6.13.',                                   */
 /* '13.14.','13.14.15.',                                        */
 /* '12.13.14.','12.6.13.14.',                                   */
 /* '12.13.14.15.','12.6.13.14.15.' = '8'                        */
 /*                                                              */
 /* SYNCHRONIZED:                                                */
 /* SYNCHRONIZED LEFT:                                           */
 /* SYNCHRONIZED RIGHT:                                          */
 /* '16.','16.18.','16.19.' = '9'                                */
 /*                                                              */
 /* JUSTIFIED:                                                   */
 /* JUSTIFIED RIGHT:                                             */
 /* '17.','17.19.' = '10'                                        */
 /*                                                              */
 /* BLANK ZERO:                                                  */
 /* BLANK WHEN ZERO:                                             */
 /* '20.22.','20.21.22.' = '11'                                  */
 /*                                                              */

 VALUE $DDCFMT
    '1.3.','1.4.' = '1'
    '2.3.','2.4.' = '2'
    '5.3.','5.4.' = '3'
    '7.','6.7.' = '4'
    '8.','6.8.' = '5'
    '11.','10.11.','10.6.11.' = '7'
    '13.','12.13.','12.6.13.',
    '13.14.','13.14.15.',
    '12.13.14.','12.6.13.14.',
    '12.13.14.15.','12.6.13.14.15.' = '8'
    '16.','16.18.','16.19.' = '9'
    '17.','17.19.' = '10'
    '20.22.','20.21.22.' = '11'
    OTHER = 'UNDEFINED';

 PROC FORMAT;
    VALUE DDSHOFMT
    1 = '01 CLAUSE'
    2 = '02-49 CLAUSE'
    3 = 'REDEFINES CLAUSE'
    4 = 'EXTERNAL CLAUSE'
    5 = 'GLOBAL CLAUSE'
    6 = 'PICTURE CLAUSE'
    7 = 'USAGE CLAUSE'
    8 = 'SIGN CLAUSE'
    9 = 'SYNCHRONIZED CLAUSE'
    10 = 'JUSTIFIED CLAUSE'
    11 = 'B.W.Z. CLAUSE'
    12 = 'VALUE CLAUSE'
    13 = 'OCCURS CLAUSE'
    14 = '66 CLAUSE'
    15 = '88 CLAUSE'
    16 = 'COPY CLAUSE'
    OTHER = 'UNRECOGNIZED CLAUSE';

 PROC FORMAT;
 /* ATTRIBUTE VECTOR FORMAT.                                     */
 /*                                                              */
 /* 01 CLAUSE                                                    */
 /* 2 = '1.'                                                     */
 /*                                                              */
 /* 02-49 CLAUSE                                                 */
 /* 4 = '2.'                                                     */
 /*                                                              */
 /* 02-49 CLAUSE REDEFINES CLAUSE                                */
 /* 12 = '2.3.'                                                  */
 /*                                                              */
 /* 02-49 CLAUSE REDEFINES CLAUSE PICTURE CLAUSE                 */
 /* 76 = '2.3.6.'                                                */
 /*                                                              */
 /* 02-49 CLAUSE REDEFINES CLAUSE USAGE CLAUSE                   */
 /* 140 = '2.3.7.'                                               */
 /*                                                              */
 /* 02-49 CLAUSE REDEFINES CLAUSE PICTURE CLAUSE USAGE CLAUSE    */
 /* 204 = '2.3.6.7.'                                             */
 /*                                                              */
 /* 01 CLAUSE PICTURE CLAUSE                                     */
 /* 66 = '1.6.'                                                  */
 /*                                                              */
 /* 02-49 CLAUSE PICTURE CLAUSE                                  */
 /* 68 = '2.6.'                                                  */
 /*                                                              */
 /* 01 CLAUSE USAGE CLAUSE                                       */
 /* 130 = '1.7.'                                                 */
 /*                                                              */
 /* 02-49 CLAUSE USAGE CLAUSE                                    */
 /* 132 = '2.7.'                                                 */
 /*                                                              */
 /* 01 CLAUSE PICTURE CLAUSE USAGE CLAUSE                        */
 /* 194 = '1.6.7.'                                               */
 /*                                                              */
 /* 02-49 CLAUSE PICTURE CLAUSE USAGE CLAUSE                     */
 /* 196 = '2.6.7.'                                               */
 /*                                                              */
 /* 01 CLAUSE PICTURE CLAUSE B.W.Z. CLAUSE                       */
 /* 2114 = '1.6.11.'                                             */
 /*                                                              */
 /* 02-49 CLAUSE PICTURE CLAUSE B.W.Z. CLAUSE                    */
 /* 2116 = '2.6.11.'                                             */
 /*                                                              */
 /* 02-49 CLAUSE REDEFINES CLAUSE PICTURE CLAUSE B.W.Z. CLAUSE   */
 /* 2124 = '2.3.6.11.'                                           */
 /*                                                              */
 /* 01 CLAUSE PICTURE CLAUSE USAGE CLAUSE B.W.Z.CLAUSE           */
 /* 2242 = '1.6.7.11.'                                           */
 /*                                                              */
 /* 02-49 CLAUSE PICTURE CLAUSE USAGE CLAUSE B.W.Z. CLAUSE       */
 /* 2244 = '2.6.7.11.'                                           */
 /*                                                              */
 /* 02-49 CLAUSE REDEFINES CLAUSE PICTURE CLAUSE USAGE CLAUSE    */
 /*              B.W.Z. CLAUSE                                   */
 /* 2252 = '2.3.6.7.11.'                                         */
 /*                                                              */
 /* 02-49 CLAUSE OCCURS CLAUSE                                   */
 /* 8196 = '2.13.'                                               */
 /*                                                              */
 /* 02-49 CLAUSE PICTURE CLAUSE OCCURS CLAUSE                    */
 /* 8260 = '2.6.13.'                                             */
 /*                                                              */
 /* 02-49 CLAUSE USAGE CLAUSE OCCURS CLAUSE                      */
 /* 8324 = '2.7.13.'                                             */
 /*                                                              */
 /* 02-49 CLAUSE PICTURE CLAUSE USAGE CLAUSE OCCURS CLAUSE       */
 /* 8388 = '2.6.7.13.'                                           */
 /*                                                              */
 /* 02-49 CLAUSE PICTURE CLAUSE B.W.Z. CLAUSE OCCURS CLAUSE      */
 /* 10308 = '2.6.11.13.'                                         */
 /*                                                              */
 /* 02-49 CLAUSE PICTURE CLAUSE USAGE CLAUSE B.W.Z. CLAUSE       */
 /*              OCCURS CLAUSE                                   */
 /* 10436 = '2.6.7.11.13.'                                       */
 /*                                                              */
 /* 66 CLAUSE                                                    */
 /* 16384 = '14.'                                                */
 /*                                                              */
 /* 88 CLAUSE                                                    */
 /* 32768 = '15.'                                                */
 /*                                                              */

 VALUE DDAVFMT
    2 = '1.'
    4 = '2.'
    12 = '2.3.'
    66 = '1.6.'
    68 = '2.6.'
    76 = '2.3.6.'
    140 = '2.3.7.'
    130 = '1.7.'
    132 = '2.7.'
    194 = '1.6.7.'
    196 = '2.6.7.'
    204 = '2.3.6.7.'
    2114 = '1.6.11.'
    2116 = '2.6.11.'
    2124 = '2.3.6.11.'
    2242 = '1.6.7.11.'
    2244 = '2.6.7.11.'
    2252 = '2.3.6.7.11.'
    8196 = '2.13.'
    8260 = '2.6.13.'
    8324 = '2.7.13.'
    8388 = '2.6.7.13.'
    10308 = '2.6.11.13.'
    10436 = '2.6.7.11.13.'
    16384 = '14.'
    32768 = '15.'
    OTHER = 'UNRECOGNIZED';

 RUN;  /* PROGRAM R2COB1 */
