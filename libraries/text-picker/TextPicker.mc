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
import Toybox.Lang;

class TextPickerView extends Ui.View {

    // this is here for completeness but is likely calculated elsewhere in an app
    static const DEVICE_WIDTH = System.getDeviceSettings().screenHeight as Number;
    static const DEVICE_HEIGHT = System.getDeviceSettings().screenWidth as Number;

    static const INPUT_LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";  // valid characters for input
    static const INPUT_CONTROLS = "<*";   // control characters for input
    static const INPUT_OK = "OK";         // what to render in place of the '*' (accept) character
    static const INPUT_BACK = "<<";       // what to render in place of the '<' (delete) character

    // these will likely need to be changed based on device
    static const PICKER_TITLE_POS = [95,30] as Array<Number>;              // title position
    static const PICKER_SUBTITLE_POS = [10,80] as Array<Number>;           // subtitle/info position
    static const PICKER_INPUT_POS = [10,DEVICE_HEIGHT/2] as Array<Number>; // input display position
    static const PICKER_X = 174;                                           // X coordinate of left side of picker
    static const PICKER_WIDTH = 32;                                        // width of the picker (from left bar to right bar)

    // fonts to use for various text; will likely change based on device
    static const FONT_PICKER_TITLE = Gfx.FONT_SMALL;
    static const FONT_PICKER_SUBTITLE = Gfx.FONT_TINY;
    static const FONT_PICKER_VALUE = Gfx.FONT_MEDIUM;
    static const FONT_PICKER_LETTER_NOT_SELECTED = Gfx.FONT_XTINY;
    static const FONT_PICKER_LETTER_SELECTED = Gfx.FONT_TINY;

    var mTitle as String;
    var mSubTitle as String;
    var mMinChars as Number;
    var mMaxChars as Number;
    var inputStr as String = "";
    var input_chars as String;
    var charIdx as Number = 0;

    function initialize(title as String, subTitle as String, minChars as Number, maxChars as Number, prefix as String or Number or Null) {
        mTitle = title;
        mSubTitle = subTitle;
        mMinChars = minChars;
        mMaxChars = maxChars;
        if (prefix != null) {
            inputStr = prefix.toString();   // ensure default value passed is a string.
        }
        input_chars = INPUT_LETTERS+INPUT_CONTROLS;
        View.initialize();
    }

    function onUpdate(dc as Gfx.Dc) as Void {
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

        var pickerFontHeight = dc.getTextDimensions(input_chars.substring(0,1) as String, FONT_PICKER_LETTER_SELECTED)[1];

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
            if ("<".equals(input_chars.substring(sidx,sidx+1))) {
                ch = INPUT_BACK;
            } else if ("*".equals(input_chars.substring(sidx,sidx+1))) {
                ch = INPUT_OK;
                // grey out the 'OK' if there aren't enough characters
                if (inputStr.length() < mMinChars) {
                    dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
                }
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


    function setCharIdx(idx as Number) as Void {
        charIdx = idx;
        if (charIdx < 0) {
            charIdx = charIdx + input_chars.length();
        }
    }

    function charSelected() as Void {
        // are we adding something from the list of valid letters?
        if (input_chars.length() >= INPUT_LETTERS.length() && charIdx < INPUT_LETTERS.length()) {
            inputStr = inputStr + input_chars.substring(charIdx,charIdx+1);
        } else if ("<".equals(input_chars.substring(charIdx,charIdx+1))) {
            inputStr = inputStr.substring(0,inputStr.length()-1) as String;
            // if we aren't at the maximum number of characters, then set the input characters to all
            //   and set the highlighted character to the back/delete char
            if (inputStr.length() < mMaxChars) {
                input_chars = INPUT_LETTERS+INPUT_CONTROLS;
                charIdx = INPUT_LETTERS.length(); // the character after the letters is the back/delete char
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


class TextPickerDelegate extends Ui.BehaviorDelegate {
    // millisec between updates when long pressing up/down on picker
    static const LONG_PRESS_UPDATE_FREQUENCY = 250;

    var picker as TextPickerView?;
    var longPressTimer as Timer.Timer?;

    function initialize(the_picker as TextPickerView) {
        picker = the_picker;
        BehaviorDelegate.initialize();
    }

    function onKey(event as Ui.KeyEvent) as Boolean {
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
    function onKeyPressed(event as Ui.KeyEvent) as Boolean {
        var key = event.getKey();
        if (key == Ui.KEY_UP || key == Ui.KEY_MODE) {
            longPressTimer = new Timer.Timer();
            longPressTimer.start( method(:onPreviousPage) as Method() as Void, LONG_PRESS_UPDATE_FREQUENCY, true );
            return true;
        } else if (key == Ui.KEY_DOWN || key == Ui.KEY_CLOCK) {
            longPressTimer = new Timer.Timer();
            longPressTimer.start( method(:onNextPage) as Method() as Void, LONG_PRESS_UPDATE_FREQUENCY, true );
            return true;
        }
        return false;
    }

    function onKeyReleased(event as Ui.KeyEvent) as Boolean {
        var key = event.getKey();
        if ((key == Ui.KEY_UP || key == Ui.KEY_MODE || key == Ui.KEY_DOWN || key == Ui.KEY_CLOCK) && longPressTimer != null) {
            longPressTimer.stop();
            longPressTimer = null;
            return true;
        }
        return false;
    }

    function onSelect() as Boolean {
        if (picker != null) {
            if ("*".equals(picker.input_chars.substring(picker.charIdx,picker.charIdx+1))) {
                // don't let the user select OK if there aren't enough characters...
                if ((picker as TextPickerView).inputStr.length() < (picker as TextPickerView).mMinChars) {
                    return true;
                }

                // we're selecting 'OK' so set the picker to null (to eliminate potential circ ref)
                picker = null;

                // *** TODO ***
                // The developer (you) must do something here, both in terms of the program
                // flow (ie. pop and/ or push a new view) and in terms of the text entered
                Ui.popView(Ui.SLIDE_RIGHT);

            } else {
                picker.charSelected();
                Ui.requestUpdate();
            }
        }
        return true;
    }

    function onBack() as Boolean {
        Ui.popView(Ui.SLIDE_RIGHT);
        picker = null;
        return true;
    }

    function onNextPage() as Boolean {
        if (picker != null) {
            picker.setCharIdx((picker.charIdx+1) % picker.input_chars.length());
            Ui.requestUpdate();
        }
        return true;
    }

    function onPreviousPage() as Boolean {
        if (picker != null) {
            picker.setCharIdx((picker.charIdx-1) % picker.input_chars.length());
            Ui.requestUpdate();
        }
        return true;
    }

}
