****************************************************************************************;
*     There are 3 programs to analyze the salmon and shellfish permit databases:       *;
*         1. permits.sas                                                               *;
*         2. harvest.sas                                                               *;
*         3. estimates.sas                                                             *;
*     This program reads and modifies data for permits                                 *;
*     This program is stored as O:\DSF\RTS\pat\permits\salmon\2012\permit.sas           *;
****************************************************************************************;

%LET PROJECT = SALMON;
%LET DATA = cislpm12c;
%LET YEAR = 2012;
%LET PROGRAM = PERMIT;


OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "O:\DSF\RTS\common\Pat\Permits\&PROJECT\&YEAR";
RUN;

TITLE1 "&PROJECT - &YEAR";

**************************************************************************;
*                              PERMIT DATA                               *;
**************************************************************************;

DATA SASDATA.&DATA; SET SASDATA.&DATA;
     CITY = UPCASE(CITY);


PROC PRINT DATA = SASDATA.&DATA (OBS=10);
     TITLE2 'PERMIT DATABASE';
     TITLE3 'FIRST 10 RECORDS';
RUN; 

PROC CONTENTS DATA = SASDATA.&DATA;
     TITLE3 '';
RUN;


DATA ISSUED; SET SASDATA.&DATA;
     RENAME STATUS = S;

DATA ISSUED; SET ISSUED;
     IF S = 'U' THEN STATUS = 'BLANK REPORT    ';
     IF S = 'N' THEN STATUS = 'DID NOT FISH';
     IF S = 'H' THEN STATUS = 'HARVEST REPORTED';
     IF S = 'Z' THEN STATUS = 'NON RESPONDENT';

     IF CITY = 'ANCHORGE' THEN CITY = 'ANCHORAGE';
     IF CITY = 'DENALI NATIONAL PARK' OR CITY = 'DENALI PARKS' THEN CITY = 'DENALI PARK';
     IF CITY = 'EGALE RIVER' THEN CITY = 'EAGLE RIVER';
     IF SUBSTR(CITY,1,6) = 'ELMEND' THEN CITY = 'ELMENDORF AFB';
     IF SUBSTR(CITY,1,6) = 'FORT R' THEN CITY = 'FORT RICHARDSON';

     IF OFFICE = 'NULL' THEN OFFICE = '';
     PERMIT = PERMITNO;
     IF OFFICE = '' THEN VENDORCOPY = 'N';
        ELSE VENDORCOPY = 'Y';
     IF S = 'Z' THEN RESPONDED = 'N'; 
        ELSE RESPONDED = 'Y';
     ALLOWED = ((FAMILYSI - 1) * 10) + 25;
     DROP IMAGEPATH PMRECID ADDRESS ZIPCODE PHONE KEYDATE COMMENTS YEAR DATEISS PERMITNO S KEYID INITIAL LICENSE_NO;
RUN;

PROC SORT; BY PERMIT;
     TITLE2 'SAS WORK ISSUED DATABASE';
     TITLE3 'CHECKS';
RUN;


PROC FREQ;
     TABLES FAMILYSI OFFICE MAILING STATUS DUPPREF VENDORCOPY RESPONDED ALLOWED CITY STATE / NOPERCENT NOROW NOCOL;  *ALLOWED NOT POTS;
PROC FREQ DATA = ISSUED;
     TABLES STATUS * RESPONDED / OUT = SUMMARY_RESPONSE;
PROC FREQ DATA = ISSUED;
     TABLES MAILING / NOPRINT OUT = MAILING;
RUN;

PROC FREQ DATA = ISSUED;
     TABLES MAILING*STATUS /  OUT = CHECK;
RUN;

PROC PRINT DATA = ISSUED;
     WHERE MAILING = 9 AND STATUS = 'HARVEST REPORTED';
     VAR PERMIT mailing STATUS VENDORCOPY RESPONDED;
RUN;

DATA PROBLEM; SET ISSUED;
     IF MAILING = 9 AND STATUS = 'HARVEST REPORTED';
	 PROBLEM = 'Y';
RUN;
PROC PRINT DATA = PROBLEM;
     VAR PERMIT mailing STATUS VENDORCOPY RESPONDED;
RUN;

