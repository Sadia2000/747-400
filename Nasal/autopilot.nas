####    autopilot help-functions                                                               ####
####    Author: Markus Bulik                                                                   ####
####    This file is licenced under the terms of the GNU General Public Licence V2 or later    ####


var abs = func(n) { return(n < 0 ? -n : n); }
var maxclambed = func(n, m, clamb) {
	if (n > m) {
		return (n < clamb ? n : clamb);
	}
	else {
		return (m < clamb ? m : clamb);
	}
}

var listenerApInitFunc = func {
	# do initializations of new properties

	setprop("/autopilot/internal/target-kp-for-altitude-vspeed-hold", -0.0095);
	setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", 0.00001);
	setprop("/autopilot/internal/target-ti-for-altitude-vspeed-hold", 10.0);
	setprop("/autopilot/internal/target-airspeed-factor-for-altitude-hold", 0.05);
	setprop("/autopilot/internal/target-climb-rate-fps", 0.0);
	setprop("/autopilot/internal/elevator-position", 0.0);

	setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min", -30.0);
	setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max", 30.0);

	setprop("/autopilot/internal/vertical-speed-fpm-clambed", 2400.0);
	setprop("/autopilot/internal/vspeed-altidude-controller-is-elapsed", 1);
	setprop("/autopilot/internal/target-altitude-agl-min-ft", 0.0);

	setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", 0.05);
	setprop("/autopilot/internal/target-ti-for-heading-hold", 15.0);
	setprop("/autopilot/internal/target-td-for-heading-hold", 0.0005);
	setprop("/autopilot/internal/target-kp-for-heading-hold-rudder", -0.005);

	setprop("/autopilot/internal/wing-leveler-hold-heading", 0);
	setprop("/autopilot/internal/wing-leveler-hold-heading-bug-deg", 0.0);

	setprop("/autopilot/internal/nav1-stear-ground-mode", 0.0);
	setprop("/autopilot/internal/nav1-pitch-deg-ground-mode", 0.0);
	setprop("/autopilot/internal/nav1-vspeed-ground-mode", 0);
	setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -450.0);
	setprop("/autopilot/internal/nav1-kp-for-throttle-ground-mode", 0.03);
	setprop("/autopilot/internal/VOR-near-by", 0);
	setprop("/autopilot/internal/target-roll-deg-for-VOR-near-by", 0.0);
	setprop("/autopilot/internal/kp-for-gs-hold", -0.015);
	setprop("/autopilot/internal/gs-rate-of-climb-scale-factor", 1.0);
	setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", 0.0);

	setprop("/autopilot/internal/speed-with-pitch-mach-scale-factor", 450.0);

	setprop("/autopilot/internal/route-manager-waypoint-near-by", 0);

	setprop("/autopilot/internal/bank-limit-filtered", getprop("/autopilot/settings/bank-limit"));
}
setlistener("/sim/signals/fdm-initialized", listenerApInitFunc);


###############################################
## altitude hold,                            ##
## vertical speed hold - objects/functions   ##
###############################################

