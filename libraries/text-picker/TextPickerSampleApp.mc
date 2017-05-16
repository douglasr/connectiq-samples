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

var gWidgetStarted = false;

//Simple app to show example of using the TextPicker library.
class TextPickerApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new TextPickerSampleView(), new TextPickerSampleInput() ];
    }

}

class TextPickerSampleView extends Ui.View {
    var devH, devW;

    function initialize() {
        var deviceSettings = System.getDeviceSettings();
        devH = deviceSettings.screenHeight;
        devW = deviceSettings.screenWidth;
        View.initialize();
    }

    function onUpdate(dc) {
        $.gWidgetStarted = false;
        var fontHeight = Gfx.getFontHeight(Gfx.FONT_SYSTEM_MEDIUM);
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(devW/2, devH/2-fontHeight*1.5, Gfx.FONT_SYSTEM_LARGE, "Text Picker", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(devW/2, devH/2, Gfx.FONT_SYSTEM_MEDIUM, "Press START", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(devW/2, devH/2+fontHeight, Gfx.FONT_SYSTEM_MEDIUM, "to enter text.", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }
}


class TextPickerSampleInput extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onKey(event) {
        var key = event.getKey();
        if (key == Ui.KEY_ENTER || key == Ui.KEY_START) {
            return onSelect();
        } else if (key == Ui.KEY_ESC || key == Ui.KEY_LAP) {
            return onBack();
        }
        return false;
    }

    function onSelect() {
        if (!$.gWidgetStarted) {
            $.gWidgetStarted = true;
            var view = new TextPickerView("INPUT TITLE","Subtitle Text/Info",4,6,"");
            Ui.pushView(view, new TextPickerDelegate(view), Ui.SLIDE_LEFT);
        }
        return true;
    }

    function onBack() {
        if ($.gWidgetStarted) {
            $.gWidgetStarted = false;
            Ui.popView(Ui.SLIDE_RIGHT);
            return true;
        }
        return false;
    }

}
