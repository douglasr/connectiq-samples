using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class BigDigitalBackground extends Ui.Drawable {

	function initialize(dictionary) {
		Drawable.initialize(dictionary);
	}

	function draw(dc) {
		// Set the background color then call to clear the screen
		dc.setColor(Gfx.COLOR_TRANSPARENT, App.getApp().getProperty("BackgroundColor"));
		dc.clear();
	}

}
