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

var routepage = func(returntype="display") {
var currentpage = getprop("instrumentation/cdu/page/current-page");
fp = flightplan();
clone = fp.clone();
clone.sid = nil;
clone.sid_trans = nil;
clone.star = nil;
clone.star_trans = nil;
clone.departure = nil;
clone.destination = nil;
var pos = geo.aircraft_position().apply_course_distance(getprop("/orientation/heading-deg"), 1000);
dash = createWP(pos, "----");
void = createWP(pos, "");
if(fp.sid != nil){
sid = createWP(pos, fp.sid.route(fp.sid_trans)[size(fp.sid.route(fp.sid_trans))-1].id, "sid");
clone.insertWP(sid,0);
}else if(clone.getPlanSize() > 0){
clone.insertWP(dash,0);
}
if(fp.star != nil){
star = createWP(pos, fp.star.route(fp.star_trans)[size(fp.star.route(fp.star_trans))-1].id, "star");
clone.appendWP(star);
}
if(fp.approach_trans != nil){
app = fp.indexOfWP(fp.approach.route()[0]);
appwtrans = fp.indexOfWP(fp.approach.route(fp.approach_trans)[0]);
index = app-appwtrans;
apptrans = [];
for(var i=0; i < index; i+=1){
append(apptrans, fp.approach.route(fp.approach_trans)[i]);
}
if(size(apptrans) > 0){
apptrans = createWP(apptrans[size(apptrans)-1], apptrans[size(apptrans)-1].id, "approach");
clone.appendWP(apptrans);
}
}
if(fp.destination_runway != nil){
destrwy = createWP(pos, "RW"~fp.destination_runway.id);
clone.appendWP(destrwy);
if(fp.indexOfWP(fp.destination_runway) < fp.getPlanSize()-1){
missed=[];
wpafter = [];
for (i=fp.indexOfWP(fp.destination_runway)+1; i < fp.getPlanSize(); i+=1){
if(fp.getWP(i).wp_role != "missed"){
append(wpafter, fp.getWP(i));
fpclonewp = createWP(fp.getWP(i), fp.getWP(i).id);
clone.deleteWP(clone.indexOfWP(fpclonewp));
}else{
append(missed, fp.getWP(i));
}
}
if(size(missed) > 0){
missedapp = createWP(pos, missed[size(missed)-1].id, "missed");
clone.appendWP(missedapp);
}
foreach(var wpfromdest; wpafter){
clone.appendWP(wpfromdest);
}
}
}
allwp = [];
for(var i=0; i < clone.getPlanSize(); i=i+1){
append(allwp,clone.getWP(i));
}
append(allwp, dash);
wpdisplay = [];
var maxpage = math.ceil(size(allwp) / 5);
setprop("instrumentation/cdu/page/maxpage", maxpage+1);
var firstwpnum = 5 * (currentpage-2);
if(firstwpnum < 0){
firstwpnum = 0;
}
for (var i=firstwpnum; i < firstwpnum+5; i=i+1){
if(i == size(allwp)){
break;
}
append(wpdisplay, allwp[i]);
}
while(size(wpdisplay) < 5){
append(wpdisplay, void);
}
if(returntype == "display"){
return wpdisplay;
}else{
return allwp;
}
}

var viacolumn = func (){
fp = flightplan();
via = [];
route = routepage();
currentpage = getprop("instrumentation/cdu/page/RTE/currentpage");
i = 0;
while(i < 5){
if(route[i].wp_role == "sid"){
if(fp.sid_trans != nil){
append(via, fp.sid.id~"."~fp.sid_trans.id);
}else{
append(via, fp.sid.id);
}
}else if(route[i].wp_role == "approach"){
append(via, "APPR TRANS");
}else if(route[i].wp_role == "star"){
if(fp.star_trans != nil){
append(via, fp.star_trans.id~"."~fp.star.id);
}else{
append(via, fp.star.id);
}
}else if(route[i].id == "----"){
append(via, "----");
}else if(find("RW", route[i].id) != -1){
if(fp.approach != nil){
append(via, fp.approach.id);
}else{
append(via, "----");
}
}else if(route[i].wp_role == "missed"){
append(via, "MISSED APPR");
}else if(route[i].id != ""){
if(currentpage == 2 and i == 1 and fp.departure_runway == nil){
append(via,"----");
}else{
append(via, "DIRECT");
}
}else{
append(via, "");
}
i = i+1
}
while(size(via) < 5){
append(via, "");
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
var allwp = [];	
foreach(var i; apts){
if(i.id == input){
append(allwp, i);
}
}
foreach(var i; fixes){
if(i.id == input){
append(allwp, i);
}
}
foreach(var i; navs){
if(i.id == input){
append(allwp, i);
}
}
if(size(allwp) == 1){
resetinput();
return allwp[0];
die();
}else if(size(allwp) > 1){
resetinput();
setprop("instrumentation/cdu/page/RTE/currentpage", getprop("instrumentation/cdu/page/current-page"));
setprop("instrumentation/cdu/page/RTE/input", input);
setprop("instrumentation/cdu/page/RTE/num", num);
newpage("rte choose waypoint");
var pos = geo.aircraft_position().apply_course_distance(getprop("/orientation/heading-deg"), 100000);
var notavail = createWP(pos,"notavail");
return notavail;	
}else{
warnmessage("NOT IN DATA BASE");
die();
}
}
}


