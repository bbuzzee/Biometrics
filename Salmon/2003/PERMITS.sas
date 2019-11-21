****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program reads and modifies data for permits                                 *;
*     This program is stored as h:\common\pat\permits\salmon\2002\permit.sas           *;
****************************************************************************************;

%LET PROJECT = SALMON;
%LET DATA = CISLPM03C;
%LET YEAR = 2003;
%LET PROGRAM = PERMIT;




OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR";
*ODS RTF FILE = "H:\COMMON\PAT\PERMITS\&PROJECT\&YEAR\&PROGRAM..RTF";
RUN;

TITLE1 "&PROJECT - &YEAR";

**************************************************************************;
*                              PERMIT DATA                               *;
**************************************************************************;

DATA SASDATA.&DATA; SET SASDATA.&DATA;


PROC PRINT DATA = SASDATA.&DATA (OBS=10);
     TITLE2 'PERMIT DATABASE';
     TITLE3 'FIRST 10 RECORDS';
RUN; 

PROC CONTENTS DATA = SASDATA.&DATA;
     TITLE3 '';
RUN;

/*
DATA COMMENTS; SET SASDATA.&DATA;
     WHERE COMMENTS NE '';
   *  KEEP PERMITNO COMMENTS;

PROC EXPORT DATA= WORK.COMMENTS 
            OUTFILE= "H:\common\PAT\Permits\Salmon\2003\PERMIT COMMENTS.xls" 
            DBMS=EXCEL2000 REPLACE;
RUN;
*/

DATA ISSUED; SET SASDATA.&DATA;
     RENAME STATUS = S;

DATA ISSUED; SET ISSUED;
     IF S = 'U' THEN STATUS = 'BLANK REPORT    ';
     IF S = 'N' THEN STATUS = 'DID NOT FISH';
     IF S = 'H' THEN STATUS = 'HARVEST REPORTED';
     IF S = 'Z' THEN STATUS = 'NON RESPONDENT';

     IF OFFICE = 'NULL' THEN OFFICE = '';
     PERMIT = PERMITNO;
     IF OFFICE = '' THEN VENDORCOPY = 'N';
        ELSE VENDORCOPY = 'Y';
     IF S = 'Z' THEN RESPONDED = 'N'; 
        ELSE RESPONDED = 'Y';
     ALLOWED = ((FAMILYSI - 1) * 10) + 25;
     DROP PMRECID ADDRESS ZIPCODE PHONE KEYDATE COMMENTS YEAR DATEISS PERMITNO S;
RUN;

PROC SORT; BY PERMIT;
     TITLE2 'SAS WORK ISSUED DATABASE';
     TITLE3 'CHECKS';
RUN;

PROC FREQ;
     TABLES FAMILYSI OFFICE MAILING STATUS DUPPREF VENDORCOPY RESPONDED ALLOWED CITY / NOPERCENT NOROW NOCOL;  *ALLOWED NOT POTS;
PROC FREQ;
     TABLES STATUS * RESPONDED;
RUN;


PROC PRINT;
     WHERE ALLOWED LT 25 OR ALLOWED = .;
     VAR PERMIT FAMILYSI ALLOWED HHMEMBERS OFFICE MAILING STATUS;
     TITLE2 'ALLOWED PROBLEMS';
     TITLE3 'SAS WORK ISSUED DATABASE';
RUN;


PROC PRINT;
     WHERE FAMILYSI GT 15;
     VAR PERMIT FAMILYSI OFFICE FIRST_NAME LAST_NAME CITY MAILING STATUS;
     TITLE2 'HUGE FAMILIES';
     TITLE3 'SAS WORK ISSUED DATABASE';
RUN;

PROC PRINT;
     WHERE OFFICE = '';
     VAR PERMIT OFFICE FIRST_NAME LAST_NAME CITY MAILING STATUS;
     TITLE2 'NO VENDOR COPY';
     TITLE3 'SAS WORK ISSUED DATABASE';
RUN;


PROC FREQ;
     TABLES PERMIT / NOPRINT OUT = CHECK;

PROC PRINT DATA = CHECK;
     WHERE COUNT GT 1;
     TITLE2 'MULTIPLE PERMIT RECORDS';
     TITLE3 'SAS WORK ISSUED DATABASE';
