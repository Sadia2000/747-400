var sidebuttons = func(button) {
deletekey = getprop("instrumentation/cdu/deletekey");
var title = getprop("/instrumentation/cdu/save/title");
var input = getprop("instrumentation/cdu/input");
var inputsize = size(getprop("instrumentation/cdu/input"));
fp = flightplan();
var currentpage = getprop("instrumentation/cdu/page/current-page");

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
}else{
deletewayp(4);
}
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
warnmessage('NOT IMPLEMENTED YET');
}

}

if(title == "POS INIT"){
if(button == "L2"){
warnmessage('NOT IMPLEMENTED YET');
}
}

}