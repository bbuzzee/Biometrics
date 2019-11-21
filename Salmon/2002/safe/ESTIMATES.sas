****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program estimates the harvest by species and fishery                        *;
*     This program is stored as h:\common\pat\permits\salmon\2002\estimates.sas        *;
****************************************************************************************;



%LET PROJECT = SALMON;
%LET PROGRAM = ESTIMATES;
%LET DATA = CISLHV02C;
%LET YEAR = 2002;
*%LET SPECIES = CRABS;
*%LET SPECIES_LIST = LITTLENECK BUTTER OTHER_CLAMS;
*%LET SPECIES_COMMA = LITTLENECK,BUTTER,OTHER_CLAMS;
*%LET SPECIES_LIST = DUNGREL TANNER;
*%LET SPECIES_COMMA = DUNGREL,TANNER;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM; *QQQ;
%LET SPECIES_LIST = RED KING COHO PINK CHUM; *QQQ;

%LET NUMBER_FISHERIES = 6;
%LET MATRIX = 7;   *NUMBER OF FISHERIES + 1;
%LET TOTAL = _7;   *NUMBER OF FISHERIES + 1;
RUN;

TITLE1 "&PROJECT - &YEAR";

OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR";
ODS RTF FILE = "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\&PROGRAM..RTF";
RUN;



**************************************************************************;
*                              ESTIMATES                                 *;
**************************************************************************;

PROC SORT DATA=SASDATA.SALMON_HARVEST; BY PERMIT; RUN;  *QQQ;
PROC SORT DATA=SASDATA.ISSUED; BY PERMIT; RUN;

DATA ALLPERMITS; MERGE SASDATA.SALMON_HARVEST(IN=INH) SASDATA.ISSUED(IN=INP); BY PERMIT;  *QQQ;
     IF INH THEN HARVFILE=1;
     IF INP THEN PERMFILE=1;
     PROJECT = 'SALMON';
RUN;

PROC PRINT DATA=ALLPERMITS;
     WHERE HARVFILE=1 AND PERMFILE=.;
     TITLE2 'PERMITS THAT ARE IN HARVEST FILE BUT NOT IN PERMIT FILE';
     TITLE3 'NEED TO ADD THESE TO PERMIT FILE';
RUN;


DATA ALLPERMITS; SET ALLPERMITS;
    IF RESPONDED EQ '' THEN RESPONDED = 'N';
RUN;


PROC PRINT DATA=ALLPERMITS (OBS = 40);
     TITLE2 'ALLPERMITS FILE';
     TITLE3 'HARVEST FILE AFTER MERGING WITH PERMITS';
RUN;


DATA RETURNED; SET ALLPERMITS (RENAME=(FISHERY = OLDFSHRY));
     IF RESPONDED = 'N' THEN DELETE;
     TOTAL = SUM(&SPECIES_COMMA,0);
     IF MAILING LE 1 THEN COMPLIANT = 'Y';
        ELSE COMPLIANT = 'N';
     IF STATUS = 'DID NOT FISH' OR STATUS = 'BLANK REPORT' THEN NOTFISH = 1;
        ELSE NOTFISH = 0;

     IF PROJECT = 'SALMON' THEN DO;
           IF STATUS = 'N' THEN OLDFSHRY = 'DID NOT FISH';
           IF NOTFISH = 1 THEN OLDFSHRY = 'DID NOT FISH';
           IF OLDFSHRY EQ 'KENAI'    THEN FISHERY = 1;
           IF OLDFSHRY EQ 'KASILOF' AND HARVDATE GE '01JUN02'D AND HARVDATE LT '01JUL02'D THEN FISHERY = 3;  *GILLNET;
           IF OLDFSHRY EQ 'KASILOF' AND FISHERY = . THEN FISHERY = 2;  *DIPNET;
           IF OLDFSHRY EQ 'FISH CREEK'     THEN FISHERY = 4;
           IF OLDFSHRY EQ 'UNKNOWN'        THEN FISHERY = 5;
           IF OLDFSHRY EQ 'DID NOT FISH'   THEN FISHERY = 6;
           IF FISHERY = . THEN FISHERY = 99;
           DROP OLDFSHRY;
     END;

     IF PROJECT = 'SHELLFISH' THEN DO;
           FISHERY = 1;
     END;

     FORMAT FISHERY 2.0;
     KEEP PERMIT HARVDATE &SPECIES_LIST STATUS TOTAL FISHERY COMPLIANT RESPONDED NOTFISH FAMILYSI OFFICE MAILING FISHERY;
RUN;

PROC PRINT DATA=RETURNED (OBS = 45);
     TITLE2 'DATA = RETURNED';
     TITLE3 'OBS = 50'; 
RUN;

