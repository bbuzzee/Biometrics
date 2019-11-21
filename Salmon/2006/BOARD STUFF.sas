
%LET PROJECT = SALMON;
%LET YEAR = 2006;
%LET SPECIES = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM,FLOUNDER; 
%LET SPECIES_LIST = RED KING COHO PINK CHUM FLOUNDER; 

%LET GILLNET_START = '15JUN06'D; 
%LET GILLNET_STOP = '24JUN06'D; 
RUN;

TITLE1 "&PROJECT - &YEAR";

OPTIONS PAGENO=1 NODATE SYMBOLGEN LINESIZE=119 PAGESIZE=67 ;
LIBNAME SASDATA BASE "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR";
RUN;



PROC SORT DATA=SASDATA.SALMON_HARVEST; BY PERMIT; RUN;  
PROC SORT DATA=SASDATA.ISSUED; BY PERMIT; RUN;

DATA ALLPERMITS; MERGE SASDATA.SALMON_HARVEST SASDATA.ISSUED ; BY PERMIT;  
RUN;

DATA ALLPERMITS2; MERGE ALLPERMITS SASDATA.PERSONAL; BY PERMIT;
     IF ALLOWED LE 35 THEN HOUSEHOLD = '2 OR LESS  ';
	 IF ALLOWED GT 35 THEN HOUSEHOLD = 'MORE THAN 2';
     RENAME FISHERY = LOCATION;
     DROP ADLNO FAMILYSI SPECIES OFFICE VENDORCOPY INITIAL KEYID LICENSE_NO STATE;
PROC SORT; BY PERMIT;

DATA RESPONDED; SET ALLPERMITS2; BY PERMIT;
     IF FIRST.PERMIT;

PROC FREQ;
     TABLES RESPONDED*HOUSEHOLD / OUT = RESPONDED_HOUSEHOLD_SIZE;
RUN;


DATA ALLPERMITS3; SET ALLPERMITS2;
     IF RESPONDED = 'Y';
     IF LOCATION EQ 'KASILOF' AND HARVDATE GE &GILLNET_START AND HARVDATE LE &GILLNET_STOP THEN FISHERY = 'KASILOF GILLNET';  *GILLNET;
     IF LOCATION EQ 'KASILOF' AND FISHERY = '' THEN FISHERY = 'KASILOF DIPNET';  *DIPNET;
     IF LOCATION EQ 'UNK FIXABLE' THEN FISHERY = 'UNKNOWN';
     IF LOCATION EQ 'UNK' THEN FISHERY = 'UNKNOWN';
     IF FISHERY = '' THEN FISHERY = LOCATION;
     MONTH = MONTH(HARVDATE);
     DAY = DAY(HARVDATE);
     SALMON = SUM(OF RED KING COHO PINK CHUM);
     IF SALMON = . THEN SALMON = 0; 
     DROP LOCATION;
RUN;


PROC FREQ DATA = ALLPERMITS3;
     TABLES FISHERY / OUT = SALMON_BY_FISHERY;
	 WEIGHT SALMON;
	 TITLE2 'NUMBER OF SALMON CAUGHT BY FISHERY';
RUN;

PROC SORT DATA = ALLPERMITS3; BY HOUSEHOLD;
PROC FREQ DATA = ALLPERMITS3; BY HOUSEHOLD;
     TABLES FISHERY / OUT = SALMON_BY_FISHERY_AND_HHSIZE;
	 WEIGHT SALMON;
	 TITLE2 'NUMBER OF SALMON CAUGHT BY FISHERY AND HOUSEHOLD SIZE';
RUN;

PROC SORT DATA = ALLPERMITS3; BY PERMIT ALLOWED HOUSEHOLD FISHERY;
PROC MEANS SUM NOPRINT DATA = ALLPERMITS3; BY PERMIT ALLOWED HOUSEHOLD FISHERY;
     VAR SALMON;
	 OUTPUT OUT = SUM_BY_PERMIT_FISHERY SUM = SALMON;


DATA KENAI; SET SUM_BY_PERMIT_FISHERY; 
     IF FISHERY = 'KENAI';
	 RENAME SALMON = KENAI;
	 DROP FISHERY _TYPE_ _FREQ_;

DATA KASILOF_DIPNET; SET SUM_BY_PERMIT_FISHERY; 
     IF FISHERY = 'KASILOF DIPNET';
	 RENAME SALMON = KASILOF_DIPNET;
	 DROP FISHERY _TYPE_ _FREQ_;

DATA KASILOF_GILLNET; SET SUM_BY_PERMIT_FISHERY; 
     IF FISHERY = 'KASILOF GILLNET';
	 RENAME SALMON = KASILOF_GILLNET;
	 DROP FISHERY _TYPE_ _FREQ_;

DATA UNKNOWN; SET SUM_BY_PERMIT_FISHERY; 
     IF FISHERY = 'UNKNOWN';
	 RENAME SALMON = UNKNOWN;
	 DROP FISHERY _TYPE_ _FREQ_;