var multiplewaypoint = func(){
	input = getprop("instrumentation/cdu/page/RTE/input");
    var apts = findAirportsByICAO(input);
	var fixes = findFixesByID(input);
	var navs = findNavaidsByID(input);
	var allwp = [];	
foreach(var i; apts){
if(i.id == input){
	append(allwp, i);
}
}
foreach(var i; fixes){
if(i.id == input){
append(allwp, i);
}
}
foreach(var i; navs){
if(i.id == input){
append(allwp, i);
}
}
currentpage = getprop("instrumentation/cdu/page/current-page");
maxpage = math.ceil(size(allwp)/5);
setprop("instrumentation/cdu/page/maxpage", maxpage);
var pos = geo.aircraft_position().apply_course_distance(getprop("/orientation/heading-deg"), 100000);
var void = createWP(pos," ");
displaywp = [];
index = (currentpage-1)*5;
if(index < 0) index = 0;
for(var i=index; i < index+5; i+=1){
if(i < size(allwp)){
append(displaywp, allwp[i]);
}else{
append(displaywp, void);
}
}
return displaywp;
}

var resetinput = func {
setprop("instrumentation/cdu/input", "");
update();
}

var insertinroute = func(input,index,wpghost=nil) {
fp = flightplan();
if(wpghost == nil){
wp = routepage()[index];
allwp = routepage("all");
var currentpage = getprop("instrumentation/cdu/page/current-page");
index = index+((currentpage-2)*5);
}else{
wp = routepage()[0];
}
if(wp.id != "" or (wp.id == "" and index == 1)){
if(wpghost == nil){
input = findinput(input);
if(input.id != "notavail"){
input = createWP(input, input.id);
}
sidindex =nil;
starindex = 999999;
apptransindex = 999999;
destindex = 999999;
missedindex = 999999;
i=0;
foreach(var wpmatch; allwp){
if(wpmatch.wp_role == "sid"){
sidindex = i;
}else if(wpmatch.wp_role == "star"){
starindex = i;
}else if(wpmatch.wp_role == "approach"){
apptransindex = i;
}else if(find("RW", wpmatch.id) != -1){
destindex = i;
}else if(wpmatch.wp_role == "missed"){
missedindex = i;
}
i=i+1;
}
depindex = nil;
if(sidindex != nil){
depindex = size(fp.sid.route(fp.sid_trans));
if(index == 1){
depindex = depindex+1;
}
depindex = depindex+index;
}else if(fp.departure != nil){
depindex = index;
if(index == 0){
depindex = index+1;
}
}else if(index != 0){
depindex = index-1;
}
arrindex = nil;
print("prev index:"~index);
if(index >= starindex){
if(index == starindex){
arrindex = fp.indexOfWP(fp.star.route(fp.star_trans)[0]);
}else if(index == apptransindex or index == destindex or index == missedindex){
warnmessage("NOT ALLOWED");
die();
}
}else if(index >= apptransindex){
if(index == apptransindex){
arrindex = fp.indexOfWP(fp.approach.route(fp.approach_trans)[0]);
}else if(index == destindex or index == missedindex){
warnmessage("NOT ALLOWED");
die();
}
}else if(index >= destindex){
if(index == destindex){
arrindex = fp.indexOfWP(fp.destination_runway);
}else if(index == missedindex){
warnmessage("NOT ALLOWED");
die();
}
}else if(index >= missedindex){
if(index == missedindex){
arrindex = fp.indexOfWP(fp.destination_runway)+1;
}
}
afterindex = nil;
if(index > starindex and apptransindex == 999999 and destindex == 999999 and missedindex == 999999){
afterindex = fp.indexOfWP(fp.star.route(fp.star_trans)[size(fp.star.route(fp.star_trans))-1]);
}else if(index > apptransindex and destindex == 999999 and missedindex == 999999){
afterindex = destindex-1;
}else if(index > destindex and missedindex == 999999){
afterindex = destindex;
}else if(index > missedindex){
misswp = createWP(allwp[missedindex], allwp[missedindex].id);
arrindex = fp.indexOfWP(misswp);
}
if(afterindex != nil){
index = (index/5-currentpage+2)*math.ceil(afterindex/5)-afterindex;
}else if(arrindex !=nil){
index = arrindex;
}else if(depindex != nil){
index = depindex;
}
if(input.id == "notavail"){
setprop("instrumentation/cdu/page/RTE/index", index);
die();
}
}else{
input = createWP(input, input.id);
}
fp.insertWP(input, index);
update();
resetinput();
}
}

