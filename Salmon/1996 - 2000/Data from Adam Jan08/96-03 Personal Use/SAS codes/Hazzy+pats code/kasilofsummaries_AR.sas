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
run;
proc sort data=work96; by fishery harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work96;
  by fishery harvdate;
  var red king;
  where fishery='DIP  KASILOF         -' or fishery='GILL KASILOF         -';
  output out=redharvest96 n=hseholds sum=redtotal kingtotal mean=meanred meanking;
  run;

proc print data=redharvest96;
  format redtotal kingtotal 10. meanred meanking 4.1;
  title "number households (permits) fishing and harvest by date in Kasilof River fishery 1996";
run;

* Get distribution of permits fishing at the Kasilof by household size;
* First need to get one line per permit;

Proc sort data=work96; by fishery licensen;
proc summary data=work96; by fishery licensen;
  where fishery='DIP  KASILOF         -' or fishery='GILL KASILOF         -';
  var red king;
  id familysi;
  output out = kasilofpermits96 n=hhdays sum=;
  run;

* get mean harvest per permit in the entire Kasilof fishery;
Proc summary data=kasilofpermits96; by fishery;
*  class licensen;
  var red king hhdays;
  output out=totharv96;
  format red king 10.;
Proc print data=totharv96;
  title "totharv96 the mean harvest and mean days fished per permit";
proc sort data=kasilofpermits96; by fishery familysi;
Proc summary data=kasilofpermits96; by fishery familysi;
  var red king hhdays;
  output out=familyharv96 mean=meanred meanking meandays sum=totalreds totalking totaldays;
  format meandays 3.1 meanred meanking 4.1 totalreds totalking 10.;
Proc print data=familyharv96; by fishery;
  title "familyharv96 the mean and total harvest and days fished per permit by familysize";
proc freq data=kasilofpermits96; by fishery;
  tables familysi / list;
  title "frequency of family size in Kasilof fishery 1996";
proc freq data=kasilofpermits96; by fishery;
  tables hhdays / list;
  title "frequency of days fished by permits in Kasilof fishery 1996";
* start with all97b-the cleaned up 1997 permit&harvest file;
data work97; set uciperm.harv97b;
run;
proc sort data=work97; by fishery harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work97; by fishery harvdate;
  var red king;
  where fishery='Kasilof River Dip Net' or fishery='Kasilof River Gill Net';
  output out=redharvest97 n=hseholds sum=redtotal kingtotal mean=meanred meanking;
proc print data=redharvest97;
  format redtotal kingtotal 10. meanred meanking 4.1;
  title "number households (permits) fishing and harvest by date in Kasilof River fishery 1997";

* Get distribution of permits fishing at the Kasilof by household size;
* First need to get one line per permit;

Proc sort data=work97; by fishery permit;
proc summary data=work97; by fishery permit;
  where fishery='Kasilof River Dip Net' or fishery='Kasilof River Gill Net';
  var red king;
  id familysi;
  output out = kasilofpermits97 n=hhdays sum=;

* get mean harvest per permit in the entire Kasilof fishery;
Proc summary data=kasilofpermits97; by fishery;
  var red king hhdays;
  output out=totharv97;
  format red king 10.;
Proc print data=totharv97;
  title "totharv97 the mean harvest and mean days fished per permit in 1997";
proc sort data=kasilofpermits97; by fishery familysi;
Proc summary data=kasilofpermits97; by fishery familysi;
  var red king hhdays;
  output out=familyharv97 mean=meanred meanking meandays sum=totalreds totalking totaldays;
Proc print data=familyharv97;
  format meandays 3.1 meanred meanking 4.1 totalreds totalking 10.;
  title "familyharv97 the mean and total harvest and days fished per permit by familysize in 1997";
proc freq data=kasilofpermits97; by fishery;
  tables familysi;
  title "frequency of family size in Kasilof fishery 1997";
proc freq data=kasilofpermits97; by fishery;
  tables hhdays;
  title "frequency of days fished by permits in Kasilof fishery 1997";

* start with harv98-the cleaned up 1998 harvest file and permit98 the cleaned up permit file;
data workharv98; set uciperm.harv98;
run;
* Get 1998 permit file into the new SAS format;
* Only need to do this once;
/* LIBNAME UCIPERM v612 'H:\BIO\UCI_PERM';
data permit98; set uciperm.permit98;
run;
LIBNAME UCIPERM 'H:\BIO\UCI_PERM';
data uciperm.permit98; set permit98;
run; */

data workperm98; set uciperm.permit98;
run;
Proc sort data=workperm98; by cisalprm;
proc sort data=workharv98; by cisalprm;
run;
data work98; merge workharv98 (in=inh) workperm98 (in=inp); by cisalprm;
  if inh=1 then inharv=1;
  if inp=1 then inperm=1;
run;
proc sort data=work98; by fishery harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work98; by fishery harvdate;
  var red king;
  where fishery='Kasilof River Dip Net' or fishery='Kasilof River Gill Net';
  output out=redharvest98 n=hseholds sum=redtotal kingtotal mean=meanred meanking;

proc print data=redharvest98;
  format redtotal kingtotal 10. meanred meanking 4.1;
  title "number households (permits) fishing and harvest by date in Kasilof River fishery 1998";

* Get distribution of permits fishing at the Kasilof by household size;
* First need to get one line per permit;

Proc sort data=work98; by cisalprm fishery;
proc summary data=work98; by cisalprm fishery;
  where fishery='Kasilof River Dip Net' or fishery='Kasilof River Gill Net';
  var red king;
  id familysi;
  output out = kasilofpermits98 n=hhdays sum=;

