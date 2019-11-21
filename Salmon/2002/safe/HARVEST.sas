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
%LET DATA = CISLHV02C;
%LET YEAR = 2002;
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

PROC PRINT DATA = SASDATA.&DATA;
     WHERE COMMENTS NE '';
     VAR PERMITNO COMMENTS;
RUN;


DATA HARVEST; SET SASDATA.&DATA (DROP =  YEAR KEYDATE HVRECID COMMENTS MAILING);
     SPECIES = 'SALMON';  *QQQ;
     IF HARVDATE EQ '01JAN01'D THEN HARVDATE = .;
     IF NOCATCH = 1 THEN CATCH = 'N'; IF NOCATCH NE 1 THEN CATCH = 'Y';
     IF NOHRVRPT = 1 THEN HRVRPT = 'N'; IF NOHRVRPT NE 1 THEN HRVRPT = 'Y';
     RENAME  /*HARDSHELL = OTHER_CLAMS*/ PERMITNO = PERMIT;  *QQQ;
RUN;


PROC SORT; BY PERMIT;     
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


PROC UNIVARIATE PLOT;
     VAR &SPECIES_LIST;
RUN;


     

/*
DATA OUTLIERS; SET HARVEST;
     IF SPECIES = 'CLAMS' THEN DO;
                          IF LITTLENECK GE 45 OR BUTTER GE 45 THEN OUTLIER = 'Y';
                          END;
     IF SPECIES = 'CRABS' THEN DO;
                          IF DUNGREL GE 70 OR TANNER GE 40 THEN OUTLIER = 'Y';
                          END;

PROC PRINT;
     WHERE OUTLIER = 'Y';
     TITLE3 'SUSPECTED OUTLIERS';
RUN;



DATA HARVEST; SET HARVEST;
     IF LITTLENECK GE 30 THEN LITTLENECK = ROUND((LITTLENECK/55),1);
     IF BUTTER GE 30 THEN BUTTER = ROUND((LITTLENECK/55),1);
     IF NOHRVRPT = 1 THEN NOCATCH = 1;
     DROP NOHRVRPT;
*/

DATA SASDATA.SALMON_HARVEST; SET HARVEST; *QQQ;
RUN;

ODS RTF CLOSE;
RUN;
