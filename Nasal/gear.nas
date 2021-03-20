var gearlever = func {
if (getprop ("controls/gear/gear-state") == -1){
setprop ("controls/gear/gear-down", 1);
}
if (getprop ("controls/gear/state") == 1){
setprop ("controls/gear/gear-down", 1);
}
}

var bodyaltgear = func {
if (getprop ("controls/gear/gear-state") == 0)
setprop ("controls/gear/gear-down", 1);
setprop ("/controls/failures/gear[0]/stuck", 0);
setprop ("/controls/failures/gear[2]/stuck", 0);
setprop ("/controls/failures/gear[3]/stuck", 0);
}

var wingsaltgear = func {
if (getprop ("controls/gear/gear-state") == 0)
setprop ("controls/gear/gear-down", 1);
setprop ("/controls/failures/gear[1]/stuck", 0);
setprop ("/controls/failures/gear[5]/stuck", 0);
}