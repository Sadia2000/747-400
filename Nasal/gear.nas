var gear = func {
	if (getprop ("controls/gear/gear-state") == -1 and !getprop("gear/gear[1]/wow")){
    controls.gearDown(1)
	}elsif (getprop ("controls/gear/gear-state") == 1){
    controls.gearDown(-1)

}
    settimer(gear,0.2);

};
setlistener("/sim/signals/fdm-initialized", gear);