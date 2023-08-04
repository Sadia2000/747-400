# ==============================================================================
# Boeing 747-400 pfd by Gijs de Rooy
# ==============================================================================

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2))
			x = x + m;
	return x;
}

var cdu_canvas_pilot = nil;
var cdu_canvas_copilot = nil;
var cdu_display_pilot = nil;
var cdu_display_copilot = nil;

var canvas_CDU_pilot = {
	new: func(canvas_group_pilot)
	{
		var m = { parents: [canvas_CDU_pilot] };
		var cdu = canvas_group_pilot;
		var font_mapper = func(family, weight)
		{
			if( family == "verdana" and weight == "normal" )
				return "747-400-CDU.ttf";
		};
		
		canvas.parsesvg(cdu, "Aircraft/747-400/Models/Cockpit/Instruments/CDU/CDU.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["DarkGreenBackGround","title","scratchpad","pagenum","tiret","l1","l2","l3","l4","l5","l6","l7","l8","l9","l10","l11","l12","small-l2","small-l4","small-l6","small-l8","small-l10","small-l12","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11","r12","c1","c2","c3","c4","c5","c6","c7","c8","c9","c10","c11","c12","small-c2","small-c4","small-c6","small-c8","small-c10","small-c12","small-r2","small-r4","small-r6","small-r8","small-r10","small-r12","l1-big","l3-big","l5-big","l7-big","l9-big","l11-big","c1-big","c3-big","c5-big","c7-big","c9-big","c11-big","r1-big","r3-big","r5-big","r7-big","r9-big","r11-big",];
		foreach(var key; svg_keys) {
			m[key] = cdu.getElementById(key);
		}
		return m;
	},
	update_pilot: func()
	{

		me["pagenum"].setText(getprop("instrumentation/cdu/page/page-num"));
		me["title"].setText(getprop("instrumentation/cdu/page/title"));
		me["scratchpad"].setText(getprop("instrumentation/cdu/input"));
		me["tiret"].setText(getprop("instrumentation/cdu/lines/tiret"));
		
for(var i = 1; i <= 12; i+=1){
me["r"~i].setText(getprop("instrumentation/cdu/lines/r"~i));
}

for(var i = 1; i <= 12; i+=1){
me["c"~i].setText(getprop("instrumentation/cdu/lines/c"~i));
}

for(var i = 1; i <= 12; i+=1){
me["l"~i].setText(getprop("instrumentation/cdu/lines/l"~i));
}

for(var i = 2; i <= 12; i+=2){
me["small-c"~i].setText(getprop("instrumentation/cdu/lines/small/c"~i));
}

for(var i = 2; i <= 12; i+=2){
me["small-l"~i].setText(getprop("instrumentation/cdu/lines/small/l"~i));
}

for(var i = 2; i <= 12; i+=2){
me["small-r"~i].setText(getprop("instrumentation/cdu/lines/small/r"~i));
}

for(var i = 1; i <= 12; i+=2){
me["l"~i~"-big"].setText(getprop("instrumentation/cdu/lines/big/c"~i));
}

for(var i = 1; i <= 12; i+=2){
me["c"~i~"-big"].setText(getprop("instrumentation/cdu/lines/big/l"~i));
}

for(var i = 1; i <= 12; i+=2){
me["r"~i~"-big"].setText(getprop("instrumentation/cdu/lines/big/r"~i));
}

newpage = getprop("instrumentation/cdu/update");
if(newpage == 1){
			me["pagenum"].hide();
		me["title"].hide();
		me["scratchpad"].hide();
		me["tiret"].hide();		
for(var i = 1; i <= 12; i+=1){
me["r"~i].hide();
}
for(var i = 1; i <= 12; i+=1){
me["c"~i].hide();
}
for(var i = 1; i <= 12; i+=1){
me["l"~i].hide()
}
for(var i = 2; i <= 12; i+=2){
me["small-c"~i].hide();
}
for(var i = 2; i <= 12; i+=2){
me["small-l"~i].hide();
}
for(var i = 2; i <= 12; i+=2){
me["small-r"~i].hide();
}
for(var i = 1; i <= 12; i+=2){
me["l"~i~"-big"].hide();
}

for(var i = 1; i <= 12; i+=2){
me["c"~i~"-big"].hide();
}

for(var i = 1; i <= 12; i+=2){
me["r"~i~"-big"].hide();
}

}else{
			me["pagenum"].show();
		me["title"].show();
		me["scratchpad"].show();
		me["tiret"].show();		
for(var i = 1; i <= 12; i+=1){
me["r"~i].show();
}
for(var i = 1; i <= 12; i+=1){
me["c"~i].show();
}
for(var i = 1; i <= 12; i+=1){
me["l"~i].show()
}
for(var i = 2; i <= 12; i+=2){
me["small-c"~i].show();
}
for(var i = 2; i <= 12; i+=2){
me["small-l"~i].show();
}
for(var i = 2; i <= 12; i+=2){
me["small-r"~i].show();
}
for(var i = 1; i <= 12; i+=2){
me["l"~i~"-big"].show();
}

for(var i = 1; i <= 12; i+=2){
me["c"~i~"-big"].show();
}

for(var i = 1; i <= 12; i+=2){
me["r"~i~"-big"].show();
}
}
		
		settimer(func me.update_pilot(), 0.1);
}
};



setlistener("sim/signals/fdm-initialized", func() {
	cdu_display_pilot = canvas.new({
		"name": "CAPTAIN CDU",
		"size": [1024, 864],
		"view": [1024, 864],
		"mipmapping": 1
	});
	cdu_display_pilot.addPlacement({"node": "cdu.capt-screen"});
	var group_pilot = cdu_display_pilot.createGroup();
	cdu_canvas_pilot = canvas_CDU_pilot.new(group_pilot);
	cdu_canvas_pilot.update_pilot();
});

setlistener("sim/signals/reinit", func cdu_display_pilot.del());

var showCdupilot = func() {
	var dlg = canvas.Window.new([600, 600], "dialog").set("resize", 1);
	dlg.setCanvas(cdu_display_pilot);
}
