# ==============================================================================
# Boeing 747-400 pfd by Gijs de Rooy
# ==============================================================================

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2))
			x = x + m;
	return x;
}

var pfd_canvas = nil;
var pfd_display = nil;

var canvas_PFD = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_PFD] };
		var pfd = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(pfd, "Aircraft/747-400/Models/Cockpit/Instruments/PFD/PFD.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["afdsMode","altTape","altText1","altText2","atMode","bankPointer","baroSet","cmdSpd","compass","curAlt1","curAlt2","curAlt3","curAltBox","curAltMtrTxt","curSpd","curSpdTen","dhText","dmeDist","fdX","fdY","flaps0","flaps1","flaps10","flaps20","flaps5","gpwsAlert","gsPtr","gsScale","horizon","ilsCourse","ilsId","locPtr","locScale","locScaleExp","machText","markerBeacon","markerBeaconText","maxSpdInd","mcpAltMtr","minimums","minSpdInd","pitchMode","radioAltInd","risingRwy","risingRwyPtr","rollMode","selAltBox","selAltPtr","selHdgText","spdTape","spdTrend","speedText","tenThousand","touchdown","v1","v2","vertSpd","vr","vref","vsiNeedle","vsPointer","atArmText","latArmText","vertArmText"];
		foreach(var key; svg_keys) {
			m[key] = pfd.getElementById(key);
		}
		debug.dump(m["horizon"].getCenter());
		m.h_trans = m["horizon"].createTransform();
		m.h_rot = m["horizon"].createTransform();
		
		var c1 = m["spdTrend"].getCenter();
		m["spdTrend"].createTransform().setTranslation(-c1[0], -c1[1]);
		m["spdTrend_scale"] = m["spdTrend"].createTransform();
		m["spdTrend"].createTransform().setTranslation(c1[0], c1[1]);
		var c2 = m["risingRwyPtr"].getCenter();
		m["risingRwyPtr"].createTransform().setTranslation(-c2[0], -c2[1]);
		m["risingRwyPtr_scale"] = m["risingRwyPtr"].createTransform();
		m["risingRwyPtr"].createTransform().setTranslation(c2[0], c2[1]);
		
		m["horizon"].set("clip", "rect(241.8, 694.7, 733.5, 211.1)");
		m["minSpdInd"].set("clip", "rect(156, 1024, 829, 0)");
		m["maxSpdInd"].set("clip", "rect(156, 1024, 829, 0)");
		m["spdTape"].set("clip", "rect(156, 1024, 829, 0)");
		m["altTape"].set("clip", "rect(156, 1024, 829, 0)");
		m["cmdSpd"].set("clip", "rect(156, 1024, 829, 0)");
		m["selAltPtr"].set("clip", "rect(156, 1024, 829, 0)");
		m["vsiNeedle"].set("clip", "rect(287, 1024, 739, 930)");
		m["compass"].set("clip", "rect(700, 1024, 990, 0)");
		m["curAlt3"].set("clip", "rect(463, 1024, 531, 0)");
		m["curSpdTen"].set("clip", "rect(455, 1024, 541, 0)");

		return m;
	},
	update: func()
	{
		var radioAlt = getprop("/position/altitude-agl-ft")-24;
		#var radioAlt = getprop("instrumentation/radar-altimeter/radar-altitude-ft") or 0;
		var alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		var ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
		if (ias < 30)
			ias = 30;
		var pitch = getprop("/orientation/pitch-deg");
		var roll =  getprop("/orientation/roll-deg");
		var hdg =  getprop("/orientation/heading-deg");
		var vSpd = getprop("/velocities/vertical-speed-fps");
		var wow = getprop("/gear/gear/wow");
		var apAlt = getprop("/it-autoflight/input/alt");
		var apSpd = getprop("/it-autoflight/input/kts");
		
		#10 deg = 105px
		me.h_trans.setTranslation(0,pitch*10.5);
		me.h_rot.setRotation(-roll*D2R,me["horizon"].getCenter());
		
		me["bankPointer"].setRotation(-roll*D2R);
		me["compass"].setRotation(-hdg*D2R);
			
		# Flight director
		if (getprop("/it-autoflight/input/fd1") or getprop("/it-autoflight/input/fd2")) {
			if (getprop("/it-autoflight/fd/roll-bar") != nil) {
				var fdRoll = (getprop("/it-autoflight/fd/roll-bar"))*3;
				if (fdRoll > 90)
					fdRoll = 90;
				elsif (fdRoll < -90)
					fdRoll = -90;
				me["fdX"].setTranslation(fdRoll,0);
			}
			if (getprop("/it-autoflight/fd/pitch-bar") != nil) {
				var fdPitch = (getprop("/it-autoflight/fd/pitch-bar"))*3;
				if (fdPitch > 60)
					fdPitch = 60;
				elsif (fdPitch < -45)
					fdPitch = -45;
				me["fdY"].setTranslation(0,-fdPitch);
			}
			me["fdX"].show();
			me["fdY"].show();
		} else {
			me["fdX"].hide();
			me["fdY"].hide();
		}
		
		# 121 kts = 675 px -> 5.584
		# 806 ft = 675 px -> 0.837
		var cmdSpd = apSpd-ias;
		if (cmdSpd > 60)
			cmdSpd = 60;
		elsif(cmdSpd < -60)
			cmdSpd = -60;
		me["cmdSpd"].setTranslation(0,-cmdSpd*5.584);
		var mach = getprop("velocities/mach");
		if (mach >= 0.40) {
			me["machText"].setText(sprintf("%.3f",mach));
			me["machText"].show();
		} else
			me["machText"].hide();
		me["altText1"].setText(sprintf("%2.0f",math.floor(apAlt/1000)));
		me["altText2"].setText(sprintf("%03.0f",math.mod(apAlt,1000)));
		me["mcpAltMtr"].setText(sprintf("%5.0f",apAlt*FT2M));
		
		#if ()
		#	gpwsAlert.setText(getprop("instrumentation/mk-viii/outputs/warning"));
		#else
		#	gpwsAlert.setText("");
		var altAbs = abs(alt);
		me["curAlt1"].setText(sprintf("%2.0f",math.floor(altAbs/1000)));
		me["curAlt2"].setText(sprintf("%1.0f",math.mod(math.floor(altAbs/100),10)));
		me["curAlt3"].setTranslation(0,(math.mod(altAbs,100)/20)*35);
		me["curAltMtrTxt"].setText(sprintf("%4.0f",alt*FT2M));
		var curAltDiff = alt-apAlt;
		if (abs(curAltDiff) > 300 and abs(curAltDiff) < 900) {
			me["curAltBox"].setStrokeLineWidth(5);
			if ((alt > apAlt and vSpd > 1) or (alt < apAlt and vSpd < 1)) {
				me["curAltBox"].setColor(1,0.5,0);
				me["selAltBox"].hide();
			} else {
				me["curAltBox"].setColor(1,1,1);
				me["selAltBox"].show();
			}
		} else {
			me["curAltBox"].setStrokeLineWidth(3);
			me["curAltBox"].setColor(1,1,1);
			me["selAltBox"].hide();
		}
		if (curAltDiff > 403)
			curAltDiff = 403;
		elsif (curAltDiff < -403)
			curAltDiff = -403;
		me["selAltPtr"].setTranslation(0,curAltDiff*0.837);

		me["curSpd"].setText(sprintf("%2.0f",math.floor(ias/10)));
		me["curSpdTen"].setTranslation(0,math.mod(ias,10)*45);
		
		if (getprop("instrumentation/marker-beacon/outer")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("OM");
		} elsif (getprop("instrumentation/marker-beacon/middle")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("MM");
		} elsif (getprop("instrumentation/marker-beacon/inner")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("IM");
		} else {
			me["markerBeacon"].hide();
		}
		
		var sigQ = getprop("instrumentation/nav/signal-quality-norm") or 0;
		if(sigQ > 0.95) {
			var deflection = getprop("instrumentation/nav/heading-needle-deflection-norm"); # 1 dot = 1 degree, full needle deflection is 10 deg
			if (deflection > 0.3)
				deflection = 0.3;
			if (deflection < -0.3)
				deflection = -0.3;
				
			me["locPtr"].show();
			
			if (radioAlt < 2500) {
				me["risingRwy"].show();
				me["risingRwyPtr"].show();
				if (radioAlt< 200) {
					if(abs(deflection) < 0.1)
						me["risingRwy"].setTranslation(deflection*500,-(200-radioAlt)*0.682);
					else
						me["risingRwy"].setTranslation(deflection*250,-(200-radioAlt)*0.682);
					me["risingRwyPtr_scale"].setScale(1, ((200-radioAlt)*0.682)/11);
				} else {
					me["risingRwy"].setTranslation(deflection*150,0);
					me["risingRwyPtr_scale"].setScale(1, 1);
				}
			} else {
				me["risingRwy"].hide();
				me["risingRwyPtr"].hide();
			}
			
			if(abs(deflection) < 0.233) # 2 1/3 dot
				me["locPtr"].setColorFill(1,0,1,1);
			else
				me["locPtr"].setColorFill(1,0,1,0);
			if(abs(deflection) < 0.1) {
				me["locPtr"].setTranslation(deflection*500,0);
				me["risingRwyPtr"].setTranslation(deflection*500,0);
				me["locScaleExp"].show();
				me["locScale"].hide();
			} else {
				me["locPtr"].setTranslation(deflection*250,0);
				me["risingRwyPtr"].setTranslation(deflection*250,0);
				me["locScaleExp"].hide();
				me["locScale"].show();
			}
		} else {
			me["locPtr"].hide();
			me["locScaleExp"].hide();
			me["locScale"].hide();
			me["risingRwy"].hide();
			me["risingRwyPtr"].hide();
		}
		
		if(getprop("instrumentation/nav/gs-in-range")) {
			me["gsPtr"].show();
			me["gsScale"].show();
			me["gsPtr"].setTranslation(0,-getprop("instrumentation/nav/gs-needle-deflection-norm")*140);
		} else {
			me["gsPtr"].hide();
			me["gsScale"].hide();
		}
		
		if (alt < 10000 and alt > 0)
			me["tenThousand"].show();
		else
			me["tenThousand"].hide();
		if (vSpd != nil) {
			var vertSpd = vSpd*60;
			if (abs(vertSpd) > 400) {
				me["vertSpd"].setText(sprintf("%4.0f",roundToNearest(vertSpd,50)));
				me["vertSpd"].show();
			} else {
				me["vertSpd"].hide();
			}
			var targetVs = getprop("instrumentation/pfd/target-vs") or 0;
			me["vsPointer"].setTranslation(0,-targetVs);
		}
		if (radioAlt < 2500) {
			if (radioAlt > 500)
				me["radioAltInd"].setText(sprintf("%4.0f",roundToNearest(radioAlt,20)));
			elsif (radioAlt > 100)
				me["radioAltInd"].setText(sprintf("%4.0f",roundToNearest(radioAlt,10)));
			else
				me["radioAltInd"].setText(sprintf("%4.0f",roundToNearest(radioAlt,2)));
			me["radioAltInd"].show();
		} else {
			me["radioAltInd"].hide();
		}
		var spdTrend = getprop("instrumentation/pfd/speed-trend-up") or 0;
		if (abs(spdTrend > 0.1))
			me["spdTrend_scale"].setScale(1, spdTrend);
		else
			me["spdTrend_scale"].setScale(1, 0);
		
		me["spdTape"].setTranslation(0,ias*5.584);
		me["altTape"].setTranslation(0,alt*0.837);
		
		var vsiDeg = getprop("instrumentation/pfd/vsi-needle-deg") or 0;
		me["vsiNeedle"].setRotation(vsiDeg*D2R);
		
		settimer(func me.update(), 0.03);
	},
	update_ap_modes: func()
	{
		if (itaf.Output.ap1.getValue() or itaf.Output.ap2.getValue()) {
			me["afdsMode"].setText("CMD");
		} elsif (itaf.Output.fd1.getValue() or itaf.Output.fd2.getValue()) {
			me["afdsMode"].setText("FD");
		} else {
			me["afdsMode"].setText("");
		}
		
		me["atMode"].setText(itaf.fmaThr.getValue());
		me["atArmText"].setText("");
		me["rollMode"].setText(itaf.fmaLat.getValue());
		me["latArmText"].setText(itaf.fmaArm.getValue());
		me["pitchMode"].setText(itaf.fmaVert.getValue());
		
		if (itaf.Output.apprArm.getValue())
		    me["vertArmText"].setText("G/S");
		else
		    me["vertArmText"].setText("");
			
		if (itaf.Output.vert.getValue() == 1)
			me["vsPointer"].show();
		else
			me["vsPointer"].hide();
	},
	update_slow: func()
	{
		me.update_ap_modes();
		var wow = getprop("gear/gear/wow");
		var flaps = getprop("/controls/flight/flaps");
		var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
		var apSpd = getprop("it-autoflight/input/kts");
		var dh = getprop("instrumentation/mk-viii/inputs/arinc429/decision-height");
		
		if (var navId = getprop("instrumentation/nav/data-is-valid") != nil)
			me["ilsId"].setText(navId);
		
		var v1 = getprop("instrumentation/fmc/vspeeds/V1") or 0;
		if (v1 > 0) {
			if (wow) {
				me["v1"].show();
				me["v1"].setTranslation(0,-v1*5.63915);
				me["vr"].show();
				me["vr"].setTranslation(0,-getprop("instrumentation/fmc/vspeeds/VR")*5.63915);
			} else {
				me["v1"].hide();
				me["vr"].hide();
			}
			me["v2"].setTranslation(0,-getprop("instrumentation/fmc/vspeeds/V2")*5.63915);
		} else {
			me["v1"].hide();
			me["vr"].hide();
		}
		if (getprop("instrumentation/pfd/flaps-0-kt") != nil) {
			me["flaps0"].setTranslation(0,-getprop("instrumentation/pfd/flaps-0-kt")*5.63915);
			me["flaps1"].setTranslation(0,-getprop("instrumentation/pfd/flaps-1-kt")*5.63915);
			me["flaps5"].setTranslation(0,-getprop("instrumentation/pfd/flaps-5-kt")*5.63915);
			me["flaps10"].setTranslation(0,-getprop("instrumentation/pfd/flaps-10-kt")*5.63915);
			me["flaps20"].setTranslation(0,-getprop("instrumentation/pfd/flaps-20-kt")*5.63915);
		}
		
		if (getprop("instrumentation/fmc/phase-name") == "APPROACH") {
			if (flaps == 1)
				var vref = getprop("instrumentation/pfd/flaps-30-kt");
			else
				var vref = getprop("instrumentation/pfd/flaps-25-kt");
			me["vref"].show();
			me["vref"].setTranslation(0,-vref*5.63915);
		} else
			me["vref"].hide();
		
		me["flaps0"].hide();
		me["flaps1"].hide();
		me["flaps5"].hide();
		me["flaps10"].hide();
		me["flaps20"].hide();
		if (alt < 20000) {
			if (flaps == 0.033) {
				me["flaps0"].show(); me["flaps1"].show();
			} elsif (flaps == 0.167) {
				me["flaps1"].show(); me["flaps5"].show();
			} elsif (flaps == 0.333) {
				me["flaps5"].show(); me["flaps10"].show();
			} elsif (flaps == 0.667) {
				me["flaps10"].show(); me["flaps20"].show();
			}
		}
		if (getprop("instrumentation/weu/state/stall-speed") != nil)
			me["minSpdInd"].setTranslation(0,-getprop("instrumentation/weu/state/stall-speed")*5.63915);
		if (getprop("instrumentation/fmc/vspeeds/Vmax") != nil)
			me["maxSpdInd"].setTranslation(0,-getprop("instrumentation/fmc/vspeeds/Vmax")*5.63915);
		if (dh != nil)
			me["minimums"].setTranslation(0,-dh*0.9);
		if (getprop("autopilot/route-manager/destination/field-elevation-ft") != nil) {
			me["touchdown"].setTranslation(0,-getprop("autopilot/route-manager/destination/field-elevation-ft")*0.9);
			me["touchdown"].show();
		} else
			me["touchdown"].hide();
		
		if(wow or (getprop("instrumentation/airspeed-indicator/indicated-speed-kt") <= 35)) {
			me["minSpdInd"].hide();
			me["maxSpdInd"].hide();
		} else {
			me["minSpdInd"].show();
			me["maxSpdInd"].show();
		}
		me["baroSet"].setText(sprintf("%2.2f",getprop("instrumentation/altimeter/setting-inhg")));
		me["ilsCourse"].setText(sprintf("CRS %3.0f",getprop("instrumentation/nav/radials/selected-deg")));
		me["dhText"].setText(sprintf("DH%3.0f",dh));
		me["selHdgText"].setText(sprintf("%3.0f",getprop("it-autoflight/input/hdg")));
		me["speedText"].setText(sprintf("%3.0f",apSpd));
        
		#if (getprop("instrumentation/dme/in-range")) {
		var navDist = getprop("instrumentation/nav/nav-distance") or 0;
		if(navDist > 0) {
			me["dmeDist"].setText(sprintf("DME %2.01f",navDist*0.000539));
			me["dmeDist"].show();
		} else {
			me["dmeDist"].hide();
		}
		
		settimer(func me.update_slow(), 0.5);
	},
};

setlistener("sim/signals/fdm-initialized", func() {
	pfd_display = canvas.new({
		"name": "PFD",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	pfd_display.addPlacement({"node": "screen.pfd-capt"});
	pfd_display.addPlacement({"node": "screen.pfd-fo"});
	var group = pfd_display.createGroup();
	pfd_canvas = canvas_PFD.new(group);
	pfd_canvas.update();
	pfd_canvas.update_slow();
});

setlistener("sim/signals/reinit", func pfd_display.del());

var showPfd = func() {
	var dlg = canvas.Window.new([600, 600], "dialog").set("resize", 1);
	dlg.setCanvas(pfd_display);
}
