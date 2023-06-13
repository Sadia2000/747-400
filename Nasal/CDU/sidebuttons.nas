var sidebuttons = func(button) {
var deletekey = getprop("instrumentation/cdu/deletekey");
var title = getprop("/instrumentation/cdu/save/title");
var input = getprop("instrumentation/cdu/input");
var inputsize = size(getprop("instrumentation/cdu/input"));
fp = flightplan();
var currentpage = getprop("instrumentation/cdu/page/current-page");
var baroset = "instrumentation/altimeter/mode";

if (title == "MENU"){
	if (button == "L1"){
	newpage("IDENT");
	}
if (button == "R1"){
	newpage("EFIS CONTROL");
	 }
}

if (title == "INIT/REF INDEX"){
	if (button == "L1"){
		newpage("IDENT");
	}
if (button == "L2"){
	newpage("POS INIT");
}
if (button == "L3"){
	newpage("PERF INIT");
}
}

if (title == "DEP/ARR INDEX"){
	if (button == "L1"){
		newpage("DEPARTURES");
	  }
if (button == "R2"){
	newpage("DESTINATION");
	}
}

if(title == "DEPARTURES"){
if(button == "L1"){
	if(getprop("autopilot/route-manager/departure/sid") == ""){
		setprop("autopilot/route-manager/departure/sid", getprop("instrumentation/cdu/lines/l2"));
		newpage(title);
		resettrans();
	}else if(fp.sid_trans == nil and currentpage != 1){
		fp.sid_trans = getprop("instrumentation/cdu/lines/l2");
		newpage(title);
	}
}

if(button == "L2"){
	if(getprop("autopilot/route-manager/departure/sid") == ""){
		setprop("autopilot/route-manager/departure/sid", getprop("instrumentation/cdu/lines/l4"));
		newpage(title);
		resettrans();
	}else if(fp.sid_trans == nil and getprop("instrumentation/cdu/lines/l4") != "-NONE-" ){
		fp.sid_trans = getprop("instrumentation/cdu/lines/l4");
		newpage(title);
}
}

if(button == "L3"){
	if(getprop("autopilot/route-manager/departure/sid") == ""){
		setprop("autopilot/route-manager/departure/sid", getprop("instrumentation/cdu/lines/l6"));
		newpage(title);
		resettrans();
	}else if(fp.sid_trans == nil){
		fp.sid_trans = getprop("instrumentation/cdu/lines/l6");
		newpage(title);
	}
}

if(button == "L4"){
	if(getprop("autopilot/route-manager/departure/sid") == ""){
		setprop("autopilot/route-manager/departure/sid", getprop("instrumentation/cdu/lines/l8"));
		newpage(title);
		resettrans();
	}else if(fp.sid_trans == nil){
		fp.sid_trans = getprop("instrumentation/cdu/lines/l8");
		newpage(title);
	}
}

if(button == "L5"){
	if(getprop("autopilot/route-manager/departure/sid") == ""){
		setprop("autopilot/route-manager/departure/sid", getprop("instrumentation/cdu/lines/l10"));
		newpage(title);
		resettrans();
	}else if(fp.sid_trans == nil){
	fp.sid_trans = getprop("instrumentation/cdu/lines/l10");
		newpage(title);
	}
}

if(button == "R1"){
	if(getprop("autopilot/route-manager/departure/runway") == ""){
		setprop("autopilot/route-manager/departure/runway", getprop("instrumentation/cdu/lines/r2"));
		newpage(title);
	}
}

if(button == "R2"){
	if(getprop("autopilot/route-manager/departure/runway") == ""){
		setprop("autopilot/route-manager/departure/runway", getprop("instrumentation/cdu/lines/r4"));
		newpage(title);
	}
}

if(button == "R3"){
	if(getprop("autopilot/route-manager/departure/runway") == ""){
		setprop("autopilot/route-manager/departure/runway", getprop("instrumentation/cdu/lines/r6"));
		newpage(title);
	}
}

if(button == "R4"){
	if(getprop("autopilot/route-manager/departure/runway") == ""){
		setprop("autopilot/route-manager/departure/runway", getprop("instrumentation/cdu/lines/r8"));
		newpage(title);
	}
}

if(button == "R5"){
	if(getprop("autopilot/route-manager/departure/runway") == ""){
		setprop("autopilot/route-manager/departure/runway", getprop("instrumentation/cdu/lines/r10"));
		newpage(title);
	}
}

if(button == "L6"){
	if(fp.sid_trans != nil or fp.sid != nil or getprop("autopilot/route-manager/departure/runway") != ""){
		erasesidpage();
		newpage(title);
	}else{
		newpage("DEP/ARR INDEX");
	}
}

if(button == "R6"){
	newpage("RTE 1");
}
}

if(title == "DESTINATION"){
if(button == "L1"){
	if(getprop("autopilot/route-manager/destination/star") == ""){
		setprop("autopilot/route-manager/destination/star", getprop("instrumentation/cdu/lines/l2"));
		newpage(title);
		resetstrans();
		}else if(fp.star_trans == nil and currentpage != 1){
		fp.star_trans = getprop("instrumentation/cdu/lines/l2");
		newpage(title);
	}
}

if(button == "L2"){
	if(getprop("autopilot/route-manager/destination/star") == ""){
		setprop("autopilot/route-manager/destination/star", getprop("instrumentation/cdu/lines/l4"));
		newpage(title);
		resetstrans();
	}else if(fp.star_trans == nil){
		fp.star_trans = getprop("instrumentation/cdu/lines/l4");
		newpage(title);
	}
}

if(button == "L3"){
	if(getprop("autopilot/route-manager/destination/star") == ""){
		setprop("autopilot/route-manager/destination/star", getprop("instrumentation/cdu/lines/l6"));
		newpage(title);
		resetstrans();
	}else if(fp.star_trans == nil){
		fp.star_trans = getprop("instrumentation/cdu/lines/l6");
		newpage(title);
	}
}

if(button == "L4"){
	if(getprop("autopilot/route-manager/destination/star") == ""){
		setprop("autopilot/route-manager/destination/star", getprop("instrumentation/cdu/lines/l8"));
		newpage(title);
		resetstrans();
	}else if(fp.star_trans == nil){
		fp.star_trans = getprop("instrumentation/cdu/lines/l8");
		newpage(title);
	}
}

if(button == "L5"){
if(getprop("autopilot/route-manager/destination/star") == ""){
setprop("autopilot/route-manager/destination/star", getprop("instrumentation/cdu/lines/l10"));
newpage(title);
resetstrans();
}else if(fp.star_trans == nil){
fp.star_trans = getprop("instrumentation/cdu/lines/l10");
newpage(title);
}
}

if(button == "R1"){
if(fp.approach == nil and getprop("instrumentation/cdu/page/app/num") >= 1 and currentpage <= getprop("instrumentation/cdu/page/app/maxpage")){
fp.approach = getprop("instrumentation/cdu/lines/r2");
newpage(title);
resetatrans();
}else if(fp.destination_runway == nil and ((getprop("instrumentation/cdu/page/app/num") < 1 and currentpage == getprop("instrumentation/cdu/page/app/maxpage")) or currentpage >= getprop("instrumentation/cdu/page/app/maxpage"))){
dest = airportinfo(fp.destination.id);
destrwy = dest.runway(getprop("instrumentation/cdu/lines/r2"));
fp.destination_runway = destrwy;
newpage(title);
}else if(fp.approach != nil and fp.approach_trans == nil and currentpage != 1){
fp.approach_trans = getprop("instrumentation/cdu/lines/r2");
newpage(title);
}
}

if(button == "R2"){
if(fp.approach == nil and getprop("instrumentation/cdu/page/app/num") >= 2 and currentpage <= getprop("instrumentation/cdu/page/app/maxpage")){
fp.approach = getprop("instrumentation/cdu/lines/r4");
newpage(title);
resetatrans();
}else if(fp.destination_runway == nil and ((getprop("instrumentation/cdu/page/app/num") < 2 and currentpage == getprop("instrumentation/cdu/page/app/maxpage")) or currentpage >= getprop("instrumentation/cdu/page/app/maxpage"))){
dest = airportinfo(fp.destination.id);
destrwy = dest.runway(getprop("instrumentation/cdu/lines/r4"));
fp.destination_runway = destrwy;
newpage(title);
}else if(fp.approach != nil and fp.approach_trans == nil){
fp.approach_trans = getprop("instrumentation/cdu/lines/r4");
newpage(title);
}
}

if(button == "R3"){
if(fp.approach == nil and getprop("instrumentation/cdu/page/app/num") >= 3 and currentpage <= getprop("instrumentation/cdu/page/app/maxpage")){
fp.approach = getprop("instrumentation/cdu/lines/r6");
newpage(title);
resetatrans();
}else if(fp.destination_runway == nil and ((getprop("instrumentation/cdu/page/app/num") < 3 and currentpage == getprop("instrumentation/cdu/page/app/maxpage")) or currentpage >= getprop("instrumentation/cdu/page/app/maxpage"))){
dest = airportinfo(fp.destination.id);
destrwy = dest.runway(getprop("instrumentation/cdu/lines/r6"));
fp.destination_runway = destrwy;
newpage(title);
}else if(fp.approach != nil and fp.approach_trans == nil){
fp.approach_trans = getprop("instrumentation/cdu/lines/r6");
newpage(title);
}
}

if(button == "R4"){
if(fp.approach == nil and getprop("instrumentation/cdu/page/app/num") >= 4 and currentpage <= getprop("instrumentation/cdu/page/app/maxpage")){
fp.approach = getprop("instrumentation/cdu/lines/r8");
newpage(title);
resetatrans();
}else if(fp.destination_runway == nil and ((getprop("instrumentation/cdu/page/app/num") < 4 and currentpage == getprop("instrumentation/cdu/page/app/maxpage")) or currentpage >= getprop("instrumentation/cdu/page/app/maxpage"))){
dest = airportinfo(fp.destination.id);
destrwy = dest.runway(getprop("instrumentation/cdu/lines/r8"));
fp.destination_runway = destrwy;
newpage(title);
}else if(fp.approach != nil and fp.approach_trans == nil){
fp.approach_trans = getprop("instrumentation/cdu/lines/r8");
newpage(title);
}
}

if(button == "R5"){
if(fp.approach == nil and getprop("instrumentation/cdu/page/app/num") >= 5 and currentpage <= getprop("instrumentation/cdu/page/app/maxpage")){
fp.approach = getprop("instrumentation/cdu/lines/r10");
newpage(title);
resetatrans();
}else if(fp.destination_runway == nil and ((getprop("instrumentation/cdu/page/app/num") < 5 and currentpage == getprop("instrumentation/cdu/page/app/maxpage")) or currentpage >= getprop("instrumentation/cdu/page/app/maxpage"))){
dest = airportinfo(fp.destination.id);
destrwy = dest.runway(getprop("instrumentation/cdu/lines/r10"));
fp.destination_runway = destrwy;
newpage(title);
}else if(fp.approach != nil and fp.approach_trans == nil){
fp.approach_trans = getprop("instrumentation/cdu/lines/r10");
newpage(title);
}
}

if(button == "L6"){
if(fp.star_trans != nil or fp.star != nil or fp.approach != nil or fp.destination_runway != nil){
erasestarpage();
newpage(title);
}else{
newpage("DEP/ARR INDEX");
}
}

if(button == "R6"){
newpage("RTE 1");
}
}

if(title == "RTE 1"){
if(input != ""){
if(currentpage == 1){
if(button == "L1"){
if(deletekey == 0){
fp.departure = findinput(input, "airport");
}else{
fp.departure = nil;
update();
clear();
}
}
if(button == "L2"){
if(deletekey == 0){
fp.departure_runway = findinput(input, "runway");
}else{
depsave = fp.departure;
fp.departure = nil;
fp.departure = depsave;
update();
clear();
}
}
if(button == "L6"){
if(deletekey == 0){
fp.activate();
update();
}
}
if(button == "R1"){
if(deletekey == 0){
fp.destination = findinput(input, "airport");
}else{
fp.destination = nil;
update();
clear();
}
}
if(button == "R2"){
if(deletekey == 0){
if(size(input) <= 8){
setprop("instrumentation/cdu/flt-no", input);
update();
resetinput();
}else{
warnmessage("NOT ALLOWED");
}
}else{
setprop("instrumentation/cdu/flt-no", "--------");
update();
clear();
}
}
}else{
if(button == "R1"){
if(deletekey == 0){
insertinroute(input, 0);
}else{
deletewayp(0);
}
}
if(button == "R1"){
if(deletekey == 0){
insertinroute(input, 0);
}else{
deletewayp(0);
}
}
if(button == "R2"){
if(deletekey == 0){
insertinroute(input, 1);
}else{
deletewayp(1);
}
}
if(button == "R3"){
if(deletekey == 0){
insertinroute(input, 2);
}else{
deletewayp(2);
}
}
if(button == "R4"){
if(deletekey == 0){
insertinroute(input, 3);
}else{
deletewayp(3);
}
}
if(button == "R5"){
if(deletekey == 0){
insertinroute(input, 4);
}
else{
deletewayp(4);
}
}
}
} 
else{
if(button == "R6"){
if(getprop("autopilot/route-manager/active") != 1){
setprop("/autopilot/route-manager/input","@ACTIVATE");
}
else{
newpage("PERF INIT");
}
}
}
}

if(title == "rte choose waypoint"){
if(button == "L1"){
var multipleway = multiplewaypoint()[0];
var rtenum = getprop("instrumentation/cdu/page/RTE/num");
multipleinsertinroute(multipleway,rtenum);
}
if(button == "L2"){
var multipleway = multiplewaypoint()[1];
var rtenum = getprop("instrumentation/cdu/page/RTE/num");
multipleinsertinroute(multipleway,rtenum);
}
if(button == "L3"){
var multipleway = multiplewaypoint()[2];
var rtenum = getprop("instrumentation/cdu/page/RTE/num");
multipleinsertinroute(multipleway,rtenum);
}
if(button == "L4"){
var multipleway = multiplewaypoint()[3];
var rtenum = getprop("instrumentation/cdu/page/RTE/num");
multipleinsertinroute(multipleway,rtenum);
}
if(button == "L5"){
var multipleway = multiplewaypoint()[4];
var rtenum = getprop("instrumentation/cdu/page/RTE/num");
multipleinsertinroute(multipleway,rtenum);
}
}

if (title == "IDENT"){
if (button == "L6"){
newpage("INIT/REF INDEX");
  }
  if (button == "R6"){
newpage("POS INIT");
  }
}

if (title == "EFIS CONTROL"){
if (button == "L1"){
var inputisnumber = isnum(input);
if (inputisnumber == 1){
if (input >= 22.0 and input <= 32.0){
update();
setprop (baroset, "IN-HG");
setprop("instrumentation/altimeter/setting-inhg", sprintf("%2.2f" , input));
setprop("instrumentation/cdu/input", "");
}
else if (input >= 2200 and input <= 3200){
update();
setprop (baroset, "IN-HG");
setprop("instrumentation/altimeter/setting-inhg", sprintf("%2.2f" , input*0.01));
setprop("instrumentation/cdu/input", "");
}
else if (input >= 745 and input <= 1084){
update();
setprop (baroset, "HPA");
setprop("instrumentation/altimeter/setting-hpa", sprintf("%04.0f" , input));
setprop("instrumentation/cdu/input", "");
}
else{
setprop("instrumentation/cdu/input", "");
warnmessage('INVALID ENTRY');	
}
}
else{
if (input == "H"){
update();
setprop("instrumentation/cdu/input", "");
setprop(baroset, "HPA");
}
else if (input == "I"){
update();
setprop("instrumentation/cdu/input", "");
setprop(baroset, "IN-HG");
}
else if (input == "S"){
if(getprop(baroset) == "IN-HG"){
update();
setprop("instrumentation/cdu/input", "");
setprop("instrumentation/altimeter/setting-inhg", "29.92");
}
else if(getprop(baroset) == "HPA"){
update();
setprop("instrumentation/cdu/input", "");
setprop("instrumentation/altimeter/setting-hpa", "1013");	
}
}
else if (input == "STD"){
if(getprop(baroset) == "IN-HG"){
update();
setprop("instrumentation/cdu/input", "");
setprop("instrumentation/altimeter/setting-inhg", "29.92");
}
else if(getprop(baroset) == "HPA"){
update();
setprop("instrumentation/cdu/input", "");
setprop("instrumentation/altimeter/setting-hpa", "1013");	
}
}
else{
setprop("instrumentation/cdu/input", "");
warnmessage('INVALID ENTRY');	
}
}
}



if (button == "L2"){
	update();
	if(isint(input) == 1){
	setprop("instrumentation/mk-viii/inputs/arinc429/decision-height", input);
	setprop("instrumentation/cdu/input", "");
	}
	else{
	warnmessage('INVALID ENTRY');
	setprop("instrumentation/cdu/input", "");
	}
}


if (button == "L3"){
	update();
	setprop("instrumentation/mk-viii/inputs/arinc429/decision-height", "200");                                                                    
}




if (button == "L5"){
if (getprop("instrumentation/efis/inputs/range-nm") != 640){
update();
setprop("instrumentation/efis/inputs/range-nm", getprop("instrumentation/efis/inputs/range-nm")*2);
}
}
if (button == "L6"){
if (getprop("instrumentation/efis/inputs/range-nm") != 10){
update();
setprop("instrumentation/efis/inputs/range-nm", getprop("instrumentation/efis/inputs/range-nm")/2);
}
}
if (button == "R1"){
update();
setprop("instrumentation/efis/mfd/display-mode", "MAP");
}
if (button == "R2"){
update();
setprop("instrumentation/efis/mfd/display-mode", "PLAN");
}
if (button == "R3"){
update();
setprop("instrumentation/efis/mfd/display-mode", "APP");
}
if (button == "R4"){
update();
setprop("instrumentation/efis/mfd/display-mode", "VOR");
}
if (button == "R5"){
update();
if (getprop("instrumentation/efis[0]/inputs/nd-centered") == 0){
setprop("instrumentation/efis[0]/inputs/nd-centered", 1);
setprop("instrumentation/efis[1]/inputs/nd-centered", 1);
}
else{
setprop("instrumentation/efis[0]/inputs/nd-centered", 0);
setprop("instrumentation/efis[1]/inputs/nd-centered", 0);
}
}

if (button == "R6"){
newpage("EFIS OPTIONS");
}
}

if (title == "EFIS OPTIONS"){
if (button == "L1"){
update();
if(getprop("instrumentation/efis[0]/inputs/wxr") == 1){
setprop("instrumentation/efis[0]/inputs/wxr", 0);
setprop("instrumentation/efis[1]/inputs/wxr", 0);
}
else{
setprop("instrumentation/efis[0]/inputs/wxr", 1);
setprop("instrumentation/efis[1]/inputs/wxr", 1);	
}
}

if (button == "L2"){
update();
if(getprop("instrumentation/efis[0]/inputs/pos") == 1){
setprop("instrumentation/efis[0]/inputs/pos", 0);
setprop("instrumentation/efis[1]/inputs/pos", 0);
}
else{
setprop("instrumentation/efis[0]/inputs/pos", 1);
setprop("instrumentation/efis[1]/inputs/pos", 1);	
}
}
if (button == "L3"){
warnmessage('NOT IMPLEMENTED YET');
}
if (button == "R1"){
update();
if(getprop("instrumentation/efis[0]/inputs/wpt") == 1){
setprop("instrumentation/efis[0]/inputs/wpt", 0);
setprop("instrumentation/efis[1]/inputs/wpt", 0);
}
else{
setprop("instrumentation/efis[0]/inputs/wpt", 1);
setprop("instrumentation/efis[1]/inputs/wpt", 1);	
}
}
if (button == "R2"){
update();
if(getprop("instrumentation/efis[0]/inputs/sta") == 1){
setprop("instrumentation/efis[0]/inputs/sta", 0);
setprop("instrumentation/efis[1]/inputs/sta", 0);
}
else{
setprop("instrumentation/efis[0]/inputs/sta", 1);
setprop("instrumentation/efis[1]/inputs/sta", 1);	
}
}
if (button == "R3"){
if(getprop("instrumentation/efis[0]/inputs/arpt") == 1){
setprop("instrumentation/efis[0]/inputs/arpt", 0);
setprop("instrumentation/efis[1]/inputs/arpt", 0);
}
else{
setprop("instrumentation/efis[0]/inputs/arpt", 1);
setprop("instrumentation/efis[1]/inputs/arpt", 1);	
}
}
if (button == "R4"){
update();
if(getprop("instrumentation/efis[0]/inputs/data") == 1){
setprop("instrumentation/efis[0]/inputs/data", 0);
setprop("instrumentation/efis[1]/inputs/data", 0);
}
else{
setprop("instrumentation/efis[0]/inputs/data", 1);
setprop("instrumentation/efis[1]/inputs/data", 1);	
}
}
if (button == "R5"){
update();
warnmessage('NOT IMPLEMENTED YET');
}
if (button == "R6"){
update();
warnmessage('NOT IMPLEMENTED YET');
}
}


if(title == "POS INIT"){
if(button == "L2"){
if (inputsize == 4){
var AirstripConfirm = findAirportsByICAO(input);
if (size(AirstripConfirm) == 1){
update();
setprop ("instrumentation/cdu/page/POS-INIT/airport", input);
setprop ("instrumentation/cdu/input", "");
}
else{
update();
warnmessage('INVALID ENTRY');
}
}
else if(deletekey == 1){
update();
setprop ("instrumentation/cdu/page/POS-INIT/airport", "");
setprop ("instrumentation/cdu/input", "");
}
}
if(button == "L3"){
if(getprop("instrumentation/cdu/page/POS-INIT/airport") != ""){
if (input != ""){
warnmessage('NOT IMPLEMENTED YET');
}
}
}
var airporte = getprop("instrumentation/cdu/page/POS-INIT/airport");
var infoe = airportinfo(airporte);
if(button == "R2"){
setprop ("instrumentation/cdu/input", latdeg2dmm(infoe.lat)~" "~londeg2dmm(infoe.lon));
update();
}
if(button == "R6"){
newpage("RTE 1");
}
if(button == "L6"){
newpage("INIT/REF INDEX");
}
if(button == "R1"){
update();	
setprop ("instrumentation/cdu/input", LastREGISTEREDPOS);	
}
if(button == "R4"){
if (input == ""){
setprop ("instrumentation/cdu/input", latdeg2dmm(getprop("position/latitude-deg"))~" "~londeg2dmm(getprop("position/longitude-deg")));
update();
}
else{
update();
}
}
}
}
