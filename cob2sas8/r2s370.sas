 /****************************************************************/
 /*                                                              */
 /*    NAME: R2S370                                              */
 /*   TITLE: PROGRAM 'R2S370', ADDON TO 'COB2SAS, RELEASE 2'     */
 /* PRODUCT: SAS VERSION 8 AND ABOVE                             */
 /*  SYSTEM: WINDOWS UNIX                                        */
 /*    DATA: COB2SAS, RELEASE 2                                  */
 /*                                                              */
 /*  AUTHOR: MARC HOWELL                                         */
 /* SUPPORT: MARC HOWELL                                         */
 /*    MISC: WHEN USING, INVOKE SAS WITH THE SYSTEM OPTIONS:     */
 /*                      'DQUOTE MACRO'                          */
 /*                                                              */
 /****************************************************************/
 /* PROGRAM CHANGES ALL OF THE INFORMATS GENERATED BY COB2SAS    */
 /* TO THE S370Fxxx INFORMATS.  TO BE USED WHEN THE DATA HAS     */
 /* BEEN DOWNLOADED TO WINDOWS/UNIX IN BINARY                    */
 /*                                                              */

data dictnry;
  set dictnry;
  if infmt ne ' ' then do;
    len=substr(infmt,indexc(infmt,'123456789'));
    inf=upcase(substr(infmt,1,indexc(infmt,'123456789')-1));
    select (inf);
      when ('$CHAR') infmt='$CHAR'||compress(len);
/*      when ('$CHAR') infmt='$EBCDIC'||compress(len);*/
      when ('ZD')    infmt='S370FZD'||compress(len);
      when ('PD')    infmt='S370FPD'||compress(len);
      when ('RB')    infmt='S370FRB'||compress(len);
      when ('IB')    infmt='S370FIB'||compress(len);
      otherwise infmt=' ';
    end;
  end;
run;
