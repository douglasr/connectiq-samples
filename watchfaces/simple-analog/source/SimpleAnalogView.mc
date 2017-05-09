using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

class SimpleAnalogView extends Ui.WatchFace {

    static const HOUR_TICK_LENGTH = 10;
    static const MINUTE_TICK_LENGTH = 6;	
	static const MINUTE_MARK_COLOR = Gfx.COLOR_LT_GRAY;
	static const SECOND_HAND_COLOR = Gfx.COLOR_RED;

	var cDisplaySeconds;
	var cDisplayBatteryGraph;

	var middleX;
	var middleY;
	var arcRadius;
	var updateSeconds = false;
	var resBackground;

	function initialize() {
		WatchFace.initialize();
		middleX = $.gDeviceSettings.screenWidth/2;
		middleY = $.gDeviceSettings.screenHeight/2;
		arcRadius = $.gDeviceSettings.screenHeight/2;
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
		resBackground = Ui.loadResource(Rez.Drawables.Background);
	}

	// Update the view
	function onUpdate(dc) {
	    // only retrieve the settings if they've actually changed
		if ($.gSettingsChanged) {
			$.gSettingsChanged = false;
			retrieveSettings();
		}

		// get local time, UTC time and UTC date
		var timeNow = Time.now();
		var clockTime = Time.Gregorian.info(timeNow, Time.FORMAT_MEDIUM);
		var dateStr = clockTime.day_of_week.substring(0,3).toUpper() + " " + clockTime.day.format("%02d");

		// clear the screen
		dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
		dc.clear();

		// draw the background
		dc.drawBitmap(0,0,resBackground);

		// draw the 12 o'clock marker
		dc.setPenWidth(9);
		dc.setColor(MINUTE_MARK_COLOR, Gfx.COLOR_TRANSPARENT);
		dc.drawLine(DeviceOverride.TOP_HOUR_MARKER_LEFT_X,-1,DeviceOverride.TOP_HOUR_MARKER_LEFT_X,DeviceOverride.TOP_HOUR_MARKER_HEIGHT);
		dc.drawLine(DeviceOverride.TOP_HOUR_MARKER_RIGHT_X,-1,DeviceOverride.TOP_HOUR_MARKER_RIGHT_X,DeviceOverride.TOP_HOUR_MARKER_HEIGHT);
        dc.setPenWidth(5);
        dc.setColor(SECOND_HAND_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(DeviceOverride.TOP_HOUR_MARKER_LEFT_X,0,DeviceOverride.TOP_HOUR_MARKER_LEFT_X,DeviceOverride.TOP_HOUR_MARKER_HEIGHT);
        dc.drawLine(DeviceOverride.TOP_HOUR_MARKER_RIGHT_X,0,DeviceOverride.TOP_HOUR_MARKER_RIGHT_X,DeviceOverride.TOP_HOUR_MARKER_HEIGHT);

        var radian, points;

        // draw the minute marks
        dc.setPenWidth(1);
        dc.setColor(MINUTE_MARK_COLOR, Gfx.COLOR_TRANSPARENT);
        for (var i=0; i < 60; i++) {
            // skip the three ticks at the top of the hour
            if (i >= 44 && i <= 46) {
                continue;
            }
            points = calcLineFromCircleEdge(arcRadius,MINUTE_TICK_LENGTH,Math.toRadians(6*i));
            dc.drawLine(points[0],points[1],points[2],points[3]);
        }

		// draw the larger hour marks
		dc.setColor(MINUTE_MARK_COLOR, Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(5);
        for (var i=0; i < 12; i++) {
	        // skip the mark at the top of the hour
	        if (i == 9) {
	            continue;
	        }
	        radian = Math.toRadians(30*i);
	        points = calcLineFromCircleEdge(arcRadius,HOUR_TICK_LENGTH,radian);
	        dc.drawLine(points[0],points[1],points[2],points[3]);
        }
		dc.setPenWidth(1);

        // draw the day of week & day of month
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(middleX-DeviceOverride.DATE_BOX_W/2, DeviceOverride.DATE_Y-DeviceOverride.DATE_BOX_H/2, DeviceOverride.DATE_BOX_W, DeviceOverride.DATE_BOX_H, 4);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
		dc.drawText(middleX, DeviceOverride.DATE_Y, DeviceOverride.DATE_FONT, dateStr, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);

		// manually draw/update the battery indicator bars (if so configured)
		if (App.getApp().getBooleanProperty("DisplayBatteryIndicator",true)) {
			updateBatteryLevel(dc);
		}

		// draw the hands
		drawHands(dc, clockTime, updateSeconds);
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
		resBackground = null;
	}

	// The user has just looked at their watch. Timers and animations may be started here.
	function onExitSleep() {
		if (cDisplaySeconds) {
			updateSeconds = true;
			WatchUi.requestUpdate();
		}
	}

	// Terminate any active timers and prepare for slow updates.
	function onEnterSleep() {
		if (cDisplaySeconds) {
			updateSeconds = false;
			WatchUi.requestUpdate();
		}
	}

	function drawHands(dc, clockTime, drawSecondHand) {
        var hourHand;
        var minuteHand;
        var secondHand;

        // draw the hour. Convert it to minutes and compute the angle.
        hourHand = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHand = hourHand / (12 * 60.0);
        hourHand = hourHand * Math.PI * 2 - degreesToRadians(90);
        drawHand(dc, hourHand, DeviceOverride.HOUR_HAND_LENGTH, 6, Gfx.COLOR_WHITE);

        // draw the minute
        minuteHand = (clockTime.min / 60.0) * Math.PI * 2 - degreesToRadians(90);
        drawHand(dc, minuteHand, DeviceOverride.MINUTE_HAND_LENGTH, 6, Gfx.COLOR_WHITE);

		// clean up the center
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
		dc.fillCircle(middleX, middleY, 8);
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		dc.drawCircle(middleX, middleY, 8);

        // draw the second hand
        if (drawSecondHand) {
        	secondHand = (clockTime.sec / 60.0) * Math.PI * 2 - degreesToRadians(90);
        	drawHand(dc, secondHand, DeviceOverride.SECOND_HAND_LENGTH, 2, SECOND_HAND_COLOR);
			dc.setColor(SECOND_HAND_COLOR, Gfx.COLOR_TRANSPARENT);
			for (var i=6; i > 0; i--) {
				dc.drawCircle(middleX, middleY, i);
			}
        }
		dc.setPenWidth(1);
	}

    function drawHand(dc, angle, length, width, color) {
    	var endX = Math.cos(angle) * length;
    	var endY = Math.sin(angle) * length;
    	dc.setColor(color,Gfx.COLOR_TRANSPARENT);
    	dc.setPenWidth(width);
    	dc.drawLine(middleX, middleY, middleX+endX, middleY+endY);
    }

	function updateBatteryLevel(dc) {
		var batteryLevel = System.getSystemStats().battery;
		var x = $.gDeviceSettings.screenWidth/2-25;
		var y = DeviceOverride.BATTERY_GRAPH_Y;
		var w = 50;
		var h = 6;

		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
		dc.fillRectangle(x-1, y-1, w+2, h);
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.fillRectangle(x, y, batteryLevel/100*w, h-2);
		dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.drawRectangle(x-1, y-1, w+2, h);
	}

	function degreesToRadians(deg) {
		return (deg * Math.PI / 180);
	}

    function calcLineFromCircleEdge(arcRadius,lineLength,radian) {
        var pointX = ((arcRadius-lineLength) * Math.cos(radian)).toNumber()+middleX;
        var endX = (arcRadius * Math.cos(radian)).toNumber()+middleX;
        var pointY = ((arcRadius-lineLength) * Math.sin(radian)).toNumber()+middleY;
        var endY = (arcRadius * Math.sin(radian)).toNumber()+middleY;
        return [pointX,pointY,endX,endY];
    }

	function retrieveSettings() {
		$.gDeviceSettings = System.getDeviceSettings();
		cDisplaySeconds = App.getApp().getBooleanProperty("DisplaySeconds",true);
		cDisplayBatteryGraph = App.getApp().getBooleanProperty("DisplayBatteryGraph",true);
	}
}
