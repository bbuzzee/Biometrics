PROC EXPORT DATA= WORK.HARVEST 
            OUTFILE= "H:\common\PAT\Permits\Salmon\2002\harvest new.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="harvest new"; 
RUN;
