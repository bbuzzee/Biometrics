%LET PROJECT = SALMON;
%LET DATA = CISLPM05C;
%LET YEAR = 2005;
%LET PROGRAM = CORRECTED ESTIMATES;

%LET F1 = KENAI;
%LET F2 = KASILOF DIPNET;
%LET F3 = KASILOF GILLNET;
%LET F4 = FISH CREEK;
%LET F5 = UNK FIXABLE;
%LET F6 = UNKNOWN;
%LET F7 = TOTAL;

%LET NUMBER_FISHERIES = 6;
%LET MATRIX = 7;   *NUMBER OF FISHERIES + 1;
%LET TOTAL = _7;   *NUMBER OF FISHERIES + 1;

OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR";
*ODS RTF FILE = "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\&PROGRAM..RTF";
RUN;

TITLE1 "&PROJECT - &YEAR";
TITLE2 "CORRECTED ESTIMATES";

DATA UNCORRECTED; SET SASDATA.FINAL_ESTIMATES;
     MERGEVAR = 1;

DATA CF; SET SASDATA.CF_UNKNOWNS;
     MERGEVAR = 1;

DATA CORRECTED; MERGE UNCORRECTED CF; BY MERGEVAR;
     IF VARIABLE = 'TOTAL' THEN DELETE;
     DROP MERGEVAR BHH7 SE7;

PROC PRINT;
PROC CONTENTS;
RUN;

DATA CORRECTED; SET CORRECTED;
      IF VARIABLE = 'DAYS' THEN DO;  
                                NBHH1 = BHH1 + (BHH5 *  P_KENAI_DAYS);
                                NBHH2 = BHH2 + (BHH5 *  P_KASILOF_DAYS);
                                NBHH5 = BHH5 - ((BHH5 *  P_KENAI_DAYS) + (BHH5 *  P_KASILOF_DAYS));
                                NSE1 = SQRT(SE1**2 + V_P_DAYS);
                                NSE2 = SQRT(SE2**2 + V_P_DAYS);
                                END;

      IF VARIABLE = 'chum' THEN DO;  
                                NBHH1 = BHH1 + (BHH5 *  P_KENAI_CHUMS);
                                NBHH2 = BHH2 + (BHH5 *  P_KASILOF_CHUMS);
                                NBHH5 = BHH5 - ((BHH5 *  P_KENAI_CHUMS) + (BHH5 *  P_KASILOF_CHUMS));
                                NSE1 = SQRT(SE1**2 + V_P_CHUMS);
                                NSE2 = SQRT(SE2**2 + V_P_CHUMS);
                                END;

     IF VARIABLE = 'coho' THEN DO;  
                                NBHH1 = BHH1 + (BHH5 *  P_KENAI_COHOS);
                                NBHH2 = BHH2 + (BHH5 *  P_KASILOF_COHOS);
                                NBHH5 = BHH5 - ((BHH5 *  P_KENAI_COHOS) + (BHH5 *  P_KASILOF_COHOS));
                                NSE1 = SQRT(SE1**2 + V_P_COHOS);
                                NSE2 = SQRT(SE2**2 + V_P_COHOS);
                                END;

      IF VARIABLE = 'king' THEN DO;  
                                NBHH1 = BHH1 + (BHH5 *  P_KENAI_KINGS);
                                NBHH2 = BHH2 + (BHH5 *  P_KASILOF_KINGS);
                                NBHH5 = BHH5 - ((BHH5 *  P_KENAI_KINGS) + (BHH5 *  P_KASILOF_KINGS));
                                NSE1 = SQRT(SE1**2 + V_P_KINGS);
                                NSE2 = SQRT(SE2**2 + V_P_KINGS);
                                END;

      IF VARIABLE = 'pink' THEN DO;  
                                NBHH1 = BHH1 + (BHH5 *  P_KENAI_PINKS);
                                NBHH2 = BHH2 + (BHH5 *  P_KASILOF_PINKS);
                                NBHH5 = BHH5 - ((BHH5 *  P_KENAI_PINKS) + (BHH5 *  P_KASILOF_PINKS));
                                NSE1 = SQRT(SE1**2 + V_P_PINKS);
                                NSE2 = SQRT(SE2**2 + V_P_PINKS);
                                END;

      IF VARIABLE = 'red' THEN DO;  
                                NBHH1 = BHH1 + (BHH5 *  P_KENAI_REDS);
                                NBHH2 = BHH2 + (BHH5 *  P_KASILOF_REDS);
                                NBHH5 = BHH5 - ((BHH5 *  P_KENAI_REDS) + (BHH5 *  P_KASILOF_REDS));
                                NSE1 = SQRT(SE1**2 + V_P_REDS);
                                NSE2 = SQRT(SE2**2 + V_P_REDS);
                                END;



      IF VARIABLE = 'flounder' THEN DO;  
                                NBHH1 = BHH1 + (BHH5 *  P_KENAI_FLOUNDER);
                                NBHH2 = BHH2 + (BHH5 *  P_KASILOF_FLOUNDER);
                                NBHH5 = BHH5 - ((BHH5 *  P_KENAI_FLOUNDER) + (BHH5 *  P_KASILOF_FLOUNDER));
                                NSE1 = SQRT(SE1**2 + V_P_FLOUNDER);
                                NSE2 = SQRT(SE2**2 + V_P_FLOUNDER);
                                END;


     KEEP VARIABLE NBHH1 NBHH2 NBHH5 NSE1 NSE2 BHH3 BHH4 BHH6 SE3-SE6;