PROC PRINT DATA=RETURNED;
     WHERE NOTFISH=1 AND (HARVDATE GT 0 OR TOTAL GT 0);
     TITLE2 'RECORDS IN RETURNED MARKED DID NOT FISH, BUT HAVE EFFORT OR HARVEST';
     TITLE3 'CHECK THESE OUT';
RUN;

PROC PRINT DATA=RETURNED;
     WHERE FISHERY EQ 99;
     TITLE2 'RECORDS IN RETURNED WITH MISSING FISHERY';
RUN;

PROC FREQ;
     TABLES FISHERY;
     TITLE2 'FISHERY FREQUENCY';
     TITLE3;

RUN;


* SOME PERMITS MAY HAVE MORE THAN ONE RECORD FOR THE SAME FISHERY AND DATE.
  WE DON'T WANT TO COUNT THOSE AS TWO DAYS FISHED, SO NEED TO SUM THOSE RECORDS.;

PROC SORT DATA=RETURNED; BY PERMIT FISHERY HARVDATE; 
PROC SUMMARY DATA=RETURNED; BY PERMIT FISHERY HARVDATE;
     VAR &SPECIES_LIST TOTAL;
     ID FAMILYSI NOTFISH OFFICE MAILING STATUS COMPLIANT RESPONDED;
     OUTPUT OUT=RETURNED SUM=;
RUN;



PROC SORT DATA=RETURNED; BY PERMIT FISHERY;
DATA SASDATA.RESPONDED; SET RETURNED (DROP = _TYPE_ _FREQ_ RESPONDED);
RUN;



DATA RETURNED; SET SASDATA.RESPONDED; 

PROC PRINT DATA = RETURNED (OBS = 55);
     TITLE2 'DATA RETURNED';
RUN;

PROC SUMMARY DATA=RETURNED NWAY; BY PERMIT;
     VAR &SPECIES_LIST TOTAL;
     ID FAMILYSI NOTFISH STATUS COMPLIANT MAILING; 
     OUTPUT OUT=TOTALHARV N(HARVDATE)=DAYS SUM=;
RUN;


* DO THIS SUMMARY & PRINT JUST TO CHECK THE SUM OF HARVEST FOR RETURNED PERMITS TO SEE IF
     I'M ON TRACK;
PROC SORT DATA = RETURNED; BY FISHERY;
PROC MEANS SUM NOPRINT DATA = RETURNED; BY FISHERY;
     VAR &SPECIES_LIST TOTAL;
     OUTPUT OUT = CHECK SUM=;
PROC PRINT LABEL;
     LABEL _FREQ_ = 'RECORDS';
     TITLE2 'REPORTED HARVEST BY FISHERY - NOT EXPANDED OR CORRECTED';
RUN;


* NOW GET FILE FISHERYHARVEST WITH ONE LINE PER PERMIT IN EACH FISHERY (SUM ACROSS DATES)
     REMEMBER SOME PERMITS FISHED IN MORE THAN ONE FISHERY, SO STILL HAVE MORE THAN ONE
     LINE PER PERMIT;
PROC SORT DATA = RETURNED; BY PERMIT;
PROC SUMMARY DATA=RETURNED NWAY; BY PERMIT;
     CLASS FISHERY;
     VAR &SPECIES_LIST TOTAL;
     ID FAMILYSI NOTFISH STATUS MAILING COMPLIANT; 
     OUTPUT OUT=FISHERYHARVEST N=DAYS SUM=;
RUN;

DATA FISHERYHARVEST; SET FISHERYHARVEST (DROP = _TYPE_ _FREQ_);
PROC PRINT DATA=FISHERYHARVEST (OBS = 60);
     TITLE2 'FISHERYHARVEST AFTER SUMMARY';
RUN; 

* TRANSPOSE SO SPECIES BECOME ROWS AND FISHERIES ARE COLUMNS;
PROC SORT DATA = FISHERYHARVEST; BY PERMIT FAMILYSI NOTFISH STATUS MAILING COMPLIANT;
PROC TRANSPOSE DATA=FISHERYHARVEST OUT=FISHERYWIDE; BY PERMIT FAMILYSI NOTFISH STATUS MAILING COMPLIANT;
     VAR DAYS &SPECIES_LIST TOTAL;
     ID FISHERY;
RUN;



DATA FISHERYWIDE;  SET FISHERYWIDE;
     RENAME _NAME_=VARIABLE;
     &TOTAL = SUM(OF _1-_&NUMBER_FISHERIES);

PROC SORT DATA=FISHERYWIDE; BY PERMIT VARIABLE;
PROC PRINT DATA = FISHERYWIDE (OBS=65) LABEL;
     LABEL _1 = 'REPORTED' VARIABLE = 'VARIABLE' &TOTAL = 'TOTAL';
     TITLE2 'FISHERYHARVEST AFTER TRANSPOSE';
     TITLE3 'DATA=FISHERYWIDE';
