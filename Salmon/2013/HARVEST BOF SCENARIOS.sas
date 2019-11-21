%LET PROJECT = SALMON;
%LET DATA = CISLHV13C;
%LET YEAR = 2013;
%LET SP = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM,FLOUNDER; 
%LET SPECIES_LIST = RED KING COHO PINK CHUM FLOUNDER; 
%LET PROGRAM = HARVEST;
%LET GILLNET_START = '15JUN13'D; 
%LET GILLNET_STOP = '24JUN13'D; 


OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;

LIBNAME SASDATA BASE "O:\DSF\RTS\PAT\PERMITS\&PROJECT\&YEAR";
RUN;


TITLE1 "&PROJECT - &YEAR";
RUN;


DATA FAMILY_SIZE; SET SASDATA.ISSUED;
     IF STATUS = 'HARVEST REPORTED';
     FAMILY_SIZE = FAMILYSI;
     KEEP FAMILY_SIZE PERMIT;
PROC SORT; BY PERMIT;
RUN;


**************************************************************************;
*                              HARVEST DATA                              *;
**************************************************************************;


DATA HARVEST; SET SASDATA.&DATA (DROP =  YEAR KEYDATE HVRECID MAILING KEYID EDITED);
     IF NOCATCH = 1 THEN CATCH = 'N'; IF NOCATCH NE 1 THEN CATCH = 'Y';
     IF NOHRVRPT = 1 THEN HRVRPT = 'N'; IF NOHRVRPT NE 1 THEN HRVRPT = 'Y';
     IF FISHERY = '' THEN FISHERY = 'UNKNOWN';
     RANDOM = RANUNI(7987);
     RENAME PERMITNO = PERMIT;
     DROP NOCATCH NOHRVRPT COMMENTS;
PROC SORT; BY PERMIT;
RUN;

DATA HARVEST; MERGE HARVEST FAMILY_SIZE; BY PERMIT;
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
     DROP IMAGEPATH;
RUN;

DATA HARVEST; SET HARVEST;
     IF KING GT RED AND (FISHERY = 'KENAI' OR (FISHERY = 'KASILOF' AND HARVDATE GT &GILLNET_STOP)) THEN DO; ***** DATA CHANGED IN 2013 DUE TO WHAT MANAGERS THOUGHT WAS DATA RECORDING ERRORS;
        RED = RED + KING;
        KING = 0;
     END;




PROC SORT; BY PERMIT MONTH DAY FISHERY;  
PROC PRINT DATA = HARVEST (OBS = 40);
     TITLE2 'HARVEST FILE WITH A RANDOM NUMBER AND FAMILY SIZE ADDED';
     TITLE3 ;
RUN;

PROC SORT; BY PERMIT RANDOM; 
DATA SCENARIOS; SET HARVEST;
     RED_CUM + RED;
RUN;

DATA SCENARIOS; SET SCENARIOS;
     LAGRED = LAG1(RED_CUM);
     LAGPERMIT = LAG1(PERMIT);
RUN;

PROC PRINT DATA = SCENARIOS (OBS = 40);
     TITLE2 'DATA SCENARIOS - USED IN SCENARIOS 2 - 6';
RUN;

DATA CUM_CORRECTION; SET SCENARIOS; BY PERMIT;
     IF FIRST.PERMIT;
     CUM_CORRECTION = LAGRED;
     KEEP PERMIT CUM_CORRECTION;
PROC PRINT DATA = CUM_CORRECTION (OBS = 40);
RUN;

DATA SCENARIOS; MERGE SCENARIOS CUM_CORRECTION; BY PERMIT;
     IF LAGPERMIT NE PERMIT THEN REDCUM = RED;
     IF LAGPERMIT EQ PERMIT THEN REDCUM = RED_CUM - CUM_CORRECTION;
     LAGREDCUM = LAG1(REDCUM);
RUN;






DATA SCENARIO_2; SET SCENARIOS;
     IF LAGPERMIT EQ PERMIT AND LAGREDCUM GT 10 THEN DELETE;
PROC SORT DATA = SCENARIO_2; BY PERMIT RANDOM;

DATA SCENARIO_2; SET SCENARIO_2; BY PERMIT;
     NEW_RED = RED;
     IF LAST.PERMIT AND REDCUM GT 10 THEN NEW_RED = RED - (REDCUM - 10); 
     DROP RED; 

PROC PRINT DATA = SCENARIO_2 (OBS = 40);
     TITLE2 'SCENARIO 2';
