# 744 electrical system
# by reeed (Feb, Sep 2010)
# see 747-400 Acft Operating Manual

# Copyright (C) 2010 Ivan Ngeow <ivanngeow@gmail.com>
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

var apu_started = 0;
var on_ground = 1;
var pbrake_time = getprop('sim/time/elapsed-sec') - 50;
var debug = props.globals.initNode('debug', '', 'STRING');
var strobe = aircraft.light.new("/sim/model/lights/strobe", [0.5, 1], "/controls/lighting/strobe");
var beacon = aircraft.light.new("/sim/model/lights/beacon", [1, 2], "/controls/lighting/beacon");
var sys = 'systems/electrical/';
var controls = 'controls/electric/';

var ssb = 'open';
var ext_pwr = [0, 0];
var apu_gen = [0, 0];
var sync_src = ['', ''];

props.globals.initNode(controls~'ground-service', 1, 'BOOL');
props.globals.initNode(controls~'standby-power', 0, 'INT');
props.globals.initNode(controls~'battery', 1, 'BOOL');
props.globals.initNode(controls~'apu', 0, 'INT');	# probably redundant

props.globals.initNode(sys~'battery-off', 0, 'BOOL');

for (var i = 0; i < 2; i += 1) {
  props.globals.initNode(controls~'utility['~i~']', 1, 'BOOL');
  props.globals.initNode(sys~'utility-off['~i~']', 1, 'BOOL');
  ext_pwr[i] = props.globals.initNode(sys~'external-power['~i~']', 0, 'INT');
  apu_gen[i] = props.globals.initNode(sys~'apu-generator['~i~']' , 0, 'INT');
  sync_src[i] = props.globals.initNode(sys~'ac-sync-bus-source['~i~']', '', 'STRING');
}

var i = 28;
#setprop(sys, 'suppliers/main-batt-v', i);
#setprop(sys, 'suppliers/apu-batt-v', i);
#setprop(sys, 'outputs/main-hot-batt-bus-v', i);
#setprop(sys, 'outputs/apu-hot-batt-bus-v', i);

# EICAS synoptic props
for (var i = 0; i < 4; i += 1) {
  props.globals.initNode(sys~'eicas/utility['~i~']', 0, 'BOOL');
  props.globals.initNode(sys~'eicas/flowbar.gc['~i~']', 0, 'BOOL');
  props.globals.initNode(sys~'eicas/flowbar.bt['~i~']', 0, 'BOOL');
}

