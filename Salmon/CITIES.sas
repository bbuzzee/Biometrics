
OPTIONS PAGENO=1;
OPTIONS NODATE;
OPTIONS SYMBOLGEN;
LIBNAME SASDATA BASE "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT";
RUN;


PROC IMPORT OUT= WORK.CITIES2007 DATAFILE= "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\CITIES 2007 - 2012_KD.xls" DBMS=EXCEL REPLACE;
     RANGE="'2007$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.CITIES2008 DATAFILE= "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\CITIES 2007 - 2012_KD.xls" DBMS=EXCEL REPLACE;
     RANGE="'2008$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.CITIES2009 DATAFILE= "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\CITIES 2007 - 2012_KD.xls" DBMS=EXCEL REPLACE;
     RANGE="'2009$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.CITIES2012 DATAFILE= "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\CITIES 2007 - 2012_KD.xls" DBMS=EXCEL REPLACE;
     RANGE="'2012$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.CITIES2015 DATAFILE= "O:\DSF\RTS\common\PAT\PERMITS\&PROJECT\CITIES 2007 - 2012_KD.xls" DBMS=EXCEL REPLACE;
     RANGE="'2015$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


DATA CITIES2007; SET CITIES2007;
     CITY2007 = CITY;
     REGION2007 = REGION;
     AREA2007 = AREA;
     NEW_NAME2007 = NEW_NAME;
PROC SORT; BY CITY;

DATA CITIES2008; SET CITIES2008;
     CITY2008 = CITY;
     REGION2008 = REGION;
     AREA2008 = AREA;
     NEW_NAME2008 = NEW_NAME;
PROC SORT; BY CITY;

DATA CITIES2009; SET CITIES2009;
     CITY2009 = CITY;
     REGION2009 = REGION;
     AREA2009 = AREA;
     NEW_NAME2009 = NEW_NAME;
PROC SORT; BY CITY;

DATA CITIES2012; SET CITIES2012;
     CITY2012 = CITY;
     REGION2012 = REGION;
     AREA2012 = AREA;
     NEW_NAME2012 = NEW_NAME;
PROC SORT; BY CITY;

DATA CITIES2015; SET CITIES2015;
     CITY2015 = CITY;
     REGION2015 = REGION;
     AREA2015 = AREA;
     NEW_NAME2015 = NEW_NAME;
PROC SORT; BY CITY;


DATA CITIES; MERGE CITIES2007 CITIES2008 CITIES2009 CITIES2012 CITIES2015; BY CITY;
     IF CITY = 'XXXXXXXXXXXXXXXXXXX' THEN DELETE;
     IF AREA = '' THEN AREA = '1';
     IF REGION2007 NE . AND REGION2008 NE . AND REGION2007 NE REGION2008 THEN PROBLEM = 'YES';
     IF REGION2007 NE . AND REGION2009 NE . AND REGION2007 NE REGION2009 THEN PROBLEM = 'YES';
     IF REGION2008 NE . AND REGION2009 NE . AND REGION2008 NE REGION2009 THEN PROBLEM = 'YES';

     IF AREA2007 NE ' ' AND AREA2008 NE ' ' AND AREA2007 NE AREA2008 THEN PROBLEM = 'YES';
     IF AREA2007 NE ' ' AND AREA2009 NE ' ' AND AREA2007 NE AREA2009 THEN PROBLEM = 'YES';
     IF AREA2008 NE ' ' AND AREA2009 NE ' ' AND AREA2008 NE AREA2009 THEN PROBLEM = 'YES';

PROC PRINT DATA = CITIES;
     WHERE PROBLEM = 'YES';
RUN;

PROC PRINT DATA = CITIES;
RUN;   

PROC FREQ;
     TABLES CITY * REGION * AREA * NEW_NAME / NOPRINT OUT = CITIES2;

PROC PRINT DATA = CITIES2;
RUN;

DATA CITIES2; SET CITIES2;
     KEEP CITY REGION AREA NEW_NAME;

PROC EXPORT DATA= WORK.CITIES2
            OUTFILE= "O:\DSF\RTS\PAT\PERMITS\Salmon\CITIES.XLS" 
            DBMS=EXCEL2000 REPLACE;
            SHEET="CITIES"; 
RUN;

DATA SASDATA.CITIES; SET CITIES2;
RUN;