RUN;


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
     WHERE VARIABLE EQ 'TOTAL' AND (NOTFISH NE 1) AND (&TOTAL = . OR &TOTAL = 0);
     TABLES &TOTAL /MISSING OUT=NOHARVEST;
     TITLE2 'NUMBER OF RESPONDING PERMITS THAT FISHED, BUT DID NOT CATCH ANYTHING FROM FILE FISHERYWIDE';
     TITLE3;
RUN;

* COUNT THE NUMBER OF PERMITS THAT DID NOT FISH.     THERE ARE 7 RECORDS FOR 
     EACH PERMIT IN FISHERYWIDE, BUT THE NOTFISH FIELD IS IDENTICAL FOR ALL 7
     RECORDS, SO JUST CHOOSE ONE OF THE VARIABLE LINES TO COUNT FOR EACH PERMIT;
PROC SORT DATA=FISHERYWIDE; BY VARIABLE NOTFISH;
PROC FREQ DATA=FISHERYWIDE; 
     WHERE VARIABLE EQ 'DAYS';
     TABLES NOTFISH*MAILING/MISSING OUT=NOFISHING;
     TITLE2 'NUMBER OF RESPONDING PERMITS THAT DID NOT FISH (NOTFISH=1)FROM FISHERYWIDE';
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
PROC PRINT LABEL;
     LABEL _1 = 'REPORTED HARVEST' BN_ = 'NUMBER RETURNED PERMITS' VARIABLE = 'VARIABLE';
     TITLE2 'TOTAL REPORTED HARVEST';
     TITLE3 'ALL RETURNS';
RUN;



PROC SUMMARY DATA=FISHERYWIDE NWAY;
     WHERE MAILING EQ 0;
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=BH_V N=BN_V SUM=  MEAN=MEAN1-MEAN&MATRIX;
DATA BH_V; SET BH_V (DROP = _TYPE_ _FREQ_);
PROC PRINT LABEL;
     LABEL _1 = 'REPORTED HARVEST' BN_V = 'NUMBER VOLUNTARY PERMITS' VARIABLE = 'VARIABLE' MEAN1 = 'AVERAGE PER PERMIT';
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
PROC PRINT LABEL;
     LABEL _1 = 'REPORTED HARVEST' BN_1 = 'NUMBER MAILING 1 PERMITS' VARIABLE = 'VARIABLE' MEAN1 = 'AVERAGE PER PERMIT';
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
PROC PRINT LABEL;
     LABEL _1 = 'REPORTED HARVEST' BN_2 = 'NUMBER MAILING 2 PERMITS' VARIABLE = 'VARIABLE' MEAN1 = 'AVERAGE PER PERMIT';
     TITLE3 'MAILING 2';
RUN;


* GET THE TOTAL REPORTED COMPLIANT HARVEST FROM EACH FISHERY.
     THIS IS USED IN THE FOLLOWING CALCULATIONS!
     BN_C = THE NUMBER OF COMPLIANT PERMITS;
PROC SUMMARY DATA=FISHERYWIDE NWAY;
     WHERE COMPLIANT EQ 'Y';
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=BH_C N=BN_C SUM= MEAN=MEAN1-MEAN&MATRIX;
DATA BH_C; SET BH_C (DROP = _TYPE_ _FREQ_);
PROC PRINT LABEL;
     LABEL _1 = 'REPORTED HARVEST' BN_C = 'NUMBER COMPLIANT PERMITS' VARIABLE = 'VARIABLE' MEAN1 = 'AVERAGE PER PERMIT';
     TITLE3 'COMPLIANT';
RUN;


DATA BN_C; SET BH_C; WHERE VARIABLE='DAYS'; RUN;

* NOW CALCULATE MEAN NON-COMPLIANT HARVEST (LHB_D), THE NUMBER OF
     NON-COMPLIANT PERMITS (LN_D), AND THE VARIANCE OF THE MEAN (BS1-BS7);
PROC SUMMARY DATA=FISHERYWIDE NWAY;
     WHERE COMPLIANT EQ 'N';
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=LHB_D N=LN_D SUM=  MEAN=MEAN1-MEAN&MATRIX VAR=BS1-BS&MATRIX;
RUN;
DATA LHB_D; SET LHB_D (DROP = _FREQ_);
PROC PRINT LABEL;
     LABEL _1 = 'REPORTED HARVEST' LN_D = 'NUMBER NON-COMPLIANT PERMITS' VARIABLE = 'VARIABLE' 
        MEAN1 = 'AVERAGE PER PERMIT' BS1 = 'VARIANCE';
     TITLE3 'NON COMPLIANT';
RUN;

