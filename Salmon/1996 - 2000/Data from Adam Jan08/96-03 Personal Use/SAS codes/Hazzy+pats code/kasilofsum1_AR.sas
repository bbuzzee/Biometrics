* filename=cohobydate96-00.sas.  Used to get summary of coho harvest by day in Kasilof River fishery;
/* Here are the correct 1996 fishery names-they are a pain to get correct because of the spaces
    IF FISHERY EQ 'DIP  FISH CREEK      -' THEN ;
    IF FISHERY EQ 'DIP  KENAI RIVER     -' THEN ;
    IF FISHERY EQ 'DIP  KASILOF         -' THEN ;
    IF FISHERY EQ 'GILL KASILOF         -' THEN ;
    IF FISHERY EQ 'OTHER                -' THEN ;
    IF fishery EQ 'Did Not Fish'           THEN ; */

options pageno=1;
title ' ';
Title2 ' ';
run;
* start with harv96-the cleaned up 1996 harvest file;
libname UCIPERM 'H:\My Documents\Personal Use\Imported files\From Hazzy';  *H:\BIO\UCI_PERM';
data work96; set uciperm.harv96;
format harvdate mmddyy8.;
year = 1996;
if fishery = 'DIP  KASILOF         -' then fishry = 'Kasilof River Dip Net ';
if fishery = 'GILL KASILOF         -' then fishry = 'Kasilof River Gill Net';
run;
proc sort data=work96; by year fishry harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work96; by year fishry harvdate;
  var red king;
  where fishry='Kasilof River Dip Net' or fishry='Kasilof River Gill Net';
  output out=redharvest96 n=hseholds sum=redtotal kingtotal mean=meanred meanking;
run;
* start with all97b-the cleaned up 1997 permit&harvest file;
data work97; set uciperm.harv97b;
year = 1997;
if fishery = 'Kasilof River Dip Net' then fishry =  'Kasilof River Dip Net ';
if fishery = 'Kasilof River Gill Net' then fishry = 'Kasilof River Gill Net';
run;
proc sort data=work97; by year fishry harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work97; by year fishry harvdate;
  var red king;
  where fishry='Kasilof River Dip Net' or fishry='Kasilof River Gill Net';
  output out=redharvest97 n=hseholds sum=redtotal kingtotal mean=meanred meanking;
run;
* start with harv98-the cleaned up 1998 harvest file and permit98 the cleaned up permit file;
data workharv98; set uciperm.harv98;
run;

* Get 1998 permit file into the new SAS format - Only need to do this once;
data workperm98; set uciperm.permit98;
run;
Proc sort data=workperm98; by cisalprm;
proc sort data=workharv98; by cisalprm;
run;
data work98; merge workharv98 (in=inh) workperm98 (in=inp); by cisalprm;
year = 1998;
if fishery = 'Kasilof River Dip Net' then fishry =  'Kasilof River Dip Net ';
if fishery = 'Kasilof River Gill Net' then fishry = 'Kasilof River Gill Net';
if inh=1 then inharv=1;
if inp=1 then inperm=1;
run;
proc sort data=work98; by year fishry harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work98; by year fishry harvdate;
  var red king;
  where fishry='Kasilof River Dip Net' or fishry='Kasilof River Gill Net';
  output out=redharvest98 n=hseholds sum=redtotal kingtotal mean=meanred meanking;
run;

* Get 1999 permit file into the new SAS format - Only need to do this once;
data workperm99; set uciperm.permit99;
  keep cisalprm lastname city familysi blankrpt hrvrptlo dupapp permref void notfish;
run;
* start with harv99-the cleaned up 1999 harvest file;
data workharv99; set uciperm.harv99; run;
Proc sort data=workperm99; by cisalprm;
proc sort data=workharv99; by cisalprm;
run;
data work99; merge workharv99 (in=inh) workperm99 (in=inp); by cisalprm;
year = 1999;
if fishery = 'Kasilof River Dip Net' then fishry =  'Kasilof River Dip Net ';
if fishery = 'Kasilof River Gill Net' then fishry = 'Kasilof River Gill Net';
if inh=1 then inharv=1;
if inp=1 then inperm=1;
run;
proc sort data=work99; by year fishry harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work99; by year fishry harvdate;
  var red king;
  where fishry='Kasilof River Dip Net' or fishry='Kasilof River Gill Net';
  output out=redharvest99 n=hseholds sum=redtotal kingtotal mean=meanred meanking;
run;

* start with harvest00-the cleaned up 2000 harvest file;
data work00; set uciperm.harvest00;
year = 2000;
if (fishery eq 2) then fishry = 'Kasilof River Dip Net ';
if (fishery eq 3) then fishry = 'Kasilof River Gill Net';
run;
proc sort data=work00; by year fishry harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work00; by year fishry harvdate;
  var red king;
  where fishry='Kasilof River Dip Net' or fishry='Kasilof River Gill Net';
  output out=redharvest00 n=hseholds sum=redtotal kingtotal mean=meanred meanking;
run;
data combo; set redharvest96 redharvest97 redharvest98 redharvest99 redharvest00;
proc sort data=combo; by fishry year harvdate;
proc print data=combo;
  format redtotal 10. meanred meanking 4.1;
  var year fishry harvdate hseholds redtotal meanred kingtotal meanking;
  title "number households (permits) fishing and harvest by date in Kasilof River fishery";
run;