## special pid-control-adjust for altitude-hold
# Params: Kp, Kp-max, Kp-min, Ti, Td
var AltitudeHoldPidControllerAdjust = {
	new : func(kp, kpMinClamb, kpMaxClamb, ti, td) {
	m = { parents : [AltitudeHoldPidControllerAdjust] };

		m.kp = kp;				# initial Kp-value of the pid-controller
		m.correctedKp = m.kp;		# corrected Kp-value of the pid-controller
		m.kpMinClamb = kpMinClamb;		# minimal value for kp
		m.kpMaxClamb = kpMaxClamb;		# maximal value for kp
		m.ti = ti;
		m.td = td;

		m.kpInterpolate = 0;
		m.kpInterpolationIncrement = 0;
		m.kpInterpolationLastKp = m.kp;
		m.kpInterpolationIsRunning = 0;

		m.tdInterpolate = 0;
		m.tdInterpolationCounter = 0;
		m.tdInterpolationIncrement = 0.00001;
		m.tdInterpolationIsRunning = 0;

		m.climbRateInterpolationCounter = 0;
		m.climbRateMinInterpolationIncrement = 0.1;
		m.climbRateMaxInterpolationIncrement = 0.1;
		m.targetClimbRateFpsMin = 0.0;
		m.targetClimbRateFpsMax = 0.0;
		m.verticalSpeedFpmClambed = 0.0;

		m.correctedSpeedByPitchKp = -0.35;
		m.speedByPitchKpInterpolate = 0;
		m.speedByPitchKpInterpolationIncrement = 0;
		m.speedByPitchKpInterpolationLastKp = m.correctedSpeedByPitchKp;
		m.speedByPitchKpInterpolationIsRunning = 0;

		# tank-geometry

		m.tank0Geometry = {"y": 0,      "x": 0,    "tank": "/consumables/fuel/tank[0]/level-gal_us"};
		m.tank1Geometry = {"y": -1000,  "x": 500,  "tank": "/consumables/fuel/tank[1]/level-gal_us"};
		m.tank2Geometry = {"y": -700,   "x": 300,  "tank": "/consumables/fuel/tank[2]/level-gal_us"};
		m.tank3Geometry = {"y": -300,   "x": 100,  "tank": "/consumables/fuel/tank[3]/level-gal_us"};
		m.tank4Geometry = {"y": 300,    "x": 100,  "tank": "/consumables/fuel/tank[4]/level-gal_us"};
		m.tank5Geometry = {"y": 700,    "x": 300,  "tank": "/consumables/fuel/tank[5]/level-gal_us"};
		m.tank6Geometry = {"y": 1000,   "x": 500,  "tank": "/consumables/fuel/tank[6]/level-gal_us"};
		m.tank7Geometry = {"y": 0,      "x": 1400, "tank": "/consumables/fuel/tank[7]/level-gal_us"};

		m.totalGalUS = 200000.0;
		m.xMoment = 320.0;
		m.xMomentThreshold = 320.0;

		m.counterForElevatorMovement = 0;
		m.elevatorTrimPosAverages = [0.0, 0.0, 0.0, 0.0, 0.0];

		m.counterForThrottleMovement = 0;
		m.pitchAverages = [0.0, 0.0, 0.0, 0.0, 0.0];

		m.counterForAglSecond = 0;
		m.terrainElevationMax = 0.0;
		m.lat = getprop("/position/latitude-deg");
		m.lon = getprop("/position/longitude-deg");

		return m;
	},

	calculateXMoment : func() {
		me.totalGalUS = getprop(me.tank0Geometry["tank"]) +
				getprop(me.tank1Geometry["tank"]) +
				getprop(me.tank2Geometry["tank"]) +
				getprop(me.tank3Geometry["tank"]) +
				getprop(me.tank4Geometry["tank"]) +
				getprop(me.tank5Geometry["tank"]) +
				getprop(me.tank6Geometry["tank"]) +
				getprop(me.tank7Geometry["tank"]);
		if (me.totalGalUS > 0) {	# avoid division by zero
			me.xMoment = (getprop(me.tank0Geometry["tank"]) * me.tank0Geometry["x"] +
					getprop(me.tank1Geometry["tank"]) * me.tank1Geometry["x"] +
					getprop(me.tank2Geometry["tank"]) * me.tank2Geometry["x"] +
					getprop(me.tank3Geometry["tank"]) * me.tank3Geometry["x"] +
					getprop(me.tank4Geometry["tank"]) * me.tank4Geometry["x"] +
					getprop(me.tank5Geometry["tank"]) * me.tank5Geometry["x"] +
					getprop(me.tank6Geometry["tank"]) * me.tank6Geometry["x"] +
					getprop(me.tank7Geometry["tank"]) * me.tank7Geometry["x"]) / me.totalGalUS;
		}
	},

	# Params: Kp, Kp-max, Kp-min, Ti, Td
	init : func(kp, kpMinClamb, kpMaxClamb, ti, td) {
		me.kp = kp;
		me.kpMinClamb = kpMinClamb;
		me.kpMaxClamb = kpMaxClamb;
		me.ti = ti;
		me.td = td;
		me.correctedKp = me.kp;

		me.kpInterpolate = 0;
		me.kpInterpolationIncrement = 0;
		me.kpInterpolationLastKp = m.kp;
		me.kpInterpolationIsRunning = 0;

		me.tdInterpolate = 0;
		me.tdInterpolationCounter = 0;
		me.tdInterpolationIncrement = 0.00001;
		me.tdInterpolationIsRunning = 0;

		me.climbRateInterpolationCounter = 0;
		me.climbRateMinInterpolationIncrement = 0.1;
		me.climbRateMaxInterpolationIncrement = 0.1;
		me.targetClimbRateFpsMin = 0.0;
		me.targetClimbRateFpsMax = 0.0;
		me.verticalSpeedFpmClambed = 0.0;

		me.correctedSpeedByPitchKp = -0.35;
		me.speedByPitchKpInterpolate = 0;
		me.speedByPitchKpInterpolationIncrement = 0;
		me.speedByPitchKpInterpolationLastKp = me.correctedSpeedByPitchKp;
		me.speedByPitchKpInterpolationIsRunning = 0;

		me.counterForElevatorMovement = 0;
		me.elevatorTrimPosAverages[0] = 0.0;
		me.elevatorTrimPosAverages[1] = 0.0;
		me.elevatorTrimPosAverages[2] = 0.0;
		me.elevatorTrimPosAverages[3] = 0.0;
		me.elevatorTrimPosAverages[4] = 0.0;

		me.counterForThrottleMovement = 0;
		me.pitchAverages[0] = 0.0;
		me.pitchAverages[1] = 0.0;
		me.pitchAverages[2] = 0.0;
		me.pitchAverages[3] = 0.0;
		me.pitchAverages[4] = 0.0;

		me.counterForAglSecond = 0;
		me.terrainElevationMax = 0.0;
		me.lat = getprop("/position/latitude-deg");
		me.lon = getprop("/position/longitude-deg");
	},

	# may be called from outside, if smooth iterpolation of Kp value for speed-with-pitch is required
	interpolateSpeedWithPitchKp : func(iterations) {
		if (me.speedByPitchKpInterpolationIsRunning == 0) {
			me.speedByPitchKpInterpolationLastKp = me.correctedSpeedByPitchKp;
			me.speedByPitchKpInterpolate = 0.0;
			me.speedByPitchKpInterpolationIncrement = me.speedByPitchKpInterpolationLastKp / iterations;

			#print ("AltitudeHoldPidControllerAdjust: speedByPitchKpInterpolationIncrement=", me.speedByPitchKpInterpolationIncrement);

			me.speedByPitchKpInterpolationIsRunning = 1;
		}
	},

	# overwrite this method from parent 'PidControllerKpAdjust'
	# params: lbs : the total weight in lbs
	calculateSpeedWithPitchKp : func(lbs, airspeedKt, altitudeFt) {

		#print("AltitudeHoldPidControllerAdjust: lbs=", lbs);
		#print("AltitudeHoldPidControllerAdjust: xMoment=", me.xMoment);

		me.correctedSpeedByPitchKp = -0.35;

		# deal with airspeed, altitude, weight, CoG
		if (lbs > 250000.0 or me.xMoment > 300.0) {
			me.correctedSpeedByPitchKp = -0.25;
		}

		if (me.speedByPitchKpInterpolationIsRunning == 1) {

			me.speedByPitchKpInterpolate += me.speedByPitchKpInterpolationIncrement;
			if (me.speedByPitchKpInterpolationIncrement > 0) {
				if (me.speedByPitchKpInterpolate >= me.speedByPitchKpInterpolationLastKp) {
					me.speedByPitchKpInterpolationIsRunning = 0;
				}
			}
			else {
				if (me.speedByPitchKpInterpolate <= me.speedByPitchKpInterpolationLastKp) {
					me.speedByPitchKpInterpolationIsRunning = 0;
				}
			}
			me.correctedSpeedByPitchKp = me.speedByPitchKpInterpolate;
		}
	},


	# adjusts 'Kp' value for spee-with-pitch mode
	# params: error: the error of the controlled parameter
	#         xMoment: the actual x-moment
	#         lbs  : the total weight in lbs
	#         airspeedKt: the actual airspeed in knots
	#         altitudeFt: actual altitude in feet
	# this routine must be called subsequently in certain time-intervalls
	adjustSpeedWithPitchKp : func(lbs, airspeedKt, altitudeFt) {

		me.calculateSpeedWithPitchKp(lbs, airspeedKt, altitudeFt);

		#print("AltitudeHoldPidControllerAdjust: correctedSpeedByPitchKp=", me.correctedSpeedByPitchKp);
		setprop("/autopilot/internal/target-kp-for-speed-with-pitch-hold", me.correctedSpeedByPitchKp);
	},



	# may be called from outside, if smooth iterpolation of Kp value is required
	interpolateKp : func(iterations) {
		if (me.kpInterpolationIsRunning == 0) {
			me.kpInterpolationLastKp = me.correctedKp;
			me.kpInterpolate = (me.kpInterpolationLastKp * 0.1);
			me.kpInterpolationIncrement = me.kpInterpolationLastKp / iterations;

			#print ("AltitudeHoldPidControllerAdjust: kpInterpolationIncrement=", me.kpInterpolationIncrement);

			me.kpInterpolationIsRunning = 1;

			# set the property
			me.clambKp();
			#print("AltitudeHoldPidControllerAdjust.interpolateKp: kpInterpolate=", me.kpInterpolate);
			setprop("/autopilot/internal/target-kp-for-altitude-vspeed-hold", me.kpInterpolate);
		}
	},

	clambKp : func() {
		# clamb kp

		if (me.kpInterpolationIsRunning == 0) {
			me.correctedKp = (me.correctedKp < me.kpMinClamb ? me.kpMinClamb : me.correctedKp);
			me.correctedKp = (me.correctedKp > me.kpMaxClamb ? me.kpMaxClamb : me.correctedKp);
		}
		else {
			me.kpInterpolate += me.kpInterpolationIncrement;
			if (me.kpInterpolationIncrement > 0) {
				if (me.kpInterpolate >= me.kpInterpolationLastKp) {
					me.kpInterpolationIsRunning = 0;
				}
			}
			else {
				if (me.kpInterpolate <= me.kpInterpolationLastKp) {
					me.kpInterpolationIsRunning = 0;
				}
			}
			me.correctedKp = me.kpInterpolate;
		}

		#print ("AltitudeHoldPidControllerAdjust: clambKp -> me.correctedKp=", me.correctedKp);
	},

	# overwrite this method from parent 'PidControllerKpAdjust'
	# params: lbs : the total weight in lbs
	calculateKp : func(lbs, airspeedKt, altitudeFt) {

		me.correctedKp = me.kp;

		#print("AltitudeHoldPidControllerAdjust: lbs=", lbs);
		#print("AltitudeHoldPidControllerAdjust: xMoment=", me.xMoment);

		# deal with airspeed, altitude, weight, CoG
		if (airspeedKt < 170.0) {
			if (lbs > 250000.0 or me.xMoment < 350.0) {
				if (me.xMoment < 350.0) {
					if (lbs > 250000.0) {
						me.correctedKp = -0.01;		# (not yet testet)
					}
					else {
						me.correctedKp = -0.015;
					}
				}
				else {
					if (lbs > 250000.0) {
						me.correctedKp = -0.008;
					}
					else {
						me.correctedKp = -0.009;
					}
				}
			}
			else {
				me.correctedKp = -0.012;
			}
		}
		elsif (airspeedKt < 190.0) {
			if (lbs > 250000.0 or me.xMoment < 350.0) {
				me.correctedKp = -0.008;
			}
			else {
				me.correctedKp = -0.0095;
			}
		}
		else {
			if (airspeedKt > 450.0) {
				me.correctedKp = -0.0035;
			}
			elsif (airspeedKt > 400.0) {
				me.correctedKp = -0.0065;
			}
			elsif (airspeedKt > 340.0) {
				me.correctedKp = -0.0075;
			}
			elsif (airspeedKt > 300.0) {
				me.correctedKp = -0.0085;
			}
			elsif (airspeedKt > 190.0) {
				me.correctedKp = -0.0095;
			}
			else {
				me.correctedKp = -0.011;
			}
			if (me.xMoment > 190.0) {
				# deal with CoG
				me.correctedKp += 0.002 + ((me.xMoment - 190.0) * 0.000014);
			} 

			if (lbs > 250000.0 and altitudeFt > 10000.0) {
				# deal with weight - gets substruction of 0.00375 at 400.000 lbs
				me.correctedKp += (lbs - 250000.0) * 0.000000025;
			}

			# deal with altitude - >20000 ft: gets a substraction of '-0.003' at 400000 feet
			if (altitudeFt > 20000.0) {
				if (lbs > 250000.0) {
					me.correctedKp += (altitudeFt - 20000.0) * 0.0000038;
				}
				else {
					me.correctedKp += (altitudeFt - 20000.0) * 0.0000004;
				}
			}


			# set fixed value in this case
			if (lbs > 250000.0 and altitudeFt > 25000.0) {
				me.correctedKp = (me.correctedKp > -0.0015 ? -0.0015 : me.correctedKp);
			}
			else {
				me.correctedKp = (me.correctedKp > -0.002 ? -0.002 : me.correctedKp);
			}
		}
	},


	# adjusts 'Kp' value
	# params: error: the error of the controlled parameter
	#         xMoment: the actual x-moment
	#         lbs  : the total weight in lbs
	#         airspeedKt: the actual airspeed in knots
	#         altitudeFt: actual altitude in feet
	# this routine must be called subsequently in certain time-intervalls
	adjustKp : func(lbs, airspeedKt, altitudeFt) {

		if (me.kpInterpolationIsRunning == 0) {
			me.calculateKp(lbs, airspeedKt, altitudeFt);
		}
		me.clambKp();

		#print("AltitudeHoldPidControllerAdjust: correctedKp=", me.correctedKp);
		setprop("/autopilot/internal/target-kp-for-altitude-vspeed-hold", me.correctedKp);
	},


	# may be called from outside, if smooth iterpolation of Td value is required
	interpolateTd : func() {
		#print ("AltitudeHoldPidControllerAdjust: interpolateTd ...");
		me.tdInterpolationCounter = 30;
		me.tdInterpolate = 0.0;

		me.tdInterpolationIsRunning = 1;

		# set the property
		setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", me.tdInterpolate);
	},

	# adusts 'Td' value
	# this routine must be called subsequently in certain time-intervalls
	adjustTd : func(lbs, airspeedKt, altitudeFt) {

		# experimental me.td: initial: 1.5

		var targetTd = 1.5;
		if (me.xMoment > 190.0) {
			if (airspeedKt < 230.0) {
				targetTd = 2.8;
			}
			elsif (lbs > 250000.0 and airspeedKt > 260) {
				targetTd = 1.8;
			}
			elsif (airspeedKt > 330.0 and altitudeFt > 20000.0) {
				targetTd = 2.5;
			}
			elsif (airspeedKt > 250.0 and altitudeFt > 20000.0) {
				targetTd = 3.0;
			}
			else {
				targetTd = 1.5;
			}
		}
		else {
			if (airspeedKt <= 190.0) {
				targetTd = 0.002;
	 		}
			elsif (airspeedKt < 230.0 and lbs > 250000.0) {
				targetTd = 2.8;
			}
			else {
				targetTd = 1.5;
			}
		}
		# iterate to 'targetTd'
		me.td = (me.td > targetTd ? (me.td - 0.01) : me.td);
		me.td = (me.td < targetTd ? (me.td + 0.01) : me.td);
		# if 'targetTd' < increment -> set explicitely to 'targetTd'
		if (abs(me.td - targetTd) < 0.02 and targetTd < 0.01) {
			me.td = targetTd;
		}


		if (me.tdInterpolationIsRunning == 1 and me.tdInterpolate < me.td) {

			if (me.tdInterpolationCounter > 0) {
				# begin increment: increasing reciprocal with time (me.tdInterpolationCounter) from 0.00167 to 0.05
				me.tdInterpolationIncrement = 1 / (me.tdInterpolationCounter * me.tdInterpolationCounter);

				me.tdInterpolationCounter -= 1;
			}

			me.tdInterpolate += me.tdInterpolationIncrement;
			me.tdInterpolate = (me.tdInterpolate < me.td ? me.tdInterpolate : me.td);
			setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", me.tdInterpolate);
		}
		else {
			me.tdInterpolationCounter = 0;
			tdInterpolationIsRunning = 0;
			setprop("/autopilot/internal/target-td-for-altitude-vspeed-hold", me.td);
		}

		#print ("AltitudeHoldPidControllerAdjust: td=", getprop("/autopilot/internal/target-td-for-altitude-vspeed-hold"));
	},

	# adusts 'Ti' value
	# this routine must be called subsequently in certain time-intervalls
	adjustTi : func(lbs, airspeedKt, altitudeFt) {

		var targetTi = 10.0;
		if (airspeedKt < 190.0) {
			if (lbs > 250000.0 or me.xMoment < 350.0) {
				targetTi = 30.0;
			}
			else {
				targetTi = 50.0;
			}
		}
		else {
			targetTi = 10.0;
			if (airspeedKt < 250.0 and me.xMoment < 350.0) {
				targetTi = 30.0;
			}
			elsif (lbs > 250000.0) {
				if (altitudeFt > 25000.0) {
					targetTi = 50.0;
				}
				else {
					if (airspeedKt < 250.0) {
						targetTi = 30.0;
					}
				}
			}
			if (airspeedKt > 250.0 and altitudeFt > 20000.0 and me.xMoment > 190.0) {
				targetTi = 50.0;
			}
		}
		# iterate ti 'targetTi'
		me.ti = (me.ti < targetTi ? (me.ti + 1.0) : me.ti);
		me.ti = (me.ti > targetTi ? (me.ti - 1.0) : me.ti);

		#print ("AltitudeHoldPidControllerAdjust: me.ti=", me.ti);
		setprop("/autopilot/internal/target-ti-for-altitude-vspeed-hold", me.ti);
	},

	# adjust elevator-position to avoid elevator-trim getting to it's end-position: alt-/vspeed-modes are driven by elevator-trim
	adjustElevatorPosition : func() {
		# experimental - move elevator if elevator-trim reaches end-position
		if (me.counterForElevatorMovement >= size(me.elevatorTrimPosAverages)) {	# each 5-th iteration
			var elevatorTrimPosAverage = 0.0;
			for (var i=0; i < size(me.elevatorTrimPosAverages); i=i+1) {
				elevatorTrimPosAverage += me.elevatorTrimPosAverages[i];
			}
			elevatorTrimPosAverage = elevatorTrimPosAverage / size(me.elevatorTrimPosAverages);
			var elevatorPos = getprop("/autopilot/internal/elevator-position");
			#print("AltitudeHoldPidControllerAdjust: adjustElevatorPosition=", elevatorTrimPosAverage);
			if (elevatorTrimPosAverage < -0.5) {
				if (elevatorPos >= -0.99) {
					interpolate("/autopilot/internal/elevator-position", elevatorPos - 0.01, 0.9);
					#print("AltitudeHoldPidControllerAdjust: adjustElevatorPosition=", getprop("/autopilot/internal/elevator-position"));
				}
			}
			elsif (elevatorTrimPosAverage > 0.5) {
				if (elevatorPos <= 0.99) {
					interpolate("/autopilot/internal/elevator-position", elevatorPos + 0.01, 0.9);
					#print("AltitudeHoldPidControllerAdjust: adjustElevatorPosition=", getprop("/autopilot/internal/elevator-positionr"));
				}
			}

			me.counterForElevatorMovement = 0;
		}
		else {
			if (me.counterForElevatorMovement < size(me.elevatorTrimPosAverages)) {
				me.elevatorTrimPosAverages[me.counterForElevatorMovement] = getprop("/controls/flight/elevator-trim");
			}
			me.counterForElevatorMovement += 1;
		}
	},

	# does initializations for AGL-hold
	initializeAgl : func() {
		me.lat = getprop("/position/latitude-deg");
		me.lon = getprop("/position/longitude-deg");
		setprop("/autopilot/internal/target-altitude-agl-min-ft",
			getprop("/position/altitude-agl-ft") + getprop("/autopilot/settings/target-agl-ft"));
		me.terrainElevationMax = 0.0;
	},

	# calculates AGL-maximals for AGL-hold with looking ahead
	# (this routine has to run subsequently each 0.2 seconds)
	calculateAgl : func(lbs) {

		# look ahead 30 times (6 seconds) the distance we have covered since last call

		var lat = getprop("/position/latitude-deg");
		var lon = getprop("/position/longitude-deg");
		var latDiff = lat - me.lat;
		var lonDiff = lon - me.lon;
		#print("lat=", lat, "  latDiff=", latDiff);
		#print("lon=", lon, "  lonDiff=", lonDiff);

		if (latDiff < 1.0 and lonDiff < 1.0) {	# ignore measurement, if we pass the 'null-line'
			me.lat = lat;
			me.lon = lon;

			var testSquareSize = (math.sqrt((latDiff * latDiff) + (lonDiff * lonDiff)));
			var scaleFactorLat = 0.000009;
			var scaleFactorLon = 0.00004;
			# look ahead 6 seconds
			var lookAheadInterval = 30.0;
			var terrainElevationLookAhead6 = 0.0;
			# this takes care of the direction, look more far to the side as in moving-direction
			var testSquareSizeLat = testSquareSize + (testSquareSize / abs(lonDiff) * testSquareSize);
			testSquareSizeLat = (testSquareSizeLat > (testSquareSize * 5.0) ? (testSquareSize * 5.0) : testSquareSizeLat);
			var testSquareSizeLon = testSquareSize + (testSquareSize / abs(latDiff) * testSquareSize);
			testSquareSizeLon = (testSquareSizeLon > (testSquareSize * 5.0) ? (testSquareSize * 5.0) : testSquareSizeLon);
			terrainElevationLookAhead6 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead6);
			terrainElevationLookAhead6 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval) + testSquareSizeLat,
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead6);
			terrainElevationLookAhead6 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval) - testSquareSizeLat,
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead6);
			terrainElevationLookAhead6 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval) + testSquareSizeLon,
								terrainElevationLookAhead6);
			terrainElevationLookAhead6 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval) - testSquareSizeLon,
								terrainElevationLookAhead6);
			#print("terrainElevationLookAhead6=", terrainElevationLookAhead6);

			# look ahead 2 seconds
			var lookAheadInterval = 10.0;
			var terrainElevationLookAhead2 = 0.0;
			# this takes care of the direction, look more far to the side as in moving-direction
			var testSquareSizeLat2 = (testSquareSize * 0.5) + (testSquareSize * 0.5 * testSquareSizeLat);
			var testSquareSizeLon2 = (testSquareSize * 0.5) + (testSquareSize * 0.5 * testSquareSizeLat);
			terrainElevationLookAhead2 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead2);
			terrainElevationLookAhead2 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval) + testSquareSizeLat2,
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead2);
			terrainElevationLookAhead2 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval) - testSquareSizeLat2,
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead2);
			terrainElevationLookAhead2 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval) + testSquareSizeLon2,
								terrainElevationLookAhead2);
			terrainElevationLookAhead2 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval) - testSquareSizeLon2,
								terrainElevationLookAhead2);
			#print("terrainElevationLookAhead2=", terrainElevationLookAhead2);
		
			# look ahead 30 (40 at high weight) seconds
			var lookAheadInterval = (lbs > 200000.0 ? 200.0 : 150.0);
			var terrainElevationLookAhead30 = 0.0;
			# this takes care of the direction, look more far to the side as in moving-direction
			var testSquareSizeLat30 = (testSquareSize * 4.0) + (testSquareSize * 4.0 * testSquareSizeLat);
			var testSquareSizeLon30 = (testSquareSize * 4.0) + (testSquareSize * 4.0 * testSquareSizeLat);
			terrainElevationLookAhead30 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead30);
			terrainElevationLookAhead30 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval) + testSquareSizeLat30,
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead30);
			terrainElevationLookAhead30 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval) - testSquareSizeLat30,
								lon + (lonDiff * lookAheadInterval),
								terrainElevationLookAhead30);
			terrainElevationLookAhead30 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval) + testSquareSizeLon30,
								terrainElevationLookAhead30);
			terrainElevationLookAhead30 = me.getTerrainElevation(lat + (latDiff * lookAheadInterval),
								lon + (lonDiff * lookAheadInterval) - testSquareSizeLon30,
								terrainElevationLookAhead30);
			#print("terrainElevationLookAhead30=", terrainElevationLookAhead30);

			var terrainElevationLookAhead = terrainElevationLookAhead6;

			# if terrain far away (30 seconds) raizes/falls heavily (more than 500 ft),
			# we take this value for calculation of target altitude
			if (abs(terrainElevationLookAhead30 - terrainElevationLookAhead) > 500.0) {
				terrainElevationLookAhead = (terrainElevationLookAhead30 > terrainElevationLookAhead
					? terrainElevationLookAhead30 :terrainElevationLookAhead);
			}

			# if actual terrain-elevation ('terrainElevationLookAhead2') is greater than look-ahead-terrain-elevation 
			# ('terrainElevationLookAhead6'), we have to stay on higher altitude-level to avoid diving to early
			terrainElevationLookAhead = (terrainElevationLookAhead2 > terrainElevationLookAhead
				? terrainElevationLookAhead2 : terrainElevationLookAhead);

			# set new elevation-maximum
			me.terrainElevationMax = (terrainElevationLookAhead > me.terrainElevationMax
				? terrainElevationLookAhead : me.terrainElevationMax);
		}

		# each 2 seconds set a new target-altitude-value 
		if (me.counterForAglSecond >= 10) {
			# indicates one second elapsed
			me.counterForAglSecond = 0;

			interpolate("/autopilot/internal/target-altitude-agl-min-ft",
					me.terrainElevationMax + getprop("/autopilot/settings/target-agl-ft"), 1.0);
			#print("target-altitude-agl-min-ft=", getprop("/autopilot/internal/target-altitude-agl-min-ft"));
			me.terrainElevationMax = 0.0;
		}
		else {
			me.counterForAglSecond += 1;
		}

	},

	getTerrainElevation : func(lat, lon, terrainElevationPrev) {
		var info = geodinfo(lat, lon);
		if (info != nil) {
			var terrainElevation = info[0] * 3.28084;	# 'info[0]' gets elevation in meters
			if (terrainElevation < 0.0) { terrainElevationLook = 0.0; }
			return (terrainElevation > terrainElevationPrev ? terrainElevation : terrainElevationPrev);
		}
		return 0.0;
	},

	# adusts 'Kp' value for first altitude-PID-controller (Stage 1: determine appropriate vertical-speed)
	adjustAirspeedKp : func(airspeedKt) {
		# deal with airspeed (own factor), airspeed-dependent factor (0.011 - 0.0176), if speed < 220 kts, 0.05 if speed > 250 kts

		var airspeedKp = 0.05;

		#print ("Airspeed-KT=", airspeedKt);

		if (airspeedKt < 190.0) {
			airspeedKp = 0.02;
		}
		else {
			airspeedDiff = (airspeedKt - 240.0);
			if (airspeedDiff < 0) {
				# if airspeed < 240 kt substruct an amount from 'airspeedKp'
				var newAirspeedKp = airspeedKp - (abs(airspeedDiff) * 0.001);
				if (newAirspeedKp > 0.011) {
					airspeedKp = newAirspeedKp;
				}
				else {
					# not less than '0.011'
					airspeedKp = 0.011;
				}
				#print ("1: airspeedDiff=", airspeedDiff, "  airspeedKp=", airspeedKp);

				# if airspeed < 200 add a small amount to 'airspeedKp' again
				if (airspeedDiff < -40.0) {
					airspeedDiff = (airspeedDiff + 40.0);
					airspeedKp = airspeedKp + (abs(airspeedDiff) * 0.0001);
					#print ("2: airspeedDiff=", airspeedDiff, "  airspeedKp=", airspeedKp);
				}
			}
		}
		#print ("airspeedKp=", airspeedKp);
		setprop("/autopilot/internal/target-airspeed-factor-for-altitude-hold", airspeedKp);

		return airspeedKp;
	},

	interpolateMinMaxClimbRate : func(interpolations) {

		if (getprop("/autopilot/locks/altitude") == "vertical-speed-hold") {
			# initialize with actual vertical-speed
			me.verticalSpeedFpmClambed = getprop("/velocities/vertical-speed-fps") * 60;
		}

		if (me.climbRateInterpolationCounter <= 0) {
			me.climbRateInterpolationCounter = interpolations;

			if (getprop("/autopilot/locks/altitude") == "altitude-hold" or
				getprop("/autopilot/locks/altitude") == "agl-hold" or
				getprop("/autopilot/locks/altitude") == "pitch-hold" or
				getprop("/autopilot/locks/altitude") == "aoa-hold" or
				getprop("/autopilot/locks/altitude") == "gs1-hold" or
				getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

				var climbRateFps = getprop("/velocities/vertical-speed-fps");

				me.targetClimbRateFpsMin = getprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min");	
				me.targetClimbRateFpsMax = getprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max");
				setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min", climbRateFps);
				setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max", climbRateFps);

				me.climbRateMinInterpolationIncrement = (me.targetClimbRateFpsMin - climbRateFps) / interpolations;
				me.climbRateMaxInterpolationIncrement = (me.targetClimbRateFpsMax - climbRateFps) / interpolations;
			}
		}
	},

	adjustMinMaxClimbRate : func(lbs, airspeedKt, altitudeFt) {
		#print("adjustMinMaxClimbRate: climbRateInterpolationCounter=", me.climbRateInterpolationCounter);

		if (getprop("/autopilot/locks/altitude") == "vertical-speed-hold") {
			var verticalSpeedFpm = getprop("/it-autoflight/input/vs");

			var verticalSpeedDiff = verticalSpeedFpm - me.verticalSpeedFpmClambed;

			if (abs(verticalSpeedDiff) > 40) {
				if (verticalSpeedDiff > 0) {
					me.verticalSpeedFpmClambed += 40.0;
				}
				else {
					me.verticalSpeedFpmClambed -= 40.0;
				}
				setprop("/autopilot/internal/vertical-speed-fpm-clambed", me.verticalSpeedFpmClambed);
				#print("adjustMinMaxClimbRate: me.verticalSpeedFpmClambed=", me.verticalSpeedFpmClambed);
			}
		}
		else if (getprop("/autopilot/locks/altitude") == "altitude-hold" or
			getprop("/autopilot/locks/altitude") == "agl-hold" or
			getprop("/autopilot/locks/altitude") == "pitch-hold" or
			getprop("/autopilot/locks/altitude") == "aoa-hold" or
			getprop("/autopilot/locks/altitude") == "gs1-hold" or
			getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

			if (me.climbRateInterpolationCounter > 0) {
				var climbRateFpsMin = getprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min");
				var climbRateFpsMax = getprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max");

				me.climbRateInterpolationCounter -= 1;

				if (me.climbRateInterpolationCounter > 0) {
					setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min",
						(climbRateFpsMin + me.climbRateMinInterpolationIncrement));
					setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max",
						(climbRateFpsMax + me.climbRateMaxInterpolationIncrement));
				}
			}
			else {
				# set min-/max-climbrate
				setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-min",
						me.calculateMinClimbRate(lbs, airspeedKt, altitudeFt));
				setprop("/autopilot/internal/target-climp-rate-fps-for-altitude-hold-clambed-max",
						me.calculateMaxClimbRate(lbs, airspeedKt, altitudeFt));
			}
		}
	},

	calculateMinClimbRate : func(lbs, airspeedKt, altitudeFt) {
		# calculate minimal climbrate
		var minClimbRate = -15.0;
		if (lbs > 200000.0) {
			minClimbRate = -12.0;
		}
		if (airspeedKt < 190.0) {
			minClimbRate += (190.0 - airspeedKt) * 0.6;
			minClimbRate = (minClimbRate > -5.0 ? -5.0 : minClimbRate);
		}
		#print("minClimbRate=", minClimbRate);
		return minClimbRate;
	},

	calculateMaxClimbRate : func(lbs, airspeedKt, altitudeFt) {
		# calculate maximal climbrate
		var maxClimbRate = 30.0;
		if (lbs > 200000.0 or me.xMoment < 260.0) {
			maxClimbRate = 20.0;
		}
		elsif (lbs > 150000.0 or me.xMoment < 260.0) {
			maxClimbRate = 25.0;
		}
		if (altitudeFt > 20000.0) {
			maxClimbRate -= (altitudeFt - 20000.0) * 0.001334;
			maxClimbRate = (maxClimbRate < 10.0 ? 10.0 : maxClimbRate);
		}
		if (airspeedKt < 190.0) {
			maxClimbRate -= (190.0 - airspeedKt) * 0.6;
			maxClimbRate = (maxClimbRate < 3.0 ? 3.0 : maxClimbRate);
		}
		#print("maxClimbRate=", maxClimbRate);
		return maxClimbRate;
	}
};


