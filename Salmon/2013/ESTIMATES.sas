****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*  This program estimates the harvest by species and fishery                           *;
*  This program is stored as O:\DSF\RTS\pat\permits\salmon\2013\estimates.sas          *;
****************************************************************************************;


%LET PROJECT = SALMON;
%LET PROGRAM = ESTIMATES;
%LET DATA = CISLHV13C;
%LET YEAR = 2013;
%LET SPECIES = SALMON;
%LET SPECIES_COMMA = RED,KING,COHO,PINK,CHUM,FLOUNDER; 
%LET SPECIES_LIST = RED KING COHO PINK CHUM FLOUNDER; 

%LET GILLNET_START = '15JUN13'D; 
%LET GILLNET_STOP = '24JUN13'D; 


%LET NUMBER_FISHERIES = 6;
%LET MATRIX = 7;  
%LET TOTAL = _7;  
RUN;

TITLE1 "&PROJECT - &YEAR";

OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "O:\DSF\RTS\PAT\PERMITS\&PROJECT\&YEAR";
RUN;


TITLE1 "&PROJECT - &YEAR";

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

PROC FREQ DATA = SASDATA.ISSUED;
     TABLES MAILING / NOPRINT OUT = BN;

PROC TRANSPOSE DATA = BN OUT = BN;
      VAR COUNT;

DATA BN; SET BN (RENAME=(COL1 = BN_0 COL2 = BN_1 COL3 = BN_2));
     KEEP BN_0 BN_1 BN_2;
RUN;


PROC SORT DATA=SASDATA.SALMON_HARVEST; BY PERMIT; RUN;  
PROC SORT DATA=SASDATA.ISSUED; BY PERMIT; RUN;

DATA ALLPERMITS; MERGE SASDATA.SALMON_HARVEST (IN=INH) SASDATA.ISSUED (IN=INP); BY PERMIT;  
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
    DROP HARVFILE PERMFILE OFFICE;
RUN;

PROC PRINT DATA = ALLPERMITS (OBS = 50);
     TITLE2 'ALLPERMITS DATASET';
     TITLE3 'FIRST 50 OBSERVATIONS';
RUN;


/*
PROC PRINT DATA=ALLPERMITS (OBS = 40);
     TITLE2 'ALLPERMITS FILE';
     TITLE3 'HARVEST FILE AFTER MERGING WITH PERMITS';
RUN;
*/


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


DATA SASDATA.FISHED_MAILING2; SET FISHED_MAILING2;
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

DATA SASDATA.HARVESTED; SET HARVESTED;
RUN;



DATA HARVESTED; SET SASDATA.HARVESTED; 

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


* GET THE TOTAL REPORTED COMPLIANT HARVEST FROM EACH FISHERY.
     THIS IS USED IN THE FOLLOWING CALCULATIONS!
     BN_C = THE NUMBER OF COMPLIANT PERMITS;
PROC SUMMARY DATA=FISHERYWIDE NWAY;
     WHERE COMPLIANT EQ 'Y';
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=BH_C N=BN_C SUM= MEAN=MEAN1-MEAN&MATRIX;
DATA BH_C; SET BH_C (DROP = _TYPE_ _FREQ_);
     IF VARIABLE = 'TOTAL' THEN DELETE;
PROC PRINT LABEL;
     LABEL _1="REPORTED HARVEST &F1" _2="REPORTED HARVEST &F2" _3="REPORTED HARVEST &F3" 
           _4="REPORTED HARVEST &F4" _5="REPORTED HARVEST &F5" _6="REPORTED HARVEST &F6" _7="REPORTED HARVEST &F7"  
         BN_C = 'NUMBER COMPLIANT PERMITS' VARIABLE = 'VARIABLE' 
        MEAN1="MEAN &F1" MEAN2 = "MEAN &F2" MEAN3 = "MEAN &F3"
        MEAN4="MEAN &F4" MEAN5 = "MEAN &F5" MEAN6 = "MEAN &F6" MEAN7 = "MEAN &F7";
     TITLE3 'COMPLIANT';
