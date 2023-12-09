
var cdu =  func{
var title = getprop("/instrumentation/cdu/save/title");
var fp = flightplan();
var currentpage = getprop("instrumentation/cdu/page/current-page");
var maxpage = getprop("instrumentation/cdu/page/maxpage");
var seloract = getprop("instrumentation/cdu/page/deparr/seloract");
titre = "";
 l1 = "";
 l2 = "";
 l3 = "";
 l4 = "";
 l5 = "";
 l6 = "";
 l7 = "";
 l8 = "";
 l9 = "";
 l10 = "";
 l11 = "";
 l12 = "";
 sl2 = "";
 sl4 = "";
 sl6 = "";
 sl8 = "";
 sl10 = "";
 sl12 = "";
 bl1="";
 bl3="";
 bl5="";
 bl7="";
 bl9="";
 bl11="";
 c1 = "";
 c2 = "";
 c3 = "";
 c4 = "";
 c5 = "";
 c6 = "";
 c7 = "";
 c8 = "";
 c9 = "";
 c10 = "";
 c11 = "";
 c12 = "";
 sc2 = "";
 sc4 = "";
 sc6 = "";
 sc8 = "";
 sc10 = "";
 sc12 = "";
 bc1="";
 bc3="";
 bc5="";
 bc7="";
 bc9="";
 bc11="";
 r1 = "";
 r2 = "";
 r3 = "";
 r4 = "";
 r5 = "";
 r6 = "";
 r7 = "";
 r8 = "";
 r9 = "";
 r10 = "";
 r11 = "";
 r12 = "";
 sr2 = "";
 sr4 = "";
 sr6 = "";
 sr8 = "";
 sr10 = "";
 sr12 = "";
 br1="";
 br3="";
 br5="";
 br7="";
 br9="";
 br11="";
 tiret = "";
 page = "";
pagenum = "";

if (title == "MENU"){
titre = title;
tiret = "";
pagenum = "";
l2 = "<FMC";
l4 = "<ACARS";
l6 = "<SAT";
l10 = "<ACMS";
l12 = "<CMC";
c2 = "<ACT>";
c4 = "<REQ>";
r1 = "EFIS CP";
r2 = "SELECT>";
r3 = "EICAS CP";
r4 = "SELECT>";
}


if (title == "INIT/REF INDEX"){
titre = title;
 pagenum = "";
  tiret = "";
l2 = "<IDENT";
l4 = "<POS";
l6 = "<PERF";
l8 = "<THRUST LIM";
l10 = "<TAKEOFF";
l12 = "<APPROACH";
r2 = "NAV DATA>";
r12 = "MAINT>";
}

if (title == "IDENT"){
titre = title;
 pagenum = "";
tiret = "------------------------";
l1 = "MODEL";
l2 = "747-400";
l3 = "NAV DATA";
l4 = "AIRAC 1310";
l7 = "OP PROGRAM";
l8 = "";
l9 = "DRAG/FF";
l10 = "+0.0/+0.0";
l12 = "<INDEX";
r1 = "ENGINES";
r2 = "-80C2B1F";
r3 = "ACTIVE";
r4 = "SEP29OCT17/13";
r9 = "CO DATA";
r10 = "";
r12 = "POS INIT>";
}

if (title == "EFIS CONTROL"){
titre = title;
 pagenum = "";
tiret = "             -----------";
l1 = "BARO SET";
if(getprop("instrumentation/altimeter/mode") == "IN-HG"){
l2 = sprintf("%2.2f",getprop("instrumentation/altimeter/setting-inhg"));
sl2 = small(l2,"IN");
}
else{
l2 = sprintf("%04.0f",getprop("instrumentation/altimeter/setting-hpa"));
sl2 = small(l2," HPA");
}
l3 = "DH SET";
l4 = sprintf("%i", getprop("instrumentation/mk-viii/inputs/arinc429/decision-height"));
sl4 = small(l4,"FT");
l6 = "<DH RESET";
l7 = "MDA SET";
l10 = "<RANGE INCR";
l11 = sprintf("%i", getprop("instrumentation/efis/inputs/range-nm"))~"NM";
l12 = "<RANGE DECR";
r1 = "MODE";

if (getprop("instrumentation/efis/mfd/display-mode") == "MAP"){
r2 = "<SEL>  MAP>";
}else{
r2 = "MAP>";
}

if (getprop("instrumentation/efis/mfd/display-mode") == "PLAN"){
r4 = "<SEL>  PLN>";
}else{
r4 = "PLN>";
}

if (getprop("instrumentation/efis/mfd/display-mode") == "APP"){
r6 = "<SEL>  APP>";
}else{
r6 = "APP>";
}

if (getprop("instrumentation/efis/mfd/display-mode") == "VOR"){
r8 = "<SEL> VOR>";
}else{
r8 = "VOR>";
}


if (getprop("instrumentation/efis[0]/inputs/nd-centered") == 0){
r10 = "CTR>";
}
else{
r10 = "<SEL> CTR>";
}

r12 = "OPTIONS>";
}

if (title == "EFIS OPTIONS"){
titre = title;
tiret = "------------------------";
if (getprop("instrumentation/efis[0]/inputs/wxr") == 1){
l2 = "<WXR <SEL>";
}
else{
l2 = "<WXR";	
}
if (getprop("instrumentation/efis[0]/inputs/pos") == 1){
l4 = "<POS <SEL>";
}
else{
l4 = "<POS";	
}
l6 = "<MTRS <SEL>";
l10 = "<VOR";

if (getprop("instrumentation/efis[0]/inputs/wpt") == 1){
r2 = "<SEL> WPT>";
}
else{
r2 = "WPT>";	
}
if (getprop("instrumentation/efis[0]/inputs/sta") == 1){
r4 = "<SEL> STA>";
}
else{
r4 = "STA>";	
}
if (getprop("instrumentation/efis[0]/inputs/arpt") == 1){
r6 = "<SEL> ARPT>";
}
else{
r6 = "ARPT>";	
}
if (getprop("instrumentation/efis[0]/inputs/data") == 1){
r8 = "<SEL> DATA>";
}
else{
r8 = "DATA>";	
}
r10 = "ADF>";
r12 = "CONTROL>";
}

if (title == "PERF INIT"){
titre = title;
l1 = "GR WT ADV";
l2 = "###.#";
l3 = "FUEL";
l4 = "###.#";
sl4 = "           CALC";
}


if (title == "POS INIT"){
pagenum = getprop("instrumentation/cdu/page/current-page")~"/"~getprop("instrumentation/cdu/page/maxpage");
if (getprop("instrumentation/cdu/page/current-page") == 1){
titre = title;
tiret = "------------------------";
l3 = "REF AIRPORT";
if (getprop("instrumentation/cdu/page/POS-INIT/airport") == ""){
l4 = "----";
} else{
l4 = getprop("instrumentation/cdu/page/POS-INIT/airport");
}
l5 = "GATE";
if (getprop("instrumentation/cdu/page/POS-INIT/airport") == ""){
l6 = "";
} else{
l6 = "----";
}
l7 = "UTC (GPS)";
l8 = sprintf("%02.0f",getprop("instrumentation/clock/indicated-hour"))~""~sprintf("%02.0f",getprop("instrumentation/clock/indicated-min"));
sl8 = "      Z";
l9 = "SET HDG";
l10 = "---g";
l12 = "<INDEX";
r1 = "LAST POS";
r2 = LastREGISTEREDPOS;
var airport = getprop("instrumentation/cdu/page/POS-INIT/airport");
var info = airportinfo(airport);
if (airport != ""){
r4 = latdeg2dmm(info.lat)~" "~londeg2dmm(info.lon);
}
else {
r4 = "";
}
r7 = "GPS POS";
r8 = latdeg2dmm(getprop("position/latitude-deg"))~" "~londeg2dmm(getprop("position/longitude-deg"));
r9 = "SET IRS POS";
r10 = "###g##.# ####g##.#";
r12 = "ROUTE>";
tiret = "------------------------";
}

if (getprop("instrumentation/cdu/page/current-page") == 2){
l1 = "FMC POS "~"("~"GPS"~")";
l2 = latdeg2dmm(getprop("position/latitude-deg"))~" "~londeg2dmm(getprop("position/longitude-deg"));

var GroundS1 = 0;
var GroundS2 = 0;
var GroundS1L = 0;
var GroundS2L = 0;
if (rand() > 0.5){
GroundS1 = sprintf("%4.0f", (getprop("velocities/groundspeed-kt") + (2 * rand())));
GroundS2 = sprintf("%4.0f", (getprop("velocities/groundspeed-kt") + (2 * rand())));
}else{
GroundS1 = sprintf("%4.0f", (getprop("velocities/groundspeed-kt") - (2 * rand())));
GroundS2 = sprintf("%4.0f", (getprop("velocities/groundspeed-kt") - (2 * rand())));	
}


r1 = "GS";
r2 = GroundS1~"  ";
sr2 = "KT";
r4 = GroundS2~"  ";
sr4 = "KT";

# var timer = maketimer (2, func(){
# r5 = RadPosition();
# });
# timer.start();

# var UpdateGS = func(){
# GSTrue1 = sprintf("%4.0f", (getprop("velocities/groundspeed-kt") + (4 * rand())));
# GSTrue2 = sprintf("%4.0f", (getprop("velocities/groundspeed-kt") + (4 * rand())));
# Timing.restart(2);
# }

# var GSTrue1 = "";
# var GSTrue2 = "";
# Timing.start();
# var Timing = maketimer(2, UpdateGS);

}
}

if (title == "RTE 1"){

l12 = "<RTE 2";

if (getprop("autopilot/route-manager/active") != 1){
r12 = "ACTIVATE>";
}
else{
r12 = "PERF INIT>";
}

if(currentpage == 1){
routepage();
titre = title;
pagenum = currentpage~"/"~maxpage;
tiret = "";
bc7 = "------------------------";
l1 = "ORIGIN";
r1 = "DEST";
if (fp.departure != nil){
l2 = fp.departure.id;
}else{
l2 = "####";
}
if (fp.destination != nil){
r2 = fp.destination.id;
}else{
r2 = "####";
}
l3 = "RUNWAY";
r3 = "FLT NO";
if (fp.departure_runway != nil){
l4 = "RW"~fp.departure_runway.id;
}else{
l4 = "-----";
}
if (getprop("instrumentation/cdu/flt-no") != ""){
r4 = getprop("instrumentation/cdu/flt-no");
}else{
r4 = "--------";
}
l5 = "REQUEST";
l6 = "<SEND";
r5 = "CO ROUTE";
r6 = "----------";
}
else{
titre = "RTE 1";
pagenum = currentpage~"/"~maxpage;
r1 = "TO";
l1 = "VIA";
r2 = routepage()[0].id;
r4 = routepage()[1].id;
r6 = routepage()[2].id;
r8 = routepage()[3].id;
r10 = routepage()[4].id;
l2 = viacolumn()[0];
l4 = viacolumn()[1];
l6 = viacolumn()[2];
l8 = viacolumn()[3];
l10 = viacolumn()[4];
tiret = "------------------------";
}
}

if (title == "DEP/ARR INDEX"){
titre = title;
pagenum = "1/1";
tiret = "";
l2 = "<DEP";
r2 = "ARR>";
c1 = "RTE 1";
c2 = getprop("autopilot/route-manager/departure/airport");
c4 = getprop("autopilot/route-manager/destination/airport");
r4 = "ARR>";
r11 = "ARR";
c11 = "OTHER";
l11 = "DEP";
l12 = "<----";
r12 = "---->";
}

if(title == "DEPARTURES"){
titre = getprop("autopilot/route-manager/departure/airport")~" "~title;
pagenum = currentpage~"/"~maxpage;
r12 = "ROUTE>";
if(fp.sid_trans != nil or fp.sid != nil or getprop("autopilot/route-manager/departure/runway") != ""){
l12 = "<ERASE";
}else{
l12 = "<INDEX";
}
tiret = "------------------------";
if(fp.departure != nil){
r1 = "RUNWAYS";
if (getprop("autopilot/route-manager/departure/runway") == "" and fp.sid == nil){
r2 = rwys(getprop("autopilot/route-manager/departure/airport"))[0];
r4 = rwys(getprop("autopilot/route-manager/departure/airport"))[1];
r6 = rwys(getprop("autopilot/route-manager/departure/airport"))[2];
r8 = rwys(getprop("autopilot/route-manager/departure/airport"))[3];
r10 = rwys(getprop("autopilot/route-manager/departure/airport"))[4];
}else if(getprop("autopilot/route-manager/departure/runway") == ""){
r2 = rwysofsid()[0];
r4 = rwysofsid()[1];
r6 = rwysofsid()[2];
r8 = rwysofsid()[3];
r10 = rwysofsid()[4];
}else if(currentpage == 1){
r2 = "<SEL>"~addspace(getprop("autopilot/route-manager/departure/runway"),"left");
}
if(fp.sid == nil){
l1 = "SIDS";
l2 = sids()[0];
l4 = sids()[1];
l6 = sids()[2];
l8 = sids()[3];
l10 = sids()[4];
}else if(fp.sid_trans == nil){
if(currentpage == 1){
l1 = "SIDS";
l2 = addspace(fp.sid.id,"right")~"<SEL>";
l3 = "TRANS";
l4 = sidstrans(4)[0];
l6 = sidstrans(4)[1];
l8 = sidstrans(4)[2];
l10 = sidstrans(4)[3];
}else{
l1 = "TRANS";
l2 = sidstrans()[0];
l4 = sidstrans()[1];
l6 = sidstrans()[2];
l8 = sidstrans()[3];
l10 = sidstrans()[4];
}
}else if(currentpage == 1){
l3 = "TRANS";
l4 = addspace(fp.sid_trans.id,"right")~"<SEL>";
l1 = "SIDS";
l2 = addspace(fp.sid.id,"right")~"<SEL>";
}
}else{
l1 = "SIDS";
r1 = "RUNWAYS";
}
}

if(title == "DESTINATION"){
titre = getprop("autopilot/route-manager/destination/airport")~" ARRIVALS";
pagenum = currentpage~"/"~maxpage;
tiret = "------------------------";
var appnum = getprop("instrumentation/cdu/page/app/num");
r12 = "ROUTE>";
if(fp.star_trans != nil or fp.star != nil or fp.approach != nil or fp.destination_runway != nil){
l12 = "<ERASE";
}else{
l12 = "<INDEX";
}
if(fp.destination == nil){
l1 = "STARS";
r1 = "APPROACHES";
r3 = "RUNWAYS";
}else{
if(fp.star == nil){
l1 = "STARS";
l2 = stars()[0];
l4 = stars()[1];
l6 = stars()[2];
l8 = stars()[3];
l10 = stars()[4];
}else if(fp.star_trans == nil){
if(currentpage == 1){
l1 = "STARS";
l2 = addspace(fp.star.id,"right")~"<SEL>";
l3 = "TRANS";
l4 = starstrans(4)[0];
l6 = starstrans(4)[1];
l8 = starstrans(4)[2];
l10 = starstrans(4)[3];
}else{
l1 = "TRANS";
l2 = starstrans()[0];
l4 = starstrans()[1];
l6 = starstrans()[2];
l8 = starstrans()[3];
l10 = starstrans()[4];
}
}else if(currentpage == 1){
l1 = "STARS";
l2 = addspace(fp.star.id,"right")~"<SEL>";
l3 = "TRANS";
l4 = addspace(fp.star_trans.id,"right")~"<SEL>"
}
if(fp.approach == nil and fp.destination_runway == nil){
if(fp.star == nil){
if(currentpage <= getprop("instrumentation/cdu/page/app/maxpage")){
r1 = "APPROACHES";
r2 = approaches()[0];
r4 = approaches()[1];
r6 = approaches()[2];
r8 = approaches()[3];
r10 = approaches()[4];
if(appnum == 1){
r3 = "RUNWAYS";
r4 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[0];
r6 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[1];
r8 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[2];
r10 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[3];
}else if(appnum == 2){
r5 = "RUNWAYS";
r6 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[0];
r8 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[1];
r10 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[2];
}else if(appnum == 3){
r7 = "RUNWAYS";
r8 = rwys(getprop("autopilot/route-manager/destinatione/airport"), 1)[0];
r10 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[1];
}else if(appnum == 4){
r9 = "RUNWAYS";
r10 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[0];
}
}else{
r1 = "RUNWAYS";
r2 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[0];
r4 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[1];
r6 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[2];
r8 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[3];
r10 = rwys(getprop("autopilot/route-manager/destination/airport"), 1)[4];
}
}else if(fp.star != nil){
if(currentpage <= getprop("instrumentation/cdu/page/app/maxpage")){
r1 = "APPROACHES";
r2 = appsofrwy(getprop("instrumentation/cdu/page/current-page"))[0];
r4 = appsofrwy(getprop("instrumentation/cdu/page/current-page"))[1];
r6 = appsofrwy(getprop("instrumentation/cdu/page/current-page"))[2];
r8 = appsofrwy(getprop("instrumentation/cdu/page/current-page"))[3];
r10 = appsofrwy(getprop("instrumentation/cdu/page/current-page"))[4];
if(appnum == 1){
r3 = "RUNWAYS";
r4 = rwysofstar()[0];
r6 = rwysofstar()[1];
r8 = rwysofstar()[2];
r10 = rwysofstar()[3];
}else if(appnum == 2){
r5 = "RUNWAYS";
r6 = rwysofstar()[0];
r8 = rwysofstar()[1];
r10 = rwysofstar()[2];
}else if(appnum == 3){
r7 = "RUNWAYS";
r8 = rwysofstar()[0];
r10 = rwysofstar()[1];
}else if(appnum == 4){
r9 = "RUNWAYS";
r10 = rwysofstar()[0];
}
}else{
r1 = "RUNWAYS";
r2 = rwysofstar()[0];
r4 = rwysofstar()[1];
r6 = rwysofstar()[2];
r8 = rwysofstar()[3];
r10 = rwysofstar()[4];
}
}
}else if(fp.approach == nil){
r1 = "RUNWAYS";
r2 = "<SEL>"~addspace(fp.destination_runway.id, "left");
r4 = "VFR APPR>";
r5 = "RWY EXT";
sr6 = "--.-NM"
}else if(fp.approach != nil){
if(fp.approach_trans == nil){
if(currentpage == 1){
r1 = "APPROACHES";
r2 = "<SEL>"~addspace(fp.approach.id,"left");
r3 = "TRANS";
r4 = apptrans(4)[0];
r6 = apptrans(4)[1];
r8 = apptrans(4)[2];
r10 = apptrans(4)[3];
}else{
r1 = "TRANS";
r2 = apptrans()[0];
r4 = apptrans()[1];
r6 = apptrans()[2];
r8 = apptrans()[3];
r10 = apptrans()[4];
}
}else if(currentpage == 1){
r1 = "APPROACHES";
r2 = "<SEL>"~addspace(fp.approach.id,"left");
r3 = "TRANS";
r4 = "<SEL>"~addspace(fp.approach_trans.id,"left");
}
}
}
}

if(title == "rte choose waypoint"){
titre = "SELECT DESIRED WPT";
pagenum = currentpage~"/"~maxpage;
l1 = multiplewaypoint()[0].id;
if(l1 != " "){
if(contains(findNavaidsByID(l1),multiplewaypoint()[0])){
l2 = sprintf("%.2f", multiplewaypoint()[0].frequency / 100);
l1 = l1~" "~multiplewaypoint()[0].type;
}
r2 = latdeg2dmm(multiplewaypoint()[0].lat)~" "~londeg2dmm(multiplewaypoint()[0].lon);
}
l3 = multiplewaypoint()[1].id;
if(l3 != " "){
if(contains(findNavaidsByID(l3),multiplewaypoint()[1])){
l4 = sprintf("%.2f", multiplewaypoint()[1].frequency / 100);
l3 = l3~" "~multiplewaypoint()[1].type;
}
r4 = latdeg2dmm(multiplewaypoint()[1].lat)~" "~londeg2dmm(multiplewaypoint()[1].lon);
}
l5 = multiplewaypoint()[2].id;
if(l5 != " "){
if(contains(findNavaidsByID(l5),multiplewaypoint()[2])){
l6 = sprintf("%.2f", multiplewaypoint()[2].frequency / 100);
l5 = l5~" "~multiplewaypoint()[2].type;
}
r6 = latdeg2dmm(multiplewaypoint()[2].lat)~" "~londeg2dmm(multiplewaypoint()[2].lon);
}
l7 = multiplewaypoint()[3].id;
if(l7 != " "){
if(contains(findNavaidsByID(l7),multiplewaypoint()[3])){
l8 = sprintf("%.2f", multiplewaypoint()[3].frequency / 100);
l7 = l7~" "~multiplewaypoint()[3].type;
}
r8 = latdeg2dmm(multiplewaypoint()[3].lat)~" "~londeg2dmm(multiplewaypoint()[3].lon);
}
l9 = multiplewaypoint()[4].id;
if(l9 != " "){
if(contains(findNavaidsByID(l9),multiplewaypoint()[4])){
l10 = sprintf("%.2f", multiplewaypoint()[4].frequency / 100);
l9 = l9~" "~multiplewaypoint()[4].type;
}
r10 = latdeg2dmm(multiplewaypoint()[4].lat)~" "~londeg2dmm(multiplewaypoint()[4].lon);
}
}

if(title == "LEGS"){
titre = "ACT RTE 1 LEGS";
pagenum = currentpage~"/"~maxpage;
#wp names
l2=legspage("name")[0];
l4=legspage("name")[1];
l6=legspage("name")[2];
l8=legspage("name")[3];
l10=legspage("name")[4];
#wp bearing
l1 = legspage("bearing")[0];
l3 = legspage("bearing")[1];
l5 = legspage("bearing")[2];
l7 = legspage("bearing")[3];
l9 = legspage("bearing")[4];
#wp distance from prev wp
c1 = legspage("distance")[0];
c3 = legspage("distance")[1];
c5 = legspage("distance")[2];
c7 = legspage("distance")[3];
c9 = legspage("distance")[4];
#constraints
r2 = legspage("cstr")[0];
r4 = legspage("cstr")[1];
r6 = legspage("cstr")[2];
r8 = legspage("cstr")[3];
r10 = legspage("cstr")[4];
}

    setprop("/instrumentation/cdu/lines/l1", l1);
    setprop("/instrumentation/cdu/lines/l2", l2);
    setprop("/instrumentation/cdu/lines/l3", l3);
    setprop("/instrumentation/cdu/lines/l4", l4);
    setprop("/instrumentation/cdu/lines/l5", l5);
    setprop("/instrumentation/cdu/lines/l6", l6);
    setprop("/instrumentation/cdu/lines/l7", l7);
    setprop("/instrumentation/cdu/lines/l8", l8);
    setprop("/instrumentation/cdu/lines/l9", l9);
    setprop("/instrumentation/cdu/lines/l10", l10);
    setprop("/instrumentation/cdu/lines/l11", l11);
    setprop("/instrumentation/cdu/lines/l12", l12);
    setprop("/instrumentation/cdu/lines/small/l2", sl2);
    setprop("/instrumentation/cdu/lines/small/l4", sl4);
    setprop("/instrumentation/cdu/lines/small/l6", sl6);
    setprop("/instrumentation/cdu/lines/small/l8", sl8);
    setprop("/instrumentation/cdu/lines/small/l10", sl10);
    setprop("/instrumentation/cdu/lines/small/l12", sl12);
    setprop("/instrumentation/cdu/lines/big/l1", bl1);
    setprop("/instrumentation/cdu/lines/big/l3", bl3);
    setprop("/instrumentation/cdu/lines/big/l5", bl5);
    setprop("/instrumentation/cdu/lines/big/l7", bl7);
    setprop("/instrumentation/cdu/lines/big/l9", bl9);
    setprop("/instrumentation/cdu/lines/big/l11", bl11);
    setprop("/instrumentation/cdu/lines/c1", c1);
    setprop("/instrumentation/cdu/lines/c2", c2);
    setprop("/instrumentation/cdu/lines/c3", c3);
    setprop("/instrumentation/cdu/lines/c4", c4);
    setprop("/instrumentation/cdu/lines/c5", c5);
    setprop("/instrumentation/cdu/lines/c6", c6);
    setprop("/instrumentation/cdu/lines/c7", c7);
    setprop("/instrumentation/cdu/lines/c8", c8);
    setprop("/instrumentation/cdu/lines/c9", c9);
    setprop("/instrumentation/cdu/lines/c10", c10);
    setprop("/instrumentation/cdu/lines/c11", c11);
    setprop("/instrumentation/cdu/lines/c12", c12);
    setprop("/instrumentation/cdu/lines/small/c2", sc2);
    setprop("/instrumentation/cdu/lines/small/c4", sc4);
    setprop("/instrumentation/cdu/lines/small/c6", sc6);
    setprop("/instrumentation/cdu/lines/small/c8", sc8);
    setprop("/instrumentation/cdu/lines/small/c10", sc10);
    setprop("/instrumentation/cdu/lines/small/c12", sc12);
    setprop("/instrumentation/cdu/lines/big/c1", bc1);
    setprop("/instrumentation/cdu/lines/big/c3", bc3);
    setprop("/instrumentation/cdu/lines/big/c5", bc5);
    setprop("/instrumentation/cdu/lines/big/c7", bc7);
    setprop("/instrumentation/cdu/lines/big/c9", bc9);
    setprop("/instrumentation/cdu/lines/big/c11", bc11);
    setprop("/instrumentation/cdu/lines/r1", r1);
    setprop("/instrumentation/cdu/lines/r2", r2);
    setprop("/instrumentation/cdu/lines/r3", r3);
    setprop("/instrumentation/cdu/lines/r4", r4);
    setprop("/instrumentation/cdu/lines/r5", r5);
    setprop("/instrumentation/cdu/lines/r6", r6);
    setprop("/instrumentation/cdu/lines/r7", r7);
    setprop("/instrumentation/cdu/lines/r8", r8);
    setprop("/instrumentation/cdu/lines/r9", r9);
    setprop("/instrumentation/cdu/lines/r10", r10);
    setprop("/instrumentation/cdu/lines/r11", r11);
    setprop("/instrumentation/cdu/lines/r12", r12);
    setprop("/instrumentation/cdu/lines/small/r2", sr2);
    setprop("/instrumentation/cdu/lines/small/r4", sr4);
    setprop("/instrumentation/cdu/lines/small/r6", sr6);
    setprop("/instrumentation/cdu/lines/small/r8", sr8);
    setprop("/instrumentation/cdu/lines/small/r10", sr10);
    setprop("/instrumentation/cdu/lines/small/r12", sr12);
	setprop("/instrumentation/cdu/lines/big/r1", br1);
    setprop("/instrumentation/cdu/lines/big/r3", br3);
    setprop("/instrumentation/cdu/lines/big/r5", br5);
    setprop("/instrumentation/cdu/lines/big/r7", br7);
    setprop("/instrumentation/cdu/lines/big/r9", br9);
    setprop("/instrumentation/cdu/lines/big/r11", br11);
    setprop("/instrumentation/cdu/page/page-num", pagenum);
    setprop("/instrumentation/cdu/lines/tiret", tiret);
    setprop("/instrumentation/cdu/page/title", titre);
    settimer(cdu,0.1);
    }
setlistener("/sim/signals/fdm-initialized", cdu);
