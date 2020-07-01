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

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Application as App;
using Toybox.Timer;

class TextPickerModView extends Ui.View {

    // this is here for completeness but is likely calculated elsewhere in an app
    static const DEVICE_WIDTH = System.getDeviceSettings().screenHeight;
    static const DEVICE_HEIGHT = System.getDeviceSettings().screenWidth;

//    static const INPUT_LETTERS = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789";  // valid characters for input
    static const INPUT_LETTERS = ["ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz", "1234567890"];  // valid characters for input Grouped in Upper Case, Lower Case, and Numbers
	static const INPUT_TOG_CONTROLS = ["@#", "!#", "!@"]; 
    static const INPUT_CONTROLS = "<*";   // control characters for input
    static const INPUT_OK = "OK";         // what to render in place of the '*' (accept) character
    static const INPUT_BACK = "<<";       // what to render in place of the '<' (delete) character
    static const INPUT_CAPS = "ABC";       // what to render in place of the '!' (Upper Case) character
    static const INPUT_LOWER_CASE = "abc";       // what to render in place of the '@' (Lower Case) character
    static const INPUT_NUMBERS = "123";       // what to render in place of the '#' (Numbers) character

    // these will likely need to be changed based on device
    // Adjusted to scale on page.  Larger screens could show more characters in the scroll
    // But is still usabel on 240x240 up to 280x280.  Did not try on F3 or Venu devices.
    static const PICKER_TITLE_POS = [(DEVICE_WIDTH*.45).toNumber(),(DEVICE_HEIGHT*.125).toNumber()];                // title position
    static const PICKER_SUBTITLE_POS = [(DEVICE_WIDTH*.1).toNumber(),(DEVICE_HEIGHT*.333).toNumber()];             // subtitle/info position
    static const PICKER_INPUT_POS = [(DEVICE_WIDTH*.1).toNumber(),(DEVICE_HEIGHT/2).toNumber()];   // input display position
    static const PICKER_X = (DEVICE_WIDTH*.725).toNumber();                            // X coordinate of left side of picker
    static const PICKER_WIDTH = 32;                         // width of the picker (from left bar to right bar)
//    static const PICKER_TITLE_POS = [95,30];                // title position
//    static const PICKER_SUBTITLE_POS = [10,80];             // subtitle/info position
//    static const PICKER_INPUT_POS = [10,DEVICE_HEIGHT/2];   // input display position
//    static const PICKER_X = 174;                            // X coordinate of left side of picker
//    static const PICKER_WIDTH = 32;                         // width of the picker (from left bar to right bar)

    // fonts to use for various text; will likely change based on device
    static const FONT_PICKER_TITLE = Gfx.FONT_SMALL;
    static const FONT_PICKER_SUBTITLE = Gfx.FONT_TINY;
    static const FONT_PICKER_VALUE = Gfx.FONT_MEDIUM;
    static const FONT_PICKER_LETTER_NOT_SELECTED = Gfx.FONT_XTINY;
    static const FONT_PICKER_LETTER_SELECTED = Gfx.FONT_TINY;

    var mTitle;
    var mSubTitle;
    var mMinChars;
    var mMaxChars;
    var inputStr = "";
    var input_chars;
    var togCaseIdx = 0; // Used to display the active Letters case or numbers and the available case/number selectors
    var charIdx = 0;

    function initialize(title, subTitle, minChars, maxChars, prefix) {
        mTitle = title;
        mSubTitle = subTitle;
        mMinChars = minChars;
        mMaxChars = maxChars;
        if (prefix != null) {
            inputStr = prefix.toString();   // ensure default value passed is a string.
        }
        if (inputStr.length() >= mMaxChars) {   // Check to see if string passed is at max size  
        	input_chars = INPUT_CONTROLS;		// Set controls only if default string is >= max size
        } else {								// otherwise build full list based on 
        	input_chars = INPUT_LETTERS[togCaseIdx]+INPUT_TOG_CONTROLS[togCaseIdx]+INPUT_CONTROLS;        
        }
        View.initialize();
    }

