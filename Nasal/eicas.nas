var throttle		= 0;
var radio_alt		= 0;
var flaps			= 0;
var parkbrake		= 0;
var speed			= 0;
var reverser		= 0;
var apu_running		= 0;
var gear_down		= 0;
var gear_override	= 0;
var flap_override	= 0;
var ap_passive		= 1;
var ap_disengaged	= 0;
var rudder_trim		= 0;
var elev_trim		= 0;
var engfire			= [0,0,0,0];
var engext	        = [0,0,0,0];
var secondary_eicas = {};
var secEICAS		= {};
var pack 			= [0,0,0];

var num_lines = 15;

msgs_warning = [];
msgs_caution = [];
msgs_advisory = [];
msgs_memo = [];

props.globals.initNode("/instrumentation/weu/state/stall-speed",-100);

eicas = props.globals.initNode("/instrumentation/eicas");
eicas_msg_warning	= eicas.initNode("msg/warning"," ","STRING");
eicas_msg_caution	= eicas.initNode("msg/caution"," ","STRING");
eicas_msg_advisory	= eicas.initNode("msg/advisory"," ","STRING");
eicas_msg_memo		= eicas.initNode("msg/memo"," ","STRING");

setlistener("sim/signals/fdm-initialized", func() {
	setlistener("controls/gear/gear-down",            func { update_listener_inputs() } );
	setlistener("controls/gear/brake-parking",        func { update_listener_inputs() } );
	setlistener("controls/engines/engine/reverser",   func { update_listener_inputs() } );
	setlistener("engines/engine[0]/on-fire", func(n) { engfire[0] = n.getValue(); } );
	setlistener("engines/engine[1]/on-fire", func(n) { engfire[1] = n.getValue(); } );
	setlistener("engines/engine[2]/on-fire", func(n) { engfire[2] = n.getValue(); } );
	setlistener("engines/engine[3]/on-fire", func(n) { engfire[3] = n.getValue(); } );
	setlistener("engines/engine[0]/extinguished", func(n) { engext[0] = n.getValue(); } );
	setlistener("engines/engine[1]/extinguished", func(n) { engext[1] = n.getValue(); } );
	setlistener("engines/engine[2]/extinguished", func(n) { engext[2] = n.getValue(); } );
	setlistener("engines/engine[3]/extinguished", func(n) { engext[3] = n.getValue(); } );
	setlistener("controls/flight/rudder-trim",        func { update_listener_inputs() } );
	setlistener("controls/flight/elevator-trim",      func { update_listener_inputs() } );
	setlistener("sim/freeze/replay-state",            func { update_listener_inputs() } );
	setlistener("/autopilot/autobrake/step",          func { update_listener_inputs() } );
	setlistener("/controls/pneumatic/pack-control[0]",func { pack[0] = (getprop("/controls/pneumatic/pack-control[0]")>0); } );
	setlistener("/controls/pneumatic/pack-control[1]",func { pack[1] = (getprop("/controls/pneumatic/pack-control[1]")>0); } );
	setlistener("/controls/pneumatic/pack-control[2]",func { pack[2] = (getprop("/controls/pneumatic/pack-control[2]")>0); } );
	
	setlistener("controls/engines/engine/throttle",   func { update_throttle_input() } );

	update_listener_inputs();
	update_throttle_input();
    update_system();
    
    setprop("/instrumentation/eicas/display","ENG");
});

