var liveryCanvas = canvas.new({
	"name": "Livery System",
	"size": [8192, 8192],
	"view": [8192, 8192],
	"mipmapping": 1 
});

var root = liveryCanvas.createGroup();
var update = func(){
	var layers = {};
	var path="Aircraft/747-400/Models/"; # IF YOU WANT TO USE IT WITH OTHER AIRCRAFTS JUST CHANGE THIS
	var image= getprop('/sim/model/livery/texture');
	layers[image] = root.createChild("image").setFile(path~image).setSize(8192,8192);

	layers[image].show();
	liveryCanvas.addPlacement({"node": "antennae"}); # AND THOSE WITH THE OBJECTS THAT LIVERY NEED TO BE APPLIED
	liveryCanvas.addPlacement({"node": "apu.intake"});
	liveryCanvas.addPlacement({"node": "cargo.door1"});
	liveryCanvas.addPlacement({"node": "cargo.door2"});
	liveryCanvas.addPlacement({"node": "cargo.door3"});
	liveryCanvas.addPlacement({"node": "cockpit-frame"});
	liveryCanvas.addPlacement({"node": "cover.L1"});
	liveryCanvas.addPlacement({"node": "cover.L2"});
	liveryCanvas.addPlacement({"node": "cover.L3"});
	liveryCanvas.addPlacement({"node": "cover.L4"});
	liveryCanvas.addPlacement({"node": "cover.L5"});
	liveryCanvas.addPlacement({"node": "cover.L6"});
	liveryCanvas.addPlacement({"node": "cover.L7"});
	liveryCanvas.addPlacement({"node": "cover.L8"});
	liveryCanvas.addPlacement({"node": "cover.R1"});
	liveryCanvas.addPlacement({"node": "cover.R2"});
	liveryCanvas.addPlacement({"node": "cover.R3"});
	liveryCanvas.addPlacement({"node": "cover.R4"});
	liveryCanvas.addPlacement({"node": "cover.R5"});
	liveryCanvas.addPlacement({"node": "cover.R6"});
	liveryCanvas.addPlacement({"node": "cover.R7"});
	liveryCanvas.addPlacement({"node": "cover.R8"});
	liveryCanvas.addPlacement({"node": "door.L1"});
	liveryCanvas.addPlacement({"node": "door.L2"});
	liveryCanvas.addPlacement({"node": "door.L3"});
	liveryCanvas.addPlacement({"node": "door.L4"});
	liveryCanvas.addPlacement({"node": "door.L5"});
	liveryCanvas.addPlacement({"node": "door.L6"});
	liveryCanvas.addPlacement({"node": "door.R1"});
	liveryCanvas.addPlacement({"node": "door.R2"});
	liveryCanvas.addPlacement({"node": "door.R3"});
	liveryCanvas.addPlacement({"node": "door.R4"});
	liveryCanvas.addPlacement({"node": "door.R5"});
	liveryCanvas.addPlacement({"node": "door.R6"});
	liveryCanvas.addPlacement({"node": "escape-hatch"});
	liveryCanvas.addPlacement({"node": "fuselage"});
	liveryCanvas.addPlacement({"node": "h-stab.trimL"});
	liveryCanvas.addPlacement({"node": "h-stab.trimR"});
	liveryCanvas.addPlacement({"node": "hinge.L1"});
	liveryCanvas.addPlacement({"node": "hinge.L2"});
	liveryCanvas.addPlacement({"node": "hinge.L3"});
	liveryCanvas.addPlacement({"node": "hinge.L4"});
	liveryCanvas.addPlacement({"node": "hinge.L5"});
	liveryCanvas.addPlacement({"node": "hinge.L6"});
	liveryCanvas.addPlacement({"node": "hinge.L7"});
	liveryCanvas.addPlacement({"node": "hinge.L8"});
	liveryCanvas.addPlacement({"node": "hinge.L9"});
	liveryCanvas.addPlacement({"node": "hinge.L10"});
	liveryCanvas.addPlacement({"node": "hinge.R1"});
	liveryCanvas.addPlacement({"node": "hinge.R2"});
	liveryCanvas.addPlacement({"node": "hinge.R3"});
	liveryCanvas.addPlacement({"node": "hinge.R4"});
	liveryCanvas.addPlacement({"node": "hinge.R5"});
	liveryCanvas.addPlacement({"node": "hinge.R6"});
	liveryCanvas.addPlacement({"node": "hinge.R7"});
	liveryCanvas.addPlacement({"node": "hinge.R8"});
	liveryCanvas.addPlacement({"node": "hinge.R9"});
	liveryCanvas.addPlacement({"node": "hinge.R10"});
	liveryCanvas.addPlacement({"node": "ladder.hatch"});
	liveryCanvas.addPlacement({"node": "mlg.coverLL"});
	liveryCanvas.addPlacement({"node": "mlg.coverLR"});
	liveryCanvas.addPlacement({"node": "mlg.coverUL"});
	liveryCanvas.addPlacement({"node": "mlg.coverUR"});
	liveryCanvas.addPlacement({"node": "mlg.doorLLA"});
	liveryCanvas.addPlacement({"node": "mlg.doorLLF"});
	liveryCanvas.addPlacement({"node": "mlg.doorLLM"});
	liveryCanvas.addPlacement({"node": "mlg.doorLRA"});
	liveryCanvas.addPlacement({"node": "mlg.doorLRF"});
	liveryCanvas.addPlacement({"node": "mlg.doorLRM"});
	liveryCanvas.addPlacement({"node": "mlg.doorRLA"});
	liveryCanvas.addPlacement({"node": "mlg.doorRLF"});
	liveryCanvas.addPlacement({"node": "mlg.doorRLM"});
	liveryCanvas.addPlacement({"node": "mlg.doorRRA"});
	liveryCanvas.addPlacement({"node": "mlg.doorRRF"});
	liveryCanvas.addPlacement({"node": "mlg.doorRRM"});
	liveryCanvas.addPlacement({"node": "n1.pylon"});
	liveryCanvas.addPlacement({"node": "n2.pylon"});
	liveryCanvas.addPlacement({"node": "n3.pylon"});
	liveryCanvas.addPlacement({"node": "n4.pylon"});
	liveryCanvas.addPlacement({"node": "nlg.doorLA"});
	liveryCanvas.addPlacement({"node": "nlg.doorLF"});
	liveryCanvas.addPlacement({"node": "nlg.doorRA"});
	liveryCanvas.addPlacement({"node": "nlg.doorRF"});
	liveryCanvas.addPlacement({"node": "press.L1"});
	liveryCanvas.addPlacement({"node": "press.L2"});
	liveryCanvas.addPlacement({"node": "press.R1"});
	liveryCanvas.addPlacement({"node": "press.R2"});
	liveryCanvas.addPlacement({"node": "rudder1"});
	liveryCanvas.addPlacement({"node": "rudder2"});
	liveryCanvas.addPlacement({"node": "slat.L1"});
	liveryCanvas.addPlacement({"node": "slat.L2"});
	liveryCanvas.addPlacement({"node": "slat.L3"});
	liveryCanvas.addPlacement({"node": "slat.L4"});
	liveryCanvas.addPlacement({"node": "slat.R1"});
	liveryCanvas.addPlacement({"node": "slat.R2"});
	liveryCanvas.addPlacement({"node": "slat.R3"});
	liveryCanvas.addPlacement({"node": "slat.R4"});
	liveryCanvas.addPlacement({"node": "v-stab"});
	liveryCanvas.addPlacement({"node": "wing.L1"});
	liveryCanvas.addPlacement({"node": "wing.L2"});
	liveryCanvas.addPlacement({"node": "wing.L3"});
	liveryCanvas.addPlacement({"node": "wing.R1"});
	liveryCanvas.addPlacement({"node": "wing.R2"});
	liveryCanvas.addPlacement({"node": "wing.R3"});
	liveryCanvas.addPlacement({"node": "winglet.L"});
	liveryCanvas.addPlacement({"node": "winglet.R"});
	liveryCanvas.addPlacement({"node": "n1.cowl"});
	liveryCanvas.addPlacement({"node": "n1.rev"});
	liveryCanvas.addPlacement({"node": "n2.cowl"});
	liveryCanvas.addPlacement({"node": "n2.rev"});
	liveryCanvas.addPlacement({"node": "n3.cowl"});
	liveryCanvas.addPlacement({"node": "n3.rev"});
	liveryCanvas.addPlacement({"node": "n4.cowl"});
	liveryCanvas.addPlacement({"node": "n4.rev"});
};
setlistener("/sim/model/livery/livery-change", func {
	update();
	setprop("/sim/model/livery/livery-change", 0);
}, 1, 0);