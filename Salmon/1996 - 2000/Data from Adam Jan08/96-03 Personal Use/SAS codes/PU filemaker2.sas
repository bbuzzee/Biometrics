*This code combines each years datasets into one dataset and standardizes fishery varible.  
	error prone because each dataset is in a slightly different format and noone is familiar 
	with the procedures for each year.;
options pageno=1 linesize=132 pagesize=76;
title ' ';
Title2 ' ';
run;
libname UCIPERM 'H:\My Documents\Personal Use\Imported files\From Hazzy';
LIBNAME SASDATA 'H:\My Documents\Personal Use\Imported files\From Pat Hansen';
LIBNAME SASDATA2 'H:\My Documents\Personal Use\Imported files\From Pat Hansen\03 stuff';

* reduce harv96 (the cleaned up 1996 harvest/permit file);
data work96; set uciperm.harv96;
year = 1996;
format fishery2 $char35.;
	IF FISHERY EQ 'GILL KASILOF         -' THEN fishery2='Kasilof River Gill Net';
	IF FISHERY EQ 'DIP  FISH CREEK      -' THEN fishery2='Fish Creek Dip Net';
    IF FISHERY EQ 'DIP  KENAI RIVER     -' THEN fishery2='Kenai River Dip Net';
    IF FISHERY EQ 'DIP  KASILOF         -' THEN fishery2='Kasilof River Dip Net';
    IF FISHERY EQ 'OTHER                -' THEN fishery2='Unknown';
    IF fishery EQ 'Did Not Fish'           THEN fishery2='Did not fish';
	IF notfish EQ 'T'           			THEN fishery2='Did not fish';
if familysi ge 1 then allowed=(familysi-1)*10+25; else allowed=.; 
if familysi=. then familysi=(allowed-25)/10+1;
keep licensen city harvdate familysi allowed red king coho pink chum noresp year fishery2;
label licensen=' ';
rename licensen=idnum;
run;

* reduce harv97b (the cleaned up 1997 harvest/permit file);
data work97; set uciperm.harv97b;
year = 1997; idnum=input(permit, $char6.); idnum=permit;
format fishery2 $char35.; 
fishery2=fishery; if fishery='None' then fishery2='Unknown';
	if fishery='Did Not Fish' then fishery2='Did not fish';
if familysi ge 1 then allowed=(familysi-1)*10+25; else allowed=.; 
keep city familysi harvdate allowed red king coho pink chum noresp year fishery2 idnum;
run;

* start with harv98 (the cleaned up 1998 harvest file);
data workharv98; set uciperm.harv98; run;
* Get 1998 permit file into the SAS format.  Only need to do this once;
data workperm98; set uciperm.permit98; run;
Proc sort data=workperm98; by cisalprm; proc sort data=workharv98; by cisalprm;
run;
data work98; merge workharv98 (in=inh) workperm98 (in=inp); by cisalprm;
year = 1998; idnum=input(cisalprm, $char6.); idnum=cisalprm;
if inh=1 then inharv=1;
if inp=1 then inperm=1;
format fishery2 $char35.; 
fishery2=fishery; if notfish=1 then fishery2='Did not fish';
	if fishery='None' then fishery2='Unknown';
	*There was no 'noresp' field and 'blankrep' field only had one positive value so will 
	assume blank fishery2 means no response during analysis.; 
keep idnum city harvdate familysi allowed red king coho pink chum year fishery2;
run;

* Get 1999 permit file into the new SAS format.  Only need to do this once;
data workperm99; set uciperm.permit99;
  keep cisalprm lastname city familysi blankrpt hrvrptlo dupapp permref void notfish;
