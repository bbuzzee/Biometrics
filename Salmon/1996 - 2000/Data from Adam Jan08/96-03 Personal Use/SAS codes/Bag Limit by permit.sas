*Bag limit analysis by permit;

*first compare familysize, number of trips and year by permit number (true comparison since 
	one permit is good for all four fisheries);
*Get one record per permit, n is number of trips (sometimes to more than one fishery);
proc sort data=sasuser.pufile2; by year idnum; run; 
proc summary data=sasuser.pufile2; 
by year idnum; where nodata ne 1 and fishery ne 'Did not fish'; 
	id familysi allowed;
	var total;
	output out=oneline sum(total)=;
	run;

*Standardize familysize and number of trips;
data familysize; set oneline; 
	format familysi2 $2. freq2 $2.; 
	*remove nonsensical family sizes and combine huge families;
	if familysi=. then delete; if familysi=0 then delete;
	if familysi ge 7 then familysi2='7+'; else familysi2=familysi;
	*combine trip number tails;
	if _freq_ ge 5 then freq2='5+'; else freq2=_freq_;
run;
	
*percentage of bag limits filled, exceed hypothesized bag limits;
data limit; set familysize; 
	format limit $25.;
	if total ge 0 and total lt .25*allowed then limit='0.0%-24.9% of bag limit';
		else if total ge .25*allowed and total lt .5*allowed then limit='25.0%-49.9% of bag limit';
		else if total ge .5*allowed and total lt .75*allowed then limit='50.0%-74.9% of bag limit';
		else if total ge .75*allowed and total le allowed then limit='75.0%-100.0% of bag limit';
		else if total gt allowed then limit='Exceeded bag limit';
	*give chitna bag limit and other hypothesized bag limits and % above/below; 
	if familysi2 eq '1' then climit=15; else climit=30;
		if total le climit then ltchitna='Less than chitna bag limit'; 
		else ltchitna='Exceeds chitna bag limit';
	limit255=(familysi-1)*5+25;
		if total le limit255 then lt255='Less than 25/5 bag limit'; 
		else lt255='Exceeds 25/5 bag limit';
	limit1510=(familysi-1)*10+15;
		if total le limit1510 then lt1510='Less than 15/10 bag limit'; 
		else lt1510='Exceeds 15/10 bag limit';
	limit155=(familysi-1)*5+15;
		if total le limit155 then lt155='Less than 15/5 bag limit';
		else lt155='Exceeds 15/5 bag limit';
	run;

*give results;
*% of bag limit filled by year;
proc sort data=limit; by year; run;
title '% of bag limit filled by year'; 
proc freq data=limit;
	tables limit*year/out=limityear outpct chisq expected;
	run;
proc transpose data=limityear out=lyeartrans; by limit; var pct_col; id year; run;

*% of bag limit filled by family size;
proc sort data=limit; by year familysi2; run;
title '% of bag limit filled by familysize'; 
proc freq data=limit; by year; 
	tables limit*familysi2/out=famlim_f outpct chisq expected; 
	run;
proc transpose data=famlim_f out=famlim_ft; by year limit; var pct_col; id familysi2; run;
*frequency of permits by familysize;
title '% of permits by familysize'; 
proc freq data=limit; tables familysi2/out=family_f; run;
*frequency of harvest by familysize;
title '% of harvest by familysize'; 
proc freq data=limit; weight total; tables familysi2/out=famhar_f; run;


*% of bag limit filled by number of trips;
proc sort data=limit; by freq2; run;
title '% of bag limit filled by number of trips and fishery';
proc freq data=limit; tables limit*freq2/out=triplim_f outpct chisq expected; run;
proc transpose data=triplim_f out=triplim_ft; by limit; var pct_col; id freq2; run;
*frequency permits by number of trips;
title '% of permits by number of trips';
proc freq data=limit; tables freq2/out=trip_f; run;
*frequency of harvest by number of trips;
title '% of harvest by number of trips';
proc freq data=limit; weight total; tables freq2/out=triphar_f; run;


*% of permit holders who would exceeded the chitna bag limit;
proc sort data=limit; by year; run;
title '% of permits who would exceed the chitna bag limit';
proc freq data=limit; tables ltchitna*year/outpct chisq expected; run;



*test not catagorizing % of bag limit;
data test; set familysize; pct2=total/allowed; pct=round(pct2,.05); if pct2 gt 1 then delete; run;
proc sort data=test; by familysi2; run;
proc freq data=test; by year; tables pct/out=pct_fyr; run;
proc sort data=test; by familysi2; run;
proc freq data=test; by familysi2; tables pct/out=pct_ffam; run;
proc sort data=test; by freq2; run;
proc freq data=test; by freq2; tables pct/out=pct_ftrp; run;
symbol1 i=join;
proc gplot data=pct_fyr; plot percent*pct=year; run; quit;
proc gplot data=pct_ffam; plot percent*pct=familysi2; run; quit;
proc gplot data=pct_ftrp; plot percent*pct=freq2; run; quit;

proc sort data=test; by year; run;
proc means data=test; by year; var pct; run;
proc sort data=test; by familysi2; run;
proc means data=test; by familysi2; var pct; run;
proc sort data=test; by freq2; run;
proc means data=test; by freq2; var pct; run;