/*
MIT License

Copyright (c) 2017 Douglas Robertson (douglas@edgeoftheearth.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


Author: Douglas Robertson (GitHub: [douglasr](https://github.com/douglasr); Garmin Connect: dbrobert)
License: MIT License
*/


using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

// Simple app to show example of using the ActivityIndicator library.
class ActivityIndicatorSampleApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new ActivtyIndicatorSampleView() ];
    }

}

class ActivtyIndicatorSampleView extends Ui.View {
    var devH, devW;
    var timer;

    function initialize() {
        var deviceSettings = System.getDeviceSettings();
        devH = deviceSettings.screenHeight;
        devW = deviceSettings.screenWidth;
        View.initialize();
        timer = new Timer.Timer();
        timer.start( method(:timerCallback), 200, true );   // 5 updates per second
    }

    function onUpdate(dc) {
        var fontHeight = Gfx.getFontHeight(Gfx.FONT_SYSTEM_MEDIUM);
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(devW/2, devH/2-fontHeight*1.5, Gfx.FONT_SYSTEM_MEDIUM, "Activity Indicator", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(devW/2, devH/2, Gfx.FONT_SYSTEM_SMALL, "Infinitely waiting...", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        ActivityIndicator.drawActivityIndicator(dc);
    }

    function timerCallback() {
        Ui.requestUpdate();
    }
}
