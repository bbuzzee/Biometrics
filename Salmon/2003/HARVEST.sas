****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program reads and modifies data for harvest                                 *;
*     This program is stored as h:\common\pat\permits\salmon\2002\harvest.sas          *;
****************************************************************************************;


*** SEARCH FOR QQQ;

%LET PROJECT = SALMON;
%LET DATA = CISLHV03C;
%LET YEAR = 2003;
%LET SP = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM; *QQQ;
%LET SPECIES_LIST = RED KING COHO PINK CHUM; *QQQ;
%LET PROGRAM = HARVEST;


OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR";
*ODS RTF FILE = "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\&PROGRAM..RTF";
RUN;


TITLE1 "&PROJECT - &YEAR";


**************************************************************************;
*                              HARVEST DATA                              *;
**************************************************************************;

PROC CONTENTS DATA = SASDATA.&DATA;
RUN;

DATA COMMENTS; SET SASDATA.&DATA;
     WHERE COMMENTS NE '';
   * KEEP PERMITNO COMMENTS;

PROC EXPORT DATA= WORK.COMMENTS 
            OUTFILE= "H:\common\PAT\Permits\Salmon\2003\&PROGRAM COMMENTS.xls" 
            DBMS=EXCEL2000 REPLACE;
RUN;


DATA HARVEST; SET SASDATA.&DATA (DROP =  YEAR KEYDATE HVRECID MAILING KEYID EDITED);
     SPECIES = 'SALMON';  *QQQ;
   * IF HARVDATE EQ '01JAN01'D THEN HARVDATE = .;
     IF NOCATCH = 1 THEN CATCH = 'N'; IF NOCATCH NE 1 THEN CATCH = 'Y';
     IF NOHRVRPT = 1 THEN HRVRPT = 'N'; IF NOHRVRPT NE 1 THEN HRVRPT = 'Y';
     IF FISHERY = '' THEN FISHERY = 'UNKNOWN';
     RENAME PERMITNO = PERMIT;
RUN;

DATA HARVEST; SET HARVEST;
     MONTH = MONTH(HARVDATE);
     DAY = DAY(HARVDATE);
     IF FISHERY = 'KENAI' AND MONTH LE 5 THEN HARVDATE = '01JAN90'D;
     IF FISHERY = 'KENAI' AND MONTH GE 9 THEN HARVDATE = '01JAN90'D;
     IF FISHERY = 'KASILOF' AND MONTH LE 5 THEN HARVDATE = '01JAN90'D;
     IF FISHERY = 'KASILOF' AND MONTH EQ 6 AND DAY LT 15 THEN HARVDATE = '01JAN90'D;
     IF FISHERY = 'KASILOF' AND MONTH GE 9 THEN HARVDATE = '01JAN90'D;
     IF FISHERY = 'KASILOF' AND MONTH EQ 8 AND DAY GT 7 THEN HARVDATE = '01JAN90'D;
     DROP MONTH DAY;
RUN;



*NEED TO FIX SOME OF THE UNKNOWN FISHERIES;
*DORA WENT THROUGH THE COMMENTS AND DETERMINED THE REAL FISHERY;

PROC IMPORT OUT= WORK.FIX_UNKNOWNS DATAFILE= "H:\common\PAT\Permits\Salmon\2003\FISHERY UNKNOWN_EDITS.xls" 
      DBMS=EXCEL2000 REPLACE;
      GETNAMES=YES;
RUN;

DATA FIX_UNKNOWNS; SET FIX_UNKNOWNS;
     IF NEW_FISHERY = 'DELETE' THEN DELETE;
     DROP HARVDATE;
RUN; 
PROC SORT DATA = FIX_UNKNOWNS; BY PERMIT COMMENTS;
PROC SORT DATA = HARVEST; BY PERMIT COMMENTS;

DATA HARVEST; MERGE HARVEST FIX_UNKNOWNS; BY PERMIT COMMENTS;
     IF FISHERY = 'UNKNOWN' AND NEW_FISHERY NE 'UNKNOWN' THEN FISHERY = NEW_FISHERY;
     IF FISHERY = '' THEN FISHERY = 'UNKNOWN';
     DROP NEW_FISHERY COMMENTS;
RUN;
PROC FREQ;
TABLES FISHERY;
RUN;


PROC SORT DATA = HARVEST; BY PERMIT;     
PROC PRINT DATA = HARVEST (OBS = 40);
     TITLE2 'HARVEST FILE';
     TITLE3 ;
RUN;

PROC FREQ;
     TABLES CATCH HRVRPT HARVDATE FISHERY;
RUN;

PROC FREQ;
     TABLES &SPECIES_LIST;
     TITLE2 'HARVEST DATABASE';
     TITLE3 ;
run;


PROC UNIVARIATE PLOT;
     VAR &SPECIES_LIST;
RUN;


     
DATA SASDATA.SALMON_HARVEST; SET HARVEST; *QQQ;
RUN;


*ODS RTF CLOSE;
RUN;

