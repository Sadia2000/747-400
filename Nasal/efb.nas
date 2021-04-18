var l1 = "";
var l2 = "";
var l3 = "";
var l4 = "";
var l5 = "";
var l6 = "";
var l7 = "";
var l8 = "";
var l9 = "";
var l10 = "";
var l11 = "";
var l12 = "";
var l13 = "";
var r1 = "";
var r3 = "";
var r5 = "";
var r7 = "";
var r9 = "";
var r11 = "";
var r13 = "";
var helper = "";
var keypress = "";
var lastlog = "";
var hist1 = "";
var hist2 = "";
var hist3 = "";
var hist4 = "";
var hist5 = "";
var hist6 = "";

var fuelrequired = 0;
var fuelrecommended = 0;


var efb = {
	init : func { 
        me.UPDATE_INTERVAL = 0.05; 
        me.loopid = 0; 
# Initialize

setprop("/instrumentation/efb/page", "MENU");

setprop("/instrumentation/efb/chart/rotation", 0);
setprop("/instrumentation/efb/diagram/rotation", 0);

setprop("/instrumentation/efb/manual-page", 0);

setprop("/instrumentation/efb/vnav_autogen/first", 0);
setprop("/instrumentation/efb/vnav_autogen/gen", 0);

setprop("/instrumentation/efb/catchme/score", 0);


        me.reset(); 
}, 

	update : func {

var keypress = getprop("/instrumentation/efb/keypress");

if (getprop("/instrumentation/efb/page") == "MENU") {
	
	page.clearpage();
	page.index();

if (keypress == "l1") { setprop("/instrumentation/efb/page", "Documents");
keypress = "";
}
if (keypress == "l2") { setprop("/instrumentation/efb/page", "Ground Services");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Ground Services") {
	
	page.clearpage();
	page.groundservices();

	if (getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow") == 1 and getprop("/gear/gear[3]/wow") == 1 and getprop("/gear/gear[4]/wow") == 1) {	
if (keypress == "l1") {
if (getprop("controls/switches/gpu") == 0) {
setprop("controls/switches/gpu", 1);
}else{
setprop("controls/switches/gpu", 0);
}
keypress = "";
}

if (keypress == "l2") {
if (getprop("controls/switches/cargo_ramp") == 0) {
setprop("controls/switches/cargo_ramp", 1);
}else{
setprop("controls/switches/cargo_ramp", 0);
}
keypress = "";
}

if (keypress == "l3") {
setprop("instrumentation/efb/page", "Fuel Truck Page");
keypress = "";
}
}
} elsif (getprop("instrumentation/efb/page") == "Fuel Truck Page"){

	page.clearpage();
	page.fuelpage();

	if (getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow") == 1 and getprop("/gear/gear[3]/wow") == 1 and getprop("/gear/gear[4]/wow") == 1) {
if (keypress == "l1") {
if (getprop("controls/switches/Fuel-pipe") == 0) {
if (getprop("controls/switches/Fuel") == 0) {
setprop("controls/switches/Fuel", 1);
}else{
setprop("controls/switches/Fuel", 0);
}
keypress = "";
}
}
if (keypress == "l2") {
if (getprop("controls/switches/Fuel") == 1){
if (getprop("controls/switches/Fuel-pipe") == 0) {
setprop("controls/switches/Fuel-pipe", 1);
}else{
setprop("controls/switches/Fuel-pipe", 0);
}
}
keypress = "";
}
if (keypress == "l6") {
setprop("instrumentation/efb/page", "Ground Services");
keypress = "";
}
}
} elsif (getprop("/instrumentation/efb/page") == "Documents") {
	
	page.clearpage();
	page.documents();

if (keypress == "l1") { setprop("/instrumentation/efb/page", "Checklists Page: 1");
keypress = "";
}


} elsif (getprop("/instrumentation/efb/page") == "Checklists Page: 1") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",0);
setprop("/instrumentation/efb/checklists/y",0);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Checklists Page: 2");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Checklists Page: 2") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",1);
setprop("/instrumentation/efb/checklists/y",0);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Checklists Page: 3");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Checklists Page: 3") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",2);
setprop("/instrumentation/efb/checklists/y",0);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Checklists Page: 4");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Checklists Page: 4") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",3);
setprop("/instrumentation/efb/checklists/y",0);

r13 = "NEXT CHECKLIST >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Checklists Page: 5");
keypress = "";
}

} elsif (getprop("/instrumentation/efb/page") == "Checklists Page: 5") {
	
	page.clearpage();

setprop("/instrumentation/efb/checklists/x",0);
setprop("/instrumentation/efb/checklists/y",1);

r13 = "BACK TO START >";

if (keypress == "r7") { setprop("/instrumentation/efb/page", "Checklists Page: 1");
keypress = "";
}

}



