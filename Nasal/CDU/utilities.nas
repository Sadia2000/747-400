var latdeg2dmm = func(deglatpos) {
var deg_int = int(deglatpos);
var decimal = (deglatpos - deg_int) * 60;
outputlatmin = decimal;
if(deglatpos < 0){
var nordsud = "S";
outputlatmin = -1 * (outputlatmin);
deg_int = -1 * (deg_int);
}else{
var nordsud = "N";
}
			var outputlatdeg = sprintf("%02.f",abs(deg_int));
var outputlat = nordsud~outputlatdeg~"g"~sprintf("%02.1f",outputlatmin);
return outputlat;
}



var londeg2dmm = func(deglonpos) {
var deg_int = int(deglonpos);
var decimal = (deglonpos - deg_int) * 60;
outputlonmin = decimal;
if(deglonpos < 0){
var estwest = "W";
outputlonmin = -1 * (outputlonmin);
deg_int = -1 * (deg_int);
}else{
var estwest = "E";
}
			var outputlondeg = sprintf("%02.f",abs(deg_int));
			
var outputlon = estwest~outputlondeg~"g"~sprintf("%02.1f",outputlonmin);
return outputlon;
}

var scratchpad = func(v) {
if(size(getprop("instrumentation/cdu/input")) < 24 and size(getprop("instrumentation/cdu/save/input")) < 24){
if(getprop("instrumentation/cdu/warnmessage") == 1){
clear();
}
setprop("instrumentation/cdu/input",getprop("instrumentation/cdu/input")~v);
}
}

var clear = func {
if (getprop("instrumentation/cdu/warnmessage") == 1){
setprop("/instrumentation/cdu/input", getprop("instrumentation/cdu/save/input"));
setprop("/instrumentation/cdu/warnmessage", 0);
setprop("instrumentation/cdu/deletekey", 0);
}else{
		var length = size(getprop("/instrumentation/cdu/input")) - 1;
		setprop("/instrumentation/cdu/input",substr(getprop("/instrumentation/cdu/input"),0,length));
	}
	}
	
var warnmessage = func(mes) {
setprop("instrumentation/cdu/warnmessage", 1);
setprop("instrumentation/cdu/save/input", getprop("instrumentation/cdu/input"));
setprop("instrumentation/cdu/input", mes);
update();
}

var sids = func {
var airport = airportinfo(getprop("autopilot/route-manager/departure/airport"));
var currentpage = getprop("instrumentation/cdu/page/current-page");
if(getprop("autopilot/route-manager/departure/runway") != ""){
var allsid = airport.sids(getprop("autopilot/route-manager/departure/runway"));
}else{
var allsid = airport.sids();
}
allsid = sort(allsid,func(a,b) cmp(a,b));
var sid = [];
var sidsnum = size(allsid);
pages = math.ceil(sidsnum / 5);
if(getprop("instrumentation/cdu/page/maxpage") < pages){
setprop("instrumentation/cdu/page/maxpage", pages);
}
var i = 0;
var count = (currentpage - 1) * 5;

while(i < 5){
if(count <= sidsnum-1){
append(sid, allsid[count]);
count = count + 1;
i = i + 1;
}else{
append(sid, "");
i = i + 1;
}
}

if(sidsnum != 0){
return sid;
}else{
if(currentpage == 1){
return ["-NONE-", "", "", "",""];
}else{
return ["", "", "", "", ""];
}
}
}

var stars = func {
var airport = airportinfo(getprop("autopilot/route-manager/destination/airport"));
var currentpage = getprop("instrumentation/cdu/page/current-page");
if(getprop("autopilot/route-manager/destination/runway") != ""){
var allstar = airport.stars(getprop("autopilot/route-manager/destination/runway"));
}else{
var allstar = airport.stars();
}
allstar = sort(allstar,func(a,b) cmp(a,b));
var star = [];
var starsnum = size(allstar);
pages = math.ceil(starsnum / 5);
if(getprop("instrumentation/cdu/page/maxpage") < pages){
setprop("instrumentation/cdu/page/maxpage", pages);
}
var i = 0;
var count = (currentpage - 1) * 5;

while(i <= 5){
if(count <= starsnum-1){
append(star, allstar[count]);
count = count + 1;
i = i + 1;
}else{
append(star, "");
i = i + 1;
}
}

if(starsnum != 0){
return star;
}else{
if(currentpage == 1){
return ["-NONE-", "", "", "",""];
}else{
return ["", "", "", "", ""];
}
}
}