* get mean harvest per permit in the entire Kasilof fishery;
proc sort data=kasilofpermits98; by fishery;
Proc summary data=kasilofpermits98; by fishery;
  var red king hhdays;
  output out=totharv98;
  format red king 10.;
Proc print data=totharv98;
  title "totharv98 the mean harvest and mean days fished per permit in 1998";
proc sort data=kasilofpermits98; by fishery familysi;
Proc summary data=kasilofpermits98; by fishery familysi;
  var red king hhdays;
  output out=familyharv98 mean=meanred meanking meandays sum=totalreds totalking totaldays;
Proc print data=familyharv98;
  format meandays 3.1 meanred meanking 4.1 totalreds totalking 10.;
  title "familyharv98 the mean and total harvest and days fished per permit by familysize in 1998";
proc freq data=kasilofpermits98; by fishery;
  tables familysi;
  title "frequency of family size in Kasilof fishery 1998";
  run;
proc freq data=kasilofpermits98; by fishery;
  tables hhdays;
  title "frequency of days fished by permits in Kasilof fishery 1998";
  run;

* Get 1999 permit file into the new SAS format;
* Only need to do this once;
/* LIBNAME UCIPERM v612 'H:\BIO\UCI_PERM';
data permit99; set uciperm.cislpm99;
run;
LIBNAME UCIPERM 'H:\BIO\UCI_PERM';
data uciperm.permit99; set permit99;
run; */

data workperm99; set uciperm.permit99;
  keep cisalprm lastname city familysi blankrpt hrvrptlo dupapp permref void notfish;
run;
* start with harv99-the cleaned up 1999 harvest file;
data workharv99; set uciperm.harv99; run;
Proc sort data=workperm99; by cisalprm;
proc sort data=workharv99; by cisalprm;
run;
data work99; merge workharv99 (in=inh) workperm99 (in=inp); by cisalprm;
  if inh=1 then inharv=1;
  if inp=1 then inperm=1;
run;
proc sort data=work99; by fishery harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work99; by fishery harvdate;
  var red king;
  where fishery='Kasilof River Dip Net' or fishery='Kasilof River Gill Net';
  output out=redharvest99 n=hseholds sum=redtotal kingtotal mean=meanred meanking;

proc print data=redharvest99;
  format redtotal kingtotal 10. meanred meanking 4.1;
  title "number households (permits) fishing and harvest by date in Kasilof River fishery 1999";

* Get distribution of permits fishing at the Kasilof by household size;
* First need to get one line per permit;

Proc sort data=work99; by cisalprm fishery;
proc summary data=work99; by cisalprm fishery;
  where fishery='Kasilof River Dip Net' or fishery='Kasilof River Gill Net';
  var red king;
  id familysi;
  output out = kasilofpermits99 n=hhdays sum=;
  run;

* get mean harvest per permit in the entire Kasilof fishery;
proc sort data=kasilofpermits99; by fishery;
Proc summary data=kasilofpermits99; by fishery;
  var red king hhdays;
  output out=totharv99;
  format red king 10.;
Proc print data=totharv99;
  title "totharv99 the mean harvest and mean days fished per permit in 1999";
proc sort data=kasilofpermits99; by fishery familysi;
Proc summary data=kasilofpermits99; by fishery familysi;
  var red king hhdays;
  output out=familyharv99 mean=meanred meanking meandays sum=totalreds totalking totaldays;
Proc print data=familyharv99;
  format meandays 3.1 meanred meanking 4.1 totalreds totalking 10.;
  title "familyharv99 the mean and total harvest and days fished per permit by familysize in 1999";
proc freq data=kasilofpermits99; by fishery;
  tables familysi;
  title "frequency of family size in Kasilof fishery 1999";
proc freq data=kasilofpermits99; by fishery;
  tables hhdays;
  title "frequency of days fished by permits in Kasilof fishery 1999";
  run;

* start with harvest00-the cleaned up 2000 harvest file;
data work00; set uciperm.harvest00;
run;
proc sort data=work00; by fishery harvdate;

* Get red harvest and number of permits fishing by date;
proc summary data=work00; by fishery harvdate;
  var red king;
  where fishery=2 or fishery=3;
  output out=redharvest00 n=hseholds sum=redtotal kingtotal mean=meanred meanking;

proc print data=redharvest00;
  format redtotal 10. meanred meanking 4.1;
  title "number households (permits) fishing and harvest by date in Kasilof River fishery 2000";

* Get distribution of permits fishing at the Kasilof by household size;
* First need to get one line per permit;

Proc sort data=work00; by fishery permit;
proc summary data=work00; by fishery permit;
  where fishery=2 or fishery=3;
  var red king;
  id familysi;
  output out = kasilofpermits00 n=hhdays sum=;

* get mean harvest per permit in the entire Kasilof fishery;
Proc summary data=kasilofpermits00; by fishery;
  var red king hhdays;
  output out=totharv00;
  format red king 10.;
Proc print data=totharv00;
  title "totharv00 the mean harvest and mean days fished per permit in 2000";
proc sort data=kasilofpermits00; by fishery familysi;
Proc summary data=kasilofpermits00; by fishery familysi;
  var red king hhdays;
  output out=familyharv00 mean=meanred meanking meandays sum=totalreds totalking totaldays;
Proc print data=familyharv00;
  format meandays 3.1 meanred meanking 4.1 totalreds totalking 10.;
  title "familyharv00 the mean and total harvest and days fished per permit by familysize in 2000";
proc freq data=kasilofpermits00; by fishery;
  tables familysi;
  title "frequency of family size in Kasilof fishery 2000";

proc freq data=kasilofpermits00; by fishery;
  tables hhdays;
  title "frequency of days fished by permits in Kasilof fishery 2000";
run;