RUN;



DATA SASDATA.SALMON_HARVEST_SCENARIO_2; SET SCENARIO_2; 
     RENAME NEW_RED = RED;
     DROP LAGPERMIT LAGRED CUM_CORRECTION RED_CUM LAGREDCUM REDCUM RANDOM FAMILY_SIZE ;
RUN;


PROC PRINT DATA = SASDATA.SALMON_HARVEST_SCENARIO_2 (OBS = 40);
     TITLE2 'SCENARIO 2';
RUN;




DATA SCENARIO_3; SET SCENARIOS;
     LIMIT = 10 + ((FAMILY_SIZE - 1) * 5);
     IF LAGPERMIT EQ PERMIT AND LAGREDCUM GT LIMIT THEN DELETE;
PROC SORT DATA = SCENARIO_3; BY PERMIT RANDOM;

DATA SCENARIO_3; SET SCENARIO_3; BY PERMIT;
     NEW_RED = RED;
     IF LAST.PERMIT AND REDCUM GT LIMIT THEN NEW_RED = RED - (REDCUM - LIMIT); 
     DROP RED; 

PROC PRINT DATA = SCENARIO_3 (OBS = 40);
     TITLE2 'SCENARIO 3';
RUN;


DATA SASDATA.SALMON_HARVEST_SCENARIO_3; SET SCENARIO_3; 
     RENAME NEW_RED = RED;
     DROP LAGPERMIT LAGRED CUM_CORRECTION RED_CUM LAGREDCUM REDCUM RANDOM FAMILY_SIZE LIMIT;
RUN;

PROC PRINT DATA = SASDATA.SALMON_HARVEST_SCENARIO_3 (OBS = 40);
     TITLE2 'SCENARIO 3';
RUN;





DATA SCENARIO_4; SET SCENARIOS;
     IF LAGPERMIT EQ PERMIT AND LAGREDCUM GT 15 THEN DELETE;
PROC SORT DATA = SCENARIO_4; BY PERMIT RANDOM;

DATA SCENARIO_4; SET SCENARIO_4; BY PERMIT;
     NEW_RED = RED;
     IF LAST.PERMIT AND REDCUM GT 15 THEN NEW_RED = RED - (REDCUM - 15); 
     DROP RED; 

DATA SASDATA.SALMON_HARVEST_SCENARIO_4; SET SCENARIO_4; 
     RENAME NEW_RED = RED;
     DROP LAGPERMIT LAGRED CUM_CORRECTION RED_CUM LAGREDCUM REDCUM RANDOM FAMILY_SIZE ;
RUN;


PROC PRINT DATA = SASDATA.SALMON_HARVEST_SCENARIO_4 (OBS = 40);
     TITLE2 'SCENARIO 4';
RUN;


DATA SCENARIO_5; SET SCENARIOS;
     IF LAGPERMIT EQ PERMIT AND LAGREDCUM GT 20 THEN DELETE;
PROC SORT DATA = SCENARIO_5; BY PERMIT RANDOM;

DATA SCENARIO_5; SET SCENARIO_5; BY PERMIT;
     NEW_RED = RED;
     IF LAST.PERMIT AND REDCUM GT 20 THEN NEW_RED = RED - (REDCUM - 20); 
     DROP RED; 

DATA SASDATA.SALMON_HARVEST_SCENARIO_5; SET SCENARIO_5; 
     RENAME NEW_RED = RED;
     DROP LAGPERMIT LAGRED CUM_CORRECTION RED_CUM LAGREDCUM REDCUM RANDOM FAMILY_SIZE ;
RUN;


PROC PRINT DATA = SASDATA.SALMON_HARVEST_SCENARIO_5 (OBS = 40);
     TITLE2 'SCENARIO 5';
RUN;


DATA SCENARIO_6; SET SCENARIOS;
     LIMIT = 15 + ((FAMILY_SIZE - 1) * 5);
     IF LAGPERMIT EQ PERMIT AND LAGREDCUM GT LIMIT THEN DELETE;
PROC SORT DATA = SCENARIO_6; BY PERMIT RANDOM;

DATA SCENARIO_6; SET SCENARIO_6; BY PERMIT;
     NEW_RED = RED;
     IF LAST.PERMIT AND REDCUM GT LIMIT THEN NEW_RED = RED - (REDCUM - LIMIT); 
     DROP RED; 

PROC PRINT DATA = SCENARIO_6 (OBS = 40);
     TITLE2 'SCENARIO 6';