DATA NOFISHING; SET SUM_BY_PERMIT_FISHERY; 
     IF FISHERY = '';
	 FISHED = 'N';
	 DROP FISHERY _TYPE_ _FREQ_ SALMON;

DATA FISHERY_BY_PERMIT; MERGE KENAI KASILOF_DIPNET KASILOF_GILLNET UNKNOWN NOFISHING; BY PERMIT;
     IF KENAI = . THEN KENAI = 0;
     IF KASILOF_DIPNET = . THEN KASILOF_DIPNET = 0;
     IF KASILOF_GILLNET = . THEN KASILOF_GILLNET = 0;
     IF UNKNOWN = . THEN UNKNOWN = 0;
     IF FISHED = '' THEN FISHED = 'Y';
	 TOTAL_SALMON = KENAI + KASILOF_DIPNET + KASILOF_GILLNET + UNKNOWN;

PROC PRINT DATA = FISHERY_BY_PERMIT (OBS = 50);
RUN;

DATA PERCENT_FISHERY; SET FISHERY_BY_PERMIT;
     IF TOTAL_SALMON GT 0 THEN DO;
          KENAI = ROUND((KENAI/TOTAL_SALMON)*100,1);
          KASILOF_DIPNET = ROUND((KASILOF_DIPNET/TOTAL_SALMON)*100,1);
          KASILOF_GILLNET = ROUND((KASILOF_GILLNET/TOTAL_SALMON)*100,1);
         UNKNOWN = ROUND((UNKNOWN/TOTAL_SALMON)*100,1);
	END;

     IF TOTAL_SALMON EQ 0 THEN DO;
          KENAI = .;
          KASILOF_DIPNET = .;
          KASILOF_GILLNET = .;
         UNKNOWN = .;
	END;
RUN;

PROC SORT; BY HOUSEHOLD;

PROC MEANS NOPRINT DATA = PERCENT_FISHERY; BY HOUSEHOLD;
     VAR KENAI KASILOF_DIPNET KASILOF_GILLNET UNKNOWN;
	 OUTPUT OUT = PERCENT_OF_TOTAL MEAN = KENAI KASILOF_DIPNET KASILOF_GILLNET UNKNOWN;

DATA PERCENT_OF_TOTAL; SET PERCENT_OF_TOTAL;
     DROP _TYPE_ _FREQ_; 
PROC PRINT;
     TITLE2 'AVERAGE PERCENT OF TOTAL SALMON HARVESTED BY FISHERY';
RUN;

DATA PERCENT_ALLOWED; SET FISHERY_BY_PERMIT;
     KENAI = ROUND((KENAI/ALLOWED)*100,1);
     KASILOF_DIPNET = ROUND((KASILOF_DIPNET/ALLOWED)*100,1);
     KASILOF_GILLNET = ROUND((KASILOF_GILLNET/ALLOWED)*100,1);
     UNKNOWN = ROUND((UNKNOWN/ALLOWED)*100,1);
PROC SORT; BY HOUSEHOLD;

PROC MEANS NOPRINT DATA = PERCENT_ALLOWED; BY HOUSEHOLD;
     VAR KENAI KASILOF_DIPNET KASILOF_GILLNET UNKNOWN;
     OUTPUT OUT = PERCENT_OF_ALLOWED MEAN = KENAI KASILOF_DIPNET KASILOF_GILLNET UNKNOWN;

DATA PERCENT_OF_ALLOWED; SET PERCENT_OF_ALLOWED;
     DROP _TYPE_ _FREQ_; 
PROC PRINT;
     TITLE2 'AVERAGE PERCENT OF ALLOWED BY FISHERY';
RUN;








/*
PROC EXPORT DATA= WORK.RESPONDED_HOUSEHOLD_SIZE
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS 2006 BOARD STUFF.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="RESPONDED BY HOUSEHOLD SIZE"; 
RUN;

PROC EXPORT DATA= WORK.SALMON_BY_FISHERY
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS 2006 BOARD STUFF.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="HARVEST BY PERMIT AND FISHERY"; 
RUN;

PROC EXPORT DATA= WORK.HARVEST_BY_PERMIT
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS 2006 BOARD STUFF.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="HARVEST BY PERMIT"; 
RUN;


PROC EXPORT DATA= WORK.SALMON_BY_FISHERY_AND_HHSIZE
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS 2006 BOARD STUFF.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="HARVEST BY FISHERY AND HHSIZE"; 
RUN;

PROC EXPORT DATA= WORK.FISHERY_BY_PERMIT
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS 2006 BOARD STUFF.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="FISHERIES BY PERMIT"; 
RUN;


PROC EXPORT DATA= WORK.PERCENT_OF_TOTAL
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS 2006 BOARD STUFF.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="AVERAGE PERCENT OF TOTAL"; 
RUN;

PROC EXPORT DATA= WORK.PERCENT_OF_ALLOWED
            OUTFILE= "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS 2006 BOARD STUFF.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="AVERAGE PERCENT OF ALLOWED"; 
RUN;

*/