run;
* start with harv99-the cleaned up 1999 harvest file;
data workharv99; set uciperm.harv99; run;
Proc sort data=workperm99; by cisalprm; proc sort data=workharv99; by cisalprm;
run;
data work99; merge workharv99 (in=inh) workperm99 (in=inp); by cisalprm;
year = 1999; idnum=input(cisalprm, $char6.); idnum=cisalprm;
if inh=1 then inharv=1;
if inp=1 then inperm=1;
format fishery2 $char35.; 
fishery2=fishery; if notfish=1 then fishery2='Did not fish';
	if fishery='None' then fishery2='Unknown';
	*There was no 'noresp' field and 'blankrep' field did not explain all cases where there was no harvest info
	so will assume blank fishery2 means no response during analysis.;
if familysi ge 1 then allowed=(familysi-1)*10+25; else allowed=.; 
keep idnum city harvdate familysi red king coho pink chum year fishery2 allowed;
run;

* start with harvest00-the cleaned up 2000 harvest file;
data work00; set uciperm.harvest00;
year = 2000; idnum=input(permit, $char6.); idnum=permit;
format fishery2 $char35.;
	IF FISHERY EQ 1 THEN fishery2='Kenai River Dip Net';
    IF FISHERY EQ 2 THEN fishery2='Kasilof River Dip Net';
    IF FISHERY EQ 3 THEN fishery2='Kasilof River Gill Net';
	IF FISHERY EQ 4 THEN fishery2='Fish Creek Dip Net';
    IF notfish EQ 1 THEN fishery2='Did not fish';
    IF FISHERY EQ 5 THEN fishery2='Unknown';
	*There was no 'noresp' field and 'blankrep' field did not contain any positive values but 
	all fishery=5 records had recorded harvest;
allowed=.; if familysi ge 1 then allowed=(familysi-1)*10+25;
keep idnum city harvdate familysi allowed red king coho pink chum year fishery2;
run;

* start with cislhv01c (the cleaned up 2001 harvest file);
data workharv01; set sasdata.cislhv01c; run;
* Get 2001 permit file.;
data workperm01z; set sasdata.cislpm01z; run;
data workperm01c; set sasdata.cislpm01c; run;
data workperm01; set workperm01z workperm01c; run; 
Proc sort data=workperm01; by permitno; proc sort data=workharv01; by permitno; run;
data work01; merge workharv01 (in=inh) workperm01 (in=inp); by permitno;
if inh=1 then inharv=1;
if inp=1 then inperm=1;
year = 2001; idnum=input(permitno, $char6.); idnum=permitno;
format fishery $char35.; fishery2=fishery;
IF FISHERY EQ 'KASILOF' AND HARVDATE GE '01JUN01'D AND HARVDATE LT '01JUL01'D THEN fishery2='Kasilof River Gill Net';
    IF FISHERY EQ 'KASILOF' AND fishery2 ne 'Kasilof River Gill Net' THEN fishery2='Kasilof River Dip Net';	
    IF FISHERY EQ 'KENAI' THEN fishery2='Kenai River Dip Net';
	IF FISHERY EQ 'FISH CREEK' THEN fishery2='Fish Creek Dip Net';
	IF notfish EQ 1 THEN fishery2='Did not fish';
    IF FISHERY EQ 'UNKNOWN' THEN fishery2='Unknown';  
if familysi ge 1 then allowed=(familysi-1)*10+25; 
keep idnum city harvdate  familysi allowed red king coho pink chum blankrpt year fishery2;
run;

* start with cislhv02c (the cleaned up 2002 harvest file);
data workharv02; set sasdata.CISLHV02C; run;
* Get 2002 permit file.;
data workperm02; set sasdata.cislpm02c; run;
Proc sort data=workperm02; by permitno; proc sort data=workharv02; by permitno; run;
data work02; merge workharv02 (in=inh) workperm02 (in=inp); by permitno;
if inh=1 then inharv=1;
if inp=1 then inperm=1;
year = 2002; idnum=input(permitno, $char6.); idnum=permitno;
format fishery $char35.; fishery2=fishery;
IF FISHERY EQ 'KASILOF' AND HARVDATE GE '01JUN02'D AND HARVDATE LT '25JUN02'D THEN fishery2='Kasilof River Gill Net';
    IF FISHERY EQ 'KASILOF' AND fishery2 ne 'Kasilof River Gill Net' THEN fishery2='Kasilof River Dip Net';	
    IF FISHERY EQ 'KENAI' THEN fishery2='Kenai River Dip Net';
	IF FISHERY EQ 'FISH CREEK' THEN fishery2='Fish Creek Dip Net';
	IF notfish EQ 1 THEN fishery2='Did not fish';
    IF FISHERY EQ 'UNKNOWN' THEN fishery2='Unknown'; 