var altitudePidControllerAdjust = AltitudeHoldPidControllerAdjust.new(-0.0095, -0.017, -0.0009, 10.0, 1.5);


var targetAltitudeFtPrev = 0;
var verticalSpeedFpmPrev = 0;
var targetAglFtPrev = 0;
var targetPitchDegPrev = 0;
var targetAoaDegPrev = 0;
var listenerApAltitudeClambSwitchFunc = func {
	if (	getprop("/autopilot/locks/altitude") == "altitude-hold" or
		getprop("/autopilot/locks/altitude") == "agl-hold" or
		getprop("/autopilot/locks/altitude") == "pitch-hold" or
		getprop("/autopilot/locks/altitude") == "aoa-hold" or
		getprop("/autopilot/locks/altitude") == "vertical-speed-hold" or
		getprop("/autopilot/locks/altitude") == "gs1-hold" or
		getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

		#print("listenerApAltitudeClambFunc -> triggered");

		altitudePidControllerAdjust.interpolateKp(40);
		altitudePidControllerAdjust.interpolateTd();
		altitudePidControllerAdjust.interpolateMinMaxClimbRate(40);

		targetAltitudeFtPrev = getprop("/it-autoflight/input/alt");
		verticalSpeedFpmPrev = getprop("/it-autoflight/input/vs");
		targetPitchDegPrev = getprop("/autopilot/settings/target-pitch-deg");
		targetAoaDegPrev = getprop("/autopilot/settings/target-aoa-deg");
		targetAglFtPrev = getprop("/autopilot/settings/target-agl-ft");

		setprop("/autopilot/internal/elevator-position", getprop("/controls/flight/elevator"));
		setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", getprop("/velocities/vertical-speed-fps"));
	}
}
var listenerApAltitudeClambFunc = func {
	if (	getprop("/autopilot/locks/altitude") == "altitude-hold" or
		getprop("/autopilot/locks/altitude") == "agl-hold" or
		getprop("/autopilot/locks/altitude") == "pitch-hold" or
		getprop("/autopilot/locks/altitude") == "aoa-hold" or
		getprop("/autopilot/locks/altitude") == "vertical-speed-hold" or
		getprop("/autopilot/locks/altitude") == "gs1-hold" or
		getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

		if (	getprop("/it-autoflight/input/alt") != targetAltitudeFtPrev or
			getprop("/it-autoflight/input/vs") != verticalSpeedFpmPrev or
			getprop("/autopilot/settings/target-pitch-deg") != targetPitchDegPrev or
			getprop("/autopilot/settings/target-aoa-deg") != targetAoaDegPrev or
			getprop("/autopilot/settings/target-agl-ft") != targetAglFtPrev) {
			#print("listenerApAltitudeClambFunc -> triggered");

			altitudePidControllerAdjust.interpolateKp(40);
			altitudePidControllerAdjust.interpolateTd();
			altitudePidControllerAdjust.interpolateMinMaxClimbRate(40);

			targetAltitudeFtPrev = getprop("/it-autoflight/input/alt");
			verticalSpeedFpmPrev = getprop("/it-autoflight/input/vs");
			targetPitchDegPrev = getprop("/autopilot/settings/target-pitch-deg");
			targetAoaDegPrev = getprop("/autopilot/settings/target-aoa-deg");
			targetAglFtPrev = getprop("/autopilot/settings/target-agl-ft");
		}
	}
}

