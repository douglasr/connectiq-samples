using Toybox.Application as App;
using Toybox.WatchUi as Ui;

var gDeviceSettings;
var gSettingsChanged = true;

class SimpleAnalogApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
		$.gDeviceSettings = System.getDeviceSettings();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // New app settings have been received so trigger a UI update
	function onSettingsChanged() {
		$.gSettingsChanged = true;
		$.gDeviceSettings = System.getDeviceSettings();
		Ui.requestUpdate();
	}

    // Return the initial view of your application here
    function getInitialView() {
        return [ new SimpleAnalogView() ];
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

}