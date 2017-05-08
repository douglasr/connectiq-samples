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
*/


    // Approximation of the Earth's radius in kilometres.
    // See Wikipedia for more details: https://en.wikipedia.org/wiki/Earth_radius
    EARTH_RADIUS_KM = 6371;

    // Returns the distance (in kilometres) between two points using
    // equirectangular approximation.
    // Requires SDK 1.3.0 or greater, when the toRadians() method was added to
    //   the Math module. If deploying to SDK 1.2.x then change the use of
    //   Math.toRadians() method to the degreesToRadians() method below.
    // NOTE: This is a close approximation that utilizes cosine to account for
    //   the fact that lines of longitude converge as they approach the poles.
    //   The calculation is simple and fast (from a computational perspective)
    //   but is only an accurate aspproximation over short distances; location,
    //   distance and bearing of the two points will affect the result.
    function distanceEquiretangularApproximation(lat1, lon1, lat2, lon2) {
        var deg_lon = Math.toRadians(lon2-lon1) * Math.cos(Math.toRadians((lat1+lat2)/2));
        var deg_lat = Math.toRadians(lat2-lat1);
        return Math.sqrt((deg_lon^2)+(deg_lat^2))*EARTH_RADIUS_KM;
    }

    function degreesToRadians(deg) {
        return (deg * Math.PI / 180);
    }