var rwys = func(apt,star=0) {
var airport = airportinfo(apt);
var currentpage = getprop("instrumentation/cdu/page/current-page");
allrwys = keys(airport.runways);
var rwy = [];
var rwysnum = size(allrwys);
pages = math.ceil(rwysnum / 5);
if(getprop("instrumentation/cdu/page/maxpage") < pages){
setprop("instrumentation/cdu/page/maxpage", pages);
}
var i = 0;
if(star == 1 and currentpage > getprop("instrumentation/cdu/page/app/maxpage")){
var count = (currentpage - 1 - getprop("instrumentation/cdu/page/app/maxpage"))* 5+(5-getprop("instrumentation/cdu/page/app/num"));
}else{
var count = (currentpage - 1) * 5;
}

while(i < 5){
if(count <= rwysnum-1){
append(rwy, allrwys[count]);
count = count + 1;
i = i + 1;
}else{
append(rwy, "");
i = i + 1;
}
}
return rwy;
}

var approaches = func {
var airport = airportinfo(getprop("autopilot/route-manager/destination/airport"));
var currentpage = getprop("instrumentation/cdu/page/current-page");
var allrwys = airport.getApproachList();
allrwy = keys(airport.runways);
allrwys = sort(allrwys,func(a,b) cmp(a,b));
var rwy = [];
var rwysnum = size(allrwys);
var rwynum = size(allrwy);
pages = math.ceil((rwysnum + rwynum)/5);
page = math.ceil(rwysnum/5);
if(getprop("instrumentation/cdu/page/maxpage") < pages){
setprop("instrumentation/cdu/page/maxpage", pages);
}
setprop("instrumentation/cdu/page/app/maxpage", page);
var i = 0;
var count = (currentpage - 1) * 5;
var appnum = 0;

while(i < 5){
if(count <= rwysnum-1){
append(rwy, allrwys[count]);
appnum = appnum + 1;
count = count + 1;
i = i + 1;
}else{
append(rwy, "");
i = i + 1;
}
}
if(rwysnum != 0){
if(currentpage > pages){
setprop("instrumentation/cdu/page/app/num", 0);
}else{
if(appnum > getprop("instrumentation/cdu/page/app/num")){
setprop("instrumentation/cdu/page/app/num", appnum);
}
}
return rwy;
}else{
setprop("instrumentation/cdu/page/app/maxpage", 1);
if(currentpage == 1){
setprop("instrumentation/cdu/page/app/num", 1);
return ["-NONE-", "", "", "",""];
}else{
setprop("instrumentation/cdu/page/app/num", 0);
return ["", "", "", "", ""];
}
}
}

var rwysofsid = func {
currentpage = getprop("instrumentation/cdu/page/current-page");
var airport = airportinfo(getprop("autopilot/route-manager/departure/airport"));
var selsid = getprop("autopilot/route-manager/departure/sid");
var allrwys = keys(airport.runways);
allrwys = sort(allrwys,func(a,b) cmp(a,b));
result = [];
foreach(var i; allrwys){
allsids = airport.sids(i);
foreach(var f; allsids){
if(f == selsid){
append(result, i);
}
}
}
while(size(result) < (currentpage-1)*5+5){
append(result, "");
}
pages = math.ceil(size(result) / 5);
if(pages > getprop("instrumentation/cdu/page/maxpage")){
setprop("instrumentation/cdu/page/maxpage", pages);
}
returned = [];
m = 0;
count = (currentpage-1)*5;
while(m < 5){
l8 = result[count];
append(returned, l8);
m = m + 1;
count = count + 1;
}
return returned;
}

var rwysofstar = func {
var currentpage = getprop("instrumentation/cdu/page/current-page");
var apppage = getprop("instrumentation/cdu/page/app/maxpage");
var airport = airportinfo(getprop("autopilot/route-manager/destination/airport"));
var selstar = getprop("autopilot/route-manager/destination/star");
var allrwys = keys(airport.runways);
allrwys = sort(allrwys,func(a,b) cmp(a,b));
var result = [];
foreach(var i; allrwys){
allstars = airport.stars(i);
foreach(var f; allstars){
if(f == selstar){
append(result, i);
}
}
}
while(size(result) < (currentpage-apppage-1)*5+5+(5-getprop("instrumentation/cdu/page/app/num"))){
append(result, "");
}
returned = [];
m = 0;
count = (currentpage-apppage-1)*5+(5-getprop("instrumentation/cdu/page/app/num"));
while(m < 5){
l8 = result[count];
append(returned, l8);
m = m + 1;
count = count + 1;
}
return returned;
}

