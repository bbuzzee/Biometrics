%LET PROJECT = SALMON;
%LET PROGRAM = EXTRA ESTIMATES;
%LET YEAR = 2006;
%LET SPECIES = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM,FLOUNDER; 
%LET SPECIES_LIST = RED KING COHO PINK CHUM FLOUNDER; 

%LET GILLNET_START = '15JUN06'D; 
%LET GILLNET_STOP = '24JUN06'D; 
RUN;

TITLE1 "&PROJECT - &YEAR";

OPTIONS PAGENO=1 NODATE SYMBOLGEN LINESIZE=119 PAGESIZE=67 ;
LIBNAME SASDATA BASE "O:\DSF\RTS\PAT\PERMITS\&PROJECT\&YEAR";
RUN;



PROC SORT DATA=SASDATA.SALMON_HARVEST; BY PERMIT; RUN;  
PROC SORT DATA=SASDATA.ISSUED; BY PERMIT; RUN;

DATA ALLPERMITS; MERGE SASDATA.SALMON_HARVEST SASDATA.ISSUED ; BY PERMIT;  
RUN;

DATA ALLPERMITS2; MERGE ALLPERMITS SASDATA.PERSONAL; BY PERMIT;
     RENAME FISHERY = LOCATION;
     DROP ADLNO FAMILYSI SPECIES OFFICE VENDORCOPY;

DATA ALLPERMITS3; SET ALLPERMITS2;
     IF RESPONDED = 'Y' AND STATUS EQ 'HARVEST REPORTED';
     IF LOCATION EQ 'KASILOF' AND HARVDATE GE &GILLNET_START AND HARVDATE LE &GILLNET_STOP THEN FISHERY = 'KASILOF GILLNET';  *GILLNET;
     IF LOCATION EQ 'KASILOF' AND FISHERY = '' THEN FISHERY = 'KASILOF DIPNET';  *DIPNET;
     IF LOCATION EQ 'UNK FIXABLE' THEN FISHERY = 'UNKNOWN';
     IF LOCATION EQ 'UNK' THEN FISHERY = 'UNKNOWN';
     IF FISHERY = '' THEN FISHERY = LOCATION;
     DROP LOCATION;
RUN;




PROC SORT DATA = ALLPERMITS3; BY HARVDATE FISHERY;
PROC MEANS DATA = ALLPERMITS3 SUM NOPRINT; BY HARVDATE FISHERY;
     ID MONTH DAY;
     VAR RED PINK COHO CHUM KING FLOUNDER;
     OUTPUT OUT = DAILY SUM = SUM_RED SUM_PINK SUM_COHO SUM_CHUM SUM_KING SUM_FLOUNDER
                        MEAN = MEAN_RED MEAN_PINK MEAN_COHO MEAN_CHUM MEAN_KING MEAN_FLOUNDER
                        STDERR = STDERR_RED STDERR_PINK STDERR_COHO STDERR_CHUM STDERR_KING STDERR_FLOUNDER
                        N = TRIPS;

DATA DAILY; SET DAILY (DROP= _TYPE_ _FREQ_);
     YEAR = YEAR(HARVDATE);
     IF YEAR = . THEN YEAR = 1990;
     DROP MONTH DAY YEAR;
PROC SORT; BY FISHERY HARVDATE;






PROC EXPORT DATA= WORK.DAILY
            OUTFILE= "O:\DSF\RTS\PAT\PERMITS\&PROJECT\DAILY HARVEST BY FISHERY" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="&YEAR"; 
RUN;



