options ORIENTATION=PORTRAIT;
*Percentage of permit holders who particiapated in more than one fisherey and the fishery 
	combonations particiapated in;

*First calculate the freqency of permit holders who participated in more than one fishery 
	including those instance where one of the fisheries is unknown;
*get one record per harvestday (omit multiple trips to same fishery);
proc sort data=sasuser.pufile2; by year idnum fishery harvdate; run; 
proc summary data=sasuser.pufile2; by year idnum fishery; 
	where fishery ne 'Did not fish' and nodata ne 1;
	id allowed;
	var total;
	output out=nodate sum(total)=;
	run;
*get one record per permit, n is the number of fisheries the permit participated in;
proc summary data=nodate; by year idnum;
	id allowed; 
	var total _freq_; 
	output out=nomulti n(_freq_)=n sum(total)=; 
	run;
*frequency of permit holders who participated in more than one fishery;
title 'Frequency of permits by year and number of fisheries participated in';
proc freq data=nomulti; tables year*n; run;
*frequency of permits and harvest by number of fisheries participated in;
title 'Frequency of permits by number of fisheries participated in';
proc freq data=nomulti; tables n/out=multi_f;; run; 
title 'Frequency of harvest by number of fisheries participated in';
proc freq data=nomulti; weight total; tables n/out=multihar_f;; run;

*% of bag limit filled by number of fisheries participated in;
data limit; set nomulti; pctbag=(total/allowed); run;
proc sort data=limit; by n; run;
title '% of bag limit filled by year'; 
proc summary data=limit; by n;
	var pctbag; output out=multipct mean= stderr=SEpctbag;
	run;


*Now determine fishery combanations chosen while omiting cases where one fishery is unknown; 
*create file with n varible and one record for each fishery by permit, also create naming 
	convention;
data multiple_0; merge nodate nomulti; by year idnum; 
	format num z5.;
		if FISHERY='Kasilof River Gill Net' then num=00001;
		IF FISHERY='Fish Creek Dip Net' then num=00010;
    	IF FISHERY='Kenai River Dip Net' then num=00100;
    	IF FISHERY='Kasilof River Dip Net' then num=01000;
		IF FISHERY='Unknown' then num=10000;
	run;
*create one record per permit with the fisheries participated in as varibles;
proc sort data=multiple_0; by year idnum n num; run;
proc transpose data=multiple_0 out=multipletrans; by year idnum n; var num; run;
*Name the fisheries participated in;
data multiple; set multipletrans;
	if col3=. then col3=0; if col2=. then col2=0;
	if col1=10000 or col2=10000 or col3=10000 or col4=10000 then delete; 
	num=col1+col2+col3;
	format fishery $48.;
		if num eq 00011 then fishery='Fish and Kasilof gill';
		if num eq 00101 then fishery='Kasilof gillnet and Kenai';
		if num eq 00110 then fishery='Fish and Kenai';
		if num eq 01001 then fishery='Kasilof dip and Kasilof gill';
		if num eq 01010 then fishery='Fish and Kasilof dip';
		if num eq 01100 then fishery='Kasilof dip and Kenai';
		if num eq 00111 then fishery='Fish, Kasilof gill, and Kenai';
		if num eq 01011 then fishery='Fish, Kasilof gill, and Kasilof dip';
		if num eq 01101 then fishery='Kasilof gill, Kasilof dip, and Kenai';
		if num eq 01110 then fishery='Fish, Kasilof dip, and Kenai';
		if n lt 2 then delete;
	run;

*Display results;
proc sort data=multiple; by n; run;
title 'Multiple fishery choices';
proc freq data=multiple; by n; where n ge 2;
	tables fishery*year/out=fisheryfreq outpct;
	run;

/*Not sure
proc sort data=fisheryfreq; by fishery; run;
proc transpose data=fisheryfreq out=fisherytrans2; by fishery; var pct_col; id year; run;

