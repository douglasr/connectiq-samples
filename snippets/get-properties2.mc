/*
MIT License

Copyright (c) 2016 Travis Vitek

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
*/

//
// This code was posted in the Garmin forums here:
// https://forums.garmin.com/showthread.php?341338-Simpler-method-to-check-for-GCM-Garmin-Express-Idiosyncracies
//

    // string is a special case if we want to disallow empty string
    function getStringProperty(key, dflt) {
        assert(dflt instanceof Lang.String);

        var val = App.getApp().getProperty(key);
        if (val != null && val instanceof Lang.String && !"".equals(val)) {
            return val;
        }

        return dflt;
    }

    function getBooleanProperty(key, dflt) {
        return getTypedProperty(key, dflt, Lang.Boolean);
    }

    function getNumberProperty(key, dflt) {
        return getTypedProperty(key, dflt, Lang.Number);
    }

    function getFloatProperty(key, dflt) {
        return getFloatProperty(key, dflt, Lang.Float);
    }

    function getDoubleProperty(key, dflt) {
        return getTypedProperty(key, dflt, Lang.Double);
    }

    hidden function getTypedProperty(key, dflt, type) {
        assert(dflt instanceof type);

        var val = App.getApp().getProperty(key);
        if (val != null && val instanceof type) {
            return val;
        }

        return dflt;
    }