var update_eicas = func(warningmsgs,cautionmsgs,advisorymsgs,memomsgs) {
	var msg="";
	var spacer="";
	var line = 0;
	for(var i=0; i<size(warningmsgs); i+=1)
	{
		msg = msg ~ warningmsgs[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	eicas_msg_warning.setValue(msg);
	msg=spacer;
	for(var i=0; i<size(cautionmsgs); i+=1)
	{
		msg = msg ~ cautionmsgs[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	eicas_msg_caution.setValue(msg);
	msg=spacer;
	for(var i=0; i<size(advisorymsgs); i+=1)
	{
		msg = msg ~ advisorymsgs[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	eicas_msg_advisory.setValue(msg);
	while (line+size(memomsgs) < num_lines) {
		line+=1;
		spacer = spacer ~ "\n";
	}
	msg=spacer;
	for(var i=0; i<size(memomsgs); i+=1)
	{
		msg = msg ~ memomsgs[i] ~ "\n";
	}
	eicas_msg_memo.setValue(msg);
}
	
var takeoff_config_warnings = func {
	if ((throttle>=0.667)and
		(!reverser))
	{
		if (((flaps<0.3)or(flaps>0.7)) and (speed < (getprop("/instrumentation/fmc/vspeeds/V1") or 200)))
			append(msgs_warning,">CONFIG FLAPS");
		if (parkbrake)
			append(msgs_warning,">CONFIG PARK BRK");
   }
}

var warning_messages = func {
	var wow = getprop("/gear/gear/wow");
	if (radio_alt>41000)
		append(msgs_warning,">CABIN ALTITUDE");
	if ((((radio_alt<800) and (throttle<0.1)) or (flaps>0.6)) and !gear_down)
		append(msgs_warning,">CONFIG GEAR");
	if (wow and (getprop("/controls/engines/engine[1]/throttle")>0.5 or getprop("/controls/engines/engine[2]/throttle")>0.5) and (getprop("/gear/gear[2]/steering-norm") != 0 or getprop("/gear/gear[3]/steering-norm") != 0))
		append(msgs_warning,">CONFIG GEAR CTR");
	if (getprop("controls/flight/speedbrake") != 0 and wow and (getprop("/controls/engines/engine[1]/throttle")>0.5 or getprop("/controls/engines/engine[2]/throttle")>0.5))
		append(msgs_warning,">CONFIG SPOILERS");	
	if (engfire[0] or engfire[1] or engfire[2] or engfire[3]) {
		var msgs_fire = "FIRE ENGINE ";
		if (engfire[0] and !engext[0])
			msgs_fire = msgs_fire~"1, ";
		if (engfire[1] and !engext[1])
			msgs_fire = msgs_fire~"2, ";
		if (engfire[2] and !engext[2])
			msgs_fire = msgs_fire~"3, ";
		if (engfire[3] and !engext[3])
			msgs_fire = msgs_fire~"4, ";
		if((!engext[0] and engfire[0]) or (!engext[1] and engfire[1]) or (!engext[2] and engfire[2]) or (!engext[3] and engfire[3]))
		append(msgs_warning,substr(msgs_fire,0,size(msgs_fire)-2));
	}
	if (getprop("instrumentation/fmc/vspeeds/Vmax") != nil) {
		if(speed > getprop("instrumentation/fmc/vspeeds/Vmax"))
			append(msgs_warning,">OVERSPEED");
	}
	if (((getprop("/fdm/jsbsim/fcs/stabilizer/trim-units") - getprop("/fdm/jsbsim/aero/stab-trim-units") > 1) or (getprop("/fdm/jsbsim/fcs/stabilizer/trim-units") - getprop("/fdm/jsbsim/aero/stab-trim-units") < -1)) and wow)
		append(msgs_warning,">CONFIG STAB");
}

var caution_messages = func {
	if (getprop("/systems/electrical/ac-bus[0]") or getprop("/systems/electrical/ac-bus[1]") or getprop("/systems/electrical/ac-bus[2]") or getprop("/systems/electrical/ac-bus[3]")) {
		var msgs_ac_bus = ">ELEC AC BUS ";
		if (getprop("/systems/electrical/ac-bus[0]"))
			msgs_ac_bus = msgs_ac_bus~"1, ";
		if (getprop("/systems/electrical/ac-bus[1]"))
			msgs_ac_bus = msgs_ac_bus~"2, ";
		if (getprop("/systems/electrical/ac-bus[2]"))
			msgs_ac_bus = msgs_ac_bus~"3, ";
		if (getprop("/systems/electrical/ac-bus[3]"))
			msgs_ac_bus = msgs_ac_bus~"4, ";
		append(msgs_caution,substr(msgs_ac_bus,0,size(msgs_ac_bus)-2));
	}
	if (getprop("/controls/engines/engine[0]/cutoff") or getprop("/controls/engines/engine[1]/cutoff") or getprop("/controls/engines/engine[2]/cutoff") or getprop("/controls/engines/engine[3]/cutoff")) {
		var msgs_eng_cutoff = ">ENG ";
		if (getprop("/controls/engines/engine[0]/cutoff"))
			msgs_eng_cutoff = msgs_eng_cutoff~"1, ";
		if (getprop("/controls/engines/engine[1]/cutoff"))
			msgs_eng_cutoff = msgs_eng_cutoff~"2, ";
		if (getprop("/controls/engines/engine[2]/cutoff"))
			msgs_eng_cutoff = msgs_eng_cutoff~"3, ";
		if (getprop("/controls/engines/engine[3]/cutoff"))
			msgs_eng_cutoff = msgs_eng_cutoff~"4, ";
		append(msgs_caution,substr(msgs_eng_cutoff,0,size(msgs_eng_cutoff)-2)~" SHUTDOWN");
	}
	var msgs_eng_fuel_press = "FUEL PRESS ENG ";
	if (!getprop("controls/fuel/tank[1]/x-feed") and !getprop("controls/fuel/tank[1]/pump-aft") and !getprop("controls/fuel/tank[1]/pump-fwd"))
		msgs_eng_fuel_press = msgs_eng_fuel_press~"1, ";
	if (!getprop("controls/fuel/tank[2]/x-feed") and !getprop("controls/fuel/tank[2]/pump-aft") and !getprop("controls/fuel/tank[2]/pump-fwd"))
		msgs_eng_fuel_press = msgs_eng_fuel_press~"2, ";
	if (!getprop("controls/fuel/tank[3]/x-feed") and !getprop("controls/fuel/tank[3]/pump-aft") and !getprop("controls/fuel/tank[3]/pump-fwd"))
		msgs_eng_fuel_press = msgs_eng_fuel_press~"3, ";
	if (!getprop("controls/fuel/tank[4]/x-feed") and !getprop("controls/fuel/tank[4]/pump-aft") and !getprop("controls/fuel/tank[4]/pump-fwd"))
		msgs_eng_fuel_press = msgs_eng_fuel_press~"4, ";
	if (size(msgs_eng_fuel_press) > 15)
		append(msgs_caution,substr(msgs_eng_fuel_press,0,size(msgs_eng_fuel_press)-2));
	if ((getprop("/consumables/fuel/tank[1]/level-lbs") < 1985) or (getprop("/consumables/fuel/tank[2]/level-lbs") < 1985) or (getprop("/consumables/fuel/tank[3]/level-lbs") < 1985) or (getprop("/consumables/fuel/tank[4]/level-lbs") < 1985))
		append(msgs_caution,"FUEL QTY LOW");
	if ((getprop("/consumables/fuel/total-fuel-lbs") < getprop("/controls/fuel/fuel-to-remain-lbs")) and (getprop("/controls/fuel/dump-valve") == 1))
		append(msgs_caution,"FUEL JETT SYS");
	if (getprop("controls/failures/gear[0]/stuck") or getprop("controls/failures/gear[1]/stuck") or getprop("controls/failures/gear[2]/stuck") or getprop("controls/failures/gear[3]/stuck") or getprop("controls/failures/gear[4]/stuck"))
		append(msgs_caution,"GEAR DISAGREE");
	if (getprop("controls/flight/speedbrake") and ((radio_alt < 800 and radio_alt > 15) or flaps > 0.7 or (radio_alt > 15 and throttle > 0.1)))
		append(msgs_caution,">SPEEDBRAKES EXT");	
}

var advisory_messages = func {
	var fuel = [0,getprop("/consumables/fuel/tank[1]/level-lbs"),getprop("/consumables/fuel/tank[2]/level-lbs"),getprop("/consumables/fuel/tank[3]/level-lbs"),getprop("/consumables/fuel/tank[4]/level-lbs"),0,0,0];
	var xfeed = [getprop("/controls/fuel/tank[1]/x-feed"),getprop("/controls/fuel/tank[2]/x-feed"),getprop("/controls/fuel/tank[3]/x-feed"),getprop("/controls/fuel/tank[4]/x-feed")];
	
	if ((getprop("/controls/anti-ice/engine[0]/carb-heat") or getprop("/controls/anti-ice/engine[1]/carb-heat") or getprop("/controls/anti-ice/engine[2]/carb-heat") or getprop("/controls/anti-ice/engine[3]/carb-heat") or getprop("/controls/anti-ice/wing-heat")) and getprop("/environment/temperature-degc") > 12)
		append(msgs_advisory,">ANTI-ICE");
	if (!getprop("/controls/engines/autostart"))
		append(msgs_advisory,">AUTOSTART OFF");
	if (!getprop("/controls/electric/battery"))
		append(msgs_advisory,">BATTERY OFF");
	if (getprop("/gear/gear[1]/btms") >= 5 or getprop("/gear/gear[2]/btms") >= 5 or getprop("/gear/gear[3]/btms") >= 5 or getprop("/gear/gear[4]/btms") >= 5)
		append(msgs_advisory,"BRAKE TEMP");
	if (getprop("/systems/electrical/bus-isolation[0]") or getprop("/systems/electrical/bus-isolation[1]") or getprop("/systems/electrical/bus-isolation[2]") or getprop("/systems/electrical/bus-isolation[3]")) {
		var msgs_bus_isln = ">ELEC BUS ISLN ";
		if (getprop("/systems/electrical/bus-isolation[0]"))
			msgs_bus_isln = msgs_bus_isln~"1, ";
		if (getprop("/systems/electrical/bus-isolation[1]"))
			msgs_bus_isln = msgs_bus_isln~"2, ";
		if (getprop("/systems/electrical/bus-isolation[2]"))
			msgs_bus_isln = msgs_bus_isln~"3, ";
		if (getprop("/systems/electrical/bus-isolation[3]"))
			msgs_bus_isln = msgs_bus_isln~"4, ";
		append(msgs_advisory,substr(msgs_bus_isln,0,size(msgs_bus_isln)-2));
	}
	if (!getprop("/controls/electric/generator-control[0]") or !getprop("/controls/electric/generator-control[1]") or !getprop("/controls/electric/generator-control[2]") or !getprop("/controls/electric/generator-control[3]")) {
		var msgs_elecGenOff = ">ELEC GEN OFF ";
		if (!getprop("/controls/electric/generator-control[0]"))
			msgs_elecGenOff = msgs_elecGenOff~"1, ";
		if (!getprop("/controls/electric/generator-control[1]"))
			msgs_elecGenOff = msgs_elecGenOff~"2, ";
		if (!getprop("/controls/electric/generator-control[2]"))
			msgs_elecGenOff = msgs_elecGenOff~"3, ";
		if (!getprop("/controls/electric/generator-control[3]"))
			msgs_elecGenOff = msgs_elecGenOff~"4, ";
		append(msgs_advisory,substr(msgs_elecGenOff,0,size(msgs_elecGenOff)-2));
	}
	if (getprop("/controls/flight/flaps") != getprop("/fdm/jsbsim/fcs/flap-cmd-norm"))
		append(msgs_advisory,">FLAP RELIEF");
	if (math.abs((fuel[1]-fuel[4])) > 3000)
		append(msgs_advisory,">FUEL IMBAL 1-4");
	if (math.abs((getprop("/consumables/fuel/tank[2]/level-lbs")-fuel[3])) > 6000)
		append(msgs_advisory,">FUEL IMBAL 2-3");
	if (((fuel[2] <= (fuel[1]+20)) or (fuel[3] <= (fuel[4]+20))) and !getprop("/controls/fuel/dump-valve") and (xfeed[0] or xfeed[3]))
		append(msgs_advisory,">FUEL TANK/ENG");
	#if ((((fuel[2] > fuel[1]) or (fuel[3] > fuel[4])) or getprop("/gear/gear/wow") == 1 ) and xfeed[0] and xfeed[3])
	#	append(msgs_advisory,">FUEL XFER 1+4");
	if (getprop("/systems/hydraulic/demand-pump-pressure-low[0]") == 1 or getprop("/systems/hydraulic/demand-pump-pressure-low[1]") == 1 or getprop("/systems/hydraulic/demand-pump-pressure-low[2]") == 1 or getprop("/systems/hydraulic/demand-pump-pressure-low[3]") == 1)
		append(msgs_advisory,"HYD PRESS DEM 1, 2, 3, 4");
	if (getprop("/systems/hydraulic/engine-pump-pressure-low[0]") == 1 or getprop("/systems/hydraulic/engine-pump-pressure-low[1]") == 1 or getprop("/systems/hydraulic/engine-pump-pressure-low[2]") == 1 or getprop("/systems/hydraulic/engine-pump-pressure-low[3]") == 1)
		append(msgs_advisory,"HYD PRESS ENG 1, 2, 3, 4");
	if (getprop("/controls/fuel/dump-valve") == 1)
		append(msgs_advisory,">JETT NOZ ON");
	if (((abs(fuel[1]-fuel[2]) > 10) or (abs(fuel[3]-fuel[4]) > 10)) and (!xfeed[0] or !xfeed[3]))
		append(msgs_advisory,">X FEED CONFIG");
	if (!getprop("controls/flight/yaw-damper"))
		append(msgs_advisory,">YAW DAMPER LWR, UPR");
	if (getprop("/autopilot/autobrake/step") == 0)
		append(msgs_advisory,"AUTOBRAKES");
	if ((getprop("consumables/tank[1]/temperature_degC") or 0) <= -37)
		append(msgs_advisory,">FUEL TEMP LOW");
	if (getprop("instrumentation/tcas/inputs/mode") == 0)
		append(msgs_advisory,">TCAS OFF");
}

var memo_messages = func {
	if (getprop("/controls/engines/con-ignition"))
		append(msgs_memo,"CON IGNITION ON");
	if (apu_running and (getprop("/engines/engine[4]/n1") > 95))
		append(msgs_memo,"APU RUNNING");
	if (parkbrake)
		append(msgs_memo,"PARK BRAKE SET");
	if (getprop("/autopilot/autobrake/step") == -2)
		append(msgs_memo,"AUTOBRAKES RTO");
	if (getprop("/autopilot/autobrake/step") > 0 and getprop("/autopilot/autobrake/step") < 5)
		append(msgs_memo,"AUTOBRAKES "~getprop("/autopilot/autobrake/step"));
	if (getprop("/autopilot/autobrake/step") == 5)
		append(msgs_memo,"AUTOBRAKES MAX");
	if (getprop("/controls/switches/seatbelt-sign") and getprop("/controls/switches/smoking-sign"))
		append(msgs_memo,"PASS SIGNS ON");
	else {
		if (getprop("/controls/switches/seatbelt-sign"))
			append(msgs_memo,"SEATBELTS ON");
		if (getprop("/controls/switches/smoking-sign"))
			append(msgs_memo,"NO SMOKING ON");
	}
	if (!pack[0] and !pack[1] and !pack[2])
		append(msgs_memo,"PACKS OFF");
	else {
		if (!pack[0] and !pack[1])
			append(msgs_memo,"PACKS 1+2 OFF");
		if (!pack[0] and !pack[2])
			append(msgs_memo,"PACKS 1+3 OFF");
		if (!pack[1] and !pack[2])
			append(msgs_memo,"PACKS 2+3 OFF");
		if (!pack[0] and (pack[1] and pack[2]))
			append(msgs_memo,"PACK 1 OFF");
		if (!pack[1] and (pack[0] and pack[2]))
			append(msgs_memo,"PACK 2 OFF");
		if (!pack[2] and (pack[0] and pack[1]))
			append(msgs_memo,"PACK 3 OFF");
	}
	if (getprop("/controls/pneumatic/pack-high-flow"))
		append(msgs_memo,"PACKS HIGH FLOW");
}
	
var update_listener_inputs = func() {
	# be nice to sim: some inputs rarely change. use listeners.
	enabled       = (getprop("sim/freeze/replay-state")!=1);
	reverser      = getprop("controls/engines/engine/reverser");
	gear_down     = getprop("controls/gear/gear-down");
	parkbrake     = getprop("controls/gear/brake-parking");
	apu_running   = getprop("engines/engine[4]/running");
	rudder_trim   = getprop("controls/flight/rudder-trim");
	elev_trim     = getprop("controls/flight/elevator-trim");
}

var update_throttle_input = func() {
	throttle = getprop("controls/engines/engine/throttle");
}
	
var update_system = func() {
	msgs_warning   = [];
	msgs_caution = [];
	msgs_advisory = [];
	msgs_memo    = [];
	
	radio_alt	= getprop("position/altitude-agl-ft")-16.5;
	speed		= getprop("velocities/airspeed-kt");
	
	takeoff_config_warnings();
	warning_messages();
	caution_messages();
	advisory_messages();
	memo_messages();
	
	update_eicas(msgs_warning,msgs_caution,msgs_advisory,msgs_memo);
	
	settimer(update_system,0.5);
}

var eicasCreated = 0;

setlistener("/instrumentation/eicas/display", func {
	if (eicasCreated == 1)
		secondary_eicas.del();
	secondary_eicas = canvas.new({
		"name": "EICASsecondary",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	secondary_eicas.addPlacement({"node": "Lower-EICAS-Screen"});
	var display = getprop("/instrumentation/eicas/display");
	var group = secondary_eicas.createGroup();
	if (display == "DRS")
		secEICAS = canvas_doors.new(group);
	elsif (display == "ELEC")
		secEICAS = canvas_elec.new(group);
	elsif (display == "ENG")
		secEICAS = canvas_eng.new(group);
	elsif (display == "FUEL")
		secEICAS = canvas_fuel.new(group);
	elsif (display == "GEAR")
		secEICAS = canvas_gear.new(group);
	elsif (display == "STAT")
		secEICAS = canvas_stat.new(group);
	secEICAS.update();
	eicasCreated = 1;
});

var showEicas = func() {
	var dlg = canvas.Window.new([400, 400], "dialog").set("resize", 1);
	dlg.setCanvas(secondary_eicas);
}
