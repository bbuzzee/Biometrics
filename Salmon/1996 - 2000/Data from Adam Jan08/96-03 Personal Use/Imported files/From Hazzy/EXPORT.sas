PROC EXPORT DATA= TMP9.PERMIT98 
            OUTFILE= "O:\DSF\RTS\Pat\Permits\Salmon\1996 - 2000\Data fro
m Adam Jan08\96-03 Personal Use\Imported files\From Hazzy\PU PERMITS 199
8.XLS" 
            DBMS=EXCEL REPLACE;
     SHEET="PERMITS 98"; 
     NEWFILE=YES;
RUN;
