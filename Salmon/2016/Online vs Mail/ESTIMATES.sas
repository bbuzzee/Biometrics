****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*  This program estimates the harvest by species and fishery                           *;
*  This program is stored as O:\DSF\RTS\common\PAT\PERMITS\salmon\2013\estimates.sas   *;
****************************************************************************************;


%LET PROJECT = SALMON;
%LET PROGRAM = ESTIMATES;
%LET YEAR = 2016;
%LET SPECIES = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM,FLOUNDER; 
%LET SPECIES_LIST = RED KING COHO PINK CHUM FLOUNDER; 

%LET GROUP = VM;  *OO, OM, VO, VM;

%LET GILLNET_START = '15JUN16'D; 
%LET GILLNET_STOP = '24JUN16'D; 


%LET NUMBER_FISHERIES = 6;
%LET MATRIX = 7;  
%LET TOTAL = _7;  
RUN;

TITLE1 "&PROJECT - &YEAR";

OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\&YEAR\Online vs Mail";
RUN;


TITLE1 "&PROJECT - &YEAR - &GROUP";

%LET F1 = KENAI;
%LET F2 = KASILOF DIPNET;
%LET F3 = KASILOF GILLNET;
%LET F4 = FISH CREEK;
%LET F5 = UNK FIXABLE;
%LET F6 = UNKNOWN;
%LET F7 = TOTAL;

run;




**************************************************************************;
*                              ESTIMATES                                 *;
**************************************************************************;
PROC SORT DATA = SASDATA.ISSUED; BY GROUP;
PROC FREQ DATA = SASDATA.ISSUED; BY GROUP;
     TABLES MAILING / NOPRINT OUT = BN;

PROC TRANSPOSE DATA = BN OUT = BN; BY GROUP;
      VAR COUNT;

DATA BN; SET BN (RENAME=(COL1 = BN_0 COL2 = BN_1 COL3 = BN_2));
     KEEP GROUP BN_0 BN_1 BN_2;
     IF GROUP = &GROUP;
RUN;
PROC PRINT DATA = BN;
RUN;

PROC SORT DATA=SASDATA.SALMON_HARVEST; BY PERMIT; RUN; 
PROC SORT DATA=SASDATA.ISSUED; BY PERMIT; RUN;

DATA ALLPERMITS; MERGE SASDATA.SALMON_HARVEST (IN=INH) SASDATA.ISSUED (IN=INP); BY PERMIT;  
     IF INH THEN HARVFILE=1;
     IF INP THEN PERMFILE=1;
     PROJECT = 'SALMON';
     IF GROUP = "&GROUP";
     DROP ISSUE_METHOD RESPONSE_METHOD RM;
RUN;


PROC PRINT DATA=ALLPERMITS;
     WHERE HARVFILE=1 AND PERMFILE=.;
     TITLE2 'PERMITS THAT ARE IN HARVEST FILE BUT NOT IN PERMIT FILE';
     TITLE3 'NEED TO ADD THESE TO PERMIT FILE';
RUN;


DATA ALLPERMITS; SET ALLPERMITS;
    IF RESPONDED EQ '' THEN RESPONDED = 'N';
    DROP HARVFILE PERMFILE OFFICE;
RUN;

PROC PRINT DATA = ALLPERMITS (OBS = 50);
     TITLE2 'ALLPERMITS DATASET';
     TITLE3 'FIRST 50 OBSERVATIONS';
RUN;




DATA RETURNED; SET ALLPERMITS (RENAME=(FISHERY = OLDFSHRY));
     IF RESPONDED = 'N' THEN DELETE;
     TOTAL = SUM(&SPECIES_COMMA,0);
     IF MAILING LT 1 THEN COMPLIANT = 'Y';
        ELSE COMPLIANT = 'N';
     IF STATUS = 'DID NOT FISH' OR STATUS = 'BLANK REPORT' THEN FISHED = 'N';
        ELSE FISHED = 'Y';

* COUNT THE NUMBER OF PERMITS THAT DID NOT FISH;

DATA NOFISH; SET RETURNED; BY PERMIT;
     IF FIRST.PERMIT;

