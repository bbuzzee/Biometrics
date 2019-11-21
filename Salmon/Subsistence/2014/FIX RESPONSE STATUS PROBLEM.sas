PROC DATASETS KILL;
RUN;


%LET PROJECT = SALMON;
%LET YEAR = 2014;
%LET PROGRAM = PERMIT;


OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA "O:\DSF\RTS\COMMON\PAT\PERMITS\&PROJECT\&YEAR";
*LIBNAME SASDATA "O:\DSF\RTS\COMMON\PAT\PERMITS\Salmon\Subsistence\&YEAR";
RUN;

TITLE1 "&PROJECT - &YEAR";

**************************************************************************;
*                              PERMIT DATA                               *;
**************************************************************************;
PROC CONTENTS DATA = SASDATA.ISSUED;
PROC CONTENTS DATA = SASDATA.PERSONAL;
RUN;

PROC FREQ DATA = SASDATA.ISSUED;
     TABLES RESPONDED*MAILING RESPONDED*STATUS STATUS*MAILING;
RUN;

PROC PRINT DATA = SASDATA.ISSUED;
     WHERE RESPONDED = 'Y' AND MAILING = 9;
PROC PRINT DATA = SASDATA.ISSUED;
     WHERE STATUS = 'HARVEST REPORTED' AND MAILING = 9;
RUN;

DATA ISSUED2; SET SASDATA.ISSUED;
     IF STATUS = 'HARVEST REPORTED' AND MAILING = 9 THEN MAILING = 0;

PROC FREQ DATA = ISSUED2;
     TABLES RESPONDED*MAILING RESPONDED*STATUS STATUS*MAILING;
RUN;

LIBNAME SASDATA "O:\DSF\RTS\COMMON\PAT\PERMITS\Salmon\Subsistence\";
DATA SASDATA.ISSUED; SET ISSUED2;
RUN;