legspage = func(VecToReturn){
fp = flightplan();
currentpage = getprop("instrumentation/cdu/page/current-page");
currentpage = (currentpage-1)*5;
var pos = geo.aircraft_position().apply_course_distance(getprop("/orientation/heading-deg"), 1000);
void = createWP(pos, "");
allwp = [];
if(fp.departure != nil){
var i = 1;
}else{
var i = 0;
}
for(var i=i; i < fp.getPlanSize(); i=i+1){
append(allwp, fp.getWP(i));
}
maxpage = math.ceil(size(allwp)/5);
if(maxpage < 1) maxpage = 1;
setprop("instrumentation/cdu/page/maxpage", maxpage);
displaywp = [];
bearing=[];
distance=[];
altspdcstr = [];
for(var i=currentpage; i < currentpage+5; i=i+1){
if(i == size(allwp)){
break;
}
append(displaywp, allwp[i].id);
wpbearing = math.round(allwp[i].leg_bearing);
wpbearing = sprintf("%03i", wpbearing)~"g";
append(bearing, wpbearing);
wpdistance = math.round(allwp[i].leg_distance);
wpdistance = sprintf("%4d", wpdistance)~"NM";
append(distance, wpdistance);
if(allwp[i].speed_cstr != 0){
var spdcstr = " "~allwp[i].speed_cstr;
}else{
var spdcstr = "---";
}
if(allwp[i].alt_cstr != 0){
if(allwp[i].alt_cstr_type == "above"){
var altcstrtype = "A";
}else if(allwp[i].alt_cstr_type == "below"){
var altcstrtype = "B";
}else{
var altcstrtype = " ";
}
altcstr = sprintf("%5d", allwp[i].alt_cstr);
var altcstr = altcstr~altcstrtype;
}else{
var altcstr = "----- ";
}
if(allwp[i].alt_cstr != nil or allwp[i].speed_cstr != nil){
append(altspdcstr, spdcstr~"/"~altcstr);
}else{
append(altspdcstr, "");
}
}
while(size(displaywp) < 5){
append(displaywp, "");
append(bearing, "");
append(distance, "");
append(altspdcstr, "");
}
if(VecToReturn == "name"){
return displaywp;
}else if(VecToReturn == "bearing"){
return bearing;
}else if(VecToReturn == "distance"){
return distance;
}else{
return altspdcstr;
}
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
wp = routepage()[num];
fp = flightplan();
if(wp.id != "" and wp.id != "----" and wp.wp_role != "sid" and wp.wp_role != "star" and find("RW", wp.id) == -1 and wp.wp_role != "missed" and wp.wp_role !="approach"){
wp = createWP(wp, wp.id);
index = fp.indexOfWP(wp);
resetinput();
setprop("instrumentation/cdu/deletekey", 0);
fp.deleteWP(index);
update();
clear();
}
}

var addspace = func(input,side,wantedspace=7){
if(side == "right"){
while(size(input) < wantedspace){
input = input~" ";
}
}else if(side == "left"){
while(size(input) < wantedspace){
input = " "~input;
}
}
return input;
}
