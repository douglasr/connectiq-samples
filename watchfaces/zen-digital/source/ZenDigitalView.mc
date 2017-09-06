using Toybox.WatchUi as WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time as Time;

class ZenDigitalView extends WatchUi.WatchFace {

    static const ARC_MAX = 68;

    var deviceModel;
    var deviceStyle;
    var screenWidth;
    var screenHeight;
    var displaySeconds = false;
    var displaySecondTimezone = false;
    var secondsLabelOrigX;
    var isWithinGesture = false;

    function initialize() {
        WatchFace.initialize();
        deviceModel = WatchUi.loadResource(Rez.Strings.DeviceModel);
        deviceStyle = $.gDeviceSettings.screenShape;
        screenWidth = $.gDeviceSettings.screenWidth;
        screenHeight = $.gDeviceSettings.screenHeight;
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        secondsLabelOrigX = View.findDrawableById("SecondsLabel").locX;
    }

    function onShow() {
    }

    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        isWithinGesture = true;
        if (App.getApp().getBooleanProperty("DisplaySeconds",true)) {
            displaySeconds = true;
        }
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        isWithinGesture = false;
        // no matter what the setting, turn the seconds off
        displaySeconds = false;
        WatchUi.requestUpdate();
    }

    function onPartialUpdate(dc) {
    }

    //! Update the view
    function onUpdate(dc) {
        // start by getting the device settings & user settings (both of which may have changed)
        $.gDeviceSettings = System.getDeviceSettings();

        // if we're not in a gesture then display nothing (by clearing the screen)...
        if (!isWithinGesture) {
            dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
            dc.clear();
            return;
        }

        var timeFormat = "$1$:$2$";
        var is24Hour = $.gDeviceSettings.is24Hour;
        displaySecondTimezone = App.getApp().getBooleanProperty("DisplaySecondTimezone",true);
        var wrapOverGoal = App.getApp().getBooleanProperty("OverGoalWrap",false);

        var timeNow = Time.now();
        var localTimeInfo = Time.Gregorian.info(timeNow, Time.FORMAT_MEDIUM);
        var localHour = localTimeInfo.hour;
        if (!is24Hour) {
            localHour = hourTo12Hour(localTimeInfo.hour);
        } else {
            if (App.getApp().getBooleanProperty("UseMilitaryFormat",true)) {
                timeFormat = "$1$$2$";
            }
            localHour = localHour.format("%02d");
        }
        var localTimeStr = Lang.format(timeFormat, [localHour, localTimeInfo.min.format("%02d")]);

        // Update the view
        var dateLabel = View.findDrawableById("DateLabel");
        var timeLabel = View.findDrawableById("TimeLabel");
        var secondsLabel = View.findDrawableById("SecondsLabel");

        dateLabel.setColor($.gFGColor);
        timeLabel.setColor($.gFGColor);

        var dateString;
        var dateFormat = "$1$ $2$";
        dateString = Lang.format(dateFormat, [localTimeInfo.day_of_week.toUpper(), localTimeInfo.day.format("%02d")]);
        dateLabel.setText(dateString);

        timeLabel.setText(localTimeStr);

        var secondTimeLabel = View.findDrawableById("SecondTimeLabel");
        if (displaySecondTimezone) {
            var utcOffset = new Time.Duration(-System.getClockTime().timeZoneOffset);   // negate the offset since we are working backwards from local to UTC
            var secondTimeOffset = App.getApp().getFloatProperty("SecondTimezoneOffset",0.0);
            var secondTime = timeNow.add(utcOffset).add(new Time.Duration(secondTimeOffset * Time.Gregorian.SECONDS_PER_HOUR));
            var secondTimeInfo = Time.Gregorian.info(secondTime, Time.FORMAT_MEDIUM);
            var secondTimeHour = secondTimeInfo.hour;
            var secondTimeStr;
            if (!is24Hour) {
                secondTimeStr = Lang.format(timeFormat + " $3$", [hourTo12Hour(secondTimeInfo.hour), secondTimeInfo.min.format("%02d"), (secondTimeInfo.hour < 12 ? "AM" : "PM")]);
            } else {
                secondTimeStr = Lang.format(timeFormat, [secondTimeHour.format("%02d"), secondTimeInfo.min.format("%02d")]);
            }
            secondTimeLabel.setColor($.gFGColor);
            secondTimeLabel.setText(secondTimeStr + (secondTimeOffset == 0 && is24Hour ? " UTC" : ""));
        } else {
            secondTimeLabel.setText("");
        }

        secondsLabel.setText("");   // most times we are going to have an empty seconds label
        if (displaySeconds) {
            if (App.getApp().getBooleanProperty("DisplayMoveIndicator",true) &&
                Toybox.ActivityMonitor.getInfo().moveBarLevel > Toybox.ActivityMonitor.MOVE_BAR_LEVEL_MIN &&
                !deviceModel.substring(0,10).equals("vivoactive") && !deviceModel.equals("fr920xt")) {
                    secondsLabel.setLocation(secondsLabelOrigX-5,secondsLabel.locY);
            } else {
                secondsLabel.setLocation(secondsLabelOrigX,secondsLabel.locY);
            }
            // technically we should be getting the seconds from the local date/time (if the main time is configured
            //   as such) but since they "should be" the same we'll just go with it...
            secondsLabel.setColor($.gFGColor);
            secondsLabel.setText(localTimeInfo.sec.format("%02d"));
        }

        // call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // now manually draw/update the steps, move and battery indicator bars (if so configured)
        if ($.gDeviceSettings.activityTrackingOn) {
            if (App.getApp().getBooleanProperty("DisplayStepsIndicator",true)) {
                var activityInfo = Toybox.ActivityMonitor.getInfo();
                var stepPercent = activityInfo.steps.toFloat()/activityInfo.stepGoal.toFloat();
                updateSteps(dc,stepPercent,wrapOverGoal);
            }
            if (App.getApp().getBooleanProperty("DisplayMoveIndicator",true)) {
                updateMoveWarning(dc);
            }
        }
        if (App.getApp().getBooleanProperty("DisplayBatteryIndicator",true)) {
            updateBatteryLevel(dc);
        }
    }

    function updateSteps(dc,stepPercent,wrapOverGoal) {
        var fillPercent = stepPercent;
        var borderColor = Gfx.COLOR_DK_GRAY;
        var fillColor = Gfx.COLOR_LT_GRAY;

        if ($.gBGColor == Gfx.COLOR_DK_GRAY) {
            borderColor = Gfx.COLOR_BLACK;
            fillColor = Gfx.COLOR_LT_GRAY;
        } else if ($.gBGColor == Gfx.COLOR_LT_GRAY) {
            borderColor = Gfx.COLOR_BLACK;
            fillColor = Gfx.COLOR_DK_GRAY;
        }

        if (fillPercent > 1.0 && wrapOverGoal) {
            fillPercent = ((stepPercent * 100).toNumber() % 100) / 100.0;
        } else if (fillPercent > 1.0) {
            fillPercent = 1.0;
        }

        if (deviceStyle == System.SCREEN_SHAPE_ROUND || deviceStyle == System.SCREEN_SHAPE_SEMI_ROUND) {
            var x = screenWidth/2;
            var y = screenHeight/2;
            var r = x-5;
            if (fillPercent > 0) {
                var arcSize = fillPercent*ARC_MAX;
                // only show a completed step bar if we've reached our goal
                if (arcSize >= ARC_MAX-0.51 && arcSize != ARC_MAX && fillPercent != 1.0) {
                    arcSize = ARC_MAX-1;
                } else if (arcSize <= 0.51) {
                    arcSize = 1;
                }
                dc.setColor(fillColor, Gfx.COLOR_TRANSPARENT);
                dc.setPenWidth(5);
                dc.drawArc(x, y, r-3, Gfx.ARC_CLOCKWISE, 214, 214-arcSize);
                dc.setPenWidth(1);
            }
            dc.setColor(borderColor, Gfx.COLOR_TRANSPARENT);
            // draw the outer and inner arc borders
            dc.drawArc(x, y, r, Gfx.ARC_CLOCKWISE, 215, 145);
            dc.drawArc(x, y, r-5, Gfx.ARC_CLOCKWISE, 215, 145);
            // draw the top and bottom borders
            for (var i=0; i < 5; i++) {
                dc.drawArc(x, y, r-i, Gfx.ARC_CLOCKWISE, 146, 145);
                dc.drawArc(x, y, r-i, Gfx.ARC_CLOCKWISE, 215, 214);
            }
            // if we're over 100%, indicate we've wrapped
            if (wrapOverGoal && stepPercent >= 1.0) {
                var wrapAngle = 145;
                while (wrapAngle < 215) {
                    for (var i=0; i < 5; i++) {
                        dc.drawArc(x, y, r-i, Gfx.ARC_CLOCKWISE, wrapAngle+1, wrapAngle);
                    }
                    wrapAngle += 4;
                }
            }
        } else {
            var barHeight = screenHeight/2;
            dc.setColor(fillColor, Gfx.COLOR_TRANSPARENT);
            dc.fillRectangle(5, (barHeight*1.5)-(barHeight*fillPercent), 5, barHeight*fillPercent);
            dc.setColor(borderColor, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(5, barHeight-barHeight/2, 5, barHeight);
            // if we're over 100%, indicate we've wrapped
            if (wrapOverGoal && stepPercent >= 1.0) {
                var wrapY = barHeight-barHeight/2;
                while (wrapY < barHeight+barHeight/2) {
                    dc.drawLine(5,wrapY,10,wrapY);
                    wrapY += 4;
                }
            }
        }
    }

    function updateMoveWarning(dc) {
        var activityInfo = Toybox.ActivityMonitor.getInfo();

        // if the move bar level is above the minimum then display the indicator...
        if (activityInfo.moveBarLevel > Toybox.ActivityMonitor.MOVE_BAR_LEVEL_MIN) {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);

            if (deviceStyle == System.SCREEN_SHAPE_ROUND || deviceStyle == System.SCREEN_SHAPE_SEMI_ROUND) {
                var x = screenWidth/2;
                var y = screenHeight/2;
                var r = x-5;
                dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
                dc.setPenWidth(5);
                for (var i=activityInfo.moveBarLevel-1; i > 0; i--) {
                    dc.drawArc(x, y, x-8, Gfx.ARC_CLOCKWISE, 0+i*9, -7+i*9);
                }
                dc.drawArc(x, y, x-8, Gfx.ARC_CLOCKWISE, 0, 325);
                dc.setPenWidth(1);
            } else {
                // nice, split up move bars (similar to the device default)
                var barHeight = screenHeight/2;
                var singleBarHeight = (barHeight-8)/8;
                for (var i=activityInfo.moveBarLevel-1; i > 0; i--) {
                    dc.fillRectangle(screenWidth-10, (barHeight+2-i*(singleBarHeight+2)), 5, singleBarHeight);
                }
                // if we're in the move bar section, there is at least one bar (the big one) of inactivity
                dc.fillRectangle(screenWidth-10, screenHeight/2+2, 5, barHeight/2-2);
            }
        }
    }

    function updateBatteryLevel(dc) {
        var batteryLevel = System.getSystemStats().battery;
        var x = screenWidth/2-25;
        var y = screenHeight-10;
        var w = 50;
        var h = 6;

        if (deviceModel.equals("epix")) {
            y = screenHeight-5;
        }
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, batteryLevel/100*w, h-2);
        dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_TRANSPARENT);
        dc.drawRectangle(x-1, y-1, w+2, h);
    }

    function hourTo12Hour(hour) {
        if (hour > 12) {
            return (hour - 12);
        } else if (hour == 0) {
            // when using the 12 hour clock, midnight is displayed as 12:00 AM (not 0:00 AM)
            return (12);
        }
        return (hour);
    }

}
