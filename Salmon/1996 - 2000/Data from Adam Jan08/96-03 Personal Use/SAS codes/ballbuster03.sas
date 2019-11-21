*Get Permit files from past years with adresess;
LIBNAME SASDATA2 'H:\My Documents\Personal Use\Imported files\From Pat Hansen\03 stuff';

* 2003;
data per03; set sasdata2.cislpm03c; 
	year = 2003; idnum=input(permitno, $char6.); idnum=permitno;
	keep year idnum first_name last_name address city state zipcode dateiss;
	rename first_name=firstname last_name=lastname;
run;

*append permit files;
data personal; set per03; 
	if state eq 'AK' then delete; 
	if state eq ' ' then delete;
	*if state eq '99' then delete;
	if year(dateiss) ne year then dateiss=.;
	if month(dateiss)=1 then dateiss=.;
	run;
proc sort data=personal; by year city; run;
proc print data=personal noobs; 
	var year /*idnum*/ firstname lastname address city state zipcode dateiss;
	run;