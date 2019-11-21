****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program reads and modifies data for harvest                                 *;
*     This program is stored as h:\common\pat\permits\salmon\2002\harvest.sas          *;
****************************************************************************************;


%LET PROJECT = SALMON;
%LET DATA = CISLHV07C;
%LET YEAR = 2007;
%LET SP = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM,FLOUNDER; 
%LET SPECIES_LIST = RED KING COHO PINK CHUM FLOUNDER; 
%LET PROGRAM = HARVEST;
%LET GILLNET_START = '15JUN07'D; 
%LET GILLNET_STOP = '24JUN07'D; 


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






DATA HARVEST; SET SASDATA.&DATA (DROP =  YEAR KEYDATE HVRECID MAILING KEYID EDITED);
     SPECIES = 'SALMON';  
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


RUN;

PROC SORT; BY PERMIT MONTH DAY FISHERY;
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

PROC FREQ DATA = HARVEST;
     TABLES PERMIT / NOPRINT OUT=FREQ_DAYS;
PROC FREQ;
     TABLES COUNT / NOPRINT OUT=FREQ_DAYS;
DATA FREQ_DAYS; SET FREQ_DAYS;
     RENAME COUNT = DAYS_FISHED;
     
PROC PRINT NOOBS;
     TITLE2 'FREQUENCY OF DAYS FISHED';
     TITLE3 ;
RUN;

PROC FREQ DATA = HARVEST;
     TABLES &SPECIES_LIST;
     TITLE2 'HARVEST DATABASE';
     TITLE3 ;
run;


PROC UNIVARIATE PLOT DATA = HARVEST;
     VAR &SPECIES_LIST;
RUN;


     
DATA SASDATA.SALMON_HARVEST; SET HARVEST; 
RUN;







DATA COMMENTS; SET SASDATA.&DATA;
     WHERE COMMENTS NE '';
     KEEP PERMITNO COMMENTS;
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





/*
PROC SORT DATA = SASDATA.SALMON_HARVEST; BY HARVDATE FISHERY;
PROC MEANS DATA = SASDATA.SALMON_HARVEST SUM NOPRINT; BY HARVDATE FISHERY;
     VAR RED PINK COHO CHUM KING FLOUNDER;
     OUTPUT OUT = DAILY SUM = RED PINK COHO CHUM KING FLOUNDER N = TRIPS;

DATA DAILY; SET DAILY (DROP= _TYPE_ _FREQ_);
     LOCATION = FISHERY;
     DROP FISHERY;

DATA DAILY; SET DAILY;
     LENGTH FISHERY $18.;
     IF LOCATION EQ 'KASILOF' AND HARVDATE GE &GILLNET_START AND HARVDATE LE &GILLNET_STOP THEN FISHERY = 'KASILOF GILLNET';  *GILLNET;
     IF LOCATION EQ 'KASILOF' AND FISHERY = '' THEN FISHERY = 'KASILOF DIPNET';  *DIPNET;
     IF FISHERY = '' THEN FISHERY = LOCATION;
     DROP LOCATION;
PROC SORT; BY FISHERY HARVDATE;
PROC PRINT DATA = DAILY (OBS = 25);
RUN;



PROC EXPORT DATA= WORK.DAILY 
            OUTFILE= "H:\common\PAT\Permits\Salmon\&YEAR\DAILY REPORTED.xls" 
            DBMS=EXCEL2000 REPLACE;
RUN;


*/