if (substr(getprop("/instrumentation/efb/page"),0,16) == "Checklists Page:") {
setprop("/instrumentation/efb/checklists/show",1);
} else {
setprop("/instrumentation/efb/checklists/show",0);
}


	# L7 is always MENU except in MENU page
if (getprop("/instrumentation/efb/page") != "MENU") {
l13 = "< MENU";
if (keypress == "l7") { setprop("/instrumentation/efb/page", "MENU");
keypress = "";
} }
	page.update();

if ((getprop("/instrumentation/efb/page") == "Airport Charts") or (getprop("/instrumentation/efb/page") == "Airport Diagram") or (getprop("/instrumentation/efb/page") == "Operating Manual")) setprop("/instrumentation/efb/text-color", 0);
else setprop("/instrumentation/efb/text-color", 1);


},


    reset : func {
        me.loopid += 1;
        me._loop_(me.loopid);
    },
    _loop_ : func(id) {
        id == me.loopid or return;
        me.update();
        settimer(func { me._loop_(id); }, me.UPDATE_INTERVAL);
    }
		
};

var page = {
	update : func {

		setprop("/instrumentation/efb/display/line1-l", l1);
		setprop("/instrumentation/efb/display/line2-l", l2);
		setprop("/instrumentation/efb/display/line3-l", l3);
		setprop("/instrumentation/efb/display/line4-l", l4);
		setprop("/instrumentation/efb/display/line5-l", l5);
		setprop("/instrumentation/efb/display/line6-l", l6);
		setprop("/instrumentation/efb/display/line7-l", l7);
		setprop("/instrumentation/efb/display/line8-l", l8);
		setprop("/instrumentation/efb/display/line9-l", l9);
		setprop("/instrumentation/efb/display/line10-l", l10);
		setprop("/instrumentation/efb/display/line11-l", l11);
		setprop("/instrumentation/efb/display/line12-l", l12);
		setprop("/instrumentation/efb/display/line13-l", l13);

		setprop("/instrumentation/efb/display/line1-r", r1);
		setprop("/instrumentation/efb/display/line3-r", r3);
		setprop("/instrumentation/efb/display/line5-r", r5);
		setprop("/instrumentation/efb/display/line7-r", r7);
		setprop("/instrumentation/efb/display/line9-r", r9);
		setprop("/instrumentation/efb/display/line11-r", r11);
		setprop("/instrumentation/efb/display/line13-r", r13);

		setprop("/instrumentation/efb/display/input-helper", helper);
		setprop("/instrumentation/efb/keypress", keypress);

},
	clearpage : func {

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
		l13 = "";

		r1 = "";
		r3 = "";
		r5 = "";
		r7 = "";
		r9 = "";
		r11 = "";
		r13 = "";

		helper = "";

},

	index : func {

l1 = "< Flight Manual Index";
l3 = "< Ground Services";

},


	groundservices : func {

	if (getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow") == 1 and getprop("/gear/gear[3]/wow") == 1 and getprop("/gear/gear[4]/wow") == 1) {

if (getprop("controls/switches/gpu") == 1){	
		l1 = "< Ground Power Unit (State:Connected)";
}
else l1 = "< Ground Power Unit (State:Disconnected)";

if (getprop("controls/switches/cargo_ramp") == 1){	
		l3 = "< Baggage Truck (State:Connected)";
}
else l3 = "< Baggage Truck (State:Disconnected)";

l5 = "< Fuel Truck Page"

}	
	else l1 = "No";
},  

	fuelpage : func {

	if (getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow") == 1 and getprop("/gear/gear[3]/wow") == 1 and getprop("/gear/gear[4]/wow") == 1) {

if (getprop("controls/switches/Fuel-pipe") == 0){
if (getprop("controls/switches/Fuel") == 1){	
		l1 = "< Fuel Truck (State:Connected)";
}
else l1 = "< Fuel Truck (State:Disconnected)";
}
else l1 = "Disconnect Fuel Pipe First";

if (getprop("controls/switches/Fuel") == 1){
if (getprop("controls/switches/Fuel-pipe") == 1){	
		l3 = "< Fuel Pipe (State:Connected)";
}
else l3 = "< Fuel Pipe (State:Disconnected)";

}
else l3="Connect Fuel Truck first";

l11 = "< Go back"

}	
	else l1 = "No";
	
}, 

	documents : func {

l1 = "< Checklists";

}


};

var toggle = func(property) {

if (getprop(property) == 1) setprop(property, 0);
else setprop(property, 1);

}

setlistener("sim/signals/fdm-initialized", func
 {
 efb.init();
 print("EFB Computer ........ Initialized");
 });