RUN;


DATA BN_C; SET BH_C; WHERE VARIABLE='DAYS'; RUN;

* NOW CALCULATE MEAN NON-COMPLIANT HARVEST (LHB_D), THE NUMBER OF
     NON-COMPLIANT PERMITS (LN_D), AND THE VARIANCE OF THE MEAN (BS1-BS6);
PROC SUMMARY DATA=FISHERYWIDE NWAY;
     WHERE COMPLIANT EQ 'N';
     CLASS VARIABLE;
     VAR _1-&TOTAL;
     OUTPUT OUT=LHB_D N=LN_D SUM=  MEAN=MEAN1-MEAN&MATRIX VAR=VAR_MEAN1-VAR_MEAN&MATRIX STDERR = SE1-SE&MATRIX;
RUN;
DATA LHB_D; SET LHB_D (DROP = _FREQ_);
     IF VARIABLE = 'TOTAL' THEN DELETE;
PROC PRINT LABEL;
     LABEL _1="REPORTED HARVEST &F1" _2="REPORTED HARVEST &F2" _3="REPORTED HARVEST &F3" 
           _4="REPORTED HARVEST &F4" _5="REPORTED HARVEST &F5" _6="REPORTED HARVEST &F6" _7="REPORTED HARVEST &F7"  
           LN_D = 'NUMBER NON-COMPLIANT PERMITS' VARIABLE = 'VARIABLE' 
        MEAN1="MEAN &F1" MEAN2 = "MEAN &F2" MEAN3 = "MEAN &F3"
        MEAN4="MEAN &F4" MEAN5 = "MEAN &F5" MEAN6 = "MEAN &F6" MEAN7 = "MEAN &F7"
           VAR_MEAN1="VAR_MEAN &F1" VAR_MEAN2 = "VAR_MEAN &F2" VAR_MEAN3 = "VAR_MEAN &F3"
           VAR_MEAN4="VAR_MEAN &F4" VAR_MEAN5 = "VAR_MEAN &F5" VAR_MEAN6 = "VAR_MEAN &F6" VAR_MEAN7 = "VAR_MEAN &F7"
           SE1="SE &F1" SE2 = "SE &F2" SE3 = "SE &F3"
           SE4="SE &F4" SE5 = "SE &F5" SE6 = "SE &F6" SE7 = "SE &F7";
     TITLE3 'NON COMPLIANT RESPONDED';
RUN;


* USE FILE TOTISS FOR TOTAL NUMBER OF PERMITS ISSUED
     CALCULATE NUMBER OF NON-COMPLIANT PERMITS (BNH_D).
     ITS VARIANCE IS THE VARIANCE OF THE ESTIMATE OF THE NUMBER OF PERMITS ISSUED.;
DATA BNH_D; MERGE SASDATA.TOTAL_ISSUED (KEEP=NHAT VAR_NHAT) BN FISHED_MAILING2;
     BNH_D = NHAT - (BN_0 + BN_1);
     BNH_D_NR = BNH_D - BN_2;
     BNH_D_NR_FISHED = BNH_D_NR * P;
     VAR_BNH_D_NR_FISHED = BNH_D_NR**2 * VAR_P   +   P**2 * VAR_NHAT   -   VAR_NHAT * VAR_P;
     FORMAT BNH_D_NR_FISHED VAR_BNH_D_NR_FISHED 5.0;
     _TYPE_ = 1;

PROC PRINT; 
     TITLE2 'DATA BNH_D'; 
     TITLE3;
RUN;


* CALCULATE NON-COMPLIANT HARVEST, EFFORT, AND THEIR VARIANCES FOR EACH FISHERY;
DATA BHH_D; MERGE LHB_D BNH_D; BY _TYPE_; 
     KEEP VARIABLE MEAN1-MEAN&MATRIX VAR_MEAN1-VAR_MEAN&MATRIX BNH_D_NR_FISHED VAR_BNH_D_NR_FISHED LN_D BNH_D;