RUN;



DATA PERSONAL; SET ISSUED;
     KEEP PERMIT ADLNO CITY STATE FIRST_NAME LAST_NAME;

DATA ISSUED; SET ISSUED;
     DROP DUPPREF ADLNO CITY STATE FIRST_NAME LAST_NAME HHMEMBERS;
PROC PRINT DATA = ISSUED (OBS = 10);
     TITLE2 'PERMANENT SAS ISSUED DATABASE';
     TITLE3 'FIRST 10 RECORDS';
RUN;


DATA SASDATA.ISSUED; SET ISSUED;
DATA SASDATA.PERSONAL; SET PERSONAL;

RUN;

DATA ISSUED; SET SASDATA.ISSUED;
     
PROC MEANS SUM DATA=ISSUED NOPRINT;
     CLASS VENDORCOPY RESPONDED MAILING;
     VAR PERMIT;
     OUTPUT OUT = SUMMARY;
RUN;

PROC SORT; BY VENDORCOPY RESPONDED MAILING _TYPE_ _FREQ_;
DATA SUMMARY; SET SUMMARY; BY VENDORCOPY RESPONDED MAILING _TYPE_ _FREQ_;
     IF FIRST._FREQ_;
     DROP PERMIT _STAT_ _TYPE_;

PROC SORT; BY MAILING RESPONDED VENDORCOPY;   
PROC PRINT DATA = SUMMARY;
     TITLE2 'SUMMARY OF DATA';
     TITLE3 'USED IN ESTIMATING THE NUMBER OF PERMITS ISSUED';
RUN;


DATA TABLE; SET SUMMARY;
     IF VENDORCOPY = 'Y' AND RESPONDED = ' ' AND MAILING = . THEN VYRB = _FREQ_;
     IF VENDORCOPY = 'N' AND RESPONDED = 'Y' AND MAILING = . THEN VNRY = _FREQ_;
     IF VENDORCOPY = 'Y' AND RESPONDED = 'N' AND MAILING = . THEN VYRN = _FREQ_;
     IF VENDORCOPY = 'Y' AND RESPONDED = 'Y' AND MAILING = 0 THEN NUMERATOR = _FREQ_;
     IF VENDORCOPY = 'Y' AND RESPONDED = ' ' AND MAILING = . THEN DENOMINATOR = _FREQ_;
     IF VYRB = . AND VNRY = . AND VYRN = . AND NUMERATOR = . AND DENOMINATOR = . THEN DELETE;
     KEEP VYRB VNRY VYRN NUMERATOR DENOMINATOR;


PROC MEANS SUM NOPRINT;
     VAR VYRB VNRY VYRN NUMERATOR DENOMINATOR;
     OUTPUT OUT = TABLE SUM=; 

DATA TABLE; SET TABLE (DROP = _TYPE_ _FREQ_);
     RESP_RATE = NUMERATOR/DENOMINATOR;
     VYRY = VYRB - VYRN;
     VNRN = ROUND((VNRY / RESP_RATE),1);
     VNRB = ROUND((VNRY + VNRN),1);
     VBRY = VYRY + VNRY;
     VBRN = VYRN + VNRN;

     VBRB = VYRY + VNRY + VYRN + VNRN;
     VBRB1 = VBRY + VBRN;
     VBRB2 = VYRB + VNRB;

     VAR_RESP_RATE = (RESP_RATE * (1-RESP_RATE))/(VYRB-1);
     VAR_VNRB = VNRY**2 * (1/(RESP_RATE**4))*VAR_RESP_RATE;
     VAR_VBRB = VAR_VNRB;

     DROP NUMERATOR DENOMINATOR;
PROC PRINT;
     TITLE2 'ESTIMATES OF THE NUMBER OF PERMITS ISSUED';
     TITLE3;
RUN;



DATA TOTAL_ISSUED; SET TABLE (KEEP = VBRB  VAR_VBRB);
     RENAME VBRB = NHAT VAR_VBRB = VAR_NHAT;
PROC PRINT;
RUN;

DATA SASDATA.TOTAL_ISSUED; SET TOTAL_ISSUED;
RUN;
proc print;
*ODS RTF CLOSE;
RUN;
