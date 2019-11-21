*get pufile ready by fixing misspelled cities, get one line permit then one line per city with
	fishery as an ID varible;
proc sort data=pu.pufile; by year idnum fishery harvdate; run;
data cities; set pu.pufile;
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
*Get a file which has the number of trips each permit made to each fishery;
proc summary data=cities; 
	by year idnum fishery; where fishery ne 'Did not fish' and nodata ne 1;
	id city;
	output out=nodate n(year)=trips_0;
	run;
*get one record per permit, fisheries is the number of fisheries the permit participated in;
proc summary data=nodate; by year idnum; 
	output out=nomulti n(year)=fisheries; 
	run;
*Combine files, delete permit holders who made more than one trip and standardize familysize 
	and number of trips;
data oneline0; length city $25; format city $25.; merge nodate nomulti; by year idnum; 
	if fisheries gt 1 then delete; if city eq ' ' then delete; 
	drop _type_ _freq_ fisheries trips_0;
run;


*import files with citynames/zones and another with zonenames, merge files;
proc import 
	datafile='H:\My Documents\Personal Use\Imported files\from Tammy Wettin\reszone2002.xls'
	out=zones0; sheet='areas'; run;
proc import 
	datafile='H:\My Documents\Personal Use\Imported files\from Dora\ReimerResZone.xls'
	out=zonenames; format region 2.; run; 
proc sort data=zones0; by region area; run;
proc sort data=zonenames; by region area; run;
data zones;  merge zones0 zonenames; by region area; run;

*merge zone file with city file, delete missing values;
proc sort data=oneline0; by city; run; proc sort data=zones; by city; run;
data cityzone0; merge zones oneline0; by city;
	if year eq . and idnum eq ' ' and fishery eq ' ' then delete;
	if region eq . and area eq ' ' then delete;
	run;

*create city percents and merge back with areas;
*create city percents;
proc sort data=cityzone0; by year fishery; run;
proc freq data=cityzone0; by year fishery;
	tables city/ out=citypct noprint; 
	run;
*create file with region/area names;
proc sort data=cityzone0; by year fishery city; run;
proc summary data=cityzone0; by year fishery city;
	id region area areaname; output out=oneline2; 
	run; 
*merge city percents and area/region names;
proc sort data=oneline2; by year fishery city; run; 
proc sort data=citypct; by year fishery city; run;
data cityzone; merge oneline2 citypct; by year fishery city; run;


*transpose file to get years as varibles;
proc sort data=cityzone; by fishery region area areaname city; run;
proc transpose data=cityzone out=cztrans; by fishery region area areaname city;
	var percent;
	id year;
	run;

*create a summary varible;
data fishery; set cztrans;
	format summary $30.;
	if region eq 2 and areaname eq 'Anchorage' then summary='Region 2-Anchorage';
	else if region eq 2 and areaname eq 'Knik Arm Drainage' then summary='Region 2-Knik Arm Drainage';
	else if region eq 2 and areaname eq 'Kenai Peninsula' then summary='Region 2-Kenai Peninsula';
	else summary='Other areas';
	run;

*sum by summary varible;
proc sort data=fishery; by fishery summary; run;
proc summary data=fishery; by fishery summary; 
	output out=fisherycity sum(_1996 _1997 _1998 _1999 _2000 _2001 _2002 _2003)=;
	run;