/*
PROC PRINT;
     LABEL BNH_D_NR_FISHED = 'NUMBER NON-RESPONDANTS FISHED' VARIABLE = 'VARIABLE' 
           MEAN1="MEAN &F1" MEAN2 = "MEAN &F2" MEAN3 = "MEAN &F3"
           MEAN4="MEAN &F4" MEAN5 = "MEAN &F5" MEAN6 = "MEAN &F6"
       VAR_MEAN1="VAR_MEAN &F1" VAR_MEAN2 = "VAR_MEAN &F2" VAR_MEAN3 = "VAR_MEAN &F3"
       VAR_MEAN4="VAR_MEAN &F4" VAR_MEAN5 = "VAR_MEAN &F5" VAR_MEAN6 = "VAR_MEAN &F6";
     TITLE2 'DATA BHH_D';
RUN; 
*/

DATA BHH_D; SET BHH_D;
     ARRAY LHB_D (&MATRIX) MEAN1-MEAN&MATRIX;
     ARRAY BHH_D (&MATRIX) BHH1-BHH&MATRIX;
     ARRAY BS_D (&MATRIX) VAR_MEAN1-VAR_MEAN&MATRIX;
     ARRAY VHB_D (&MATRIX) VHB1-VHB&MATRIX;
     ARRAY VHH (&MATRIX) VHH1-VHH&MATRIX;
     ARRAY SE (&MATRIX) SE1-SE&MATRIX;


     DO I = 1 TO (&MATRIX);
          BHH_D(I) = BNH_D_NR_FISHED * LHB_D(I);
          VHB_D(I) = (1-LN_D/BNH_D)*BS_D(I)/LN_D;
          VHH(I) = BNH_D_NR_FISHED**2 * VHB_D(I)     +     LHB_D(I)**2 * VAR_BNH_D_NR_FISHED     -     VHB_D(I) * VAR_BNH_D_NR_FISHED;
          SE(I) = SQRT(VHH(I));
          END;
DATA BHH_D; SET BHH_D (DROP = I BNH_D LN_D VAR_BNH_D_NR_FISHED VAR_MEAN1-VAR_MEAN&MATRIX VHB1-VHB&MATRIX);



PROC PRINT LABEL;
      TITLE2 "ESTIMATES FOR NON RESPONDANT, NON-COMPLIANT PERMITS";
      LABEL VARIABLE = 'VARIABLE' 
            BNH_D_NR_FISHED = 'NUMBER OF NON RESPONDANT, NON-COMPLIANT PERMITS'
            MEAN1="MEAN &F1" MEAN2 = "MEAN &F2" MEAN3 = "MEAN &F3"
            MEAN4="MEAN &F4" MEAN5 = "MEAN &F5" MEAN6 = "MEAN &F6"
            BHH1="ESTIMATED &F1 HARVEST"     VHH1="&F1 VAR"     SE1="&F1 SE"
            BHH2="ESTIMATED &F2 HARVEST"     VHH2="&F2 VAR"     SE2="&F2 SE"
            BHH3="ESTIMATED &F3 HARVEST"     VHH3="&F3 VAR"     SE3="&F3 SE"
            BHH4="ESTIMATED &F4 HARVEST"     VHH4="&F4 VAR"     SE4="&F4 SE"
            BHH5="ESTIMATED &F5 HARVEST"     VHH5="&F5 VAR"     SE5="&F5 SE"
            BHH6="ESTIMATED &F6 HARVEST"     VHH6="&F6 VAR"     SE6="&F6 SE"
            BHH7="ESTIMATED &F7 HARVEST"     VHH7="&F7 VAR"     SE7="&F7 SE";


RUN; 



* CONCATENATE THE COMPLIANT FILE (BH_C), THE NON-COMPLIANT-RESPONDED FILE (LHB_D) AND THE NON-COMPLIANT-NON-RESPONDED FILE (BHH_D).
  RENAME THE VARIABLES IN THE COMPLIANT FILE SO THEY MATCH THE NAMES OF THE EQUIVALENT NON-COMPLIANT VARIABLES;

