# ==============================================================================
# Boeing 747-400 EICAS by Gijs de Rooy
# ==============================================================================

var canvas_group = {};
var primary_dialog = {};
var primary_eicas = {};

var canvas_primary = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_primary] };
		
		var eicasP = canvas_group;
		
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(eicasP, "Aircraft/747-400/Models/Cockpit/Instruments/EICAS/primary.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["eng1egt","eng1egtBar","eng1n1","eng1n1bar","eng1n1cmdLine","eng1n1maxLine","eng1n1rect","eng1n1ref","eng1nai","eng2egt","eng2egtBar","eng2n1","eng2n1bar","eng2n1cmdLine","eng2n1maxLine","eng2n1rect","eng2n1ref","eng2nai","eng3egt","eng3egtBar","eng3n1","eng3n1bar","eng3n1cmdLine","eng3n1maxLine","eng3n1rect","eng3n1ref","eng3nai","eng4egt","eng4egtBar","eng4n1","eng4n1bar","eng4n1cmdLine","eng4n1maxLine","eng4n1rect","eng4n1ref","eng4nai","assTemp","flapsBar","flapsBox","flapsL","flapsLine","flapsText","fuelTemp","fuelTempL","fuelToRemain","fuelToRemainL","fuelTotal","gear","gear0","gear0box","gear0boxTrans","gear1","gear1box","gear1boxTrans","gear2","gear2box","gear2boxTrans","gear3","gear3box","gear3boxTrans","gear4","gear4box","gear4boxTrans","gearBox","gearBoxTrans","gearL","msgMemo","msgWarning","msgCaution","msgAdvisory","tat","thrustRefMode","wai"];
		foreach(var key; svg_keys) {
			m[key] = eicasP.getElementById(key);
		}
				
		for(var n = 1; n<=4; n+=1){
			var c = m["eng"~n~"n1bar"].getCenter();
			m["eng"~n~"n1bar"].createTransform().setTranslation(-c[0], -c[1]);
			m["eng"~n~"n1bar_scale"] = m["eng"~n~"n1bar"].createTransform();
			m["eng"~n~"n1bar"].createTransform().setTranslation(c[0], c[1]);
			c = m["eng"~n~"egtBar"].getCenter();
			m["eng"~n~"egtBar"].createTransform().setTranslation(-c[0], -c[1]);
			m["eng"~n~"egtBar_scale"] = m["eng"~n~"egtBar"].createTransform();
			m["eng"~n~"egtBar"].createTransform().setTranslation(c[0], c[1]);
		}
		c = m["flapsBar"].getCenter();
		m["flapsBar"].createTransform().setTranslation(-c[0], -c[1]);
		m["flapsBar_scale"] = m["flapsBar"].createTransform();
		m["flapsBar"].createTransform().setTranslation(c[0], c[1]);

		var timerFlaps = maketimer(10.0, func { m["flapsText"].hide();m["flapsLine"].hide();m["flapsL"].hide();m["flapsBar"].hide();m["flapsBox"].hide(); });
		setlistener("/fdm/jsbsim/fcs/flap-pos-norm", func() {
			if (getprop("/fdm/jsbsim/fcs/flap-pos-norm") == 0) {
				timerFlaps.singleShot = 1;
				timerFlaps.start(); # start the timer (with 1 second inverval)
			} else {
				timerFlaps.stop();
			}
		});
		timerFlaps.stop();
		
		var timerGear = maketimer(10.0, func { m["gear"].hide();m["gearL"].hide();m["gearBox"].hide();m["gearBoxTrans"].hide(); });
		setlistener("gear/gear/position-norm", func() {
			if (getprop("gear/gear/position-norm") == 0) {
				timerGear.singleShot = 1;
				timerGear.start(); # start the timer (with 1 second inverval)
			} else {
				timerGear.stop();
			}
		});
		
		# add some listeners
		setlistener("controls/flight/flaps",				func { me.flaps = getprop("controls/flight/flaps") } );
		setlistener("controls/gear/gear-down",				func { me.gear_down = getprop("controls/gear/gear-down") } );
		setlistener("controls/anti-ice/wing-heat",			func { m.update_wai() } );
		
		return m;
	},
	update_wai: func()
	{
		me["wai"].setVisible(getprop("controls/anti-ice/wing-heat"));
	},
	slow_update: func()
	{
		var thrustMode = getprop("fdm/jsbsim/eec/reference-thrust-mode") or -1;
		var thrustRefModeText = ["TO","TO 1","TO 2","D-TO","D-TO 1","D-TO 2","CLB","CLB 1","CLB 2","CON","CRZ","GA"];
		if (thrustMode > -1)
			me["thrustRefMode"].setText(thrustRefModeText[thrustMode]);
		else
			me["thrustRefMode"].setText("");
		var flaps = getprop("fdm/jsbsim/fcs/flaps/cmd-detent-deg") or 0;
		var flapPos = getprop("fdm/jsbsim/fcs/flaps/pos-deg") or 0;
		
		if ((var asstat = getprop("instrumentation/fmc/inputs/assumed-temp-deg-c") or -999) > -90) {
			me["assTemp"].setText(sprintf("%+02.0fc",asstat));
			me["assTemp"].show();
		} else
			me["assTemp"].hide();
		me["tat"].setText(sprintf("%+02.0fc",getprop("environment/temperature-degc")));
		me["fuelTotal"].setText(sprintf("%03.01f",(getprop("fdm/jsbsim/propulsion/total-fuel-lbs") or 0)*LB2KG/1000));
		if (getprop("/fdm/jsbsim/propulsion/fuel-dump-rate-pps") or 0 > 0) {
			me["fuelToRemain"].setText(sprintf("%03.01f",getprop("controls/fuel/fuel-to-remain-lbs")*LB2KG/1000));
			me["fuelToRemain"].show();
			me["fuelToRemainL"].show();
			me["fuelTemp"].hide();
			me["fuelTempL"].hide();
		} else {
			var fuelTempDegC = getprop("consumables/fuel/tank[1]/temperature_degC") or 0;
			me["fuelTemp"].setText(sprintf("%+02.0fc",fuelTempDegC));
			if (fuelTempDegC < -37)
				me["fuelTemp"].setColor(1,0.5,0);
			else
				me["fuelTemp"].setColor(1,1,1);
			me["fuelToRemain"].hide();
			me["fuelToRemainL"].hide();
			me["fuelTemp"].show();
			me["fuelTempL"].show();
		}
		
		if (flapPos != 0 or flaps != 0) {
			me["flapsText"].setText(sprintf("%2.0f",flaps));
			me["flapsLine"].setTranslation(0,5.233*flaps);
			me["flapsText"].setTranslation(0,5.233*flaps);
			me["flapsBar_scale"].setScale(1, flapPos/30);
			me["flapsText"].show();
			me["flapsLine"].show();
			me["flapsL"].show();
			me["flapsBar"].show();
			me["flapsBox"].show();
		}
		if (flaps != flapPos) {
			me["flapsText"].setColor(1,0,1);
			me["flapsLine"].setColor(1,0,1);
		} else {
			me["flapsText"].setColor(0,1,0);
			me["flapsLine"].setColor(0,1,0);
		}
		
		var gearStuck = [getprop("/controls/failures/gear[0]/stuck"),getprop("/controls/failures/gear[1]/stuck"),getprop("/controls/failures/gear[2]/stuck"),getprop("/controls/failures/gear[3]/stuck"),getprop("/controls/failures/gear[4]/stuck")];
		var gearPos = [getprop("gear/gear[0]/position-norm"),getprop("gear/gear[1]/position-norm"),getprop("gear/gear[2]/position-norm"),getprop("gear/gear[3]/position-norm"),getprop("gear/gear[4]/position-norm")];
		
		if (gearStuck[0] or gearStuck[1] or gearStuck[2] or gearStuck[3] or gearStuck[4]) {
			me["gear"].hide();
			me["gearBox"].hide();
			me["gearBoxTrans"].hide();
			me["gearL"].show();
			
			for(var g = 0; g <= 4; g+=1){
				me["gear"~g].show();
				me["gear"~g~"box"].show();
				if(gearPos[g] == 1) {
					me["gear"~g].setColor(0,1,0);
					me["gear"~g].setText("DN");
					me["gear"~g~"box"].setColor(0,1,0);
				} else {
					me["gear"~g].setColor(1,1,1);
					if (gearPos[g] == 0) {
						me["gear"~g].setText("UP");
						me["gear"~g~"box"].setColor(1,1,1);
					} else
						me["gear"~g].setText("");
				}
				me["gear"~g~"boxTrans"].setVisible(gearPos[g] != 1 and gearPos[g] != 0);
			}
		} else {
			for(var g = 0; g <= 4; g+=1){
				me["gear"~g].hide();
				me["gear"~g~"box"].hide();
				me["gear"~g~"boxTrans"].hide();
			}
			
			if (gearPos[0] < 0.02 and gearPos[1] < 0.02 and gearPos[2] < 0.02 and gearPos[3] < 0.02 and gearPos[4] < 0.02) {
				me["gear"].setText("UP");
				me["gear"].setColor(1,1,1);
				me["gearBox"].setColor(1,1,1);
				me["gearBoxTrans"].hide();
			} elsif (gearPos[0] > 0.98 and gearPos[1] > 0.98 and gearPos[2] > 0.98 and gearPos[3] > 0.98 and gearPos[4] > 0.98) {
				me["gear"].setText("DOWN");
				me["gear"].setColor(0,1,0);
				me["gearBox"].setColor(0,1,0);
				me["gear"].show();
				me["gearBox"].show();
				me["gearBoxTrans"].hide();
			} else {
				me["gear"].hide();
				me["gearBox"].hide();
				me["gearBoxTrans"].show();
			}
		}
		
		me["msgWarning"].setText(getprop("instrumentation/eicas/msg/warning"));
		me["msgCaution"].setText(getprop("instrumentation/eicas/msg/caution"));
		me["msgAdvisory"].setText(getprop("instrumentation/eicas/msg/advisory"));
		me["msgMemo"].setText(getprop("instrumentation/eicas/msg/memo"));
		
		settimer(func me.slow_update(), 0.3);
	},
	fast_update: func() 
	{
		var egt = [0,getprop("engines/engine[0]/egt-degf"),getprop("engines/engine[1]/egt-degf"),getprop("engines/engine[2]/egt-degf"),getprop("engines/engine[3]/egt-degf")];
		var n1 = [0,getprop("engines/engine[0]/n1"),getprop("engines/engine[1]/n1"),getprop("engines/engine[2]/n1"),getprop("engines/engine[3]/n1")];
		var throttle = [0,getprop("controls/engines/engine[0]/throttle"),getprop("controls/engines/engine[1]/throttle"),getprop("controls/engines/engine[2]/throttle"),getprop("controls/engines/engine[3]/throttle")];
		var engn1max = [0,getprop("/fdm/jsbsim/eec/throttle-max-cmd-norm[0]") or 0,getprop("/fdm/jsbsim/eec/throttle-max-cmd-norm[0]") or 0,getprop("/fdm/jsbsim/eec/throttle-max-cmd-norm[0]") or 0,getprop("/fdm/jsbsim/eec/throttle-max-cmd-norm[0]") or 0];
		
		for(var n = 1; n<=4; n+=1){
			var revPos = getprop("engines/engine["~n~"]/reverser-pos-norm") or 0;
			if (revPos > 0) {
				me["eng"~n~"n1ref"].setText("REV");
				if (revPos != 1)
					me["eng"~n~"n1ref"].setColor(1,0.5,0);
				else
					me["eng"~n~"n1ref"].setColor(0,1.0,0);
				me["eng"~n~"n1cmdLine"].hide();
			} else {
				me["eng"~n~"n1cmdLine"].show();
				me["eng"~n~"n1cmdLine"].setTranslation(0,-173.2*throttle[n]*engn1max[n]-46.8);
				me["eng"~n~"n1ref"].setText(sprintf("%3.01f",92.5*throttle[n]*engn1max[n]+25.0));
				me["eng"~n~"n1ref"].setColor(0,1.0,0);
			}
			me["eng"~n~"n1"].setText(sprintf("%3.01f",n1[n]));
			me["eng"~n~"n1maxLine"].setTranslation(0,-173.2*engn1max[n]-46.8);
			if (n1[n] != nil){
				me["eng"~n~"n1bar_scale"].setScale(1, n1[n]/117.5);
				if(n1[n] >= 117.5)
					me["eng"~n~"n1bar"].setColor(1,0,0);
				else
					me["eng"~n~"n1bar"].setColor(1,1,1);
			}
			if (egt[n] != nil) {
				me["eng"~n~"egt"].setText(sprintf("%3.0f",(egt[n]-32)/1.8));
				me["eng"~n~"egtBar_scale"].setScale(1, ((egt[n]-32)/1.8)/960);
				if ((egt[n]-32)/1.8 >= 960) {
					me["eng"~n~"egt"].setColor(1,0,0);
					me["eng"~n~"egtBar"].setColor(1,0,0);
				} elsif ((egt[n]-32)/1.8 >= 925) {
					me["eng"~n~"egt"].setColor(1,0.5,0);
					me["eng"~n~"egtBar"].setColor(1,0.5,0);
				} else {
					me["eng"~n~"egt"].setColor(1,1,1);
					me["eng"~n~"egtBar"].setColor(1,1,1);
				}
			}
			me["eng"~n~"nai"].setVisible(getprop("controls/anti-ice/engine["~(n-1)~"]/inlet-heat"));
		}
		settimer(func me.fast_update(), 0.1);
	}
};

setlistener("/nasal/canvas/loaded", func {
	primary_eicas = canvas.new({
		"name": "EICASPrimary",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	primary_eicas.addPlacement({"node": "screen.eicas"});
	var group = primary_eicas.createGroup();
	var demo = canvas_primary.new(group);
	demo.slow_update();
	demo.fast_update();
}, 1);

var showPrimaryEicas = func() {
	var dlg = canvas.Window.new([512, 512], "dialog");
	dlg.setCanvas(primary_eicas);
}