Nssb = props.globals.initNode(sys~'eicas/ssb', 'closed', 'STRING');
props.globals.initNode(sys~'eicas/flowbar.sync1', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.sync2.1', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.sync2.2', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.sync3.1', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.sync3.2', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.sync4', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.ssb', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.apu[0]', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.apu[1]', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.ext[0]', 0, 'BOOL');
props.globals.initNode(sys~'eicas/flowbar.ext[1]', 0, 'BOOL');

# there are 4 Elec objects, one for each bus
var Elec = {
  bt : 0,	# = bus ISLN light
  gc : 1,	# = gen OFF light
  ac : 0,	# ac-bus
  idg : 0,	# idg-v
  drive : 0,	# = drive DISC light
  disconnected : 0,	# drive disconnected

  new : func(i)
  {
    return {
      parents : [Elec],
      Nbus_tie  : props.globals.initNode(controls~'bus-tie['~i~']', 1, 'BOOL'),
      Ngen_cont : props.globals.initNode(controls~'generator-control['~i~']', 1, 'BOOL'),
      Nbus_isln : props.globals.initNode(sys~'bus-isolation['~i~']', me.bt, 'BOOL'),
      Ngen_off  : props.globals.initNode(sys~'generator-off['~i~']', me.gc, 'BOOL'),
      Ngen_drive : props.globals.initNode(sys~'generator-drive['~i~']', me.drive, 'BOOL'),
      Nac_bus   : props.globals.initNode(sys~'ac-bus['~i~']', me.ac, 'BOOL')
    };
  },

  # updates props based on internal vars
  update : func
  {
    me.Nbus_isln.setValue(me.bt);
    me.Ngen_off.setValue(me.gc);
    me.Ngen_drive.setValue(me.drive);
    me.Nac_bus.setValue(me.ac);
  }
};

var elec_sys = [ Elec.new(0), Elec.new(1), Elec.new(2), Elec.new(3) ];

##############################

var turn_stby_pwr_sw = func(n = 0)
{
  var a = getprop(controls, 'standby-power');

  a += n;
  if (a > 2) a = 2;
  if (a < 0) a = 0;
  setprop(controls, 'standby-power', a);
}

var turn_apu_sw = func(n = -1)
{
  var a = getprop(controls, 'apu');

      # set APU fuel ctrl to RUN if N2 > 15,
      # try again after 3 sec if not (as long as starter is still running)
      var igniter = func
      {
	var n2 = getprop('engines/apu/n2');
	if (n2 > 15) {
	  setprop('controls/engines/engine[4]/cutoff', 0);
	  print('>>> APU fuel run');
	} else {
	  if (getprop('engines/engine[4]/starter') == 1)
	    settimer(igniter, 3);
	}
      }

      var apu_shutdown = func
      {
	if (getprop(controls, 'apu') == 0) {
	  setprop('controls/engines/engine[4]/cutoff', 1);
	  print('>>> APU fuel cutoff');
	  apu_started = 0;
	}
      }

  a += n;
  if (a < 0) a = 0;
  setprop(controls, 'apu', a);

  if (a == 0 and apu_started) {
    var pwrL = sync_src[0].getValue();
    var pwrR = sync_src[1].getValue();

    # APU no longer available, unload it
    # note: abrupt power cut, do not call new_refresh(2)
    if (pwrL == 'apu') sync_src[0].setValue('');
    if (pwrR == 'apu') sync_src[1].setValue('');
    apu_gen[0].setValue(0);
    apu_gen[1].setValue(0);

    # 60 sec cooldown
    settimer(apu_shutdown, 60);

  } elsif (a == 2) {
    if (on_ground and apu_started == 0) {
      # check that the necessary batt busses are powered

      # APU start sequence
      setprop('controls/engines/engine[4]/cutoff', 1);
      setprop('controls/engines/engine[4]/starter', 1);
      settimer(igniter, 3);
      apu_started = 1;
    }
    # return the switch to ON
    settimer(func { setprop(controls, 'apu', 1); }, 0.6);
  } 
}

var push_utility = func(n)
{
  var p = controls ~ 'utility['~n~']';
  var i = getprop(p);
  i = 1 - i;
  setprop(p, i);
  new_refresh(9, n);
}

var push_batt_sw = func
{
  var p = controls ~ 'battery';
  var i = getprop(p);
  setprop(sys, 'battery-off', i);
  i = 1 - i;
  setprop(p, i);
}

var push_bus_tie = func(n)
{
  var p = elec_sys[n].Nbus_tie;
  var i = p.getValue();
  elec_sys[n].bt = i;
  i = 1 - i;
  p.setValue(i);

  if (i == 0)
    elec_sys[n].Nbus_isln.setValue(1);		# don't delay

  new_refresh(i == 0 ? 7 : 8, n);
}

var _connect_generator = func(n)
{
  # reconnect ac-sync-bus if IDG powered and BTB closed and gen cont ON
  if (elec_sys[n].idg and elec_sys[n].bt == 0 and
      elec_sys[n].Ngen_cont.getValue() == 1) {
    var n2 = n < 2 ? 0 : 1;
    sync_src[n2].setValue('idg1');
    elec_sys[n].gc = 0;
    elec_sys[n].ac = 1;
  }
}

var push_gen_cont = func(n)
{
  var p = elec_sys[n].Ngen_cont;
  var i = p.getValue();
  i = 1 - i;
  p.setValue(i);

  if (i == 0) {		# now off
    new_refresh(6, n);
  } else {
    if (elec_sys[n].idg) new_refresh(5, n);
  }
}

var push_drive_disc = func(n)
{
  # set irreversible var
  elec_sys[n].disconnected = 1;

  new_refresh(6, n);	# IDG off
}

var push_ext_apu = func(type, n)
{
  var ext = [ext_pwr[0].getValue(), ext_pwr[1].getValue()];
  var apu = [apu_gen[0].getValue(), apu_gen[1].getValue()];

  if (type == 'ext') {
    if (ext[n] == 1) {
      # connect EXT
      settimer(func { new_refresh(3, n*2); }, 3 + rand() * 3);
    } elsif (ext[n] == 2) {
      # disconnect EXT
      new_refresh(4, n*2);
    }
  }

  if (type == 'apu') {
    if (apu[n] == 1) {
      # connect APU
      settimer(func { new_refresh(1, n*2); }, 3 + rand() * 3);
    } elsif (apu[n] == 2) {
      # disconnect APU
      new_refresh(2, n*2);
    }
  }
}

# 100924 new refresh routine
# new_refresh() is called when a switch is flipped, or a change of
# state (IDG online, APU offline, EXT disconnect).
# State change is detected by elec_poll_state() every 1 sec

# We keep track of who is feeding each side of the AC sync bus:
#   unpowered, APU, EXT, IDG1, IDG2, IDG12, contraAPU, contraEXT, contraIDG

# n = [0123] for engines, [02] for halves (APU, EXT)
var new_refresh = func(action, n)
{
  var side  = int(n / 2);
  var side2 = side * 2;

	# powers the two AC busses from sync bus
	var sync_to_ac = func
	{
	  var i = sync_src[side].getValue() == '' ? 0 : 1;
	  if (elec_sys[side2  ].bt == 0) elec_sys[side2  ].ac = i;
	  if (elec_sys[side2+1].bt == 0) elec_sys[side2+1].ac = i;
	}

	var detach_idgs = func
	{
	  if (elec_sys[side2  ].bt == 0) elec_sys[side2  ].gc = 1;
	  if (elec_sys[side2+1].bt == 0) elec_sys[side2+1].gc = 1;
	}

	# attaches IDG to sync bus, powers up AC bus, gen cont,
	# detaches APU/EXT from sync bus
	var idg_on = func(x)
	{
	  if (elec_sys[n].Ngen_cont.getValue() == 1) {
	    elec_sys[n].gc = 0;
	    elec_sys[n].ac = 1;

	    if (elec_sys[n].bt == 0) {		# not isolated
	      var i = 1 - (n - side2);
	      sync_src[side].setValue('idg1');
	      # sync with the other IDG
	      _connect_generator(side2+i);
	      # detach APU/EXT
	      if (x != 0) x[side].setValue(1);
	    }
	  }
	}

  if (action == 6) {		# IDG off
    elec_sys[n].gc = 1;
    # AC bus also off if isolated
    if (elec_sys[n].bt == 1) elec_sys[n].ac = 0;
  } elsif (action == 7) {	# BTB open
    # determines AC bus and sync bus
    if (elec_sys[n].gc == 1) elec_sys[n].ac = 0;
    else {
      # depower both AC busses, if sync bus's only source is isolated
      var x = 1 - (n - side2);
      if (sync_src[side].getValue() == 'idg1' and
	  (elec_sys[side2+x].gc == 1 or elec_sys[side2+x].bt == 1)) {
	sync_src[side].setValue('');
	sync_to_ac();
      }
    }
  } elsif (action == 8) {	# BTB close
    if (elec_sys[n].gc == 0) {
      # IDG will take over the sync bus
      action = 5;
    } elsif (sync_src[side].getValue() != '')
      elec_sys[n].ac = 1;
  }

  if (sync_src[side].getValue() == '' or
      sync_src[side].getValue() == 'contra') {
    if (action == 1) {		# APU on
      sync_src[side].setValue('apu');
      sync_to_ac();
      apu_gen[side].setValue(2);
    } elsif (action == 3) {	# EXT on
      sync_src[side].setValue('ext');
      sync_to_ac();
      ext_pwr[side].setValue(2);
    } elsif (action == 5) {	# IDG on
      idg_on(0);
      sync_to_ac();
    }

  } elsif (sync_src[side].getValue() == 'apu') {
    if (action == 2) {		# APU desel
printf('DEBUG refresh(2): APU desel');
      apu_gen[side].setValue(1);
      sync_src[side].setValue('');
      # if GEN CONT on, switch back to IDG, otherwise bus is de-powered
      _connect_generator(side2  );
      _connect_generator(side2+1);
      # update AC busses
      sync_to_ac();
    } elsif (action == 3) {	# EXT on
      apu_gen[side].setValue(1);
      sync_src[side].setValue('ext');
      ext_pwr[side].setValue(2);
    } elsif (action == 5) {	# IDG on
      idg_on(apu_gen);
    }

  } elsif (sync_src[side].getValue() == 'ext') {
    if (action == 1) {		# APU on
      ext_pwr[side].setValue(1);
      sync_src[side].setValue('apu');
      apu_gen[side].setValue(2);
    } elsif (action == 4) {	# EXT desel
      ext_pwr[side].setValue(1);
      sync_src[side].setValue('');
      # connect GEN CONT if online
      _connect_generator(side2  );
      _connect_generator(side2+1);
      # update AC busses
      sync_to_ac();
    } elsif (action == 5) {	# IDG on
      idg_on(ext_pwr);
    }

  } elsif (sync_src[side].getValue() == 'idg1') {
    if (action == 1) {		# APU on
      sync_src[side].setValue('apu');
      apu_gen[side].setValue(2);
      # force GEN CONT off
      detach_idgs();
    } elsif (action == 3) {	# EXT on
      sync_src[side].setValue('ext');
      ext_pwr[side].setValue(2);
      # force GEN CONT off
      detach_idgs();
    } elsif (action == 5) {	# IDG on
      idg_on(0);
    } elsif (action == 6) {	# IDG off
      var x = 1 - (n - side2);
      # bus is depowered if both IDGs off, or the other BTB is open
      if (elec_sys[side2+x].bt == 1 or
	  (elec_sys[side2].gc == 1 and elec_sys[side2+1].gc == 1)) {
	sync_src[side].setValue('');
	elec_sys[side2  ].ac = 0;
	elec_sys[side2+1].ac = 0;
	# special case: last engine to be shut down
	if (sync_src[1-side].getValue() == 'contra') {
	  sync_src[1-side].setValue('');
	  elec_sys[(2-side2)  ].ac = 0;
	  elec_sys[(2-side2)+1].ac = 0;
	}
      }
    }
  }

  # SSB
  var contra = 1 - side;
  var s = ['', ''];
  s[side]   = sync_src[side].getValue();
  s[contra] = sync_src[contra].getValue();
  if (s[side] == s[contra] and s[side] == '')
    ssb = 'closed';
  elsif (s[side] == '') {
    sync_src[side].setValue('contra');
    sync_to_ac();
    ssb = 'closed';
  } elsif (s[contra] == '') {
    sync_src[contra].setValue('contra');
    side = contra;
    side2 = 2 - side2;
    sync_to_ac();
    ssb = 'closed';
  } elsif (s[side] == s[contra] and s[side] == 'idg1')
    ssb = 'closed';
  elsif (s[side] == 'contra' or s[contra] == 'contra')
    ssb = 'closed';
  else
    ssb = 'open';

  # utility
  var i = getprop(controls ~ 'utility[0]');
  var d = elec_sys[0].ac and i; setprop(sys~'eicas/utility[0]', d);
  var e = elec_sys[1].ac and i; setprop(sys~'eicas/utility[1]', e);
  setprop(sys, 'utility-off[0]', !(d and e));

  i = getprop(controls ~ 'utility[1]');
  d = elec_sys[2].ac and i; setprop(sys~'eicas/utility[2]', d);
  e = elec_sys[3].ac and i; setprop(sys~'eicas/utility[3]', e);
  setprop(sys, 'utility-off[1]', !(d and e));

  Nssb.setValue(ssb);

  foreach (i; elec_sys)
    i.update();	

  # update EICAS synoptic
  #settimer(flowbars, 0.8);	# after a delay
  flowbars();			# don't delay

  printf("DEBUG refresh(%d) sync %3s/%3s ac %d%d%d%d ssb %s", action, sync_src[0].getValue(), sync_src[1].getValue(), elec_sys[0].ac, elec_sys[1].ac, elec_sys[2].ac, elec_sys[3].ac, ssb);
}

var flowbars = func
{
	var countBTB = func
	{
	  var n = 0;
	  foreach (var i; elec_sys)
	    if (i.bt == 0) n += 1;
	  return n;
	}

  var doSSB = 0;
  var x = 0;
  s = [sync_src[0].getValue(), sync_src[1].getValue()];
  var c = countBTB();

  for (x = 0; x < 4; x += 1)
    setprop(sys~'eicas/flowbar.gc['~x~']', 1 - elec_sys[x].gc);

  setprop(sys~'eicas/flowbar.bt[0]', 0);
  setprop(sys~'eicas/flowbar.bt[1]', 0);
  setprop(sys~'eicas/flowbar.bt[2]', 0);
  setprop(sys~'eicas/flowbar.bt[3]', 0);
  setprop(sys~'eicas/flowbar.sync1', 0);
  setprop(sys~'eicas/flowbar.sync2.1', 0);
  setprop(sys~'eicas/flowbar.sync2.2', 0);
  setprop(sys~'eicas/flowbar.sync3.1', 0);
  setprop(sys~'eicas/flowbar.sync3.2', 0);
  setprop(sys~'eicas/flowbar.sync4', 0);
  setprop(sys~'eicas/flowbar.apu[0]', 0);
  setprop(sys~'eicas/flowbar.apu[1]', 0);
  setprop(sys~'eicas/flowbar.ext[0]', 0);
  setprop(sys~'eicas/flowbar.ext[1]', 0);
  setprop(sys~'eicas/flowbar.ssb', 0);

  if (s[0] == 'apu') {
    if (elec_sys[0].bt == 0) {
      x += 1;
      setprop(sys~'eicas/flowbar.bt[0]', 1);
      setprop(sys~'eicas/flowbar.sync1', 1);
    }
    if (elec_sys[1].bt == 0) {
      x += 1;
      setprop(sys~'eicas/flowbar.sync2.1', 1);
      setprop(sys~'eicas/flowbar.bt[1]', 1);
    }
    if (x) setprop(sys~'eicas/flowbar.apu[0]', 1);
  } elsif (s[0] == 'ext') {
    if (elec_sys[0].bt == 0) {
      x += 1;
      setprop(sys~'eicas/flowbar.bt[0]', 1);
    }
    if (elec_sys[1].bt == 0) {
      x += 1;
      setprop(sys~'eicas/flowbar.sync1', 1);
      setprop(sys~'eicas/flowbar.sync2.1', 1);
      setprop(sys~'eicas/flowbar.bt[1]', 1);
    }
    if (x) setprop(sys~'eicas/flowbar.ext[0]', 1);
  } elsif (s[0] == 'idg1') {
    if (c > 1) {
      if (elec_sys[0].bt == 0) {
	x += 1;
	setprop(sys~'eicas/flowbar.bt[0]', 1);
	setprop(sys~'eicas/flowbar.sync1', 1);
	setprop(sys~'eicas/flowbar.sync2.1', 1);
      }
      if (elec_sys[1].bt == 0) {
	x += 1;
	setprop(sys~'eicas/flowbar.bt[1]', 1);
      }
      if (s[1] == 'idg1' and x < c)
	doSSB = 1;
    }
  }

  x = 0;
  if (s[1] == 'apu') {
    if (elec_sys[3].bt == 0) {
      x += 1;
      setprop(sys~'eicas/flowbar.bt[3]', 1);
      setprop(sys~'eicas/flowbar.sync4', 1);
    }
    if (elec_sys[2].bt == 0) {
      x += 1;
      setprop(sys~'eicas/flowbar.sync3.1', 1);
      setprop(sys~'eicas/flowbar.bt[2]', 1);
    }
    if (x) setprop(sys~'eicas/flowbar.apu[1]', 1);
  } elsif (s[1] == 'ext') {
    if (elec_sys[3].bt == 0) {
      x += 1;
      setprop(sys~'eicas/flowbar.bt[3]', 1);
    }
    if (elec_sys[2].bt == 0) {
      x += 1;
      setprop(sys~'eicas/flowbar.sync4', 1);
      setprop(sys~'eicas/flowbar.sync3.1', 1);
      setprop(sys~'eicas/flowbar.bt[2]', 1);
    }
    if (x) setprop(sys~'eicas/flowbar.ext[1]', 1);
  } elsif (s[1] == 'idg1') {
    if (c > 1) {
      if (elec_sys[3].bt == 0) {
	x += 1;
	setprop(sys~'eicas/flowbar.bt[3]', 1);
	setprop(sys~'eicas/flowbar.sync4', 1);
	setprop(sys~'eicas/flowbar.sync3.1', 1);
      }
      if (elec_sys[2].bt == 0) {
	x += 1;
	setprop(sys~'eicas/flowbar.bt[2]', 1);
      }
      if (s[0] == 'idg1' and x < c)
	doSSB = 1;
    }
  }

  if (s[0] == 'contra') {
    if (elec_sys[0].bt == 0) {
      setprop(sys~'eicas/flowbar.bt[0]', 1);
      setprop(sys~'eicas/flowbar.sync1', 1);
      setprop(sys~'eicas/flowbar.sync2.1', 1);
      doSSB = 1;
    }
    if (elec_sys[1].bt == 0) {
      setprop(sys~'eicas/flowbar.bt[1]', 1);
      doSSB = 1;
    }
  }

  if (s[1] == 'contra') {
    if (elec_sys[3].bt == 0) {
      setprop(sys~'eicas/flowbar.bt[3]', 1);
      setprop(sys~'eicas/flowbar.sync4', 1);
      setprop(sys~'eicas/flowbar.sync3.1', 1);
      doSSB = 1;
    }
    if (elec_sys[2].bt == 0) {
      setprop(sys~'eicas/flowbar.bt[2]', 1);
      doSSB = 1;
    }
  }

  if (doSSB) {
    setprop(sys~'eicas/flowbar.sync2.2', 1);
    setprop(sys~'eicas/flowbar.sync3.2', 1);
    setprop(sys~'eicas/flowbar.ssb', 1);
  }
}

# static
var apu1 = 0;	# APU1 avail?
var apu2 = 0;	# APU2 avail?
var ext1 = 0;	# EXT1 avail?
var ext2 = 0;	# EXT2 avail?

var elec_poll_state = func
{
  var i = 0;
  var ep = [0, 0];

  # APU
  i = getprop(sys, 'suppliers/apu-v[0]') > 110 ? 1 : 0;
  if (i != apu1) {
    # APU no longer available
    if (apu1 == 1 and i == 0) new_refresh(2, 0);
    apu1 = i;
    apu_gen[0].setValue(i);
  }
  i = getprop(sys, 'suppliers/apu-v[1]') > 110 ? 1 : 0;
  if (i != apu2) {
    if (apu2 == 1 and i == 0) new_refresh(2, 1*2);
    apu2 = i;
    apu_gen[1].setValue(i);
  }

  # EXT
  var t = getprop('sim/time/elapsed-sec');
  on_ground = getprop('gear/gear[2]/wow') or getprop('gear/gear[3]/wow');
  ep = [0, 0];
  i = getprop(sys, 'suppliers/external-v[0]') > 110 ? 1 : 0;
  if (i != ext1) {
    if (ext1 == 1 and i == 0) new_refresh(4, 0);
    ext1 = i;
    ext_pwr[0].setValue(i);
  }
  i = getprop(sys, 'suppliers/external-v[1]') > 110 ? 1 : 0;
  if (i != ext2) {
    if (ext2 == 1 and i == 0) new_refresh(4, 1*2);
    ext2 = i;
    ext_pwr[1].setValue(i);
  }

  # EXT availability depends on pbrake_time
  if (pbrake_time == 0) {	# brake released
    # depower the sync bus
    ext_pwr[0].setValue(0);
    ext_pwr[1].setValue(0);
    if (sync_src[0].getValue() == 'ext')
      new_refresh(4, 0);
    if (sync_src[1].getValue() == 'ext')
      new_refresh(4, 1);
  } else {
    # EXT avbl after 60 sec with pbrake set
    if (t - pbrake_time > 60) {
      if (ext1 and ext_pwr[0].getValue() == 0) ext_pwr[0].setValue(1);
      if (ext2 and ext_pwr[1].getValue() == 0) ext_pwr[1].setValue(1);
    }
  }

  # IDG online
  for (i = 0; i < 4; i += 1) {
    var idg = getprop(sys, 'suppliers/idg-v['~i~']');
    # drive lights out if engines running
    var j = elec_sys[i].idg;
    var k = idg > 110 ? 1 : 0;
    elec_sys[i].drive = idg > 110 ? 0 : 1;
    if (k != j) {
      elec_sys[i].idg = k;
      k == 1 ? new_refresh(5, i) : new_refresh(6, i);
    }
  }

  #printf("DEBUG apu %d,%d ext %d,%d idg %d,%d,%d,%d", apu1, apu2, ext1, ext2, elec_sys[0].idg, elec_sys[1].idg, elec_sys[2].idg, elec_sys[3].idg);
  debug.setValue('DEBUG apu'~ apu1~apu2~ 'ext'~ ext1~ext2~ 'idg'~ elec_sys[0].idg~ elec_sys[1].idg~ elec_sys[2].idg~ elec_sys[3].idg);
  settimer(elec_poll_state, 1);
}

var mark_pbrake = func(n)
{
  if (n.getValue() == 1)
    pbrake_time = getprop('sim/time/elapsed-sec');
  else
    pbrake_time = 0;
}

elec_poll_state();
#setlistener("controls/electric/battery", batt_sw);
#setlistener("systems/electrical/outputs/main-batt-bus-v", main_batt_bus);
setlistener('controls/gear/brake-parking', mark_pbrake);

print('747-400 electrical system by Ivan Ngeow.');

# 
# /systems/electrical/outputs/
# ground-service-bus
# ground-handling-bus
# apu-standby-bus
# main-standby-bus
# capt-transfer-bus
# fo-transfer-bus
# apu-batt-bus
# main-batt-bus
# apu-hot-batt-bus
# main-hot-batt-bus
# ac-bus[4]
# dc-bus[4]
