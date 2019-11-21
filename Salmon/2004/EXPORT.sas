PROC EXPORT DATA= WORK.ALL 
            OUTFILE= "H:\common\PAT\Permits\Salmon\Harvest By Permit.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="2004"; 
RUN;