* USE FILE TOTISS FOR TOTAL NUMBER OF PERMITS ISSUED
     CALCULATE NUMBER OF NON-COMPLIANT PERMITS (BNH_D).     ITS VARIANCE IS THE 
     VARIANCE OF THE ESTIMATE OF THE NUMBER OF PERMITS ISSUED.;
DATA BNH_D; MERGE SASDATA.TOTAL_ISSUED (KEEP=NHAT VAR_NHAT) BN_C(KEEP=BN_C);
     BNH_D = NHAT - BN_C;
     _TYPE_ = 1;
PROC PRINT; 
     TITLE2 'DATA BNH_D'; 
     TITLE3;
RUN;

* CALCULATE NON-COMPLIANT HARVEST, EFFORT, AND THEIR VARIANCES FOR EACH FISHERY;
DATA BHH_D; MERGE LHB_D BNH_D; BY _TYPE_;
     DROP _TYPE_;
PROC PRINT;
     TITLE2 'DATA BHH_D';
RUN; 
     
DATA BHH_D; SET BHH_D;
     ARRAY LHB_D (&MATRIX) MEAN1-MEAN&MATRIX;
     ARRAY BHH_D (&MATRIX) BHH1-BHH&MATRIX;
     ARRAY BS_D (&MATRIX) BS1-BS&MATRIX;
     ARRAY VHB_D (&MATRIX) VHB1-VHB&MATRIX;
     ARRAY VHH (&MATRIX) VHH1-VHH&MATRIX;
     ARRAY SE (&MATRIX) SE1-SE&MATRIX;

     DO I = 1 TO (&MATRIX);
          BHH_D(I) = BNH_D*LHB_D(I);
          VHB_D(I) = (1-LN_D/BNH_D)*BS_D(I)/LN_D;
          VHH(I) = BNH_D**2 * VHB_D(I)     +     LHB_D(I)**2 * VAR_NHAT     -     VHB_D(I) * VAR_NHAT;
          SE(I) = SQRT(VHH(I));
          END;
DATA BHH_D; SET BHH_D (DROP = I);
PROC PRINT;
RUN; 

* CONCATENATE THE COMPLIANT (BH_C) FILE AND THE NON-COMPLIANT (BHH_D) FILE.     RENAME
     THE VARIABLES IN THE COMPLIANT FILE SO THEY MATCH THE NAMES OF THE EQUIVALENT
     NON-COMPLIANT VARIABLES;
DATA BH_X; SET BH_C(IN=C RENAME=(_1=BHH1 _2=BHH2 /* _3=BHH3 _4=BHH4 _5=BHH5 _6=BHH6 _2=BHH7*/)) BHH_D(IN=D);
     IF C THEN COMPLIANT=1;
     ELSE IF D THEN COMPLIANT=0;
     FORMAT _NUMERIC_ 9.0;
RUN;

* SUM THE COMPLIANT AND NONCOMPLIANT HARVESTS AND EFFORTS TO GET TOTAL HARVEST YAHOO!;
PROC SUMMARY DATA=BH_X NWAY;
     CLASS VARIABLE;
     VAR BHH1-BHH&MATRIX SE1-SE&MATRIX;
     OUTPUT OUT=BHH SUM=;
RUN;

DATA BHH; SET BHH (DROP = _TYPE_ _FREQ_);
 
PROC PRINT NOOBS LABEL;
     ID VARIABLE;
   *  VAR BHH1 SE1;
     FORMAT _NUMERIC_ COMMA9.;
     TITLE2 'ESTIMATED HARVEST AND EFFORT';
     LABEL VARIABLE = 'VARIABLE'
           BHH1='KENAI' SE1='KENAI SE'
           BHH2='KASILOF DIPNET' SE2='KASILOF DIPNET SE'
           BHH3='KASILOF GILLNET' SE3='KASILOF GILLNET SE'
           BHH4='FISH CREEK' SE4='FISH CREEK SE'
           BHH5='UNKNOWN' SE5='UNKNOWN SE'
           BHH6='DID NOT FISH' SE6='DID NOT FISH SE'
           BHH7='TOTAL' SE7='TOTAL SE';
 RUN;

ODS RTF CLOSE;
RUN;

/*

* NOW DO A BUNCH OF SUMMARIES OF THE RESPONSES;
* FIRST GET SUMMARIES OF HARVEST BY DATE FOR EACH FISHERY;

PROC SORT DATA=RETURNED; BY HARVDATE;
PROC SUMMARY DATA=RETURNED; BY HARVDATE;
     WHERE FISHERY=1;
     VAR &SPECIES_LIST TOTAL;
     OUTPUT OUT=DATESKENAI SUM=;
     FORMAT HARVDATE DATE7. &SPECIES_LIST TOTAL 7.0;
PROC PRINT DATA=DATESKENAI;
     TITLE 'REPORTED HARVEST BY DATE';
RUN;

*/