var appsofrwy = func(currentpage) {
var apt = airportinfo(getprop("autopilot/route-manager/destination/airport"));
var app = [];
var selstar = getprop("autopilot/route-manager/destination/star");
var allrwys = keys(apt.runways);
allrwys = sort(allrwys,func(a,b) cmp(a,b));
foreach(var i; allrwys){
allstars = apt.stars(i);
foreach(var f; allstars){
if(f == selstar){
append(app, i);
}
}
}
var result = [];
foreach(var j; app){
l4 = apt.getApproachList(j);
foreach(var f; l4){
append(result, f);
}
}
pages = math.ceil((size(result) + size(app))/5);
result = sort(result,func(a,b) cmp(a,b));
var current = (currentpage-1)*5+5;
while(size(result) < current){
append(result, "");
}
page = math.ceil(size(result) / 5);
if(pages > getprop("instrumentation/cdu/page/maxpage")){
setprop("instrumentation/cdu/page/maxpage", pages);
}
if(result[0] == ""){
if(currentpage == 1){
setprop("instrumentation/cdu/page/app/maxpage", 1);
return ["-NONE-", "", "", "",""];
die();
}else{
setprop("instrumentation/cdu/page/app/maxpage", 0);
return ["", "", "", "", ""];
die();
}
}
setprop("instrumentation/cdu/page/app/maxpage", page);
var count = (currentpage-1)*5;
var appnum = 0;
var m = 0;
var returned = [];
while(m < 5){
l8 = result[count];
append(returned, l8);
m = m + 1;
count = count + 1;
if(l8 != ""){
appnum = appnum + 1;
}
}
setprop("instrumentation/cdu/page/app/num", appnum);
return returned;
}

var sidstrans = func(max=5) {
var airport = airportinfo(getprop("autopilot/route-manager/departure/airport"));
var activesid = getprop("autopilot/route-manager/departure/sid");
var currentpage = getprop("instrumentation/cdu/page/current-page");
var sidtrans = [];
var i = 0;
var alltrans = airport.getSid(activesid).transitions;
alltrans = sort(alltrans,func(a,b) cmp(a,b));
var transnum = size(alltrans);
var transnumdivided = transnum / ((4+5)/2);
var notdecimalverofit = sprintf("%i", transnumdivided);
if(transnumdivided != notdecimalverofit){
pages = sprintf("%i", transnum / ((4+5)/2)) + 1;
}else{
pages = sprintf("%i", transnum / ((4+5)/2));
}
if(getprop("instrumentation/cdu/page/maxpage") < pages){
setprop("instrumentation/cdu/page/maxpage", pages);
}
var i = 0;
if(currentpage < 3){
var count = (currentpage - 1) * 4;
}else{
var count = ((currentpage - 1) * 5)-1;
}

while(i < max){
if(count <= transnum-1){
append(sidtrans, alltrans[count]);
count = count + 1;
i = i + 1;
}else{
append(sidtrans, "");
i = i + 1;
}
}
if(transnum != 0){
return sidtrans;
}else{
if(max == 4){
return ["-NONE-", "", "", ""];
}else{
return ["", "", "", "", ""];
}
}
}

var starstrans = func(max=5) {
var airport = airportinfo(getprop("autopilot/route-manager/destination/airport"));
var activestar = getprop("autopilot/route-manager/destination/star");
var currentpage = getprop("instrumentation/cdu/page/current-page");
var startrans = [];
var i = 0;
var alltrans = airport.getStar(activestar).transitions;
alltrans = sort(alltrans,func(a,b) cmp(a,b));
var transnum = size(alltrans);
var transnumdivided = transnum / ((4+5)/2);
var notdecimalverofit = sprintf("%i", transnumdivided);
if(transnumdivided != notdecimalverofit){
pages = sprintf("%i", transnum / ((4+5)/2)) + 1;
}else{
pages = sprintf("%i", transnum / ((4+5)/2));
}
if(getprop("instrumentation/cdu/page/maxpage") < pages){
setprop("instrumentation/cdu/page/maxpage", pages);
}
var i = 0;
if(currentpage < 3){
var count = (currentpage - 1) * 4;
}else{
var count = ((currentpage - 1) * 5)-1;
}

while(i < max){
if(count <= transnum-1){
append(startrans, alltrans[count]);
count = count + 1;
i = i + 1;
}else{
append(startrans, "");
i = i + 1;
}
}
if(transnum != 0){
return startrans;
}else{
if(max == 4){
return ["-NONE-", "", "", ""];
}else{
return ["", "", "", "", ""];
}
}
}

