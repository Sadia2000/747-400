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
layers[image] = root.createChild("image")
     .setFile(path~image)
     .setSize(8192,8192);

layers[image].show();
liveryCanvas.addPlacement({"node": "fuselage"}); # AND THOSE WITH THE OBJECTS THAT LIVERY NEED TO BE APPLIED
liveryCanvas.addPlacement({"node": "rudder"});
liveryCanvas.addPlacement({"node": "vstab"});
liveryCanvas.addPlacement({"node": "nlg_small_door.left"});
liveryCanvas.addPlacement({"node": "nlg_large_door.left"});
liveryCanvas.addPlacement({"node": "nlg_large_door.right"});
liveryCanvas.addPlacement({"node": "nlg_small_door.right"});
liveryCanvas.addPlacement({"node": "wlg_inner_door.left"});
liveryCanvas.addPlacement({"node": "wlg_outer_door.left"});
liveryCanvas.addPlacement({"node": "wlg_inner_door.right"});
liveryCanvas.addPlacement({"node": "wlg_outer_door.right"});
liveryCanvas.addPlacement({"node": "nosecone"});
liveryCanvas.addPlacement({"node": "cargodoor"});
liveryCanvas.addPlacement({"node": "winglet_left"});
liveryCanvas.addPlacement({"node": "winglet_right"});
liveryCanvas.addPlacement({"node": "engine_body"});
liveryCanvas.addPlacement({"node": "engine_reverser"});
};
setlistener("/sim/model/livery/livery-change", func {
update();
setprop("/sim/model/livery/livery-change", 0);
}, 1, 0);