if familysi ge 1 then allowed=(familysi-1)*10+25; 
keep idnum city harvdate familysi allowed red king coho pink chum blankrpt year fishery2;
run;

* start with cislhv03c (the cleaned up 2003 harvest file);
data workharv03; set sasdata2.cislhv03c; run;
* Get 2003 permit file.;
data workperm03; set sasdata2.cislpm03c; run;
Proc sort data=workperm03; by permitno; proc sort data=workharv03; by permitno; run;
data work03; merge workharv03 (in=inh) workperm03 (in=inp); by permitno;
if inh=1 then inharv=1;
if inp=1 then inperm=1;
year = 2003; idnum=input(permitno, $char6.); idnum=permitno;
format fishery $char35.; fishery2=fishery;
IF FISHERY EQ 'KASILOF' AND HARVDATE GE '01JUN03'D AND HARVDATE LT '25JUN03'D THEN fishery2='Kasilof River Gill Net';
    IF FISHERY EQ 'KASILOF' AND fishery2 ne 'Kasilof River Gill Net' THEN fishery2='Kasilof River Dip Net';	
    IF FISHERY EQ 'KENAI' THEN fishery2='Kenai River Dip Net';
	IF FISHERY EQ 'FISH CREEK' THEN fishery2='Fish Creek Dip Net';
	IF notfish EQ 1 THEN fishery2='Did not fish';
    IF FISHERY EQ 'UNKNOWN' THEN fishery2='Unknown'; 
if familysi ge 1 then allowed=(familysi-1)*10+25; 
keep idnum city harvdate familysi allowed red king coho pink chum blankrpt year fishery2;
run;

data PU.PUfile; set work96 work97 work98 work99 work00 work01 work02 work03;
if fishery2='Did not fish' then red=0; if fishery2='Did not fish' then king=0; 
	if fishery2='Did not fish' then coho=0; if fishery2='Did not fish' then pink=0; 
	if fishery2='Did not fish' then chum=0;
	total=red+king+chum+coho+pink;
label red='SOCKEYE' king='CHINOOK';
format red king coho pink chum 5.;
informat red king coho pink chum 5.;	
rename 	fishery2=fishery
		red=sockeye
		king=chinook;
city=upcase(city);
*Sledge hammer approach: combine noresp and blankrpt into nodata varible that indicates 
	no harvest data and then manually fill nodata for records where there was no harvest data 
	but also no record of a blank report; 
nodata=0; if noresp='T' then nodata=1; if blankrpt=1 then nodata=1; drop noresp blankrpt;
	if harvdate eq . and total eq . and fishery eq . then nodata=1;
	nodata2=0; if harvdate eq . and total eq . and fishery eq . then nodata2=1;
*Makes catch binomial for future error check; 
	catch=total; if total gt 0 then catch=1;
run;

*Check to see the noresp and blankrpt varibles are responsible for nodata value or if 
	manual sledgehammer is responsible (differs by year); 
proc freq data=PU.pufile; tables year*nodata year*nodata2; run;
*Check to see the number of permits who fished unknown fisheries and either caught fish 
	or did not (represents orignial determination when data was entered).  missing values 
	should equal the yearly 'nodata' varible above.  It does.;
proc freq data=PU.pufile; by year; tables fishery*catch; run;

