****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program reads and modifies data for harvest                                 *;
*     This program is stored as h:\common\pat\permits\salmon\2002\harvest.sas          *;
****************************************************************************************;


%LET PROJECT = SALMON;
%LET DATA = CISLHV04C;
%LET YEAR = 2004;
%LET SP = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM;
%LET SPECIES_LIST = RED KING COHO PINK CHUM;
%LET PROGRAM = HARVEST;
%LET GILLNET_START = '15JUN04'D; 
%LET GILLNET_STOP = '24JUN04'D; 


OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR";
RUN;


TITLE1 "&PROJECT - &YEAR";


**************************************************************************;
*                              HARVEST DATA                              *;
**************************************************************************;

PROC CONTENTS DATA = SASDATA.&DATA;
RUN;

PROC FREQ DATA = SASDATA.&DATA;
     TABLES nohrvrpt;
RUN;



DATA COMMENTS; SET SASDATA.&DATA;
     WHERE COMMENTS NE '';
     KEEP PERMITNO COMMENTS;
run;



DATA HARVEST; SET SASDATA.&DATA (DROP =  YEAR KEYDATE HVRECID MAILING KEYID EDITED);
     SPECIES = 'SALMON';  *QQQ;
   * IF HARVDATE EQ '01JAN01'D THEN HARVDATE = .;
     IF NOCATCH = 1 THEN CATCH = 'N'; IF NOCATCH NE 1 THEN CATCH = 'Y';
     IF NOHRVRPT = 1 THEN HRVRPT = 'N'; IF NOHRVRPT NE 1 THEN HRVRPT = 'Y';
     IF FISHERY = '' THEN FISHERY = 'UNKNOWN';
     RENAME PERMITNO = PERMIT;
     DROP NOCATCH NOHRVRPT COMMENTS;
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


     
DATA SASDATA.SALMON_HARVEST; SET HARVEST; 
RUN;


PROC EXPORT DATA= WORK.COMMENTS
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="HARVEST COMMENTS"; 
RUN;


PROC EXPORT DATA= WORK.HARVEST
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="HARVEST RECORDS"; 
RUN;


