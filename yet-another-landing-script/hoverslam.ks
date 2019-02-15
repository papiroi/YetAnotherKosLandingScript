clearscreen.
RUN functions.ks.

set radarOffset to 29.93115.	 				// The value of alt:radar when landed (on gear)
SET launchPad TO LATLNG(-0.0971980934745649, -74.5576639199546).
lock trueRadar to alt:radar - radarOffset.			// Offset radar to get distance from gear to ground
lock g to constant:g * body:mass / body:radius^2.		// Gravity (m/s^2)
lock maxDecel to (ship:availablethrust / ship:mass) - g.	// Maximum deceleration possible (m/s^2)
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		// The distance the burn will require
lock idealThrottle to stopDist / trueRadar.			// Throttle required for perfect hoverslam
lock impactTime to trueRadar / abs(ship:verticalspeed).		// Time until impact, used for landing gear

WAIT UNTIL ship:verticalspeed < -1.
	setHoverPIDLOOPS().
	setHoverTarget(-0.0971980934745649, -74.5576639199546).
	
	print "Preparing for hoverslam...".
	rcs on.
	brakes on.
	lock steering to launchPad:POSITION + R(0, -180, 0).
	when impactTime < 3.5 then {gear on.}

	UNTIL SHIP:STATUS = "LANDED" {
		print "Angle between ship and target point: " + VANG(SHIP:GEOPOSITION:POSITION, launchPad:POSITION) AT (0, 2).
		updateHoverSteering().
		IF impactTime < 6 {
			switchMode(0).
		}

		IF trueRadar < stopDist {
			print "Performing hoverslam" AT (0, 3).
			lock throttle to idealThrottle.
		}
	}

	if SHIP:STATUS = "LANDED" {
		print "Hoverslam completed" AT (0, 4).

		set ship:control:pilotmainthrottle to 0.
		rcs off.
	}

WAIT UNTIL SHIP:STATUS = "LANDED".