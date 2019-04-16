WHAT IS THIS THING I JUST DOWNLOADED?

   COB2SAS is a sample program that can assist you in converting
   COBOL data description entries (also known as, FD's,
   copybooks, or copylibs) into equivalent SAS language INPUT and
   LABEL statements.  COB2SAS reads, as it's input, your COBOL
   program (or copybook).  It parses the COBOL program searching
   for FILE DESCRIPTOR sections.  When one is encountered, it
   parses this section to produce an equivelant SAS INPUT
   statement.  Also produced is a SAS LABEL statement to
   associate the SAS variable names with the COBOL data names.
   These INPUT and LABEL statements can then be used in a SAS
   program to read the file that the FILE DESCRIPTOR section was
   pointing to.  It also produces a SAS data library that
   contains all of the information gathered about the copybook.

   COB2SAS is written in the SAS language and executes on MVS, CMS,
   VSE, and VMS.  This download contains COB2SAS with the
   modifications in place to support long variable names
   (functionality provided in Version 8 and beyond).  It also contains
   the code necessary to run COB2SAS on the Windows and UNIX
   platforms.



CHANGES TO COB2SAS IN THIS DOWNLOAD:

   Long variable name support.  The SAS variable names produced
   will be up to 30 characters long.

   By default, the SAS INPUT and LABEL statements are written to
   an external file referred to by the OUTSAS fileref.

   By default, the information gathered by COB2SAS is written to
   a permanent SAS data library referenced by the PERM libref.

   Programs added that enable the use of COB2SAS on the UNIX and
   Windows platforms.

   The SAS INPUT and LABEL statements are now written in the same
   data step.  This eliminates the need to allocate the OUTSAS
   fileref with a disposition of MOD.



WHERE'S THE DOCUMENTATION FOR COB2SAS?

  The documentation for COB2SAS are included in this download.
  They are contained in the following files :

    o R2USGD.TXT and R2USGD.HTM:
        This is the COB2SAS Usage Guide.  The TEXT form contains the
        original usage guide.  The HTML form is the same thing with a
        few updates, and it's 'prettier'.

    o R2RFRN.TXT and R2RFRN.HTM:
        This is the COB2SAS Reference Guide.  The TEXT form contains
        the original Reference Guide.  The HTML form is the same thing
        with a few updates, and it's 'prettier'.

    o R2RNTS.TXT:
        This file contains the Release Notes for COB2SAS, Release 2.
        Note that Release 2 came out in 1990.  The modifications in
        this download are not a new release.

    o DSCLMR.TXT:
        This is the disclaimer.  It basically says that COB2SAS is a
        sample program provided 'as is'.

    o COPYRIT.TXT:
        Copyright information.

    o TDMK.TXT:
        Trademark information.

    o R2NSTL.TXT:
        This is the old COB2SAS Installation Instructions.  When
        COB2SAS was distributed on tape media, you used these
        instructions.  Since you downloaded COB2SAS from the web, you
        will *NOT* use these!  The only reason I included them is
        because there is some information in there that may be useful.
        The instructions for installing COB2SAS on your desired
        platform are in the host specific README files.

    o FAQ.TXT and FAQ.HTM
        A COB2SAS FAQ (surprise surprise).

    o RDMEMVS.TXT:
        The host specific README file for MVS.  The installation
        instructions for MVS are enclosed in here.

    o RDMECMS.TXT:
        The host specific README file for CMS.  The installation
        instructions for CMS are enclosed in here.

    o RDMEUNX.TXT:
        The host specific README file for UNIX.  The installation
        instructions for UNIX are enclosed in here.

    o RDMEWIN.TXT:
        The host specific README file for Windows.  The installation
        instructions for Windows are enclosed in here.



SO, WHAT DO I DO NOW?

  Well, you need to install COB2SAS on your host.  To do this, read
  the host specific README file for the host on which you want to
  install COB2SAS.  The MVS README file is called RDMEMVS.TXT.  The
  CMS README file is called RDMECMS.TXT.  The Windows README file is
  called RDMEWIN.TXT.  The UNIX README file is called RDMEUNX.TXT.
