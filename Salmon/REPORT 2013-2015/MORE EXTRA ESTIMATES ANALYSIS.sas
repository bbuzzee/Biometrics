OPTIONS PAGENO=1 NODATE SYMBOLGEN LINESIZE=119 PAGESIZE=67 ;
LIBNAME SASDATA BASE "O:\DSF\RTS\Pat\Permits\Salmon\REPORT 2013-2015";
TITLE1 '2013, 2014, 2015 DATA COMBINED';
TITLE2 'ONLY THOSE PERMITS THAT FISHED IN ONE FISHERY ARE INCLUDED IN THE ANALYSIS';

%LET YEAR1 = 2013;
%LET YEAR2 = 2014;
%LET YEAR3 = 2015;
RUN;


DATA ALL; SET SASDATA.EXTRA2013 SASDATA.EXTRA2014 SASDATA.EXTRA2015;
     IF FISHERIES EQ 1;
     DROP FISHERIES;

PROC PRINT DATA = ALL (OBS = 20);
RUN;

PROC CONTENTS;
RUN;

DATA KENAI; SET ALL;
     IF KENAI_DAYS GE 1;
     DAYS = KENAI_DAYS;
     HARVEST = KENAI_HARVEST;
     FISHERY = 'KENAI          ';
     DROP KENAI_DAYS KENAI_HARVEST KASILOF_DIPNET_DAYS KASILOF_DIPNET_HARVEST 
          KASILOF_GILLNET_DAYS KASILOF_GILLNET_HARVEST UNKNOWN_DAYS UNKNOWN_HARVEST TOTAL_DAYS;
DATA KASILOF_DIPNET; SET ALL;
     IF KASILOF_DIPNET_DAYS GE 1;
     DAYS = KASILOF_DIPNET_DAYS;
     HARVEST = KASILOF_DIPNET_HARVEST;
     FISHERY = 'KASILOF_DIPNET';
     DROP KENAI_DAYS KENAI_HARVEST KASILOF_DIPNET_DAYS KASILOF_DIPNET_HARVEST 
          KASILOF_GILLNET_DAYS KASILOF_GILLNET_HARVEST UNKNOWN_DAYS UNKNOWN_HARVEST TOTAL_DAYS;
DATA KASILOF_GILLNET; SET ALL;
     IF KASILOF_GILLNET_DAYS GE 1;
     DAYS = KASILOF_GILLNET_DAYS;
     HARVEST = KASILOF_GILLNET_HARVEST;
     FISHERY = 'KASILOF_GILLNET';
     DROP KENAI_DAYS KENAI_HARVEST KASILOF_DIPNET_DAYS KASILOF_DIPNET_HARVEST 
          KASILOF_GILLNET_DAYS KASILOF_GILLNET_HARVEST UNKNOWN_DAYS UNKNOWN_HARVEST TOTAL_DAYS;
DATA UNKNOWN; SET ALL;
     IF UNKNOWN_DAYS GE 1;
     DAYS = UNKNOWN_DAYS;
     HARVEST = UNKNOWN_HARVEST;
     FISHERY = 'UNKNOWN';
     DROP KENAI_DAYS KENAI_HARVEST KASILOF_DIPNET_DAYS KASILOF_DIPNET_HARVEST 
          KASILOF_GILLNET_DAYS KASILOF_GILLNET_HARVEST UNKNOWN_DAYS UNKNOWN_HARVEST TOTAL_DAYS;

DATA ALLFISHERIES; SET KENAI KASILOF_DIPNET KASILOF_GILLNET UNKNOWN;
     IF HOUSEHOLD_SIZE GT 7 THEN HOUSEHOLD_SIZE = 7;
     IF DAYS GT 5 THEN DAYS = 5;
     PERCENT_ALLOWED = ROUND((HARVEST / ALLOWED) * 100,1);

PROC PRINT DATA=ALLFISHERIES (OBS=20);
RUN;


*****************************;
*         FIGURE 10 A       *;
*****************************;
PROC SORT DATA = ALLFISHERIES; BY FISHERY;
PROC FREQ DATA = ALLFISHERIES; BY FISHERY;
     TABLES HOUSEHOLD_SIZE / OUT=FIGURE10_A;
     WHERE HOUSEHOLD_SIZE NE .;

PROC PRINT DATA = FIGURE10_A;
RUN;

/*
PROC EXPORT DATA= WORK.FIGURE10_A 
     OUTFILE= "O:\DSF\RTS\common\Pat\Permits\Salmon\REPORT &YEAR1-&YEAR3\MORE EXTRA ESTIMATES.xls" 
     DBMS=EXCEL REPLACE;
     SHEET="FIGURE10_A"; 
RUN;
*/


*****************************;
*         FIGURE 10 B       *;
*****************************;
PROC SORT DATA = ALLFISHERIES; BY FISHERY;
PROC MEANS SUM NOPRINT DATA = ALLFISHERIES; BY FISHERY;
     VAR HARVEST;
     OUTPUT OUT = HARVEST_BY_FISHERY SUM = TOTAL_HARVEST;