var apptrans = func(max=5) {
var fp = flightplan();
var activeiap = fp.approach;
var currentpage = getprop("instrumentation/cdu/page/current-page");
var apptrans = [];
var i = 0;
var alltrans = activeiap.transitions;
alltrans = sort(alltrans,func(a,b) cmp(a,b));
var transnum = size(alltrans);
var transnumdivided = transnum / ((4+5)/2);
var notdecimalverofit = sprintf("%i", transnumdivided);
if(transnumdivided != notdecimalverofit){
pages = sprintf("%i", transnum / ((4+5)/2)) + 1;
}else{
pages = sprintf("%i", transnum / ((4+5)/2));
}
if(getprop("instrumentation/cdu/page/maxpage") < pages){
setprop("instrumentation/cdu/page/maxpage", pages);
}
var i = 0;
if(currentpage < 3){
var count = (currentpage - 1) * 4;
}else{
var count = ((currentpage - 1) * 5)-1;
}

while(i < max){
if(count <= transnum-1){
append(apptrans, alltrans[count]);
count = count + 1;
i = i + 1;
}else{
append(apptrans, "");
i = i + 1;
}
}
if(transnum != 0){
return apptrans;
}else{
if(max == 4){
return ["-NONE-", "", "", ""];
}else{
return ["", "", "", "", ""];
}
}
}

