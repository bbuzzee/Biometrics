*Import legal fishing seasons and delete records with nonsensical harvest dates;
proc import 
	datafile='H:\My Documents\Personal Use\Legal PU seasons.XLS'
	out=season0 replace; run;
data season; set season0; 
	first=mdy(firstmon,firstday,year); last=mdy(lastmon,lastday,year);
	format first last date7.;
	drop firstmon firstday lastmon lastday;
	firstmd=month(first)*100+day(first); lastmd=month(last)*100+day(last);
run; 
proc sort data=sasuser.Pufile2; by fishery year; run;
proc sort data=season; by fishery year; run;
data legalfish; merge sasuser.Pufile2 season; by fishery year;
	if harvdate eq . then delete;
	if harvdate lt first or harvdate gt last then delete;
	monthday=month(harvdate)*100+day(harvdate);
run;

*Sum to get harvest by date, fishery and year;
proc sort data=legalfish; by fishery year harvdate; run; 
proc summary data=legalfish; by fishery year harvdate; 
	var monthday sockeye chinook coho pink chum;
	output out=dailycatch mean(monthday)= sum(sockeye chinook coho pink chum)=;
run;

*Create a dummy dataset to fill in days when no harvest for X species in Y fishery occured;
proc sort data=season; by fishery; run;
proc summary data=season; by fishery; 
	var firstmd lastmd; output out=seasonrange min(firstmd)= max(lastmd)=; 
	run;
data seasonfill0; merge seasonrange; by fishery;
	do monthday=firstmd to 810 by 1 until (monthday=lastmd); output; end;
	drop firstmd lastmd;
run;
data seasonfill; set seasonfill0; 
	if monthday gt 731 and monthday lt 801 then delete;
	if monthday gt 630 and monthday lt 701 then delete;
	run; 

*Create datasets for each species and fishery combo which include percent of total yearly
	harvest by day;
	*Sockeye;
proc freq data=dailycatch; by fishery year;
weight sockeye;
tables monthday/ noprint outcum out=sockout;
run;
proc sort data=sockout; by fishery monthday year;
proc transpose data=sockout out=socktrans; by fishery monthday;
  var percent;
  id year;
  run;
data pusock; merge socktrans seasonfill; by fishery monthday; run;
PROC EXPORT DATA= WORK.pusock OUTFILE= "C:\Documents and Settings\amreimer\My Documents\My SAS Files\pusock.xls" 
	DBMS=EXCEL2000 REPLACE;
RUN;

	*Chinook;
proc freq data=dailycatch; by fishery year;
weight chinook;
tables monthday/ noprint outcum out=chinout;
run;
proc sort data=chinout; by fishery monthday year;
proc transpose data=chinout out=chintrans; by fishery monthday;
  var percent;
  id year;
  run;
data puchin; merge chintrans seasonfill; by fishery monthday; run;
PROC EXPORT DATA= WORK.puchin OUTFILE= "C:\Documents and Settings\amreimer\My Documents\My SAS Files\puchin.xls" 
	DBMS=EXCEL2000 REPLACE;
RUN;

	*Coho;
proc freq data=dailycatch; by fishery year; 
weight coho;
tables monthday/ noprint outcum out=cohoout;
run;
proc sort data=cohoout; by fishery monthday year;
proc transpose data=cohoout out=cohotrans; by fishery monthday;
  var percent;
  id year;
  run;
data pucoho; merge cohotrans seasonfill; by fishery monthday; run;
PROC EXPORT DATA= WORK.pucoho OUTFILE= "C:\Documents and Settings\amreimer\My Documents\My SAS Files\pucoho.xls" 
	DBMS=EXCEL2000 REPLACE;
RUN;

	*Chum;
proc freq data=dailycatch; by fishery year; 
weight chum;
tables monthday/ noprint outcum out=chumout;
run;
proc sort data=chumout; by fishery monthday year;
proc transpose data=chumout out=chumtrans; by fishery monthday;
  var percent;
  id year;
  run;
data puchum; merge chumtrans seasonfill; by fishery monthday; run;
PROC EXPORT DATA= WORK.puchum OUTFILE= "C:\Documents and Settings\amreimer\My Documents\My SAS Files\puchum.xls" 
	DBMS=EXCEL2000 REPLACE;
RUN;

	*Pink;
proc freq data=dailycatch; by fishery year;
weight pink; 
tables monthday/ noprint outcum out=pinkout;
run;
proc sort data=pinkout; by fishery monthday year;
proc transpose data=pinkout out=pinktrans; by fishery monthday;
  var percent;
  id year;
  run;
data pupink; merge pinktrans seasonfill; by fishery monthday; run;
PROC EXPORT DATA= WORK.pupink OUTFILE= "C:\Documents and Settings\amreimer\My Documents\My SAS Files\pupink.xls" 
	DBMS=EXCEL2000 REPLACE;
RUN;

