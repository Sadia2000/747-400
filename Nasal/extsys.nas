var extinguisherani = func(engine){
if((getprop("engines/engine["~engine~"]/on-fire") or getprop("engines/engine["~engine~"]/cutoff")) and !getprop("engines/engine["~engine~"]/extinguisher-arm")){
setprop("engines/engine["~engine~"]/extinguisher-arm", 1);
if(getprop("controls/hydraulic/engine-pump["~engine~"]")){
hydraulic.hyd_sys[engine].edp_sw();
}
if(electrical.elec_sys[engine].idg){
electrical.new_refresh(6, engine);
}
}
}
var extinguish = func(eng,extinguisher){
if(!getprop("engines/engine["~eng~"]/extinguisher-"~extinguisher)){
setprop("engines/engine["~eng~"]/extinguisher-"~extinguisher, 1);
setprop("engines/engine["~eng~"]/on-fire", 0);
var timer = maketimer(1, func(){
setprop("engines/engine["~eng~"]/extinguished", 0);
});
timer.singleShot = 1;
timer.start();
setprop("engines/engine["~eng~"]/extinguished", 1);
}
}
