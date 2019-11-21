PROC EXPORT DATA= WORK.ISSUED 
            OUTFILE= "H:\common\PAT\Permits\Salmon\2005\PERMITS.xls" 
            DBMS=EXCEL2000 REPLACE;
RUN;