setlistener("/autopilot/locks/speed", listenerApAltitudeClambSwitchFunc);	# for 'speed-with-pitch-trim'
		
setlistener("/autopilot/locks/altitude", listenerApAltitudeClambSwitchFunc);
setlistener("/it-autoflight/input/alt", listenerApAltitudeClambFunc);
setlistener("/it-autoflight/input/vs", listenerApAltitudeClambFunc);
setlistener("/autopilot/settings/target-pitch-deg", listenerApAltitudeClambFunc);
setlistener("/autopilot/settings/target-aoa-deg", listenerApAltitudeClambFunc);
setlistener("/autopilot/settings/target-agl-ft", listenerApAltitudeClambFunc);

var gsInRangePrev = 0;
var listenerApGsClambFunc = func {
	if (getprop("/autopilot/locks/altitude") == "gs1-hold") {

		if (getprop("/instrumentation/nav[0]/gs-in-range") != gsInRangePrev) {
			#print("listenerApGsClambFunc -> triggered");

			gsInRangePrev = getprop("/instrumentation/nav[0]/gs-in-range");

			altitudePidControllerAdjust.interpolateKp(50);
			altitudePidControllerAdjust.interpolateTd();
			altitudePidControllerAdjust.interpolateMinMaxClimbRate(50);

			setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", getprop("/velocities/vertical-speed-fps"));
		}
	}
}
setlistener("/instrumentation/nav[0]/gs-in-range", listenerApGsClambFunc);