var routepage = func(joe=0) {
var currentpage = getprop("instrumentation/cdu/page/current-page");
fp = flightplan();
var amogusamog = 0;
wpafterdest = [];
setprop("instrumentation/cdu/page/RTE/missedapp",0);
wptype = [];
if(fp.destination != nil){
if(fp.destination_runway != nil){
sec = fp.clone();
sec.star = nil;
sec.star_trans = nil;
sec.approach = nil;
sec.approach_trans = nil;
susmogus = sec.getWP(sec.getPlanSize()-1);
destwp = createWP(susmogus.lat, susmogus.lon, susmogus.id);
}else{
destwp = fp.destination;
}
destindex = fp.indexOfWP(destwp) + 1;
setprop("instrumentation/cdu/page/RTE/destwp", "-1");
while(destindex < fp.getPlanSize()){
	if(fp.getWP(destindex).wp_role == "missed" and (destindex == fp.getPlanSize()-1 or fp.getWP(fp.getPlanSize()-1).wp_role != "missed")){
		var amogusamog = 1;
		setprop("instrumentation/cdu/page/RTE/destwp", destindex);
		var baka = fp.getWP(destindex);
	}else if(fp.getWP(destindex).wp_role != "missed"){
		wpamog = fp.getWP(destindex);
append(wpafterdest, wpamog);
	}
destindex = destindex + 1;
setprop("instrumentation/cdu/page/RTE/missedapp",1);
}
}
var pos = geo.aircraft_position().apply_course_distance(getprop("/orientation/heading-deg"), 100000);
nextwp = createWP(pos.lat(),pos.lon(), "----");
if(fp.sid == nil){
sid = nextwp;
if(fp.departure == nil){
indexsid = 0;
}else{
indexsid = 1;
}
}else{
sid = fp.getWP(size(fp.sid.route(fp.sid_trans)));
indexsid = fp.indexOfWP(sid) + 1;
}
wpbeforestar = [];
append(wpbeforestar,sid);
		append(wptype, "sid");
if(fp.star != nil){
indexstar = fp.indexOfWP(fp.star.route(fp.star_trans)[0]);
}else if(fp.approach != nil){
indexstar = fp.indexOfWP(fp.approach.route(fp.approach_trans)[0]);
}else{
if(fp.destination == nil){
indexstar = fp.getPlanSize();
}else{
indexstar = fp.getPlanSize()-1;
}
}
while(indexsid < indexstar){
	wpmogus = fp.getWP(indexsid);
		append(wptype, "normal");
append(wpbeforestar, wpmogus);
indexsid = indexsid + 1;
}
var wpnum = size(wpbeforestar);
setprop("instrumentation/cdu/page/RTE/firststarwp", 9999);
setprop("instrumentation/cdu/page/RTE/laststarwp", 9999);
if(fp.star != nil){
starroute = fp.star.route();
var starwp = createWP(pos.lat(),pos.lon(),starroute[size(starroute)-1].id);
		append(wptype, "star");
if(getprop("instrumentation/cdu/page/RTE/firststarwp") == 9999){
setprop("instrumentation/cdu/page/RTE/firststarwp", wpnum);
}
setprop("instrumentation/cdu/page/RTE/laststarwp", wpnum);
append(wpbeforestar, starwp);
}
var wpnum = size(wpbeforestar);
if(fp.approach_trans != nil){
approute = fp.approach.route(fp.approach_trans);
approutetwo = fp.approach.route();
approutetrue = [];
mogusus = 0;
foreach(var mogu; approute){
	if(mogu != approutetwo[mogusus]){
		append(approutetrue, mogu);
	}
}
var apptranswp = createWP(pos.lat(),pos.lon(),approutetrue[size(approutetrue)-1].id);
		append(wptype, "approachtrans");
if(getprop("instrumentation/cdu/page/RTE/firststarwp") == 9999){
setprop("instrumentation/cdu/page/RTE/firststarwp", wpnum);
}
setprop("instrumentation/cdu/page/RTE/laststarwp", wpnum);
append(wpbeforestar, apptranswp);
}
var wpnum = size(wpbeforestar);
if(fp.destination_runway != nil){
var destrwy = createWP(pos.lat(),pos.lon(),"RW"~fp.destination_runway.id);
		append(wptype, "approach");
if(getprop("instrumentation/cdu/page/RTE/firststarwp") == 9999){
setprop("instrumentation/cdu/page/RTE/firststarwp", wpnum);
}
setprop("instrumentation/cdu/page/RTE/laststarwp", wpnum);
append(wpbeforestar, destrwy);
}
var wpnum = size(wpbeforestar);
if(amogusamog == 1){
	if(getprop("instrumentation/cdu/page/RTE/firststarwp") == 9999){
setprop("instrumentation/cdu/page/RTE/firststarwp", wpnum);
}
setprop("instrumentation/cdu/page/RTE/laststarwp", wpnum);
setprop("instrumentation/cdu/page/RTE/missedapp",1);
		append(wptype, "missed");
append(wpbeforestar, baka);
}

var wpnum = size(wpbeforestar);
var i = 0;
wpdivfive = wpnum / 5;
var wpnbr = math.ceil(wpdivfive);
conte = (currentpage - 3);
var route = [];
var t = 0;
	while(t < size(wpafterdest)){
append(wpbeforestar, wpafterdest[t]);
		append(wptype, "normal");
t = t + 1;
}
var wpnum = size(wpbeforestar);
if(wpnum > 1 or fp.sid != nil){
			append(wptype, "----");
append(wpbeforestar,nextwp);
}
if(joe == 1){
return wpbeforestar;
}else if(joe == 2){
	return wptype;
}else{
var wpnum = size(wpbeforestar);
pages = math.ceil(wpnum / 5);
if(pages == 0){
pages = pages + 2;
}else{
pages = pages + 1;
}
if(pages > getprop("instrumentation/cdu/page/maxpage")){
setprop("instrumentation/cdu/page/maxpage", pages);
}
if(currentpage != 1){
var count = (currentpage - 2) * 5;
}else{
count = 0;
}
while(i < 5){
if(count <= wpnum-1){
append(route, wpbeforestar[count].id);
count = count + 1;
i = i + 1;
}else{
append(route, "");
i = i + 1;
}
}
}
return route;
}

var viacolumn = func {
var currentpage = getprop("instrumentation/cdu/page/current-page");
fp = flightplan();
var pos = geo.aircraft_position().apply_course_distance(getprop("/orientation/heading-deg"), 100000);
viacolone = [];
wpnum = size(viacolone);
routepag = routepage(1);
wptype = routepage(2);
i = 0;
foreach(var amog; routepag){
	if(wptype[i] == "normal"){
	if(i == 1 and fp.departure_runway == nil){
		append(viacolone, "----");		
	}else{
		append(viacolone, "DIRECT");	
}		
}else if(wptype[i] == "sid"){
	if(fp.sid != nil){
		if(fp.sid_trans != nil){
			sid = fp.sid.id~"."~fp.sid_trans.id;
		}else{
			sid = fp.sid.id;
		}
	}else{
		sid = "----";
	}
		append(viacolone, sid);
	}else if(wptype[i] == "star"){
		if(fp.sid_trans != nil){
			star = fp.star.id~"."~fp.star_trans.id;
		}else{
			star = fp.star.id;
		}
		append(viacolone, star);		
	}else if(wptype[i] == "approachtrans"){
		append(viacolone, "APP TRANS");
	}else if(wptype[i] == "approach"){
	if(fp.approach != nil){
		iap = fp.approach.id;
	}else{
		iap = "----";	
	}
		append(viacolone, iap);
	}else if(wptype[i] == "missed"){
		append(viacolone, "MISSED APPR");
	}else if(wptype[i] == "----"){
		append(viacolone, "----");
	}
	i = i + 1;
}
wpnum = size(viacolone);
var count = (currentpage - 2) * 5;
var j = 0;
var via = [];
while(j < 5){
if(count <= wpnum-1){
append(via, viacolone[count]);
count = count + 1;
j = j + 1;
}else{
append(via, "");
j = j + 1;
}
}
return via;
}