    function onUpdate(dc) {
        // clear whatever is on the screen to prepare for update
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();

        var rightBarX = PICKER_X + PICKER_WIDTH;

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(PICKER_TITLE_POS[0], PICKER_TITLE_POS[1], FONT_PICKER_TITLE, mTitle, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(PICKER_SUBTITLE_POS[0], PICKER_SUBTITLE_POS[1], FONT_PICKER_SUBTITLE, mSubTitle, Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setPenWidth(2);
        dc.drawLine(PICKER_X, 0, PICKER_X, DEVICE_HEIGHT);
        dc.drawLine(rightBarX, 0, rightBarX, DEVICE_HEIGHT);

        var pickerFontHeight = dc.getTextDimensions(input_chars.substring(0,1), FONT_PICKER_LETTER_SELECTED)[1];

        var sidx;   // index of character at the top of visible list
        var eidx;   // index of character at the bottom of visible list
        var ch;     // character under the cursor

        // draw the (visible) list of characters
        for (var i=(input_chars.length() > 5 ? -2 : input_chars.length()/2-1); i <= (input_chars.length() > 5 ? 2 : input_chars.length()/2); i++) {
            if (i == 0) {
                dc.fillRectangle(PICKER_X,DEVICE_HEIGHT/2-pickerFontHeight/2,PICKER_WIDTH,pickerFontHeight);
                dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            }
            sidx = (charIdx+i) % input_chars.length();
            if (sidx < 0) {
                sidx = sidx + input_chars.length();
            }
            if (input_chars.substring(sidx,sidx+1).equals("<")) {
                ch = INPUT_BACK;
            } else if (input_chars.substring(sidx,sidx+1).equals("*")) {
                ch = INPUT_OK;
                // grey out the 'OK' if there aren't enough characters
                if (inputStr.length() < mMinChars) {
                    dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
                }
            } else if (input_chars.substring(sidx,sidx+1).equals("!")) {	// Add text for case and number slection
                ch = INPUT_CAPS;
            } else if (input_chars.substring(sidx,sidx+1).equals("@")) {
                ch = INPUT_LOWER_CASE;
            } else if (input_chars.substring(sidx,sidx+1).equals("#")) {
                ch = INPUT_NUMBERS;
            } else {
                eidx = sidx + 1;
                ch = input_chars.substring(sidx,eidx);
            }
            dc.drawText(PICKER_X+PICKER_WIDTH/2, (DEVICE_HEIGHT/2)+i*27, i == 0 ? FONT_PICKER_LETTER_SELECTED : FONT_PICKER_LETTER_NOT_SELECTED, ch, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        }
        // draw the string entered (so far)
        dc.drawText(PICKER_INPUT_POS[0], PICKER_INPUT_POS[1], FONT_PICKER_VALUE, inputStr, Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
        // draw the red cursor
        var tmpTextDims = dc.getTextDimensions(inputStr, FONT_PICKER_VALUE);
        // handle the case where the input string is empty, in which case the height will be zero too...
        if (tmpTextDims[1] == 0) {
            tmpTextDims[1] = dc.getTextDimensions("A", FONT_PICKER_VALUE)[1];
        }
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(PICKER_INPUT_POS[0]+tmpTextDims[0], DEVICE_HEIGHT/2-tmpTextDims[1]/2+1, 8, tmpTextDims[1]+1);
        // draw the red rectangle around the selected letter
        dc.setPenWidth(1);
        dc.drawRectangle(PICKER_X,DEVICE_HEIGHT/2-pickerFontHeight/2,PICKER_WIDTH,pickerFontHeight+2);
        dc.drawRectangle(PICKER_X-1,DEVICE_HEIGHT/2-pickerFontHeight/2-1,PICKER_WIDTH+2,pickerFontHeight+2);
    }


    function setCharIdx(idx) {
        charIdx = idx;
        if (charIdx < 0) {
            charIdx = charIdx + input_chars.length();
        }
    }

    function charSelected() {
        // are we adding something from the list of valid letters?
        if (input_chars.length() >= INPUT_LETTERS[togCaseIdx].length() && charIdx < INPUT_LETTERS[togCaseIdx].length()) {
            inputStr = inputStr + input_chars.substring(charIdx,charIdx+1);
        } else if (input_chars.substring(charIdx,charIdx+1).equals("<")) {
            inputStr = inputStr.substring(0,inputStr.length()-1);
            // if we aren't at the maximum number of characters, then set the input characters to all
            //   and set the highlighted character to the back/delete char
            if (inputStr.length() >= mMinChars || inputStr.length() < mMaxChars) {  // Add letters once string less than max lenght
//                input_chars = INPUT_LETTERS+INPUT_CONTROLS;
                input_chars = INPUT_LETTERS[togCaseIdx]+INPUT_TOG_CONTROLS[togCaseIdx]+INPUT_CONTROLS;  
                charIdx = INPUT_LETTERS[togCaseIdx].length()+INPUT_TOG_CONTROLS[togCaseIdx].length(); // the character after the letters is the back/delete char
            }
        }
        // if we're now at the maximum number of characters, change the input characters to
        //   only the control characters and highlight the "OK"
        if (inputStr.length() >= mMaxChars) {
            input_chars = INPUT_CONTROLS;
            charIdx = 1;
        }
    }

}


class TextPickerModDelegate extends Ui.BehaviorDelegate {
    // millisec between updates when long pressing up/down on picker
    static const LONG_PRESS_UPDATE_FREQUENCY = 250;

    var picker;
    var longPressTimer;

    function initialize(the_picker) {
        picker = the_picker;
        BehaviorDelegate.initialize();
    }

    function onKey(event) {
        var key = event.getKey();
        if (key == Ui.KEY_ENTER || key == Ui.KEY_START) {
            return onSelect();
        } else if (key == Ui.KEY_ESC || key == Ui.KEY_LAP) {
            return onBack();
        } else if (key == Ui.KEY_UP || key == Ui.KEY_MODE) {
            return onPreviousPage();
        } else if (key == Ui.KEY_DOWN || key == Ui.KEY_CLOCK) {
            return onNextPage();
        }
        return false;
    }

    // handle long press activity (used to scroll up or down through the list of letters)
    function onKeyPressed(event) {
        var key = event.getKey();
        if (key == Ui.KEY_UP || key == Ui.KEY_MODE) {
            longPressTimer = new Timer.Timer();
            longPressTimer.start( method(:onPreviousPage), LONG_PRESS_UPDATE_FREQUENCY, true );
            return true;
        } else if (key == Ui.KEY_DOWN || key == Ui.KEY_CLOCK) {
            longPressTimer = new Timer.Timer();
            longPressTimer.start( method(:onNextPage), LONG_PRESS_UPDATE_FREQUENCY, true );
            return true;
        }
        return false;
    }

    function onKeyReleased(event) {
        var key = event.getKey();
        if (key == Ui.KEY_UP || key == Ui.KEY_MODE || key == Ui.KEY_DOWN || key == Ui.KEY_CLOCK) {
            longPressTimer.stop();
            longPressTimer = null;
            return true;
        }
        return false;
    }

    function onSelect() {
        if (picker.input_chars.substring(picker.charIdx,picker.charIdx+1).equals("*")) {
            // don't let the user select OK if there aren't enough characters...
            if (picker.inputStr.length() < picker.mMinChars) {
                return true;
            }
            // *** TODO ***
            // The developer (you) must do something here, both in terms of the program
            // flow (ie. pop and/ or push a new view) and in terms of the text entered
            // sabeard note - Developer actions needs to go before setting the picker to null
            
            // we're selecting 'OK' so set the picker to null (to eliminate potential circ ref)
            picker = null;
            Ui.popView(Ui.SLIDE_RIGHT);

        } else if (picker.input_chars.substring(picker.charIdx,picker.charIdx+1).equals("!")) {  
        	// set input letters used to caps and rebuild the list to default on first character
        	picker.togCaseIdx = 0;
        	picker.input_chars = picker.INPUT_LETTERS[picker.togCaseIdx]+picker.INPUT_TOG_CONTROLS[picker.togCaseIdx]+picker.INPUT_CONTROLS;
			picker.charIdx = 0;
            Ui.requestUpdate();
        } else if (picker.input_chars.substring(picker.charIdx,picker.charIdx+1).equals("@")) {  
        	// set input letters used to lower case and rebuild the list to default on first character
        	picker.togCaseIdx = 1;
        	picker.input_chars = picker.INPUT_LETTERS[picker.togCaseIdx]+picker.INPUT_TOG_CONTROLS[picker.togCaseIdx]+picker.INPUT_CONTROLS;
			picker.charIdx = 0;
            Ui.requestUpdate();
        } else if (picker.input_chars.substring(picker.charIdx,picker.charIdx+1).equals("#")) {  
        	// set input to numbers and rebuild the list to default on first character
        	picker.togCaseIdx = 2;
        	picker.input_chars = picker.INPUT_LETTERS[picker.togCaseIdx]+picker.INPUT_TOG_CONTROLS[picker.togCaseIdx]+picker.INPUT_CONTROLS;
			picker.charIdx = 0;
            Ui.requestUpdate();
        } else {
            picker.charSelected();
            Ui.requestUpdate();
        }
        return true;
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_RIGHT);
        picker = null;
        return true;
    }

    function onNextPage() {
        picker.setCharIdx((picker.charIdx+1) % picker.input_chars.length());
        Ui.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        picker.setCharIdx((picker.charIdx-1) % picker.input_chars.length());
        Ui.requestUpdate();
        return true;
    }

}