DATA BH_X; SET BH_C(IN=C DROP=BN_C RENAME=(_1=BHH1 _2=BHH2 _3=BHH3 _4=BHH4 _5=BHH5 _6=BHH6 _7=BHH7)) 
                LHB_D(IN=DR DROP= _TYPE_ LN_D VAR_MEAN1-VAR_MEAN&MATRIX SE1-SE&MATRIX RENAME=(_1=BHH1 _2=BHH2 _3=BHH3 _4=BHH4 _5=BHH5 _6=BHH6 _7=BHH7)) 
                BHH_D(IN=DNR DROP=BNH_D_NR_FISHED);
     IF C THEN GROUP = 'COMPLIANT                    ';
     IF DR THEN GROUP = 'NON-COMPLIANT, RESPONDED';
     IF DNR THEN GROUP = 'NON-COMPLIANT, NON-RESPONDANT';
     FORMAT _NUMERIC_ 9.0;
     DROP MEAN1-MEAN&MATRIX; 
RUN;

/*
PROC PRINT;
RUN;
*/


* SUM THE COMPLIANT AND NONCOMPLIANT HARVESTS AND EFFORTS TO GET TOTAL HARVEST YAHOO!;
PROC SUMMARY DATA=BH_X NWAY;
     CLASS VARIABLE;
     VAR BHH1-BHH&MATRIX SE1-SE&MATRIX;
     OUTPUT OUT=BHH SUM=;
RUN;

DATA BHH; SET BHH (DROP = _TYPE_ _FREQ_);
 
PROC PRINT NOOBS LABEL DATA = BHH;
     ID VARIABLE;
     VAR BHH1-BHH&MATRIX SE1-SE&MATRIX;
     FORMAT _NUMERIC_ COMMA9.;
     TITLE2 'ESTIMATED HARVEST AND EFFORT';
             LABEL VARIABLE = 'VARIABLE'
                 BHH1="ESTIMATED &F1 HARVEST"      SE1="&F1 SE"
                 BHH2="ESTIMATED &F2 HARVEST"      SE2="&F2 SE"
                 BHH3="ESTIMATED &F3 HARVEST"      SE3="&F3 SE"
                 BHH4="ESTIMATED &F4 HARVEST"      SE4="&F4 SE"
                 BHH5="ESTIMATED &F5 HARVEST"      SE5="&F5 SE"
                 BHH6="ESTIMATED &F6 HARVEST"      SE6="&F6 SE"
                 BHH7="ESTIMATED &F7 HARVEST"      SE7="&F7 SE";

RUN;


DATA SASDATA.FINAL_ESTIMATES; SET BHH;
RUN;


%LET F1 = KENAI;
%LET F2 = KASILOF DIPNET;
%LET F3 = KASILOF GILLNET;
%LET F4 = FISH CREEK;
%LET F5 = UNK FIXABLE;
%LET F6 = UNKNOWN;
%LET F7 = TOTAL;


DATA BH_OUT; SET BH_;
      RENAME _1 = REPORTED_HARVEST_KENAI
             _2 = REPORTED_HARVEST_KASILOF_DIPNET
             _3 = REPORTED_HARVEST_KASILOF_GILLNET
             _4 = REPORTED_HARVEST_FISH_CREEK
             _5 = REPORTED_HARVEST_UNK_FIXABLE
             _6 = REPORTED_HARVEST_UNKNOWN
             _7 = REPORTED_HARVEST_TOTAL
            BN_ = NUMBER_RETURNED_PERMITS;
RUN;

PROC EXPORT DATA= WORK.BH_OUT
            OUTFILE= "O:\DSF\RTS\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="REPORTED HARVEST"; 
RUN;