var small = func(num, val) {
var result = "";
for(var i = 0; i < size(num)+math.ceil(size(num)/2); i+=1){
result = result~" ";
}
result = result~val;
return result;
}

var nextpage = func {
if(getprop("instrumentation/cdu/page/current-page") < getprop("instrumentation/cdu/page/maxpage")){
setprop("instrumentation/cdu/page/current-page", getprop("instrumentation/cdu/page/current-page") + 1);
update();
}
}

var prevpage = func {
if(getprop("instrumentation/cdu/page/current-page") > 1){
setprop("instrumentation/cdu/page/current-page", getprop("instrumentation/cdu/page/current-page") - 1);
update();
}
}

var newpage = func(title) {
setprop("/instrumentation/cdu/page/current-page", 1);
setprop("/instrumentation/cdu/page/maxpage", 1);
setprop("instrumentation/cdu/save/title", title);
setprop("instrumentation/cdu/update", 1);
settimer(func {
setprop("instrumentation/cdu/update", 0);
}, 0.4);
}

var resettrans = func {
fp = flightplan();
     fp.sid_trans = nil;
}

var resetstrans = func {
fp = flightplan();
     fp.star_trans = nil;
}

var resetatrans = func {
fp = flightplan();
     fp.approach_trans = nil;
}

var erasesidpage = func{
fp = flightplan();
setprop("instrumentation/cdu/save/dep", fp.departure.id);
fp.sid = nil;
fp.sid_trans = nil;
fp.departure = nil;
fp.departure = airportinfo(getprop("instrumentation/cdu/save/dep"));
}

var erasestarpage = func{
fp = flightplan();
setprop("instrumentation/cdu/save/dest", fp.destination.id);
fp.star = nil;
fp.star_trans = nil;
fp.destination = nil;
fp.destination = airportinfo(getprop("instrumentation/cdu/save/dest"));
}

findinput = func (input, type="all",num=0){
if(type == "airport"){
var apts = findAirportsByICAO(input);
if(size(apts) != 1){
warnmessage("NOT IN DATA BASE");
die();
}else{
resetinput();
return airportinfo(input);
}
}

if(type == "runway"){
fp = flightplan();
airport = fp.departure;
if(size(input) <= 3){
rwy = airport.runway(input);
if(rwy == nil){
warnmessage("NOT IN DATA BASE");
die();
}else{
resetinput();
return rwy;
die();
}
}else{
	waluigi = substr(input,2);
	rwy = airport.runway(waluigi);
	if(rwy == nil){
warnmessage("NOT IN DATA BASE");
die();
}else{
resetinput();
return rwy;
die();
}
}
}

if(type == "all"){
var apts = findAirportsByICAO(input);
var fixes = findFixesByID(input);
var navs = findNavaidsByID(input);
var wario = 0;
if(size(apts) == 1){
resetinput();
return airportinfo(input);
die();
}else if(size(fixes) == 1){
resetinput();
return fixes[0];
}else if(size(fixes) > 1){
resetinput();
			            setprop("instrumentation/cdu/page/RTE/currentpage", getprop("instrumentation/cdu/page/current-page"));
						setprop("instrumentation/cdu/page/RTE/input", input);
						setprop("instrumentation/cdu/page/RTE/num", num);
									newpage("rte choose waypoint");
var pos = geo.aircraft_position().apply_course_distance(getprop("/orientation/heading-deg"), 100000);
var newwpreturn = createWP(pos.lat(),pos.lon(),"notavail");
return newwpreturn;
}else if(size(navs) == 1){
resetinput();
return navs[0];
}else if(size(navs) > 1){
resetinput();
			            setprop("instrumentation/cdu/page/RTE/currentpage", getprop("instrumentation/cdu/page/current-page"));
						setprop("instrumentation/cdu/page/RTE/input", input);
						setprop("instrumentation/cdu/page/RTE/num", num);
			newpage("rte choose waypoint");
var pos = geo.aircraft_position().apply_course_distance(getprop("/orientation/heading-deg"), 100000);
var newwpreturn = createWP(pos.lat(),pos.lon(),"notavail");
return newwpreturn;
		
}else{
warnmessage("NOT IN DATA BASE");
die();
}
}
}


