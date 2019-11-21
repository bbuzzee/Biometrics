****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program reads and modifies data for harvest                                 *;
*     This program is stored as h:\common\pat\permits\salmon\2002\harvest.sas          *;
****************************************************************************************;




%LET PROJECT = SALMON;
%LET DATA = CISLHV02C;
%LET YEAR = 2002;
%LET SP = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM;
%LET SPECIES_LIST = RED KING COHO PINK CHUM; 
%LET PROGRAM = HARVEST;
%LET GILLNET_START = '15JUN02'D; 
%LET GILLNET_STOP = '24JUN02'D; 





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
     SPECIES = 'SALMON';
    *IF HARVDATE EQ '01JAN01'D THEN HARVDATE = .;
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
     IF FISHERY = 'UNKNOWN' AND MONTH = 6 AND DAY GE 15 THEN FISHERY = 'KASILOF';
     IF FISHERY = 'UNKNOWN' AND MONTH = 7 AND DAY LE 9 THEN FISHERY = 'KASILOF';
     IF FISHERY = 'UNKNOWN' AND MONTH = 8 AND DAY GE 1 AND DAY LE 7 THEN FISHERY = 'KASILOF';

     IF FISHERY = 'UNKNOWN' AND MONTH = 7 AND DAY GE 10 THEN FISHERY = 'UNK FIXABLE';
RUN;

PROC SORT; BY PERMIT MONTH DAY FISHERY;
PROC FREQ;
     TABLES FISHERY;
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


     

DATA SASDATA.SALMON_HARVEST; SET HARVEST; 
RUN;

ODS RTF CLOSE;
RUN;