RUN;


DATA SASDATA.SALMON_HARVEST_SCENARIO_6; SET SCENARIO_6; 
     RENAME NEW_RED = RED;
     DROP LAGPERMIT LAGRED CUM_CORRECTION RED_CUM LAGREDCUM REDCUM RANDOM FAMILY_SIZE LIMIT;
RUN;

PROC PRINT DATA = SASDATA.SALMON_HARVEST_SCENARIO_6 (OBS = 40);
     TITLE2 'SCENARIO 6';
RUN;


DATA SCENARIO_7; SET SCENARIOS;
     LIMIT = 20 + ((FAMILY_SIZE - 1) * 5);
     IF LAGPERMIT EQ PERMIT AND LAGREDCUM GT LIMIT THEN DELETE;
PROC SORT DATA = SCENARIO_7; BY PERMIT RANDOM;

DATA SCENARIO_7; SET SCENARIO_7; BY PERMIT;
     NEW_RED = RED;
     IF LAST.PERMIT AND REDCUM GT LIMIT THEN NEW_RED = RED - (REDCUM - LIMIT); 
     DROP RED; 

PROC PRINT DATA = SCENARIO_7 (OBS = 40);
     TITLE2 'SCENARIO 7';
RUN;


DATA SASDATA.SALMON_HARVEST_SCENARIO_7; SET SCENARIO_7; 
     RENAME NEW_RED = RED;
     DROP LAGPERMIT LAGRED CUM_CORRECTION RED_CUM LAGREDCUM REDCUM RANDOM FAMILY_SIZE LIMIT;
RUN;

PROC PRINT DATA = SASDATA.SALMON_HARVEST_SCENARIO_7 (OBS = 40);
     TITLE2 'SCENARIO 7';
RUN;









DATA HARVEST_SCENARIO1; SET HARVEST;
     IF FISHERY = 'KENAI';
PROC SORT; BY PERMIT RANDOM; 
DATA SCENARIOS; SET HARVEST_SCENARIO1;
     RED_CUM + RED;
RUN;

DATA SCENARIOS; SET SCENARIOS;
     LAGRED = LAG1(RED_CUM);
     LAGPERMIT = LAG1(PERMIT);
RUN;

PROC PRINT DATA = SCENARIOS (OBS = 40);
     TITLE2 'SCENARIO 1  CHANGES ONLY MADE TO THE KENAI RIVER';
RUN;

DATA CUM_CORRECTION; SET SCENARIOS; BY PERMIT;
     IF FIRST.PERMIT;
     CUM_CORRECTION = LAGRED;
     KEEP PERMIT CUM_CORRECTION;
PROC PRINT DATA = CUM_CORRECTION (OBS = 40);
RUN;

DATA SCENARIOS; MERGE SCENARIOS CUM_CORRECTION; BY PERMIT;
     IF LAGPERMIT NE PERMIT THEN REDCUM = RED;
     IF LAGPERMIT EQ PERMIT THEN REDCUM = RED_CUM - CUM_CORRECTION;
     LAGREDCUM = LAG1(REDCUM);


DATA SCENARIO_1; SET SCENARIOS;
     IF LAGPERMIT EQ PERMIT AND LAGREDCUM GT 15 THEN DELETE;
PROC SORT DATA = SCENARIO_2; BY PERMIT RANDOM;

DATA SCENARIO_1; SET SCENARIO_1; BY PERMIT;
     NEW_RED = RED;
     IF LAST.PERMIT AND REDCUM GT 15 THEN NEW_RED = RED - (REDCUM - 15); 

PROC PRINT DATA = SCENARIO_1 (OBS = 40);
RUN;

DATA SCENARIO_1; SET SCENARIO_1 (DROP = RED); 
     RENAME NEW_RED = RED;
     DROP LAGPERMIT LAGRED CUM_CORRECTION RED_CUM LAGREDCUM REDCUM RANDOM FAMILY_SIZE ;
RUN;


DATA HARVEST_1; SET HARVEST;
     IF FISHERY = 'KENAI' THEN DELETE;

DATA HARVEST_1; SET HARVEST_1 SCENARIO_1;
     DROP RANDOM FAMILY_SIZE;


DATA SASDATA.SALMON_HARVEST_SCENARIO_1; SET HARVEST_1; 
RUN;


PROC PRINT DATA = SASDATA.SALMON_HARVEST_SCENARIO_1 (OBS = 40);
RUN;