var multiplewaypoint = func(returninfo=""){
	input = getprop("instrumentation/cdu/page/RTE/input");
	var fixes = findFixesByID(input);
	var navs = findNavaidsByID(input);
	var allwp = [];	
foreach(var i; fixes){
	append(allwp, i);
}
foreach(var f; navs){
	append(allwp, f);
}
currentpage = getprop("instrumentation/cdu/page/current-page");
maxpage = math.ceil(size(allwp)/5);
setprop("instrumentation/cdu/page/maxpage", maxpage);
amogussus = [];
amogus = (currentpage-1)*5;
if(returninfo == "frequency"){
while(size(amogussus) < 5){
if(amogus < size(allwp) and allwp[amogus].type != "fix" and allwp[amogus].type != "glideslope"){
append(amogussus, sprintf("%.1f",allwp[amogus].frequency * 0.01));
}else{
append(amogussus, "    ");
}
amogus = amogus + 1;
}
}else if(returninfo == "type"){
while(size(amogussus) < 5){
if(amogus < size(allwp) and allwp[amogus].type != "fix" and allwp[amogus].type != "glideslope"){
append(amogussus, allwp[amogus].type);
}else{
append(amogussus, "");
}
amogus = amogus + 1;
}
}else if(returninfo == "lon"){
while(size(amogussus) < 5){
if(amogus < size(allwp)){
append(amogussus, londeg2dmm(allwp[amogus].lon));
}else{
append(amogussus, "");
}
amogus = amogus + 1;
}
}else if(returninfo == "lat"){
while(size(amogussus) < 5){
if(amogus < size(allwp)){
append(amogussus, latdeg2dmm(allwp[amogus].lat));
}else{
append(amogussus, "");
}
amogus = amogus + 1;
}
}else{
while(size(amogussus) < 5){
if(amogus < size(allwp)){
append(amogussus, allwp[amogus]);
}else{
append(amogussus, "");
}
amogus = amogus + 1;
}
}
	return amogussus;
}

multiplewaypointid = func(){
var allwp = multiplewaypoint();
var wplist = [];
currentpage = getprop("instrumentation/cdu/page/current-page");
amogus = 0;
while(size(wplist) < 5){
if(allwp[amogus] == ""){
append(wplist, "");
}else{
append(wplist, allwp[amogus].id);
}
amogus = amogus + 1;
}
	return wplist;
}

var resetinput = func {
setprop("instrumentation/cdu/input", "");
update();
}

var insertinroute = func(input,num) {
fp = flightplan();
var currentpage = getprop("instrumentation/cdu/page/current-page");
if(num+((currentpage-2)*5) <= size(routepage(1))){
if(num == 1 and currentpage == 2 and fp.sid == nil and fp.departure == nil){
num = 0;
}
if((fp.sid != nil and num == 0 and currentpage == 2 )or (fp.departure != nil and num == 0)){
num = 1;
}
wp = findinput(input,"all",num);
if(wp.id == input){
sec = fp.clone();
sec.cleanPlan();
sec.departure = nil;
if(fp.sid != nil){
sid = size(fp.sid.route(fp.sid_trans));
}else{
sid = 0;
}
i = (currentpage-2)*5;
laststarwp = getprop("instrumentation/cdu/page/RTE/laststarwp");
firststarwp = getprop("instrumentation/cdu/page/RTE/firststarwp");

if(fp.destination != nil){
	if(getprop("instrumentation/cdu/page/RTE/destwp") == "-1"){
if(fp.destination_runway != nil){
susmogus = sec.getWP(sec.getPlanSize()-1);
destwp = createWP(susmogus.lat, susmogus.lon, susmogus.id);
}else{
destwp = fp.destination;
}

if(getprop("instrumentation/cdu/page/RTE/missedapp") == 1){
destwp = fp.indexOfWP(destwp);
}else{
destwp = fp.indexOfWP(destwp)+1;
}

	}else{
		destwp = getprop("instrumentation/cdu/page/RTE/destwp")+1;
	}
}
numi = num + i;
index = "not avail";
setprop("instrumentation/amogus/amogus",index);
setprop("instrumentation/amogus/num",num);
if(numi > laststarwp and fp.destination != nil){
wp = findinput(input,"all",num);
if(wp.id == input){
index = destwp + (numi - (laststarwp + 1));
setprop("instrumentation/amogus/amogus",index);
}
}else if(numi <= firststarwp){
	wp = findinput(input,"all",num);
	if(wp.id == input){
index = sid + i + num;
setprop("instrumentation/amogus/amogus",index);
	}
}else{
warnmessage("NOT ALLOWED");
die();
}
if(index != "not avail"){
wpinsert = createWP(wp.lat, wp.lon, wp.id);
fp.insertWP(wpinsert, index);
resetinput();
}
}
}
}

