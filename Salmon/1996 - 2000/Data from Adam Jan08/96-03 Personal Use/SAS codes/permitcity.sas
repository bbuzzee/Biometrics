*get pufile ready by fixing misspelled cities, getting one line permit then one line per city;
proc sort data=sasuser.pufile2; by year idnum; run;
data cities; set sasuser.pufile2;
format city2 $20.;
	if city eq 'ANCH0RAGE' then city='ANCHORAGE';
	else if city eq 'ANCHORAE' then city='ANCHORAGE';
	else if city eq 'BEAVERCREEK' then city='BEAVER CREEK';
	else if city eq 'COOPER  CENTER' then city='COPPER CENTER';
	else if city eq 'CHICKALOON CPO' then city='CHICKALOON';
	else if city eq 'DELTA' then city='DELTA JUNCTION';
	else if city eq 'DELTA JCT' then city='DELTA JUNCTION';
	else if city eq 'DENALI PARK' then city='DENALI NATIONAL PARK';
	else if city eq 'EALGE RIVER' then city='EAGLE RIVER';
	else if city eq 'EAGLE RIVERQ' then city='EAGLE RIVER';
	else if city eq 'ELMENDORF' then city='ELMENDORF AFB';
	else if city eq 'ELMENDORF A F B' then city='ELMENDORF AFB';
	else if city eq 'ELMENDORF AFB' then city='ELMENDORF AFB';
	else if city eq 'EAFB' then city='ELMENDORF AFB';
	else if city eq 'FUNNY RIVER' then city='STERLING';
	else if city eq 'FT RICHARDSON' then city='FORT RICHARDSON';
	else if city eq 'FT. RICHARDSON' then city='FORT RICHARDSON';
	else if city eq 'FT WAINWRIGHT' then city='FORT WAINWRIGHT';
	else if city eq 'GLENALLEN' then city='GLENNALLEN';
	else if city eq 'Homer' then city='HOMER';
	else if city eq 'NIKOLAEVSKI' then city='NIKOLAEVSK';
	else if city eq 'NILNILCHIK' then city='NINILCHIK';
	else if city eq 'NINILCHIKA' then city='NINILCHIK';
	else if city eq 'NINLCHIK' then city='NINILCHIK';
	else if city eq 'NORTH KENAI' then city='KENAI';
	else if city eq 'SOLDATNA' then city='SOLDOTNA';
	run;
proc summary data=cities;  by year idnum; id city; output out=oneline0; run;
proc sort data=oneline0; by year city; run;
proc summary data=oneline0; by year city; output out=oneline; run;

*import files with citynames/zones and another with zonenames, merge files;
proc import 
	datafile='H:\My Documents\Personal Use\Imported files\from Tammy Wettin\reszone2002.xls'
	out=zones0; sheet='areas'; format region 2.; run;
proc import 
	datafile='H:\My Documents\Personal Use\Imported files\from Dora\ReimerResZone.xls'
	out=zonenames; format region 2.; run; 
proc sort data=zones0; by region area; run;
proc sort data=zonenames; by region area; run;
data zones; merge zones0 zonenames; by region area; run;

*merge zone file with city file, catagorize unidentified cities, delete missing values,
	get back to one line per cat.;
proc sort data=oneline; by city; run;
proc sort data=zones; by city; run;
data cityzone0; merge zones oneline; by city; 
	if _type_=. then delete; if region=. and city=' ' then delete;
	format city2 $20.; 
		else if region=. and city ne ' ' then city2='Unknown'; 
		else city2=city;
	run;
proc sort data=cityzone0; by year city2; run;
proc summary data=cityzone0; by year city2; id region area areaname; output out=oneline2; run; 

*create city percents and merge back with areas;
proc freq data=cityzone0; by year; weight _freq_; 
	tables city2/ out=citypct noprint; 
	run;
proc sort data=oneline2; by year city2; run; proc sort data=citypct; by year city2; run;
data cityzone; merge oneline2 citypct; by year city2; run;


*transpose file to get years as varibles;
proc sort data=cityzone; by region area areaname city2; run;
proc transpose data=cityzone out=cztrans; by region area areaname city2;
	var percent;
	id year;
	run;

* average number of trips by region;
proc sort data=oneline0; by city; run;
proc sort data=zones; by city; run;
data oneline_2; merge zones oneline0; by city; 
	if _type_=. then delete; if region=. and city=' ' then delete;
	format city2 $20.; 
		else if region=. and city ne ' ' then city2='Unknown'; 
		else city2=city;
	if _freq_ ge 5 then freq2='5+'; else freq2=_freq_;
	run;
proc sort data=oneline_2; by areaname freq2; run;
proc freq data=oneline_2;
	tables areaname*freq2;
	run;