PROC FREQ DATA=NOFISH; 
     TABLES FISHED*MAILING/ OUT=NOFISHING;
     TITLE2 'NUMBER OF RESPONDING PERMITS THAT DID NOT FISH';
RUN;

PROC FREQ DATA = NOFISH; 
     WHERE MAILING = 2 OR MAILING = 1;
     TABLES FISHED/ NOPRINT OUT=NOFISHING2;
RUN;

DATA FISHED_MAILING2; SET NOFISHING2;
     IF FISHED = 'Y';
     P = PERCENT / 100;
     Q = 1 - P;
     N = COUNT / P;
     VAR_P = (P * Q)/(N-1);
     SE_P = SQRT(VAR_P);
     _TYPE_ = 1;


PROC PRINT;
     TITLE2 'MAILING 1 AND 2 PERMITS THAT FISH';
RUN;


DATA SASDATA.FISHED_MAILING2_&GROUP; SET FISHED_MAILING2;
DATA FISHED_MAILING2; SET FISHED_MAILING2 (KEEP = P VAR_P SE_P);


DATA HARVESTED; SET RETURNED;
     IF FISHED = 'N' THEN DELETE;
     IF OLDFSHRY EQ 'KENAI'    THEN FISHERY = 1;
     IF OLDFSHRY EQ 'KASILOF' AND HARVDATE GE &GILLNET_START AND HARVDATE LE &GILLNET_STOP THEN FISHERY = 3;  *GILLNET;
     IF OLDFSHRY EQ 'KASILOF' AND FISHERY = . THEN FISHERY = 2;  *DIPNET;
     IF OLDFSHRY EQ 'FISH CREEK'  THEN FISHERY = 4;
     IF OLDFSHRY EQ 'UNK FIXABLE' THEN FISHERY = 5;
    IF OLDFSHRY EQ 'UNKNOWN'     THEN FISHERY = 6;

    * DROP OLDFSHRY;

     FORMAT FISHERY 1.0;
     KEEP PERMIT HARVDATE &SPECIES_LIST TOTAL FISHERY COMPLIANT FAMILYSI MAILING OLDFSHRY;
RUN;

/*
PROC PRINT DATA=HARVESTED (OBS = 45);
     TITLE2 'DATA = HARVESTED';
     TITLE3 'OBS = 45'; 
RUN;
*/



PROC SORT DATA=HARVESTED; BY PERMIT FISHERY;

DATA SASDATA.HARVESTED_&GROUP; SET HARVESTED;
RUN;



DATA HARVESTED; SET SASDATA.HARVESTED_&GROUP; 


/*
PROC PRINT DATA = HARVESTED (OBS = 55);
     TITLE2 'DATA HARVESTED';
     TITLE3;
RUN;
*/

PROC SUMMARY DATA=HARVESTED NWAY; BY PERMIT;
     VAR HARVDATE &SPECIES_LIST TOTAL;
     ID FAMILYSI COMPLIANT MAILING; 
     OUTPUT OUT=TOTALHARV N(HARVDATE)=DAYS SUM=;
RUN;


* DO THIS SUMMARY & PRINT JUST TO CHECK THE SUM OF HARVEST FOR RETURNED PERMITS TO SEE IF I'M ON TRACK;
PROC SORT DATA = HARVESTED; BY FISHERY;
PROC MEANS SUM NOPRINT DATA = HARVESTED; BY FISHERY;
     VAR &SPECIES_LIST TOTAL;
     OUTPUT OUT = CHECK SUM=;
PROC PRINT LABEL;
     LABEL _FREQ_ = 'RECORDS';
     TITLE2 'REPORTED HARVEST BY FISHERY - NOT EXPANDED OR CORRECTED';
RUN;


* NOW GET FILE FISHERYHARVEST WITH ONE LINE PER PERMIT IN EACH FISHERY (SUM ACROSS DATES)
     REMEMBER SOME PERMITS FISHED IN MORE THAN ONE FISHERY, SO STILL HAVE MORE THAN ONE
     LINE PER PERMIT;
PROC SORT DATA = HARVESTED; BY PERMIT;
PROC SUMMARY DATA=HARVESTED NWAY; BY PERMIT;
     CLASS FISHERY;
     VAR &SPECIES_LIST TOTAL;
     ID FAMILYSI MAILING COMPLIANT; 
     OUTPUT OUT=FISHERYHARVEST N=DAYS SUM=;
