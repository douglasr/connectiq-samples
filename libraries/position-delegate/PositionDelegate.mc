/*
MIT License

Copyright (c) 2017 Travis Vitek

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

using Toybox.Position;

class PositionDelegate
{
    hidden var quality;
    hidden var when;
    hidden var callback;

    function initialize() {
    }

    function enableLocationEvents(min_quality, min_moment, callback) {
        self.quality = min_quality;
        self.when = min_moment;
        self.callback = callback;

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, self.method(:onPosition));
    }

    function onPosition(info) {
        if (info.quality >= self.quality) {
            if (self.when == null || !info.when.lessThan(self.when)) {
                Position.enableLocationEvents(Position.LOCATION_DISABLE, null);

                self.callback.invoke(info);
            }
        }
    }
}
