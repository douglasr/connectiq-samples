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

using Toybox.Graphics as Gfx;
using Toybox.System as System;

module ActivityIndicator {

    const DEVICE_HEIGHT = System.getDeviceSettings().screenHeight;
    const DEVICE_WIDTH = System.getDeviceSettings().screenWidth;

    const INDICATOR_COLOR = Toybox.Graphics.COLOR_LT_GRAY;

    // round and semi-round constants
    const INDICATOR_WIDTH = 5;
    const INDICATOR_ARC_SIZE = 16;
    const INDICATOR_ARC_MOVEMENT = 4;
    const INDICATOR_ARC_START = 102; // first arc will start at 98 (first pass will immediately subtract 4); end of arc will be at 82...

    // rectangle constants
    const INDICATOR_WIDTH_RECTANGLE = 150;
    const INDICATOR_HEIGHT_RECTANGLE = 5;
    const INDICATOR_POS_X = DEVICE_WIDTH/2;     // centered horizontally
    const INDICATOR_POS_Y = DEVICE_HEIGHT/2;    // centered vertically

    var pixelsDrawn = 0;
    var timerArcStart = INDICATOR_ARC_START;
    var screenShape = System.getDeviceSettings().screenShape;

    function drawActivityIndicator(dc) {
        switch ( screenShape ) {
            case System.SCREEN_SHAPE_ROUND:
                drawActivityIndicatorForRound(dc);
                break;

            case System.SCREEN_SHAPE_SEMI_ROUND:
                drawActivityIndicatorForSemiround(dc);
                break;

            case System.SCREEN_SHAPE_RECTANGLE:
            default:
                drawActivityIndicatorForRectangle(dc);
                break;
        }
    }

    function drawActivityIndicatorForRound(dc) {
        timerArcStart -= INDICATOR_ARC_MOVEMENT;
        var timerArcEnd = timerArcStart - INDICATOR_ARC_SIZE;
        if (timerArcStart < 0) { timerArcStart += 360; }
        if (timerArcEnd < 0) { timerArcEnd += 360; }
        dc.setPenWidth(INDICATOR_WIDTH);
        dc.setColor(INDICATOR_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(DEVICE_WIDTH/2, DEVICE_HEIGHT/2, DEVICE_HEIGHT/2-1, Gfx.ARC_CLOCKWISE, timerArcStart, timerArcEnd);
        dc.setPenWidth(1);
    }

    function drawActivityIndicatorForSemiround(dc) {
        var timerArcEnd = timerArcStart - INDICATOR_ARC_SIZE;
        dc.setPenWidth(INDICATOR_WIDTH);
        timerArcStart -= INDICATOR_ARC_MOVEMENT;
        timerArcEnd -= INDICATOR_ARC_MOVEMENT;
        if (timerArcStart < 0) { timerArcStart += 360; }
        if (timerArcEnd < 0) { timerArcEnd += 360; }
        dc.setColor(INDICATOR_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(DEVICE_WIDTH/2-2, 90, 106, Gfx.ARC_CLOCKWISE, timerArcStart, timerArcEnd);

        // handle the flat top/bottom
        var horLineSize;
        // FIXME -- this is currently hard-coded for 215x180 devices (eg. FR230/235)
        if (timerArcStart <= 136 && timerArcEnd >= 44) {
            horLineSize = ((136-timerArcStart)*1.6).toNumber();
            dc.drawLine(30+horLineSize,1,60+horLineSize,1);
        } else if (timerArcStart <= 315 && timerArcEnd >= 225) {
            horLineSize = ((315-timerArcStart)*1.6).toNumber();
            dc.drawLine(150-horLineSize,178,180-horLineSize,178);
        }
        dc.setPenWidth(1);
    }

    function drawActivityIndicatorForRectangle(dc) {
        pixelsDrawn += 5;
        if (pixelsDrawn > INDICATOR_WIDTH_RECTANGLE) {
            pixelsDrawn = pixelsDrawn - INDICATOR_WIDTH_RECTANGLE;
        }
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(INDICATOR_POS_X-INDICATOR_WIDTH_RECTANGLE/2-1, INDICATOR_POS_Y, INDICATOR_WIDTH_RECTANGLE+1, INDICATOR_HEIGHT_RECTANGLE+2);
        dc.setColor(INDICATOR_COLOR, Gfx.COLOR_TRANSPARENT);
        dc.drawRectangle(INDICATOR_POS_X-INDICATOR_WIDTH_RECTANGLE/2-1, INDICATOR_POS_Y, INDICATOR_WIDTH_RECTANGLE+1, INDICATOR_HEIGHT_RECTANGLE+2);
        dc.fillRectangle(INDICATOR_POS_X-INDICATOR_WIDTH_RECTANGLE/2, INDICATOR_POS_Y+1, pixelsDrawn, INDICATOR_HEIGHT_RECTANGLE);
    }

    function resetActivityIndicator() {
        timerArcStart = INDICATOR_ARC_START;
        pixelsDrawn = 0;
    }

}