var multipleinsertinroute = func(input,num) {
fp = flightplan();
var currentpage = getprop("instrumentation/cdu/page/RTE/currentpage");
sec = fp.clone();
sec.cleanPlan();
sec.departure = nil;
if(fp.sid != nil){
sid = size(fp.sid.route(fp.sid_trans));
}else{
sid = 0;
}
i = (currentpage-2)*5;
laststarwp = getprop("instrumentation/cdu/page/RTE/laststarwp");
firststarwp = getprop("instrumentation/cdu/page/RTE/firststarwp");

if(fp.destination != nil){
	if(getprop("instrumentation/cdu/page/RTE/destwp") == "-1"){
if(fp.destination_runway != nil){
susmogus = sec.getWP(sec.getPlanSize()-1);
destwp = createWP(susmogus.lat, susmogus.lon, susmogus.id);
}else{
destwp = fp.destination;
}

if(getprop("instrumentation/cdu/page/RTE/missedapp") == 1){
destwp = fp.indexOfWP(destwp);
}else{
destwp = fp.indexOfWP(destwp)+1;
}

	}else{
		destwp = getprop("instrumentation/cdu/page/RTE/destwp")+1;
	}
}
numi = num + i;
index = "not avail";
setprop("instrumentation/amogus/amogus",index);
setprop("instrumentation/amogus/num",num);
if(numi > laststarwp and fp.destination != nil){
index = destwp + (numi - (laststarwp + 1));
setprop("instrumentation/amogus/amogus",index);
}else if(numi <= firststarwp){
index = sid + i + num;
setprop("instrumentation/amogus/amogus",index);
}else{
warnmessage("NOT ALLOWED");
die();
}
wpinsert = createWP(input.lat,input.lon,input.id);
if(index == "notavail")
fp.insertWP(wpinsert, index);
newpage("RTE 1");
setprop("instrumentation/cdu/page/current-page", currentpage);
}

var update = func {
setprop("instrumentation/cdu/update", 1);
settimer(func {
setprop("instrumentation/cdu/update", 0);
}, 0.4);
}

var deletekeypress = func(){
resetinput();
warnmessage("DELETE");
setprop("instrumentation/cdu/deletekey", 1);
}

var deletewayp = func(num){
num = num+(getprop("instrumentation/cdu/page/current-page")-2)*5;
fp = flightplan();
sec = fp.clone();
sec.cleanPlan();
sec.departure = nil;
if(fp.sid != nil){
sid = size(fp.sid.route(fp.sid_trans));
}else{
sid = 0;
}
laststarwp = getprop("instrumentation/cdu/page/RTE/laststarwp");
firststarwp = getprop("instrumentation/cdu/page/RTE/firststarwp");
if(fp.destination != nil){
	if(getprop("instrumentation/cdu/page/RTE/destwp") == "-1"){
if(fp.destination_runway != nil){
susmogus = sec.getWP(sec.getPlanSize()-1);
destwp = createWP(susmogus.lat, susmogus.lon, susmogus.id);
}else{
destwp = fp.destination;
}

if(getprop("instrumentation/cdu/page/RTE/missedapp") == 1){
destwp = fp.indexOfWP(destwp);
}else{
destwp = fp.indexOfWP(destwp)+1;
}

	}else{
		destwp = getprop("instrumentation/cdu/page/RTE/destwp");
	}
}
if(num < size(routepage(1))-1 and num > 0 and (num < firststarwp or num > laststarwp)){
if(num > laststarwp and fp.destination != nil){
index = destwp + (num - (laststarwp + 1)) + 1;
}else if(num <= firststarwp){
if(fp.departure == nil and num == 1){
index = sid + (num-1);
}else{
index = sid + num;
}
}else{
die();
}
resetinput();
setprop("instrumentation/cdu/deletekey", 0);
fp.deleteWP(index);
update();
clear();
}
}

var addspace = func(input,side){
if(side == "right"){
while(size(input) < 7){
input = input~" ";
}
}else if(side == "left"){
while(size(input) < 7){
input = " "~input;
}
}
return input;
}