PROC SORT DATA = ALLFISHERIES; BY FISHERY HOUSEHOLD_SIZE;
PROC MEANS SUM DATA = ALLFISHERIES; BY FISHERY HOUSEHOLD_SIZE;
     VAR HARVEST;
     WHERE HOUSEHOLD_SIZE NE .;
     OUTPUT OUT=HARVEST_BY_FISHERY_HHS SUM = HARVEST_BY_FISHERY_HHS;

DATA FIGURE10_B; MERGE HARVEST_BY_FISHERY HARVEST_BY_FISHERY_HHS; BY FISHERY;
     PERCENT = (HARVEST_BY_FISHERY_HHS/TOTAL_HARVEST) * 100;
     DROP _TYPE_ _FREQ_;

PROC PRINT;
RUN;
/*
PROC EXPORT DATA= WORK.FIGURE10_B 
     OUTFILE= "O:\DSF\RTS\common\Pat\Permits\Salmon\REPORT &YEAR1-&YEAR3\MORE EXTRA ESTIMATES.xls" 
     DBMS=EXCEL REPLACE;
     SHEET="FIGURE10_B"; 
RUN;
*/


*****************************;
*         FIGURE 10 C       *;
*****************************;
PROC SORT DATA = ALLFISHERIES; BY FISHERY HOUSEHOLD_SIZE;
PROC MEANS NOPRINT DATA = ALLFISHERIES; BY FISHERY HOUSEHOLD_SIZE;
     VAR PERCENT_ALLOWED;
     WHERE HOUSEHOLD_SIZE NE .;
     WHERE PERCENT_ALLOWED NE .;
     OUTPUT OUT = FIGURE10_C MEAN = MEAN STDERR = SE N = N;

DATA FIGURE10_C; SET FIGURE10_C;
     LCI = MEAN - (1.96*SE);
     UCI = MEAN + (1.96*SE);
     DROP _TYPE_ _FREQ_;
PROC PRINT;
RUN;

/*
PROC EXPORT DATA= WORK.FIGURE10_C 
     OUTFILE= "O:\DSF\RTS\common\Pat\Permits\Salmon\REPORT &YEAR1-&YEAR3\MORE EXTRA ESTIMATES.xls" 
     DBMS=EXCEL REPLACE;
     SHEET="FIGURE10_C"; 
RUN;
*/




*****************************;
*         FIGURE 11 A       *;
*****************************;
PROC SORT DATA = ALLFISHERIES; BY FISHERY;
PROC FREQ DATA = ALLFISHERIES; BY FISHERY;
     TABLES DAYS / OUT=FIGURE11_A;
     WHERE DAYS NE .;

PROC PRINT DATA = FIGURE11_A;
RUN;

/*
PROC EXPORT DATA= WORK.FIGURE11_A 
     OUTFILE= "O:\DSF\RTS\common\Pat\Permits\Salmon\REPORT &YEAR1-&YEAR3\MORE EXTRA ESTIMATES.xls" 
     DBMS=EXCEL REPLACE;
     SHEET="FIGURE11_A"; 
RUN;
*/


*****************************;
*         FIGURE 11 B       *;
*****************************;

PROC SORT DATA = ALLFISHERIES; BY FISHERY DAYS;
PROC MEANS SUM DATA = ALLFISHERIES; BY FISHERY DAYS;
     VAR HARVEST;
     WHERE DAYS NE .;
     OUTPUT OUT=HARVEST_BY_FISHERY_DAYS SUM = HARVEST_BY_FISHERY_DAYS;

DATA FIGURE11_B; MERGE HARVEST_BY_FISHERY HARVEST_BY_FISHERY_DAYS; BY FISHERY;
     PERCENT = (HARVEST_BY_FISHERY_DAYS/TOTAL_HARVEST) * 100;
     DROP _TYPE_ _FREQ_;

PROC PRINT;
RUN;
/*
PROC EXPORT DATA= WORK.FIGURE11_B 
     OUTFILE= "O:\DSF\RTS\common\Pat\Permits\Salmon\REPORT &YEAR1-&YEAR3\MORE EXTRA ESTIMATES.xls" 
     DBMS=EXCEL REPLACE;
     SHEET="FIGURE11_B"; 
RUN;
*/



*****************************;
*         FIGURE 11 C       *;
*****************************;
PROC SORT DATA = ALLFISHERIES; BY FISHERY DAYS;
PROC PRINT DATA = ALLFISHERIES;
RUN;
PROC MEANS NOPRINT DATA = ALLFISHERIES; BY FISHERY DAYS;
     VAR PERCENT_ALLOWED;
     WHERE DAYS NE .;
     WHERE PERCENT_ALLOWED NE .;
     OUTPUT OUT = FIGURE11_C MEAN = MEAN STDERR = SE N = N;

DATA FIGURE11_C; SET FIGURE11_C;
     LCI = MEAN - (1.96*SE);
     UCI = MEAN + (1.96*SE);
     DROP _TYPE_ _FREQ_;
PROC PRINT;
RUN;

/*
PROC EXPORT DATA= WORK.FIGURE11_C 
     OUTFILE= "O:\DSF\RTS\common\Pat\Permits\Salmon\REPORT &YEAR1-&YEAR3\MORE EXTRA ESTIMATES.xls" 
     DBMS=EXCEL REPLACE;
     SHEET="FIGURE11_C"; 
RUN;
*/