RUN;

DATA FISHERYHARVEST; SET FISHERYHARVEST (DROP = _TYPE_ _FREQ_);

/*
PROC PRINT DATA=FISHERYHARVEST (OBS = 60);
     TITLE2 'FISHERYHARVEST AFTER SUMMARY';
RUN; 
*/


* TRANSPOSE SO SPECIES BECOME ROWS AND FISHERIES ARE COLUMNS;
PROC SORT DATA = FISHERYHARVEST; BY PERMIT FAMILYSI MAILING COMPLIANT;
PROC TRANSPOSE DATA=FISHERYHARVEST OUT=FISHERYWIDE; BY PERMIT FAMILYSI MAILING COMPLIANT;
     VAR DAYS &SPECIES_LIST TOTAL;
     ID FISHERY;
RUN;



DATA FISHERYWIDE;  SET FISHERYWIDE;
     RENAME _NAME_=VARIABLE;
     &TOTAL = SUM(OF _1-_&NUMBER_FISHERIES);
PROC SORT DATA=FISHERYWIDE; BY PERMIT VARIABLE;

/*
PROC PRINT DATA = FISHERYWIDE (OBS=65) LABEL;
     LABEL _1="REPORTED HARVEST &F1" _2="REPORTED HARVEST &F2" _3="REPORTED HARVEST &F3"
           _4="REPORTED HARVEST &F4" _5="REPORTED HARVEST &F5"
           VARIABLE = 'VARIABLE' &TOTAL = 'TOTAL';
     TITLE2 'FISHERYHARVEST AFTER TRANSPOSE';
     TITLE3;
RUN;
*/

* SET MISSING HARVESTS TO ZERO;
DATA FISHERYWIDE; SET FISHERYWIDE;
     ARRAY CATCH(&MATRIX) _1-&TOTAL;
     DO I=1 TO (&MATRIX);
          IF CATCH(I) EQ . THEN CATCH(I) = 0;
          END;
     DROP I;
RUN;

PROC SORT DATA=FISHERYWIDE; BY VARIABLE &TOTAL;

* COUNT THE NUMBER OF RECORDS THAT FISHED WITH NO HARVEST;
PROC FREQ DATA=FISHERYWIDE; 
     WHERE VARIABLE EQ 'TOTAL' AND (&TOTAL = . OR &TOTAL = 0);
     TABLES &TOTAL / MISSING OUT=NOHARVEST NOPRINT;
PROC PRINT; RUN;
DATA NOHARVEST; SET NOHARVEST;
     RENAME COUNT = RECORDS &TOTAL = TOTAL_HARVEST;
     DROP PERCENT;
PROC PRINT;
     TITLE2 'NUMBER OF RESPONDING PERMITS THAT FISHED, BUT DID NOT CATCH ANYTHING';
     TITLE3;
RUN;


* GET THE TOTAL REPORTED HARVEST FROM EACH FISHERY.
     THIS ISN'T USED IN THE FOLLOWING CALCULATIONS, JUST A HANDY SUMMARY.
     DO IT FIRST FOR ALL PERMITS, THEN FOR VOLUNTARY, MAIL1, MAIL2
     BN_V = THE NUMBER OF VOLUNTARY PERMITS;
PROC SUMMARY DATA=FISHERYWIDE NWAY;
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=BH_ SUM= N=BN_;
DATA BH_; SET BH_ (DROP = _TYPE_ _FREQ_);
     IF VARIABLE = 'TOTAL' THEN DELETE;
PROC PRINT LABEL;
     LABEL _1="REPORTED HARVEST &F1" _2="REPORTED HARVEST &F2" _3="REPORTED HARVEST &F3" 
           _4="REPORTED HARVEST &F4" _5="REPORTED HARVEST &F5" _6="REPORTED HARVEST &F6" _7="REPORTED HARVEST &F7"
         BN_ = 'NUMBER RETURNED PERMITS' VARIABLE = 'VARIABLE';
     TITLE2 'TOTAL REPORTED HARVEST';
     TITLE3 'ALL RETURNS';