var getTotalFuelLbs = func {
	return( getprop("/consumables/fuel/tank/level-lbs") +
		getprop("/consumables/fuel/tank[1]/level-lbs") +
		getprop("/consumables/fuel/tank[2]/level-lbs") +
		getprop("/consumables/fuel/tank[3]/level-lbs") +
		getprop("/consumables/fuel/tank[4]/level-lbs") +
		getprop("/consumables/fuel/tank[5]/level-lbs") +
		getprop("/consumables/fuel/tank[6]/level-lbs") +
		getprop("/consumables/fuel/tank[7]/level-lbs") );
}


var listenerApAltitudeKpFunc = func {

	if (  getprop("/autopilot/locks/altitude") == "altitude-hold" or
		getprop("/autopilot/locks/altitude") == "agl-hold" or
		getprop("/autopilot/locks/altitude") == "vertical-speed-hold" or
		getprop("/autopilot/locks/altitude") == "gs1-hold" or
		getprop("/autopilot/locks/altitude") == "pitch-hold" or
		getprop("/autopilot/locks/altitude") == "aoa-hold" or
		getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

		#print("listenerApAltitudeKpFunc -> activated");

		# get live parameter
		var lbs = getTotalFuelLbs();
		var altitudeFt = getprop("/position/altitude-ft");
		var airspeedKt = getprop("/velocities/airspeed-kt");

		altitudePidControllerAdjust.calculateXMoment();

		## adjusts Kp-, Ti-, Td-properties and others ##
		altitudePidControllerAdjust.adjustMinMaxClimbRate(lbs, airspeedKt, altitudeFt);
		altitudePidControllerAdjust.adjustKp(lbs, airspeedKt, altitudeFt);
		altitudePidControllerAdjust.adjustTi(lbs, airspeedKt, altitudeFt);
		altitudePidControllerAdjust.adjustTd(lbs, airspeedKt, altitudeFt);
		altitudePidControllerAdjust.adjustAirspeedKp(lbs, airspeedKt, altitudeFt);
		altitudePidControllerAdjust.adjustElevatorPosition();

		settimer(listenerApAltitudeKpFunc, 0.2);
	}
}
var listenerApAltitudeAglCalculateFunc = func {
	if (  getprop("/autopilot/locks/altitude") == "agl-hold") {

		# get live parameter
		var lbs = getTotalFuelLbs();

		## calculates values for AGL-hold ##
		altitudePidControllerAdjust.calculateAgl(lbs);

		settimer(listenerApAltitudeAglCalculateFunc, 0.2);
	}
}
var listenerApAltitudeAglFunc = func {

	if (  getprop("/autopilot/locks/altitude") == "agl-hold") {

		#print("listenerApAltitudeAglFunc -> activated");

		# initialize AGL-max-value
		altitudePidControllerAdjust.initializeAgl();

		settimer(listenerApAltitudeAglCalculateFunc, 0.2);
	}
}
var listenerApAltitudeSwitchFunc = func {
	# disable speed-with-pitch if pitch-/AoA-hold is activated (makes no sence together with pitch-/AoA-hold)
	if (	getprop("/autopilot/locks/altitude") == "pitch-hold" or
		getprop("/autopilot/locks/altitude") == "aoa-hold") {
		if (getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {
			setprop("/autopilot/locks/speed", "");
		}
	}
}

setlistener("/autopilot/locks/altitude", listenerApAltitudeKpFunc);
setlistener("/autopilot/locks/speed", listenerApAltitudeKpFunc);
setlistener("/autopilot/locks/altitude", listenerApAltitudeAglFunc);
setlistener("/autopilot/locks/altitude", listenerApAltitudeSwitchFunc);


var listenerApSpeedWithPitchFunc = func {

	if (getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

		#print("listenerApSpeedWithPitchFunc -> activated");

		# get live parameter
		var lbs = getTotalFuelLbs();
		var altitudeFt = getprop("/position/altitude-ft");
		var airspeedKt = getprop("/velocities/airspeed-kt");
		var mach = getprop("/velocities/mach");

		var machScaleFactor = airspeedKt / mach;
		#print("machScaleFactor=", machScaleFactor);
		setprop("/autopilot/internal/speed-with-pitch-mach-scale-factor", machScaleFactor);

		# calculate Kp value for speed-with-pitch
		altitudePidControllerAdjust.adjustSpeedWithPitchKp(lbs, airspeedKt, altitudeFt);

		settimer(listenerApSpeedWithPitchFunc, 0.2);
	}
}
var listenerApSpeedWithPitchClambFunc = func {
	if (getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {
		#print ("-> listenerApSpeedWithPitchClambFunc -> installed");
		altitudePidControllerAdjust.interpolateSpeedWithPitchKp(50);

		var pitch = getprop("/orientation/pitch-deg");
		setprop("/autopilot/internal/umin-for-speed-with-pitch-hold", (pitch < -2.0 ? -2.0 : pitch));
		interpolate("/autopilot/internal/umin-for-speed-with-pitch-hold", -2.0, 5);
		setprop("/autopilot/internal/umax-for-speed-with-pitch-hold", (pitch > 12.0 ? 12.0 : pitch));
		interpolate("/autopilot/internal/umax-for-speed-with-pitch-hold", 12.0, 5);
	}
}
var listenerApSpeedWithPitchSwitchFunc = func {
	if (getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {
		# disable pitch-/AoA-hold (makes no sence together with speed-with-pitch-hold)
		if (	getprop("/autopilot/locks/altitude") == "pitch-hold" or
			getprop("/autopilot/locks/altitude") == "aoa-hold") {
			setprop("/autopilot/locks/altitude", "");
		}
	}
}

setlistener("/autopilot/locks/speed", listenerApSpeedWithPitchFunc);
setlistener("/autopilot/locks/speed", listenerApSpeedWithPitchClambFunc);
setlistener("/it-autoflight/input/kts", listenerApSpeedWithPitchClambFunc);
setlistener("/autopilot/locks/speed", listenerApSpeedWithPitchSwitchFunc);



#################################################
## heading bug / true heading hold / NAV1-hold ##
#################################################

var bankLimitFunc = func {
	var bankLimit = getprop("/autopilot/settings/bank-limit");

	if (bankLimit == nil or bankLimit == 0) {	# bank-limit=0 -> 'auto'
		bankLimit = 25.0;
	}
	setprop("/autopilot/internal/bank-limit-filtered", bankLimit);
}
setlistener("/autopilot/settings/bank-limit", bankLimitFunc);


kpHeadingInterpolationIsRunning = 0;	# must be global, used also by 'autopilot-routemanager.nas'
var headingClambFunc = func {
	#print ("-> headingClambFunc -> run");
	setprop("/autopilot/internal/target-kp-for-heading-hold-clambed",
		(getprop("/autopilot/internal/target-kp-for-heading-hold-clambed") * 0.08));
	if (kpHeadingInterpolationIsRunning == 0) {
		kpHeadingInterpolationIsRunning = 1;
	}
}

var listenerApHeadingClambFunc = func {
	if (	getprop("/autopilot/locks/heading") == "dg-heading-hold" or
		getprop("/autopilot/locks/heading") == "wing-leveler" or
		getprop("/autopilot/locks/heading") == "nav1-hold") {

		#print ("-> listenerApHeadingClambFunc -> installed");
		headingClambFunc();
	}
}
# must have own function for 'true-heading-deg', otherwise we would be triggered permanatly by the route-manager
# that sets 'true-heading-deg'
var listenerApTrueHeadingClambFunc = func {
	if (getprop("/autopilot/route-manager/active") == 0) {
		if (	getprop("/autopilot/locks/heading") == "true-heading-hold" or
			getprop("/autopilot/locks/heading") == "wing-leveler") {

			#print ("-> listenerApTrueHeadingClambFunc -> installed");
			headingClambFunc();
		}
	}
}
var listenerApSwitchHeadingClambFunc = func {

	#print ("-> listenerApSwitchHeadingClambFunc -> installed");
	headingClambFunc();
}

# do not enable 'true-heading-deg', because of route-manager activates the function permanently
setlistener("/autopilot/settings/true-heading-deg", listenerApTrueHeadingClambFunc);
setlistener("/it-autoflight/input/hdg", listenerApHeadingClambFunc);
setlistener("/autopilot/locks/heading", listenerApSwitchHeadingClambFunc);
# setlistener("/autopilot/settings/gps-driving-true-heading", listenerApHeadingClambFunc);

# make adjustments for heading-hold controllers
var listenerApHeadingFunc = func {
	if (	getprop("/autopilot/locks/heading") == "dg-heading-hold" or
		getprop("/autopilot/locks/heading") == "true-heading-hold" or
		getprop("/autopilot/locks/heading") == "wing-leveler" or
		getprop("/autopilot/locks/heading") == "nav1-hold") {

		var tiAirspeedForHeadingHold = 10.0;
		var airspeedKt = getprop("/velocities/airspeed-kt");
		if (airspeedKt < 220.0) {
			tiAirspeedForHeadingHold += (220.0 - airspeedKt);
		}
		setprop("/autopilot/internal/target-ti-airspeed-for-heading-hold", tiAirspeedForHeadingHold);


		# experimantal:
		#<!-- lt 180 kts -->
		#<!--<gain>-0.007</gain>-->
		#
		#<!-- gt 180 kts, lt 300 kts -->
		#<!--<gain>-0.01</gain>-->
		#
		#<!-- gt 300 kts -->
		#<!--<gain>-0.006</gain>-->
		#
		#<!-- 310 kts, 35000 ft ==> altitude-factor NEEDED !!! -->
		#<gain>-0.003</gain>
		#

		var altitudeFt = getprop("/position/altitude-ft");

		var gainForAirspeedFactor = -0.01;
		if (airspeedKt < 180.0) {
			gainForAirspeedFactor += (180.0 - airspeedKt) * 0.0002;
			gainForAirspeedFactor = (gainForAirspeedFactor > -0.002 ? -0.002 : gainForAirspeedFactor);
		}
		elsif (airspeedKt > 300.0) {
			gainForAirspeedFactor += (airspeedKt - 300.0) * 0.00008;
			gainForAirspeedFactor = (gainForAirspeedFactor > -0.003 ? -0.003 : gainForAirspeedFactor);
		}

		if (altitudeFt > 18000.0) {
			gainForAirspeedFactor += (altitudeFt -18000.0) * 0.0000004;
			gainForAirspeedFactor = (gainForAirspeedFactor > -0.003 ? -0.003 : gainForAirspeedFactor);
		}
		#print ("gainForAirspeedFactor=", gainForAirspeedFactor);
		setprop("/autopilot/internal/target-gain-airspeed-factor-for-heading-hold", gainForAirspeedFactor);


		# Kp, Ti, Td experimantal:
		# <!-- 150 kts -->
		# <Kp>0.09</Kp>
		# <Ti>50.0</Ti>
		# <Td>6.0</Td>
		#
		# <!-- 200-300 kts -->
		# <Kp>0.05</Kp>
		# <Ti>20.0</Ti>
		# <Td>0.0001</Td>
		#
		# <!-- 300 -350 kts -->
		# <Kp>0.08</Kp>
		# <Ti>60.0</Ti>
		# <Td>0.02</Td>
		#
		# <!-- 340 -450 kts (still bad) -->
		# <Kp>0.07</Kp>
		# <Ti>200.0</Ti>
		# <Td>0.02</Td>

		# interpolate 'Kp' according to airspeed
		var kpForHeadingHold = getprop("/autopilot/internal/target-kp-for-heading-hold-clambed");
		var targetKpForHeadingHold = 0.0;
		var kpIncrement = 0.001667;
		if (airspeedKt < 250.0) {
			targetKpForHeadingHold = 0.12;
			kpIncrement = 0.003;
		}
		elsif (airspeedKt < 300.0) {
			targetKpForHeadingHold = 0.05;
			kpIncrement = 0.001667;
		}
		elsif (airspeedKt < 350.0) {
			targetKpForHeadingHold = 0.08;
			kpIncrement = 0.002667;
		}
		else {
			targetKpForHeadingHold = 0.07;
			kpIncrement = 0.002333;
		}
		kpForHeadingHold = (kpForHeadingHold > targetKpForHeadingHold ? (kpForHeadingHold - kpIncrement) : kpForHeadingHold);
		kpForHeadingHold = (kpForHeadingHold < targetKpForHeadingHold ? (kpForHeadingHold + kpIncrement) : kpForHeadingHold);
		if (kpHeadingInterpolationIsRunning == 1) {
			kpHeadingInterpolationIsRunning = (abs(kpForHeadingHold - targetKpForHeadingHold) > (2 * kpIncrement) ? 1 : 0);
			#print ("RESET - kpHeadingInterpolationIsRunning=", kpHeadingInterpolationIsRunning);
		}
		setprop("/autopilot/internal/target-kp-for-heading-hold-clambed", kpForHeadingHold);
		#print ("target-kp-for-heading-hold-clambed=", getprop("/autopilot/internal/target-kp-for-heading-hold-clambed"));
		#print ("kpHeadingInterpolationIsRunning=", kpHeadingInterpolationIsRunning);


		# interpolate 'Ti' according to airspeed
		var tiForHeadingHold = getprop("/autopilot/internal/target-ti-for-heading-hold");
		var targetTi = 0.0;
		var tiIncrement = 1.0;
		if (airspeedKt < 170.0) {
			if (getprop("/autopilot/locks/heading") == "nav1-hold") {
				targetTi = 7.0;
				tiIncrement = 1.0;
			}
			else {
				targetTi = 7.0;
				tiIncrement = 1.0;
			}
		}
		elsif (airspeedKt < 300.0) {
			targetTi = 40.0;
			tiIncrement = 1.0;
		}
		elsif (airspeedKt < 350.0) {
			targetTi = 60.0;
			tiIncrement = 1.0;
		}
		else {
			targetTi = 200.0;
			tiIncrement = 10.0;
		}
		tiForHeadingHold = (tiForHeadingHold > targetTi ? (tiForHeadingHold - tiIncrement) : tiForHeadingHold);
		tiForHeadingHold = (tiForHeadingHold < targetTi ? (tiForHeadingHold + tiIncrement) : tiForHeadingHold);
		setprop("/autopilot/internal/target-ti-for-heading-hold", tiForHeadingHold);
		#print ("target-ti-for-heading-hold=", getprop("/autopilot/internal/target-ti-for-heading-hold"));


		# set 'Td' according to airspeed
		var tdForHeadingHold = getprop("/autopilot/internal/target-td-for-heading-hold");
		var targetTd = 0.0;
		var tdIncrement = 0.0;
		if (airspeedKt < 160.0) {
			if (getprop("/autopilot/locks/heading") == "nav1-hold") {
				targetTd = 0.002;
				tdIncrement = 0.0001;
			}
			else {
				targetTd = 0.002;
				tdIncrement = 0.0001;
			}
		}
		else {
			if (airspeedKt < 190.0) {
				targetTd = 0.002;
				tdIncrement = 0.0001;
			}
			elsif (airspeedKt < 300.0) {
				targetTd = 0.001;
				tdIncrement = 0.0001;
			}
			else {
				targetTd = 0.02;
				tdIncrement = 0.001;

			}
		}
		tdForHeadingHold = (tdForHeadingHold > targetTd ? (tdForHeadingHold - tdIncrement) : tdForHeadingHold);
		tdForHeadingHold = (tdForHeadingHold < targetTd ? (tdForHeadingHold + tdIncrement) : tdForHeadingHold);
		setprop("/autopilot/internal/target-td-for-heading-hold", tdForHeadingHold);
		#print ("target-td-for-heading-hold=", getprop("/autopilot/internal/target-td-for-heading-hold"));


		# Kp for rudder
		var targetKpRudder = -0.005;
#		if (airspeedKt < 190.0) {
#			targetKpRudder += (190.0 - airspeedKt) * 0.0002;
#			targetKpRudder = (targetKpRudder > 0.0 ? 0.0 : targetKpRudder);
#		}
		setprop("/autopilot/internal/target-kp-for-heading-hold-rudder", targetKpRudder);

		settimer(listenerApHeadingFunc, 0.2);
	}
}
setlistener("/autopilot/locks/heading", listenerApHeadingFunc);


var listenerApWingLevelerFunc = func {

	if (getprop("/autopilot/locks/heading") == "wing-leveler") {

		if (getprop("/orientation/roll-deg") < 1.5 and getprop("/orientation/roll-deg") > -1.5) {
			if (getprop("/autopilot/internal/wing-leveler-hold-heading") == 0) {
				setprop("/autopilot/internal/wing-leveler-hold-heading-bug-deg", getprop("/orientation/heading-magnetic-deg"));
				setprop("/autopilot/internal/wing-leveler-hold-heading", 1);
			}
		}

		settimer(listenerApWingLevelerFunc, 0.2);
	}
	else {
		setprop("/autopilot/internal/wing-leveler-hold-heading", 0);
	}
}
setlistener("/autopilot/locks/heading", listenerApWingLevelerFunc);
setlistener("/autopilot/internal/wing-leveler-hold-heading", listenerApSwitchHeadingClambFunc);
setlistener("/autopilot/internal/wing-leveler-hold-heading-bug-deg", listenerApHeadingClambFunc);



#################################################
## NAV1/GS1 hold                               ##
#################################################

setprop("/autopilot/internal/target-kp-for-nav1-hold-clambed", 0.0);
var listenerApNav1ClambFunc = func {
	if (getprop("/autopilot/locks/heading") == "nav1-hold") {
		#print ("-> listenerApNav1ClambFunc -> installed");
		setprop("/autopilot/internal/target-kp-for-nav1-hold-clambed", 0.0);
		interpolate("/autopilot/internal/target-kp-for-nav1-hold-clambed", -0.6, 10);

		headingClambFunc();
	}
}
setlistener("/autopilot/locks/heading", listenerApNav1ClambFunc);
setlistener("/instrumentation/nav[0]/nav-id", listenerApNav1ClambFunc);
setlistener("/instrumentation/nav/radials/selected-deg", listenerApNav1ClambFunc);
setlistener("/instrumentation/nav/frequencies/selected-mhz", listenerApNav1ClambFunc);

var listenerApGs1NearFarFunc = func {
	if (getprop("/autopilot/locks/altitude") == "gs1-hold") {

		#print ("-> listenerApGs1NearFarFunc -> installed");
		#print ("-> listenerApGs1NearFarFunc -> gs-rate-of-climb=", getprop("/instrumentation/nav[0]/gs-rate-of-climb"));
		var gsRateNearFarFiltered = getprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered");

		# filter unrealistic values
		if (gsRateNearFarFiltered > 5.0) {
			gsRateNearFarFiltered = 5.0;
		}
		elsif (gsRateNearFarFiltered < -20.0) {
			gsRateNearFarFiltered = -20.0;
		}

		if (getprop("/instrumentation/nav[0]/gs-in-range") == 1) {
			var nav1GsRateOfClimp = getprop("/instrumentation/nav[0]/gs-rate-of-climb");
			if (nav1GsRateOfClimp < -2.0 and nav1GsRateOfClimp > -30.0) {	# in GS
				if (getprop("/instrumentation/nav[0]/gs-rate-of-climb") != nil) {
					gsRateNearFarFiltered = nav1GsRateOfClimp;
					setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", gsRateNearFarFiltered);
				}
				else {
					setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", 0.0);
				}
			}
			else {
				# iterate to 1.67 (100 fpm)
				var gsRateNearFarFilteredIncrement = 0.2;
				if (abs(gsRateNearFarFiltered - 1.67) > 1.0) {
					gsRateNearFarFilteredIncrement = 1.0;
				}
				gsRateNearFarFiltered = (gsRateNearFarFiltered < 1.67 ? (gsRateNearFarFiltered + gsRateNearFarFilteredIncrement) : gsRateNearFarFiltered);
				gsRateNearFarFiltered = (gsRateNearFarFiltered > 1.67 ? (gsRateNearFarFiltered - gsRateNearFarFilteredIncrement) : gsRateNearFarFiltered);
				setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", gsRateNearFarFiltered);
			}
		}
		else {
			# iterate to 0.0
			var gsRateNearFarFilteredIncrement = 0.2;
			if (abs(gsRateNearFarFiltered) > 1.0) {
				gsRateNearFarFilteredIncrement = 1.0;
			}
			gsRateNearFarFiltered = (gsRateNearFarFiltered < 0.0 ? (gsRateNearFarFiltered + gsRateNearFarFilteredIncrement) : gsRateNearFarFiltered);
			gsRateNearFarFiltered = (gsRateNearFarFiltered > 0.0 ? (gsRateNearFarFiltered - gsRateNearFarFilteredIncrement) : gsRateNearFarFiltered);
			setprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered", gsRateNearFarFiltered);
		}

		#print("listenerApGs1NearFarFunc: gs-rate-of-climb-near-far-filtered=", getprop("/autopilot/internal/gs-rate-of-climb-near-far-filtered"));

		settimer(listenerApGs1NearFarFunc, 0.05);
	}
}
setlistener("/autopilot/locks/altitude", listenerApGs1NearFarFunc);

var listenerApNav1NearFarFunc = func {
	if (getprop("/autopilot/locks/heading") == "nav1-hold") {

		#print ("-> listenerApNav1NearFarFunc -> installed");

		var navDistance = getprop("instrumentation/nav[0]/nav-distance");

		# 'smooth' VOR-transition
		if (getprop("instrumentation/nav[0]/gs-in-range") == 0 and navDistance < 2000.0) {
			if (getprop("/autopilot/internal/VOR-near-by") == 0) {
				listenerApNav1ClambFunc();

				var targetRollDeg = getprop("/autopilot/internal/target-roll-deg");
				setprop("/autopilot/internal/target-roll-deg-for-VOR-near-by", 0.0);

				setprop("/autopilot/internal/VOR-near-by", 1);

				interpolate("/autopilot/internal/target-roll-deg-for-VOR-near-by", targetRollDeg, 8.0);
			}
		}
		else {
			if (getprop("/autopilot/internal/VOR-near-by") == 1) {
				listenerApNav1ClambFunc();

				setprop("/autopilot/internal/VOR-near-by", 0);
			}
		}

		# error < 2.5, error will smoothly pushed down: error-magnified = (error ^ 2) * 0.4
		# helpful for better ILS-interception on short distance
		if (getprop("/autopilot/internal/nav1-track-error-deg") != nil) {
			var gearTouchedGround = 0;
			if (	getprop("/gear/gear[0]/wow") or
				getprop("/gear/gear[1]/wow") or
				getprop("/gear/gear[2]/wow") or
				getprop("/gear/gear[3]/wow") or
				getprop("/gear/gear[4]/wow") or
				getprop("/gear/gear[5]/wow")) {
				gearTouchedGround = 1;
			}
			var nav1TrackErrorDegMagnified = getprop("/autopilot/internal/nav1-track-error-deg");
			#print("/autopilot/internal/nav1-track-error-deg=", nav1TrackErrorDegMagnified);
			if (gearTouchedGround == 0 and navDistance > 9000.0) {
				var sign = 1.0;
				if (nav1TrackErrorDegMagnified < 0.0) {
					var sign = -1.0;
				}
				if (abs(getprop("/autopilot/internal/nav1-track-error-deg")) < 2.5) {
					# push track-error down by quadratic function
					nav1TrackErrorDegMagnified = (nav1TrackErrorDegMagnified * nav1TrackErrorDegMagnified) * 0.4 * sign;
				}
				elsif (abs(getprop("/autopilot/internal/nav1-track-error-deg")) > 4.0) {
					# magnify track-error (factor 1.3) if error > 4.0
					nav1TrackErrorDegMagnified = nav1TrackErrorDegMagnified + ((4.0 - nav1TrackErrorDegMagnified) * 0.3 * sign);
	 			}
			}
			nav1TrackErrorDegMagnified = (nav1TrackErrorDegMagnified > 20.0 ? 20.0 : nav1TrackErrorDegMagnified);
			nav1TrackErrorDegMagnified = (nav1TrackErrorDegMagnified < -20.0 ? -20.0 : nav1TrackErrorDegMagnified);
			#print("nav1TrackErrorDegMagnified=", nav1TrackErrorDegMagnified);
			setprop("/autopilot/internal/nav1-track-error-deg-magnified", nav1TrackErrorDegMagnified);
		}

		settimer(listenerApNav1NearFarFunc, 0.05);
	}
}
setlistener("/autopilot/locks/heading", listenerApNav1NearFarFunc);


#########################################################
## NAV1/GS hold - with ground-mode (automatic landing) ##
#########################################################

var nav1StearGroundMode = 0;
var nav1PitchDegGroundMode = 0.0;
var nav1VspeedGroundMode = 0;
var nav1KpForThrottle = 0.0;

var listenerApNav1GroundModeFunc = func {

	setprop("/autopilot/internal/nav1-stear-ground-mode-corrected", 0.0);

	if (	getprop("/autopilot/locks/heading") == "nav1-hold" or
		getprop("/autopilot/locks/altitude") == "gs1-hold") {

		if (getprop("/instrumentation/nav[0]/in-range")) {
			#print ("-> listenerApNav1GroundModeFunc -> installed");

			nav1StearGroundMode = 0.0;
			nav1VspeedGroundMode = 0;
			nav1PitchDegGroundMode = 0.0;

			var gearTouchedGround = 0;
			if (	getprop("/gear/gear[0]/wow") or
				getprop("/gear/gear[1]/wow") or
				getprop("/gear/gear[2]/wow") or
				getprop("/gear/gear[3]/wow") or
				getprop("/gear/gear[4]/wow") or
				getprop("/gear/gear[5]/wow")) {
				gearTouchedGround = 1;
			}


			if (getprop("/autopilot/locks/altitude") == "gs1-hold") {

				var totalFuelLbs = getTotalFuelLbs();
				# print("totalFuelLbs=", totalFuelLbs);

				# calculate 'Kp' for 'glideslope with throttle' on ground-mode
				if (getprop("/controls/flight/flaps") < 0.833) {
					nav1KpForThrottle = 0.7;
					if (totalFuelLbs < 100000.0) {
						nav1KpForThrottle -= ((100000.0 - totalFuelLbs) * 0.000005);
						if (nav1KpForThrottle < 0.2) {
							nav1KpForThrottle = 0.2;
						}
					}
				}
				else {
					nav1KpForThrottle = 1.0;
					if (totalFuelLbs < 100000.0) {
						nav1KpForThrottle -= ((100000.0 - totalFuelLbs) * 0.000005);
						if (nav1KpForThrottle < 0.3) {
							nav1KpForThrottle = 0.3;
						}
					}
				}


#				if (getprop("velocities/groundspeed-kt") != 0.0) {
#					# ratio 0.085 - 0.095 seams to be appropriate
#					print("SPEED-RATIO=", getprop("velocities/vertical-speed-fps") / getprop("velocities/groundspeed-kt"));
#				}

				var gsRateOfClimb = 0.0;

				var altitudeAglFt = getprop("/position/altitude-agl-ft");

				# print("airspeed-kt=", getprop("/velocities/airspeed-kt"));
				# print("altitude-agl-ft=", altitudeAglFt);


				# calculate pitch for gs1-hold - ground-mode (NOTICE: 'nav1PitchDegGroundMode' must be set in
				# each 'if-elsif'-block instead of the last, which activates only speedbeaks !!!)

				if (altitudeAglFt < 40.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 5.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.5, 4.5);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 5.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.5, 7.5);
						}
					}

					if (nav1VspeedGroundMode < 2 and gearTouchedGround == 0) { # to not confuse the reverser
						if (	getprop("/autopilot/locks/speed") == "speed-with-throttle") {
							if (totalFuelLbs < 60000) {
								interpolate("/controls/engines/engine[0]/throttle", 0.0, 0.2);
								interpolate("/controls/engines/engine[1]/throttle", 0.0, 0.2);
								interpolate("/controls/engines/engine[2]/throttle", 0.0, 0.2);
								interpolate("/controls/engines/engine[3]/throttle", 0.0, 0.2);
							}
							else {
								interpolate("/controls/engines/engine[0]/throttle", 0.0, 0.5);
								interpolate("/controls/engines/engine[1]/throttle", 0.0, 0.5);
								interpolate("/controls/engines/engine[2]/throttle", 0.0, 0.5);
								interpolate("/controls/engines/engine[3]/throttle", 0.0, 0.5);
							}
						}
					}
					nav1VspeedGroundMode = 2; # avoid vspeed-controller running

					#setprop("/controls/flight/speedbrake", 1);
				}
				elsif (altitudeAglFt < 80.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 5.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.5, 5.0);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 5.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.0, 7.5);
						}
					}

					# control vertical speed with throttle, fixed vspeed (activate appropriate controller)
					if (totalFuelLbs < 100000) {
						setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -450.0);
					}
					else {
						setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -280.0);
					}
					nav1VspeedGroundMode = 1;

					#setprop("/controls/flight/speedbrake", 1);
				}
				elsif (altitudeAglFt < 120.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 5.0);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.0, 7.0);
						}
					}

					# control vertical speed with throttle, fixed vspeed (activate appropriate controller)
					if (totalFuelLbs < 100000) {
						setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -450.0);
					}
					else {
						setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", -280.0);
					}
					nav1VspeedGroundMode = 1;

					#setprop("/controls/flight/speedbrake", 1);
				}
				elsif (altitudeAglFt < 220.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 5.0);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.5, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.5, 7.0);
						}
					}

					# control vertical speed with throttle (vspeed dependent on groundspeed)

					if (totalFuelLbs < 100000) {
						# vspeed depends on ground-speed to hold a constand angle of decent
						gsRateOfClimb = getprop("velocities/groundspeed-kt") * -0.12;
					}
					else {
						# vspeed depends on ground-speed to hold a constand angle of decent
						gsRateOfClimb = getprop("velocities/groundspeed-kt") * -0.07;
					}
					gsRateOfClimb = (gsRateOfClimb < -20.0 ? -20.0 : gsRateOfClimb);
					gsRateOfClimb = (gsRateOfClimb > -10.0 ? -10.0 : gsRateOfClimb);
					setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", gsRateOfClimb * 33.333);

					nav1VspeedGroundMode = 1;

					#if (getprop("/velocities/airspeed-kt") > 145.0 or getprop("/orientation/pitch-deg") < 1.0) {
					#	setprop("/controls/flight/speedbrake", 1);
					#}
				}
				elsif (altitudeAglFt < 300.0) {
					if (getprop("/controls/flight/flaps") < 0.833) {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.0, 5.0);
						}
					}
					else {
						if (totalFuelLbs > 160000) {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 4.0, 12.0);
						}
						else {
							nav1PitchDegGroundMode = maxclambed(getprop("/orientation/pitch-deg"), 3.5, 7.0);
						}
					}

					# control vertical speed with throttle, follow (clambed) glideslope-signal
					gsRateOfClimb = getprop("/instrumentation/nav[0]/gs-rate-of-climb");

					if (totalFuelLbs < 100000) {
						# vspeed depends on ground-speed to hold a constand angle of decent
						gsRateOfClimb = getprop("velocities/groundspeed-kt") * -0.12;
					}
					else {
						# vspeed depends on ground-speed to hold a constand angle of decent
						gsRateOfClimb = getprop("velocities/groundspeed-kt") * -0.08;
					}
					gsRateOfClimb = (gsRateOfClimb < -20.0 ? -20.0 : gsRateOfClimb);
					gsRateOfClimb = (gsRateOfClimb > -10.0 ? -10.0 : gsRateOfClimb);
					setprop("/autopilot/internal/nav1-vspeed-ground-mode-value", gsRateOfClimb * 33.333);

					nav1VspeedGroundMode = 1;

					if (getprop("/velocities/airspeed-kt") > 145.0 or getprop("/orientation/pitch-deg") < 1.0) {
						#setprop("/controls/flight/speedbrake", 1);
					}
					else {
						setprop("/controls/flight/speedbrake", 0);
					}
				}
			}


			# calculate steering-correction due to heading-error
			if (gearTouchedGround == 1) {

				if (getprop("/autopilot/internal/nav1-stear-ground-mode-uncorrected") == nil) {
					setprop("/autopilot/internal/nav1-stear-ground-mode-uncorrected", 0.0);
				}
				var nav1StearGroundModeUncorrected = getprop("/autopilot/internal/nav1-stear-ground-mode-uncorrected");
				nav1StearGroundMode = nav1StearGroundModeUncorrected * 0.001;

				var navError = getprop("/autopilot/internal/nav1-track-error-deg");

				var correction = (getprop("/orientation/heading-deg") - getprop("/instrumentation/nav[0]/heading-deg")) * 0.02;
				nav1StearGroundMode += correction;

				# consider tiller-steering
				if (getprop("/controls/gear/tiller-enabled") != nil and getprop("/controls/gear/tiller-enabled") > 0) {
					nav1StearGroundMode = nav1StearGroundMode * 3.5;
				}
			}

			if (gearTouchedGround == 1) {

				#setprop("/controls/flight/speedbrake", 1);

				# break speed down to 20 kts and disengage autopilot (altitude-/speed-hold)

				if (getprop("/autopilot/locks/altitude") == "gs1-hold") {

					# reverse-thrust
					if (getprop("/gear/gear[0]/wow")) {
						if (getprop("/velocities/airspeed-kt") > 100.0) {
							if (getprop("/engines/engine[0]/reversed") == 0) {
								# start thrust-reversers
								if (	getprop("/autopilot/locks/speed") == "speed-with-throttle" or
									getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

									setprop("/controls/engines/engine[0]/throttle", 0.0);
									setprop("/controls/engines/engine[1]/throttle", 0.0);
									setprop("/controls/engines/engine[2]/throttle", 0.0);
									setprop("/controls/engines/engine[3]/throttle", 0.0);

									interpolate("/controls/flight/elevator", 0.0, 3.0);
									interpolate("/controls/flight/elevator-trim", 0.0, 3.0);

									settimer(startReverserProgram, 1.5);
								}
							}
						}
					}

					# breaks
					if (getprop("/velocities/airspeed-kt") > 120.0) {
						if (	getprop("/autopilot/locks/speed") == "speed-with-throttle" or
							getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

							#if (getprop("/controls/gear/brake-right") < 0.3) {
							#	setprop("/controls/gear/brake-right", 0.3);
							#}
							#if (getprop("/controls/gear/brake-left") < 0.3) {
							#	setprop("/controls/gear/brake-left", 0.3);
							#}
						}
					}
					elsif (getprop("/velocities/airspeed-kt") > 80.0) {
						if (	getprop("/autopilot/locks/speed") == "speed-with-throttle" or
							getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

							#if (getprop("/controls/gear/brake-right") < 0.5) {
							#	setprop("/controls/gear/brake-right", 0.5);
							#}
							#if (getprop("/controls/gear/brake-left") < 0.5) {
							#	setprop("/controls/gear/brake-left", 0.5);
							#}
						}
					}
					elsif (getprop("/velocities/airspeed-kt") > 20.0) {
						if (	getprop("/autopilot/locks/speed") == "speed-with-throttle" or
							getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

							#if (getprop("/controls/gear/brake-right") < 1.0) {
							#	setprop("/controls/gear/brake-right", 1.0);
							#}
							#if (getprop("/controls/gear/brake-left") < 1.0) {
							#	setprop("/controls/gear/brake-left", 1.0);
							#}
						}
					}
					else {
						# stop breaking at 20 kts to keep some speed for taxiing
						if (	getprop("/autopilot/locks/speed") == "speed-with-throttle" or
							getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

							setprop("/controls/engines/engine[0]/throttle", 0.0);
							setprop("/controls/engines/engine[1]/throttle", 0.0);
							setprop("/controls/engines/engine[2]/throttle", 0.0);
							setprop("/controls/engines/engine[3]/throttle", 0.0);

							#setprop("/controls/gear/brake-right", 0.0);
							#setprop("/controls/gear/brake-left", 0.0);
						}

						setprop("/autopilot/locks/heading", "");
						setprop("/autopilot/locks/altitude", "");
						setprop("/autopilot/locks/speed", "");

						# if reversers still running, stop them now
						if (	getprop("/autopilot/locks/speed") == "speed-with-throttle" or
							getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

							if (getprop("/engines/engine[0]/reversed") == 1) {
								reversethrust.togglereverser();
							}
						}
						setprop("/autopilot/locks/speed", "");
					}
				}
			}

			setprop("/autopilot/internal/nav1-stear-ground-mode-corrected", nav1StearGroundMode);
			setprop("/autopilot/internal/nav1-pitch-deg-ground-mode", nav1PitchDegGroundMode);
			setprop("/autopilot/internal/nav1-vspeed-ground-mode", nav1VspeedGroundMode);
			setprop("/autopilot/internal/nav1-kp-for-throttle-ground-mode", nav1KpForThrottle);
		}
		else {
			setprop("/autopilot/internal/nav1-hold-near-by-or-ground-mode", 0);
		}

		settimer(listenerApNav1GroundModeFunc, 0.1);
	}
}

