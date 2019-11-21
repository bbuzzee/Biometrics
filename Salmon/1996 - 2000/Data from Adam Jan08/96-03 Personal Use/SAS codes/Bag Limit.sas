*FAMILY SIZES OF PERMIT HOLDERS and DISTRIBUTION OF REPORTED HARVEST;
*Get one record per permit;
proc sort data=sasuser.pufile; by year idnum; run; 
proc summary data=sasuser.pufile; by year idnum; 
	id fishery familysi allowed; *only need fishery='Did not fish';
	var total;
	output out=oneline sum(total)=;
	run;

*DISTRIBUTION OF PERMITS BY FAMILYSIZE;
data familysize; set oneline; 
	*remove nonsensical family sizes and combine huge families;
	if familysi=. then delete; if familysi=0 then delete;
	format familysi2 $10. freq2 $2.; 
	if familysi ge 7 then familysi2='7+'; else familysi2=familysi; familysi2=compress(familysi2);
	*combine trip number tails;
	format freq2 $10.; 
	if _freq_ ge 7 then freq2='7+'; else freq2=_freq_; freq2=compress(freq2);
run;
proc sort data=familysize; by year familysi2; run;
title 'Family size and year';
proc freq data=familysize;
	tables familysi2/ out=familyfreq;
	run;

*DISTRIBUTION OF HARVEST BY FAMILYSIZE;
title 'Distribution of reported harvest by familysize';
proc freq data=familysize; 
	weight total;
	tables familysi2/out=familyhfreq;
	run;
	
*PERCENTAGE OF BAG LIMITS FILLED BY YEAR AND OR FAMILYSIZE;
*percentage of bag limits filled, exceed hypothesized bag limits;
data limit; set familysize; 
	if total eq . then delete;
	if familysi2 eq '1' then climit=15; else climit=30;
	limit255=(familysi-1)*5+25;
	limit1510=(familysi-1)*10+15;
	limit155=(familysi-1)*5+15;
	if fishery='Did not fish' then delete; 
	format limit $20.;
	if total ge 0 and total lt .25*allowed then limit='0.0%-24.9% of bag limit';
		else if total ge .25*allowed and total lt .5*allowed then limit='25.0%-49.9% of bag limit';
		else if total ge .5*allowed and total lt .75*allowed then limit='50.0%-74.9% of bag limit';
		else if total ge .75*allowed and total le allowed then limit='75.0%-100.0% of bag limit';
		else if total gt allowed then limit='Exceeded bag limit';
	if total le limit255 then lt255='Less than 25/5 bag limit'; else lt255='Exceeds 25/5 bag limit';
	if total le limit1510 then lt1510='Less than 15/10 bag limit'; else lt1510='Exceeds 15/10 bag limit';
	if total le limit155 then lt155='Less than 15/5 bag limit'; else lt155='Exceeds 15/5 bag limit';
	if total le climit then ltchitna='Less than chitna bag limit'; else ltchitna='Exceeds chitna bag limit';
	run;

*% of bag limit filled by year;
proc sort data=limit; by year; run;
proc freq data=limit noprint;
	tables limit*year/out=limityear outpct;
	run;
proc transpose data=limityear out=lyeartrans; by limit; var pct_col; id year; run;

*% of bag limit filled by family size;
proc sort data=limit; by familysi2; run;
proc freq data=limit noprint;
	tables limit*familysi2/out=limitfamily outpct;
	run;
proc transpose data=limitfamily out=lfamilytrans; by limit; var pct_col; id familysi2; run;

*% of bag limit filled by number of trips;
proc sort data=limit; by freq2; run;
proc freq data=limit noprint;
	tables limit*freq2/out=limittrips outpct;
	run;
proc transpose data=limittrips out=ltripstrans; by limit; var pct_col; id freq2; run;

*PERCENT OF BAG LIMIT FILLED BY FISHERY AND # OF TRIPS;


*MEAN HARVEST BY FAMILYSIZE;
title 'Mean harvest by familysize';
data limit; set limit2; if total gt allowed then delete; run;
proc sort data=limit2; by familysi2; run;
proc means data=limit mean stderr min max p25 median p75; by familysi2;
	var total;
	output out=familymean 
		mean(total)=ave stderr(total)=se p25(total)=_25 median(total)=_50 p75(total)=_75;
	run;
proc boxplot data=limit2;
	plot total*familysi2 /turnhlabel boxwidthscale=1 cboxes=black bwslegend
		endgrid;
run;

