****************************************************************************************;
*     There were 4 errors found in the SAS database sent by Kirk                       *;
*                                                                                      *;
*     there were 4 occurances of mailing = 4                                           *;
*     these were fixed based on an email from Kirk (3/22/16)                           *;
****************************************************************************************;

%LET PROJECT = SALMON;
%LET DATA = cislpm15c;
%LET YEAR = 2015;
%LET PROGRAM = PERMIT;


OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\&YEAR";
RUN;

TITLE1 "&PROJECT - &YEAR";

**************************************************************************;
*                              PERMIT DATA                               *;
**************************************************************************;

DATA PERMITS; SET SASDATA.&DATA;
     CITY = UPCASE(CITY);


PROC PRINT DATA = PERMITS (OBS=10);
     TITLE2 'PERMIT DATABASE';
     TITLE3 'FIRST 10 RECORDS';
RUN; 

PROC FREQ DATA = PERMITS;
     TABLES MAILING;
RUN;

DATA PERMITS; SET PERMITS;     ************************************************************************************2015 PROBLEM;
     IF MAILING = 4 AND PERMITNO = 14761 THEN MAILING = 1; 
	 IF MAILING = 4 THEN MAILING = 0;

PROC FREQ DATA = PERMITS;
     TABLES MAILING;
RUN;

DATA SASDATA.&DATA; SET PERMITS;
RUN;

