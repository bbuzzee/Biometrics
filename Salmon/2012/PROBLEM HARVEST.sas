****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program reads and modifies data for harvest                                 *;
*     This program is stored as O:\DSF\RTS\pat\permits\salmon\2012\harvest.sas          *;
****************************************************************************************;


%LET PROJECT = SALMON;
%LET DATA = cislhv12c;
%LET YEAR = 2012;
%LET SP = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM,FLOUNDER; 
%LET SPECIES_LIST = RED KING COHO PINK CHUM FLOUNDER; 
%LET PROGRAM = HARVEST;
%LET GILLNET_START = '15JUN12'D; 
%LET GILLNET_STOP = '24JUN12'D; 


OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "O:\DSF\RTS\common\Pat\Permits\&PROJECT\&YEAR";
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
     DROP IMAGEPATH NOCATCH NOHRVRPT COMMENTS;
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
PROC SORT DATA = HARVEST; BY PERMIT;
RUN;

DATA PROBLEM; MERGE HARVEST PROBLEM; BY PERMIT;
     IF PROBLEM = 'Y';
RUN;
PROC PRINT DATA = PROBLEM;
     VAR PERMIT harvdate red king coho pink chum flounder fishery CATCH HRVRPT blankrpt notfish mailing STATUS VENDORCOPY RESPONDED;
RUN;

