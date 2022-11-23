# =====
# Doors
# =====

Doors = {};

Doors.new = func {
   obj = { parents : [Doors],
           door1 : aircraft.door.new("controls/electric/wiperl", 0.75),
           door2 : aircraft.door.new("controls/electric/wiperr", 0.75)
         };
   return obj;
};

Doors.door1export = func {
   me.door1.toggle();
}

Doors.door2export = func {
   me.door2.toggle();
}

# ==============
# Initialization
# ==============

# objects must be here, otherwise local to init()
doorsystem = Doors.new();

# ==============
# Animations
# ==============

var wiperl = func {
	if (getprop("controls/electric/wiperl/switch") == 1 or getprop("controls/electric/wiperl/switch") == 2){
		if (getprop("controls/electric/wiperl/position-norm") == 1 or getprop("controls/electric/wiperl/position-norm") == 0){
			Boeing747.doorsystem.door1export();
		}
 	}
 	if (getprop("controls/electric/wiperl/switch") == 0){
 		if (getprop("controls/electric/wiperl/position-norm") == 1){
 			Boeing747.doorsystem.door1export();
 		}
 	}
	if (getprop("controls/electric/wiperl/switch") == 1){
		doorsystem.door1.swingtime = 0.75
	}
	if (getprop("controls/electric/wiperl/switch") == 2){
		doorsystem.door1.swingtime = 0.49
	}

	settimer(wiperl, 0);
}
_setlistener("/sim/signals/fdm-initialized", wiperl);

var wiperr = func {
	if (getprop("controls/electric/wiperr/switch") == 1 or getprop("controls/electric/wiperr/switch") == 2){
		if (getprop("controls/electric/wiperr/position-norm") == 1 or getprop("controls/electric/wiperr/position-norm") == 0){
			Boeing747.doorsystem.door2export();
		}
	}
	if (getprop("controls/electric/wiperr/switch") == 0){
		if (getprop("controls/electric/wiperr/position-norm") == 1){
			Boeing747.doorsystem.door2export();
		}
	}
	if (getprop("controls/electric/wiperr/switch") == 1){
		doorsystem.door2.swingtime = 0.75
	}
	if (getprop("controls/electric/wiperr/switch") == 2){
		doorsystem.door2.swingtime = 0.49
	}

	settimer(wiperr, 0);
}
_setlistener("/sim/signals/fdm-initialized", wiperr);