DATA CORRECTED; SET CORRECTED;
      RENAME NBHH1=BHH1 NBHH2=BHH2 NBHH5=BHH5 NSE1=SE1 NSE2=SE2;

DATA CORRECTED2; SET CORRECTED;
      VAR1 = SE1**2;
      VAR2 = SE2**2;
      VAR3 = SE3**2;
      VAR4 = SE4**2;
      VAR5 = SE5**2;
      VAR6 = SE6**2;


PROC MEANS SUM NOPRINT;
      VAR BHH1-BHH6 VAR1-VAR6;
      OUTPUT OUT = SUM SUM = BHH1-BHH6 VAR1-VAR6;

DATA SUM; SET SUM (DROP = _TYPE_ _FREQ_);
     SE1 = SQRT(VAR1);
     SE2 = SQRT(VAR2);
     SE3 = SQRT(VAR3);
     SE4 = SQRT(VAR4);
     SE5 = SQRT(VAR5);
     SE6 = SQRT(VAR6);
     VARIABLE = 'TOTAL';
     DROP VAR1-VAR6;

DATA CORRECTED; SET CORRECTED SUM;
     BHH7 = BHH1 + BHH2 + BHH3 + BHH4 + BHH5 + BHH6;
     SE7 = SQRT(SE1**2 + SE2**2 + SE3**2 + SE4**2 + SE5**2 + SE6**2);
	BHH5 = SQRT(BHH5**2);
	SE5 = 0;



PROC PRINT NOOBS LABEL DATA = CORRECTED;
     ID VARIABLE;
     VAR BHH1-BHH&MATRIX SE1-SE&MATRIX;
     FORMAT _NUMERIC_ COMMA9.;
     TITLE2 'ESTIMATED HARVEST AND EFFORT';
     TITLE3 'CORRECTED FOR UNKNOWNS';

             LABEL VARIABLE = 'VARIABLE'
                 BHH1="ESTIMATED &F1 HARVEST"      SE1="&F1 SE"
                 BHH2="ESTIMATED &F2 HARVEST"      SE2="&F2 SE"
                 BHH3="ESTIMATED &F3 HARVEST"      SE3="&F3 SE"
                 BHH4="ESTIMATED &F4 HARVEST"      SE4="&F4 SE"
                 BHH5="ESTIMATED &F5 HARVEST"      SE5="&F5 SE"
                 BHH6="ESTIMATED &F6 HARVEST"      SE6="&F6 SE" 
                 BHH7="ESTIMATED &F7 HARVEST"      SE7="&F7 SE"; 

RUN;

DATA SASDATA.CORRECTED_FINAL_ESTIMATES; SET CORRECTED;

RUN;