DATA BHH_OUT; SET BHH;
      RENAME BHH1 = ESTIMATED_HARVEST_KENAI              SE1 = KENAI_HARVEST_SE
             BHH2 = ESTIMATED_HARVEST_KASILOF_DIPNET     SE2 = KASILOF_DIPNET_HARVEST_SE
             BHH3 = ESTIMATED_HARVEST_KASILOF_GILNET     SE3 = KASILOF_GILLNET_HARVEST_SE
             BHH4 = ESTIMATED_HARVEST_FISH_CREEK         SE4 = FISH_CREEK_HARVEST_SE
             BHH5 = ESTIMATED_HARVEST_UNK_FIXABLE        SE5 = UNK_FIXABLE_HARVEST_SE
             BHH6 = ESTIMATED_HARVEST_UNKNOWN            SE6 = UNKNOWN_HARVEST_SE
             BHH7 = ESTIMATED_HARVEST_TOTAL              SE7 = TOTAL_HARVEST_SE;
RUN;

PROC EXPORT DATA= WORK.BHH_OUT
            OUTFILE= "O:\DSF\RTS\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="EXPANDED HARVEST"; 
RUN;



****************************************************************************************************************************************************;
*  KRISSY WANTED TO ADD AREA AND REGION TO THE MERGED DATASET                                                                                      *;
****************************************************************************************************************************************************;


DATA PERSONAL; SET SASDATA.PERSONAL;
     KEEP PERMIT CITY;
PROC SORT DATA = PERSONAL; BY CITY PERMIT;

DATA CITY; SET SASDATA.CITIES;
PROC SORT DATA = CITY; BY CITY;

DATA LOCATION; MERGE PERSONAL CITY; BY CITY;
     IF NEW_NAME NE ' ' THEN DO;
                               CITY = NEW_NAME;
                             END;

DATA LOCATION; SET LOCATION;
     IF CITY = ' ' THEN REGION = 4;
     IF CITY = ' ' THEN AREA = '1';
     DROP NEW_NAME;


PROC SORT DATA = LOCATION; BY PERMIT;
PROC SORT DATA = ALLPERMITS; BY PERMIT;

DATA ALLPERMITS_CITY; MERGE ALLPERMITS LOCATION; BY PERMIT;
     DROP SPECIES;



PROC EXPORT DATA= WORK.ALLPERMITS_CITY
            OUTFILE= "O:\DSF\RTS\PAT\PERMITS\&PROJECT\&YEAR\PU PERMITS.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="MERGED PERMIT AND HARVEST DATA"; 
RUN;







/*
PROC EXPORT DATA= WORK.RETURNED OUTFILE= "O:\DSF\RTS\PAT\Permits\Salmon\&YEAR\RETURNED_PERMITS.xls" DBMS=EXCEL2000 REPLACE;
RUN;





*   BAG LIMIT ANALYSIS;
DATA BAG; SET RETURNED;
     IF RESPONDED = 'Y';
     FISHERY = OLDFSHRY; 
     IF STATUS = 'DID NOT FISH' THEN DO;
                                RED = 0;
                                KING = 0;
                                COHO = 0;
                                PINK = 0;
                                CHUM = 0;
                                FLOUNDER = 0;
                                END;
     KEEP PERMIT RED KING COHO PINK CHUM FLOUNDER FISHERY familysi allowed STATUS;

PROC MEANS SUM NOPRINT; BY PERMIT ALLOWED;
     VAR RED;
     OUTPUT OUT = BAG2 SUM = RED;

DATA BAG2; SET BAG2;
     IF RED GE ALLOWED THEN LIMIT_FILLED = 'YES';
                            ELSE LIMIT_FILLED = 'NO';
     PERCENT_LIMIT = RED/ALLOWED;
     

PROC MEANS N MEAN STDERR;
     VAR PERCENT_LIMIT;
     TITLE2 'PERCENT OF PERMITS THAT CAUGHT THEIR LIMIT';
RUN;

PROC FREQ;
     TABLES LIMIT_FILLED;
RUN;



PROC PRINT DATA = RETURNED (OBS = 50);
RUN;
*/

