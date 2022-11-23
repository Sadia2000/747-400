var inses = [];
var limit = func (n,l,h) {
	if (n<l) n=l;
	if (n>h) n=h;
	return n;
}
var errmdl = {          # drift and radio update model
        node: nil,
        delete: nil,
};
errmdl.new = func (node="/ins/drift") {
        var m = { parents: [errmdl], };
        m.node = node;
        setprop(node~"/pitcherr", rand()-0.5);
        setprop(node~"/rollerr", rand()-0.5);
        settimer(func m.run(), 0);
        return m;
}
errmdl.del = func (funct = "true") {
        me.delete = funct;
}
errmdl.run = func {
        if (me.delete == nil) settimer(func me.run(), 1);
	else {
		if (me.delete != "true") call(me.delete, nil, var err = []);
	}
        interpolate(me.node~"/pitcherr", getprop(me.node~"/pitcherr")*(0.9+0.1*rand()), 1);
        interpolate(me.node~"/rollerr", getprop(me.node~"/rollerr")*(0.9+0.1*rand()), 1);
}
errmdl.reset = func {
	setprop(me.node~"/pitcherr", rand()-0.5);
        setprop(me.node~"/rollerr", rand()-0.5);
}
var ins = {
	dtime: .1,
	latfttodeg: 0,
	nvelfps: 0,
	evelfps: 0,
	track: 0,
	magtrack: 0,
	vspeed: 0,
	gndspd: 0,
	hdg: 0,
	maghdg: 0,
	dhdg: 0,
	pitch: 0,
	dpitch: 0,
	roll: 0,
	droll: 0,
	delete: nil,
	driftrate: 0,
	mode: "off",
	alignst: 0,
};
ins.new = func (name = "ins") {
	var m = { parents: [ins], };
	m.name = name;
	m.errmdl = errmdl.new("/ins/"~name~"/drift");
	m.lat = 0;
	m.long = 0;
	m.time = getprop("/sim/time/elapsed-sec");
	setprop("/ins/"~name~"/mode", "off");
	setprop("/ins/"~name~"/lat", getprop("/position/latitude-deg"));
	setprop("/ins/"~name~"/long", getprop("/position/longitude-deg"));
	settimer(func m.run(), 0);
	return m;
}
ins.del = func (funct = "true") {
	me.delete = funct;
}
ins.nav = func {
	# Integration
	me.nvelfps = getprop("/velocities/speed-north-fps");
	me.evelfps = getprop("/velocities/speed-east-fps");
	me.vspeed = 60*getprop("/velocities/vertical-speed-fps");
	me.gndspd = math.sqrt(me.nvelfps*me.nvelfps + me.evelfps*me.evelfps) * .592483801295896;
	me.track = math.atan2(me.evelfps,me.nvelfps) * 180 / math.pi;
	me.track = me.track < 0 ? me.track+360 : me.track;
	me.magtrack = me.track-getprop("/environment/magnetic-variation-deg");
	me.magtrack = me.magtrack < 0 ? me.magtrack + 360 : me.magtrack;
	me.magtrack = me.magtrack > 360 ? me.magtrack - 360 : me.magtrack;
	me.latfttodeg = 180/((getprop("/position/sea-level-radius-ft")+getprop("/position/altitude-ft"))*math.pi);
	me.lat += getprop("/velocities/speed-north-fps")*me.dtime*me.latfttodeg;
	me.long += getprop("/velocities/speed-east-fps")*me.dtime*me.latfttodeg/math.sin((90-me.lat)*math.pi/180);
	if (me.long > 180) me.long += -360;
	if (me.long < -180) me.long += 360;             # is this right?
	me.hdg = getprop("/orientation/heading-deg");
	me.maghdg = me.hdg - getprop("/environment/magnetic-variation-deg");
	me.dhdg = getprop("/orientation/yaw-rate-degps");
	me.pitch = getprop("/orientation/pitch-deg") + getprop("/ins/"~me.name~"/drift/pitcherr");
	me.dpitch = getprop("/orientation/pitch-rate-degps");
	me.roll = getprop("/orientation/roll-deg") + getprop("/ins/"~me.name~"/drift/rollerr");
	me.droll = getprop("/orientation/roll-rate-degps");

	setprop("/ins/"~me.name~"/lat", me.lat);
	setprop("/ins/"~me.name~"/long", me.long);
	setprop("/ins/"~me.name~"/trutrack", me.track);
	setprop("/ins/"~me.name~"/magtrack", me.magtrack);
	setprop("/ins/"~me.name~"/north-velocity-fps", me.nvelfps);
	setprop("/ins/"~me.name~"/east-velocity-fps", me.evelfps);
	setprop("/ins/"~me.name~"/ground-speed", me.gndspd);
	setprop("/ins/"~me.name~"/vspeed", me.vspeed);
	setprop("/ins/"~me.name~"/truheading", me.hdg);
	setprop("/ins/"~me.name~"/magheading", me.maghdg);
	setprop("/ins/"~me.name~"/heading-rate", me.dhdg);
	setprop("/ins/"~me.name~"/pitch", me.pitch);
	setprop("/ins/"~me.name~"/pitch-rate", me.dpitch);
	setprop("/ins/"~me.name~"/roll-angle", me.roll);
	setprop("/ins/"~me.name~"/roll-rate", me.droll);
}
ins.att = func {
	var elaptm = getprop("/sim/time/elapsed-sec") - me.alignst;
	me.dhdg = getprop("/orientation/yaw-rate-degps");
	me.pitch = getprop("/orientation/pitch-deg") + getprop("/ins/"~me.name~"/drift/pitcherr");
	me.dpitch = getprop("/orientation/pitch-rate-degps");
	me.roll = getprop("/orientation/roll-deg") + getprop("/ins/"~me.name~"/drift/rollerr");
	me.droll = getprop("/orientation/roll-rate-degps");
	setprop("/ins/"~me.name~"/heading-rate", me.dhdg);
	setprop("/ins/"~me.name~"/pitch", me.pitch);
	setprop("/ins/"~me.name~"/pitch-rate", me.dpitch);
	setprop("/ins/"~me.name~"/roll-angle", me.roll);
	setprop("/ins/"~me.name~"/roll-rate", me.droll);
}
ins.align = func {
	var alignt = me.time - me.alignst;	# time since alignment started
	if (getprop("/ins/"~me.name~"/nolatlonin") != "true") {	# TODO: make this only happen once, when data is entered.
		me.lat = getprop("/ins/"~me.name~"/lat");
		me.long = getprop("/ins/"~me.name~"/long");
	} else {
		me.lat = getprop("/position/latitude-deg");
		me.long = getprop("/position/longitude-deg");
	}
	me.nvelfps = 0;
	me.evelfps = 0;
	me.vspeed = 0;
	setprop("/ins/"~me.name~"/north-velocity-fps", 0);
	setprop("/ins/"~me.name~"/east-velocity-fps", 0);
	setprop("/ins/"~me.name~"/ground-speed", 0);
	setprop("/ins/"~me.name~"/vspeed", 0);
	if (alignt > 500) {	# you don't have navigation working until after 500 seconds
		setprop("/ins/"~me.name~"/navwork", "true");
		me.hdg = getprop("/orientation/heading-deg");
		me.maghdg = me.hdg - getprop("/environment/magnetic-variation-deg");
		setprop("/ins/"~me.name~"/truheading", me.hdg);
		setprop("/ins/"~me.name~"/magheading", me.maghdg);
		setprop("/ins/"~me.name~"/done-aligning", "true");
	} else {
		setprop("/ins/"~me.name~"/done-aligning", "false");
		setprop("/ins/"~me.name~"/navwork", "false");
	}
	if (alignt > 10) {	# you don't have attitude working until after 10 seconds
		setprop("/ins/"~me.name~"/attwork", "true");
		me.pitch = getprop("/orientation/pitch-deg") + getprop("/ins/"~me.name~"/drift/pitcherr");
		me.roll = getprop("/orientation/roll-deg") + getprop("/ins/"~me.name~"/drift/rollerr");
		setprop("/ins/"~me.name~"/pitch", me.pitch);
		setprop("/ins/"~me.name~"/roll-angle", me.roll);
	} else setprop("/ins/"~me.name~"/attwork", "false");
	setprop("/ins/"~me.name~"/heading-rate", me.dhdg);
	setprop("/ins/"~me.name~"/pitch-rate", me.dpitch);
	setprop("/ins/"~me.name~"/roll-rate", me.droll);

}
ins.run = func {
	if (me.delete == nil) settimer(func me.run(), 0);
	else {
		if (me.delete != "true") call(me.delete, nil, var err = []);
	}
	if (me.mode != getprop("/ins/"~me.name~"/mode")) {
		if (me.mode == "off") {
			me.errmdl.reset();
		}
		me.mode = getprop("/ins/"~me.name~"/mode");
		if (me.mode == "align" or me.mode == "align-then-nav") {
			me.alignst = me.time;	# you have just entered alignment
		}
		if (me.mode != "nav" and me.mode != "att" and me.mode != "align" and me.mode != "align-then-nav") {
			me.mode = "off";
			setprop("/ins/"~me.name~"/mode", "off");
		}
	}
	me.dtime = getprop("/sim/time/elapsed-sec") - me.time;
	me.time += me.dtime;
	if (getprop("/ins/"~me.name~"/mode") == "nav") me.nav();
	elsif (getprop("/ins/"~me.name~"/mode") == "att") me.att();
	elsif (getprop("/ins/"~me.name~"/mode") == "align") me.align();
	elsif (getprop("/ins/"~me.name~"/mode") == "align-then-nav") {
		if (getprop("/ins/"~me.name~"/done-aligning") == "true") me.nav();
		else me.align();
	}
}
var mix = {
#       lat: 0,     # waiting until quaternions are used
#       long: 0,
	nvelfps: 0,
	evelfps: 0,
	track: 0,
	magtrack: 0,
	vspeed: 0,
	gndspd: 0,
	hdg: 0,
	maghdg: 0,
	hdgx: 0,
	hdgy: 0,
	dhdg: 0,
	pitch: 0,
	dpitch: 0,
	roll: 0,
	rollx: 0,
	rolly: 0,
	droll: 0,
};
var run = func () {
	settimer(run, 0);
	mix.nvelfps = 0;
	mix.evelfps = 0;
	mix.vspeed = 0;
	mix.gndspd = 0;
	mix.hdgx = 0;
	mix.hdgy = 0;
	mix.dhdg = 0;
	mix.pitch = 0;
	mix.dpitch = 0;
	mix.roll = 0;
	mix.rollx = 0;
	mix.rolly = 0;
	mix.droll = 0;
	for(var i=0; i<size(inses); i+=1) {
		mix.nvelfps += inses[i].nvelfps;
		mix.evelfps += inses[i].evelfps;
		mix.vspeed += inses[i].vspeed;
		mix.gndspd += inses[i].gndspd;
		mix.hdgx += math.sin(inses[i].hdg*math.pi/180);
		mix.hdgy += math.cos(inses[i].hdg*math.pi/180);
		mix.dhdg += inses[i].dhdg;
		mix.pitch += inses[i].pitch;
		mix.dpitch += inses[i].dpitch;
		mix.rollx += math.sin(inses[i].roll*math.pi/180);
		mix.rolly += math.cos(inses[i].roll*math.pi/180);
		mix.droll += inses[i].droll;
	}
	mix.nvelfps *= 1/i;
	mix.evelfps *= 1/i;
	mix.track = math.atan2(mix.evelfps, mix.nvelfps)*180/math.pi;
	mix.track = mix.track < 0 ? mix.track+360 : mix.track;
	mix.magtrack = mix.track-getprop("/environment/magnetic-variation-deg");
	mix.magtrack = mix.magtrack < 0 ? mix.magtrack + 360 : mix.magtrack;
	mix.magtrack = mix.magtrack > 360 ? mix.magtrack - 360 : mix.magtrack;
	mix.vspeed *= 1/i;
	mix.gndspd *= 1/i;
	mix.hdg = math.atan2(mix.hdgx, mix.hdgy)*180/math.pi;
	mix.hdg = mix.hdg < 0 ? mix.hdg+360 : mix.hdg;
	mix.maghdg = mix.hdg-getprop("/environment/magnetic-variation-deg");
	mix.maghdg = mix.maghdg < 0 ? mix.maghdg + 360 : mix.maghdg;
	mix.maghdg = mix.maghdg > 360 ? mix.maghdg - 360 : mix.maghdg;
	mix.dhdg *= 1/i;
	mix.pitch *= 1/i;
	mix.dpitch *= 1/i;
	mix.roll = math.atan2(mix.rollx, mix.rolly)*180/math.pi;
	mix.droll *= 1/i;
#	setprop("/ins/lat", mix.lat);
#	setprop("/ins/long", mix.long);
	setprop("/ins/trutrack", mix.track);
	setprop("/ins/magtrack", mix.magtrack);
	setprop("/ins/north-velocity-fps", mix.nvelfps);
	setprop("/ins/east-velocity-fps", mix.evelfps);
	setprop("/ins/ground-speed", mix.gndspd);
	setprop("/ins/vspeed", mix.vspeed);
	setprop("/ins/truheading", mix.hdg);
	setprop("/ins/magheading", mix.maghdg);
	setprop("/ins/heading-rate", mix.dhdg);
	setprop("/ins/pitch", mix.pitch);
	setprop("/ins/pitch-rate", mix.dpitch);
	setprop("/ins/roll-angle", mix.roll);
	setprop("/ins/roll-rate", mix.droll);
}
var main = func () {
	var path = getprop("/sim/aircraft-dir") ~ "/ins.xml";
	io.read_properties(path, "/ins");
	var inschildren = props.globals.getChild("ins").getChildren();
	for(var i=0; i<size(inschildren); i+=1) {
		inses = append(inses, ins.new(inschildren[i].getName()));
	}
	settimer(run, 0);
}
setlistener("/sim/signals/fdm-initialized", main);
