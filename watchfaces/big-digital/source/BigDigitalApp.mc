using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

var gDeviceSettings;
var gFGColor;
var gBGColor;

class BigDigitalApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
        onSettingsChanged();
    }

    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new BigDigitalView() ];
    }

    //! New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        $.gDeviceSettings = System.getDeviceSettings();
		$.gFGColor = getNumberProperty("ForegroundColor",Gfx.COLOR_WHITE);
		$.gBGColor = getNumberProperty("BackgroundColor",Gfx.COLOR_BLACK);

        Ui.requestUpdate();
    }

	function getBooleanProperty(key, initial) {
		var value = getProperty(key);
		if (value != null) {
			if (value instanceof Lang.Boolean) {
				return value;
			} else if (value instanceof Lang.String) {
				// added to work around GCM Android problems
				return value.toNumber() != 0;
			}
		}
		return initial;
	}

    function getFloatProperty(key, initial) {
        var value = getProperty(key);
        if (value != null) {
            if (value instanceof Lang.Float) {
                return value;
            } else if (value instanceof Lang.Number) {
                return value.toFloat();
            } else if (value instanceof Lang.String) {
                return value.toFloat();
            }
        }
        return initial;
    }

	function getNumberProperty(key, initial) {
		var value = getProperty(key);
		if (value != null) {
			if (value instanceof Lang.Number) {
				return value;
			} else if (value instanceof Lang.Float) {
				// added to work around GCM Android problems
				return value.toNumber();
			} else if (value instanceof Lang.String) {
				return value.toNumber();
			}
		}
		return initial;
	}

}