## handle thrust-reversers for NAV1 ground-mode ##
var startReverserProgram = func {
	if (	getprop("/autopilot/locks/speed") == "speed-with-throttle" or
		getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

		if (getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {
			if (getprop("/controls/engines/engine[0]/throttle") > 0.0) {
				setprop("/controls/engines/engine[0]/throttle", 0.0);
			}
			if (getprop("/controls/engines/engine[1]/throttle") > 0.0) {
				setprop("/controls/engines/engine[1]/throttle", 0.0);
			}
			if (getprop("/controls/engines/engine[2]/throttle") > 0.0) {
				setprop("/controls/engines/engine[2]/throttle", 0.0);
			}
			if (getprop("/controls/engines/engine[3]/throttle") > 0.0) {
				setprop("/controls/engines/engine[3]/throttle", 0.0);
			}
		}

		reversethrust.togglereverser();
		settimer(reverserProgramFunc, 0.5);
	}
}
var reverserProgramFunc = func {
	if (getprop("/autopilot/locks/altitude") == "gs1-hold") {

		if (	getprop("/autopilot/locks/speed") == "speed-with-throttle" or
			getprop("/autopilot/locks/speed") == "speed-with-pitch-trim") {

			if (getprop("/engines/engine[0]/reversed") == 1) {
				if (getprop("/velocities/airspeed-kt") > 80.0) {

					if (	getprop("/controls/engines/engine[0]/throttle") < 0.8) {
						setprop("/controls/engines/engine[0]/throttle", getprop("/controls/engines/engine[0]/throttle") + 0.005);
					}
					if (	getprop("/controls/engines/engine[1]/throttle") < 0.8) {
						setprop("/controls/engines/engine[1]/throttle", getprop("/controls/engines/engine[1]/throttle") + 0.005);
					}
					if (	getprop("/controls/engines/engine[2]/throttle") < 0.8) {
						setprop("/controls/engines/engine[2]/throttle", getprop("/controls/engines/engine[2]/throttle") + 0.005);
					}
					if (	getprop("/controls/engines/engine[3]/throttle") < 0.8) {
						setprop("/controls/engines/engine[3]/throttle", getprop("/controls/engines/engine[3]/throttle") + 0.005);
					}
				}
				else {
					if (	getprop("/controls/engines/engine[0]/throttle") > 0.0) {
						setprop("/controls/engines/engine[0]/throttle", getprop("/controls/engines/engine[0]/throttle") - 0.005);
					}
					if (	getprop("/controls/engines/engine[1]/throttle") > 0.0) {
						setprop("/controls/engines/engine[1]/throttle", getprop("/controls/engines/engine[1]/throttle") - 0.005);
					}
					if (	getprop("/controls/engines/engine[2]/throttle") > 0.0) {
						setprop("/controls/engines/engine[2]/throttle", getprop("/controls/engines/engine[2]/throttle") - 0.005);
					}
					if (	getprop("/controls/engines/engine[3]/throttle") > 0.0) {
						setprop("/controls/engines/engine[3]/throttle", getprop("/controls/engines/engine[3]/throttle") - 0.005);
					}
					if (	getprop("/controls/engines/engine[0]/throttle") <= 0.01 and
						getprop("/controls/engines/engine[1]/throttle") <= 0.01 and
						getprop("/controls/engines/engine[2]/throttle") <= 0.01 and

						getprop("/controls/engines/engine[3]/throttle") <= 0.01) {

						setprop("/controls/engines/engine[0]/throttle", 0.0);
						setprop("/controls/engines/engine[1]/throttle", 0.0);
						setprop("/controls/engines/engine[2]/throttle", 0.0);
						setprop("/controls/engines/engine[3]/throttle", 0.0);
						if (getprop("/engines/engine[0]/reversed") == 1) {
							reversethrust.togglereverser();
						}
					}
				}

				settimer(reverserProgramFunc, 0.1);
			}
		}
	}
}

setlistener("/autopilot/locks/altitude", listenerApNav1GroundModeFunc);

