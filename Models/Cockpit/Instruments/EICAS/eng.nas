# ==============================================================================
# Boeing 747-400 EICAS by Gijs de Rooy
# ==============================================================================

var canvas_eng = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_eng] };
		var eicas = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(eicas, "Aircraft/747-400/Models/Cockpit/Instruments/EICAS/eng.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["eng1ff","eng1n2","eng1oilp","eng1n2bar","eng2ff","eng2n2","eng2oilp","eng2n2bar","eng3ff","eng3n2","eng3oilp","eng3n2bar","eng4ff","eng4n2","eng4oilp","eng4n2bar"];
		foreach(var key; svg_keys) {
			m[key] = eicas.getElementById(key);
		}
		
		for (var i=1; i <= 4; i = i+1) {
			var c = m["eng"~i~"n2bar"].getCenter();
			m["eng"~i~"n2bar"].createTransform().setTranslation(-c[0], -c[1]);
			m["eng"~i~"n2bar_scale"] = m["eng"~i~"n2bar"].createTransform();
			m["eng"~i~"n2bar"].createTransform().setTranslation(c[0], c[1]);
		}
		
		return m;
	},
	update: func()
	{
		for (var i=1; i <= 4; i = i+1) {
			var n2 = getprop("engines/engine["~(i-1)~"]/n2") or 0;
			me["eng"~i~"n2"].setText(sprintf("%3.01f",n2));
			me["eng"~i~"n2bar_scale"].setScale(1, n2/112.5);
			if(n2 >= 112.5) {
				me["eng"~i~"n2"].setColor(1,0,0);
				me["eng"~i~"n2bar"].setColor(1,0,0);
			} else {
				me["eng"~i~"n2"].setColor(1,1,1);
				me["eng"~i~"n2bar"].setColor(1,1,1);
			}
			me["eng"~i~"oilp"].setText(sprintf("%2.0f",getprop("engines/engine["~(i-1)~"]/oil-pressure-psi")));
		}
		
		if (getprop("engines/engine[0]/fuel-flow_pph") != nil) {
			me["eng1ff"].setText(sprintf("%2.01f",getprop("engines/engine[0]/fuel-flow_pph")*LB2KG/1000));
			me["eng2ff"].setText(sprintf("%2.01f",getprop("engines/engine[1]/fuel-flow_pph")*LB2KG/1000));
			me["eng3ff"].setText(sprintf("%2.01f",getprop("engines/engine[2]/fuel-flow_pph")*LB2KG/1000));
			me["eng4ff"].setText(sprintf("%2.01f",getprop("engines/engine[3]/fuel-flow_pph")*LB2KG/1000));
		}

		settimer(func me.update(), 0.2);
	}
};