RUN;



PROC SUMMARY DATA=FISHERYWIDE NWAY;
     WHERE MAILING EQ 0;
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=BH_V N=BN_V SUM=  MEAN=MEAN1-MEAN&MATRIX;
DATA BH_V; SET BH_V (DROP = _TYPE_ _FREQ_);
     IF VARIABLE = 'TOTAL' THEN DELETE;
PROC PRINT LABEL;
     LABEL _1="REPORTED HARVEST &F1" _2="REPORTED HARVEST &F2" _3="REPORTED HARVEST &F3" 
           _4="REPORTED HARVEST &F4" _5="REPORTED HARVEST &F5" _6="REPORTED HARVEST &F6" _7="REPORTED HARVEST &F7" 
         BN_V='NUMBER VOLUNTARY PERMITS' VARIABLE = 'VARIABLE' 
        MEAN1="MEAN &F1" MEAN2 = "MEAN &F2" MEAN3 = "MEAN &F3"
        MEAN4="MEAN &F4" MEAN5 = "MEAN &F5" MEAN6 = "MEAN &F6" MEAN7 = "MEAN &F7";
     TITLE2 'TOTAL REPORTED HARVEST';
     TITLE3 'VOLUNTARY RETURNS';
RUN;

* GET THE TOTAL REPORTED MAILING 1 HARVEST FROM EACH FISHERY.
     THIS ISN'T USED IN THE FOLLOWING CALCULATIONS, JUST A HANDY SUMMARY.
     BN_1 = THE NUMBER OF MAILING 1 PERMITS;
PROC SUMMARY DATA=FISHERYWIDE NWAY;
     WHERE MAILING = 1;
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=BH_1 N=BN_1 SUM=  MEAN=MEAN1-MEAN&MATRIX;
DATA BH_1; SET BH_1 (DROP = _TYPE_ _FREQ_);
     IF VARIABLE = 'TOTAL' THEN DELETE;
PROC PRINT LABEL;
     LABEL _1="REPORTED HARVEST &F1" _2="REPORTED HARVEST &F2" _3="REPORTED HARVEST &F3" 
           _4="REPORTED HARVEST &F4" _5="REPORTED HARVEST &F5" _6="REPORTED HARVEST &F6" _7="REPORTED HARVEST &F7"  
         BN_1 = 'NUMBER MAILING 1 PERMITS' VARIABLE = 'VARIABLE' 
        MEAN1="MEAN &F1" MEAN2 = "MEAN &F2" MEAN3 = "MEAN &F3"
        MEAN4="MEAN &F4" MEAN5 = "MEAN &F5" MEAN6 = "MEAN &F6" MEAN7 = "MEAN &F7";
     TITLE3 'MAILING 1';
RUN;

* GET THE TOTAL REPORTED MAILING 2 HARVEST FROM EACH FISHERY.
     THIS ISN'T USED IN THE FOLLOWING CALCULATIONS, JUST A HANDY SUMMARY.
     BN_2 = THE NUMBER OF MAILING 2 PERMITS;
PROC SUMMARY DATA=FISHERYWIDE NWAY;
     WHERE MAILING =2;
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=BH_2 N=BN_2 SUM=  MEAN=MEAN1-MEAN&MATRIX;
DATA BH_2; SET BH_2 (DROP = _TYPE_ _FREQ_);
     IF VARIABLE = 'TOTAL' THEN DELETE;
PROC PRINT LABEL;
     LABEL _1="REPORTED HARVEST &F1" _2="REPORTED HARVEST &F2" _3="REPORTED HARVEST &F3" 
           _4="REPORTED HARVEST &F4" _5="REPORTED HARVEST &F5" _6="REPORTED HARVEST &F6" _7="REPORTED HARVEST &F7"  
         BN_2 = 'NUMBER MAILING 2 PERMITS' VARIABLE = 'VARIABLE' 
        MEAN1="MEAN &F1" MEAN2 = "MEAN &F2" MEAN3 = "MEAN &F3"
        MEAN4="MEAN &F4" MEAN5 = "MEAN &F5" MEAN6 = "MEAN &F6" MEAN7 = "MEAN &F7";
     TITLE3 'MAILING 2';
RUN;


