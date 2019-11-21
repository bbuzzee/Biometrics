*Bag limit analysis by fishery; 
*v3 compares the average '% of bag limit filled', rather than by catagories.
*Compare familysize, number of trips and year by fishery (only comparing permits who 
	attended only one fishery);
options pageno=1 linesize=120 pagesize=60;
*Get a file which has the number of trips each permit made;
proc sort data=sasuser.pufile2; by year idnum fishery harvdate; run; 
proc summary data=sasuser.pufile2; 
	by year idnum fishery; where fishery ne 'Did not fish' and nodata ne 1;
	id familysi allowed;
	var total;
	output out=nodate sum(total)= n(year)=trips_0;
	run;
*get one record per permit, n is the number of fisheries the permit participated in;
proc summary data=nodate; by year idnum; 
	output out=nomulti n(year)=fisheries; 
	run;
*Combine files, delete permit holder who made more than one trip and standardize familysize 
	and number of trips;
data limit; merge nodate nomulti; by year idnum; 
	if fisheries gt 1 then delete; 
	format famsize $2. trips $2.; drop _type_ _freq_;
	*remove nonsensical family sizes and combine huge families;
	if familysi=. then delete; if familysi=0 then delete;
	if familysi ge 7 then famsize='7+'; else famsize=familysi;
	*combine trip number tails;
	if trips_0 ge 5 then trips='5+'; else trips=trips_0;
	pctbag=total/allowed;
	drop _type_ _freq_ fisheries trips_0 familysi;
run;


*% of bag limit filled by fishery and year;
proc sort data=limit; by fishery year; run;
proc means data=limit; class fishery year;
	var pctbag; output out=pctyear mean= uclm=uclmpctbag lclm=lclmpctbag;
	run;
title'frequency of permits by familysize and fishery';
proc freq data=limit;
	tables fishery*year/out=yrfreq outpct;
	run;
title'frequency of harvest by familysize and fishery';
proc freq data=limit; weight total;
	tables fishery*year/out=yrharfreq outpct;
	run;


title'% of bag limit filled by fishery and familysize';
proc sort data=limit; by fishery famsize; run;
proc means data=limit; class fishery famsize;
	var pctbag; output out=pctfam mean= uclm=uclmpctbag lclm=lclmpctbag;
	run;
title'frequency of permits by familysize and fishery';
proc freq data=limit;
	tables fishery*famsize/out=famfreq outpct;
	run;
title'frequency of harvest by familysize and fishery';
proc freq data=limit; weight total;
	tables fishery*famsize/out=famharfreq outpct;
	run;


title'% of bag limit filled by number of trips and fishery';
proc sort data=limit; by fishery trips; run;
proc means data=limit; class fishery trips;
	var pctbag; output out=pcttrp mean= uclm=uclmpctbag lclm=lclmpctbag;
	run;
title'frequency of permits by number of trips and fishery';
proc freq data=limit;
	tables fishery*trips/out=tripfreq outpct;
	run;
title'frequency of harvest by number of trips and fishery';
proc freq data=limit; weight total;
	tables fishery*trips/out=tripharfreq outpct;
	run;

