****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program reads and modifies data for harvest                                 *;
*     This program is stored as O:\DSF\RTS\common\PAT\PERMITS\salmon\2013\harvest.sas  *;
****************************************************************************************;


%LET PROJECT = SALMON;
%LET DATA = cislhv17c;
%LET YEAR = 2017;
%LET SP = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM,FLOUNDER; 
%LET SPECIES_LIST = RED KING COHO PINK CHUM FLOUNDER; 
%LET PROGRAM = HARVEST;
%LET GILLNET_START = '15JUN17'D; 
%LET GILLNET_STOP = '24JUN17'D;
%LET KENAI_KING_START = '25JUL17'D; 
%LET KENAI_KING_STOP = '31JUL17'D; 
 


OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\&YEAR";
RUN;


TITLE1 "&PROJECT - &YEAR";


**************************************************************************;
*                              HARVEST DATA                              *;
**************************************************************************;
/*
PROC CONTENTS DATA = SASDATA.&DATA;
RUN;

PROC FREQ DATA = SASDATA.&DATA;
     TABLES nohrvrpt FISHERY;
RUN;
*/

DATA HARVEST; SET SASDATA.&DATA (DROP =  YEAR KEYDATE HVRECID MAILING KEYID EDITED);
     SPECIES = 'SALMON';  
     IF NOCATCH = 1 THEN CATCH = 'N'; IF NOCATCH NE 1 THEN CATCH = 'Y';
     IF NOHRVRPT = 1 THEN HRVRPT = 'N'; IF NOHRVRPT NE 1 THEN HRVRPT = 'Y';
     IF FISHERY = '' THEN FISHERY = 'UNKNOWN';

	 IF RED = . THEN RED = 0;  IF KING = . THEN KING = 0; IF COHO = . THEN COHO = 0;
     IF PINK = . THEN PINK = 0;  IF CHUM = . THEN CHUM = 0;  IF FLOUNDER = . THEN FLOUNDER = 0;

     RENAME PERMITNO = PERMIT;
     DROP IMAGEPATH NOCATCH NOHRVRPT COMMENTS;
RUN;


/*
DATA HARVEST; SET HARVEST;
     JUNK = 1;
RUN;

ODS GRAPHICS ON;
PROC UNIVARIATE DATA = HARVEST NORMAL PLOT; BY JUNK;
     VAR RED KING COHO PINK CHUM FLOUNDER;
ODS GRAPHICS OFF;
RUN;

PROC BOXPLOT;
     PLOT RED*JUNK;* KING COHO PINK CHUM FLOUNDER;
RUN;
*/

/*
PROC FREQ;
     TABLES RED KING COHO PINK CHUM FLOUNDER;
RUN;
*/


DATA HARVEST; SET HARVEST;     
PROC SORT; BY FISHERY HARVDATE;


DATA HARVEST; SET HARVEST;   ************************************************************INSTRUCTIONS FROM KRISSY;
     IF KING GE 1 AND KING GT RED THEN DO;
	                                 RED = RED + KING;
                                     KING = 0;
							  END;
RUN;

DATA HARVEST; SET HARVEST;   ************************************************************INSTRUCTIONS FROM ADAM;
     IF COHO GE 1 AND COHO GT RED THEN DO;
	                                 RED = RED + COHO;
                                     COHO = 0;
							  END;
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
    * IF FISHERY = 'FISH CREEK' THEN FISHERY = 'UNKNOWN';                                       ********************************* FISH CREEK WAS CLOSED IN 2017;
RUN;
/*
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
*/
/*
PROC UNIVARIATE PLOT DATA = HARVEST;
     VAR &SPECIES_LIST;
RUN;

DATA HARVEST; SET HARVEST;
     IF KING GT RED AND (FISHERY = 'KENAI' OR (FISHERY = 'KASILOF' AND HARVDATE GT &GILLNET_STOP)) THEN PROBLEM = 'Y';

DATA HARVEST_CHANGED; SET HARVEST;
     IF PROBLEM = 'Y';
PROC PRINT DATA = HARVEST_CHANGED;
RUN;

DATA HARVEST; SET HARVEST;                             ******************* DATA CHANGED IN 2013 DUE TO WHAT MANAGERS THOUGHT WAS DATA RECORDING ERRORS;
     IF PROBLEM = 'Y' THEN DO;
        RED = RED + KING;
        KING = 0;
     END;
     DROP PROBLEM;
RUN;
*/
LIBNAME SASDATA BASE "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\&YEAR\NONRESPONSE PROBLEM";
DATA SASDATA.SALMON_HARVEST; SET HARVEST; 
RUN;







