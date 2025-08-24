// timeCalculations.js - Astronomical calculations for twilight times
// .pragma library

function degToRad(degrees) {
  return (degrees * Math.PI) / 180;
}

function radToDeg(radians) {
  return (radians * 180) / Math.PI;
}

/**
 * Calculates today's sunrise and sunset hours in local time for the given latitude, longitude.
 * Based on the formulas found in:
 *   https://en.wikipedia.org/wiki/Julian_day#Converting_Julian_or_Gregorian_calendar_date_to_Julian_Day_Number
 *   https://en.wikipedia.org/wiki/Sunrise_equation#Complete_calculation_on_Earth
 *
 * @param {Float} lat Latitude of location (South is negative)
 * @param {Float} lng Longitude of location (West is negative)
 * @param {Float} zenith Solar elevation angle (0.833 for sunrise/sunset, 6 for civil twilight, etc.)
 * @param {Date} date Optional date (defaults to today)
 * @return {Object} Returns an object with sunrise and sunset times as floats on 24-hour time.
 *                    e.g. 6.5 is 6:30am, 23.2 is 11:12pm, 0.3 is 12:18am
 *                 Returns null if the sun never rises or sets at this location.
 */
function calculateSunTimes(lat, lng, zenith, date) {
  var d = date || new Date();
  var radians = Math.PI / 180.0;
  var degrees = 180.0 / Math.PI;

  var a = Math.floor((14 - (d.getMonth() + 1.0)) / 12);
  var y = d.getFullYear() + 4800 - a;
  var m = d.getMonth() + 1 + 12 * a - 3;
  var j_day =
    d.getDate() +
    Math.floor((153 * m + 2) / 5) +
    365 * y +
    Math.floor(y / 4) -
    Math.floor(y / 100) +
    Math.floor(y / 400) -
    32045;
  var n_star = j_day - 2451545.0009 - lng / 360.0;
  var n = Math.floor(n_star + 0.5);
  var solar_noon = 2451545.0009 - lng / 360.0 + n;
  var M = 356.047 + 0.9856002585 * n;
  var C =
    1.9148 * Math.sin(M * radians) +
    0.02 * Math.sin(2 * M * radians) +
    0.0003 * Math.sin(3 * M * radians);
  var L = (M + 102.9372 + C + 180) % 360;
  var j_transit =
    solar_noon +
    0.0053 * Math.sin(M * radians) -
    0.0069 * Math.sin(2 * L * radians);
  var D =
    Math.asin(Math.sin(L * radians) * Math.sin(23.45 * radians)) * degrees;

  // Use the provided zenith angle
  var cos_omega =
    (Math.sin(-zenith * radians) -
      Math.sin(lat * radians) * Math.sin(D * radians)) /
    (Math.cos(lat * radians) * Math.cos(D * radians));

  // sun never rises or sets
  if (cos_omega > 1 || cos_omega < -1) return null;

  // get Julian dates of sunrise/sunset
  var omega = Math.acos(cos_omega) * degrees;
  var j_set = j_transit + omega / 360.0;
  var j_rise = j_transit - omega / 360.0;

  /*
   * get sunrise and sunset times in UTC
   * Check section "Finding Julian date given Julian day number and time of
   *  day" on wikipedia for where the extra "+ 12" comes from.
   */
  var utc_time_set = 24 * (j_set - j_day) + 12;
  var utc_time_rise = 24 * (j_rise - j_day) + 12;
  var tz_offset = (-1 * d.getTimezoneOffset()) / 60; // Use system timezone
  var local_rise = (utc_time_rise + tz_offset) % 24;
  var local_set = (utc_time_set + tz_offset) % 24;

  // Ensure times are positive
  if (local_rise < 0) local_rise += 24;
  if (local_set < 0) local_set += 24;

  return {
    sunrise: local_rise,
    sunset: local_set,
  };
}

function getTwilightTimes(date, latitude, longitude) {
  // Calculate different twilight times using different zenith angles
  const sunrise = calculateSunTimes(latitude, longitude, 0.833, date); // Standard sunrise/sunset
  const civilTwilight = calculateSunTimes(latitude, longitude, 6, date); // Civil twilight (6° below horizon)
  const nauticalTwilight = calculateSunTimes(latitude, longitude, 12, date); // Nautical twilight (12° below horizon)
  const astronomicalTwilight = calculateSunTimes(latitude, longitude, 18, date); // Astronomical twilight (18° below horizon)

  if (
    !sunrise ||
    !civilTwilight ||
    !nauticalTwilight ||
    !astronomicalTwilight
  ) {
    return null; // Polar day or night
  }

  return {
    astronomicalTwilightSunrise: astronomicalTwilight.sunrise,
    nauticalTwilightSunrise: nauticalTwilight.sunrise,
    civilTwilightSunrise: civilTwilight.sunrise,
    sunrise: sunrise.sunrise,
    sunset: sunrise.sunset,
    civilTwilightSunset: civilTwilight.sunset,
    nauticalTwilightSunset: nauticalTwilight.sunset,
    astronomicalTwilightSunset: astronomicalTwilight.sunset,
  };
}

function timeToMinutes(timeDecimal) {
  const hours = Math.floor(timeDecimal);
  const minutes = (timeDecimal - hours) * 60;
  return hours * 60 + minutes;
}

function getCurrentTimeMinutes() {
  const now = new Date();
  return now.getHours() * 60 + now.getMinutes();
}

function inInterval(currentMinutes, startTime, endTime) {
  const start = timeToMinutes(startTime);
  const end = timeToMinutes(endTime);

  if (start <= end) {
    return currentMinutes >= start && currentMinutes < end;
  } else {
    return currentMinutes >= start || currentMinutes < end;
  }
}

// --- Custom timing helpers ---
function parseTimeString(timeStr) {
  const parts = (timeStr || "00:00").split(":");
  const h = Math.max(0, Math.min(23, parseInt(parts[0] || 0)));
  const m = Math.max(0, Math.min(59, parseInt(parts[1] || 0)));
  return h + m / 60;
}

function getWallpaperForCustomTime(customTimes, imagePaths) {
  const currentMinutes = getCurrentTimeMinutes();

  const dawn = timeToMinutes(parseTimeString(customTimes.dawn));
  const early = timeToMinutes(parseTimeString(customTimes.earlyMorning));
  const day = timeToMinutes(parseTimeString(customTimes.day));
  const eve = timeToMinutes(parseTimeString(customTimes.evening));
  const dusk = timeToMinutes(parseTimeString(customTimes.dusk));
  const night = timeToMinutes(parseTimeString(customTimes.night));

  if (currentMinutes >= dawn && currentMinutes < early) return imagePaths.dawn;
  if (currentMinutes >= early && currentMinutes < day)
    return imagePaths.earlyMorning;
  if (currentMinutes >= day && currentMinutes < eve) return imagePaths.day;
  if (currentMinutes >= eve && currentMinutes < dusk) return imagePaths.evening;
  if (currentMinutes >= dusk && currentMinutes < night) return imagePaths.dusk;
  return imagePaths.night;
}

function getNextUpdateTimeCustom(customTimes) {
  const currentMinutes = getCurrentTimeMinutes();
  const points = [
    timeToMinutes(parseTimeString(customTimes.dawn)),
    timeToMinutes(parseTimeString(customTimes.earlyMorning)),
    timeToMinutes(parseTimeString(customTimes.day)),
    timeToMinutes(parseTimeString(customTimes.evening)),
    timeToMinutes(parseTimeString(customTimes.dusk)),
    timeToMinutes(parseTimeString(customTimes.night)),
    24 * 60 + timeToMinutes(parseTimeString(customTimes.dawn)),
  ];

  for (let i = 0; i < points.length; i++) {
    if (points[i] > currentMinutes) {
      return (points[i] - currentMinutes) * 60 * 1000;
    }
  }
  return 60 * 60 * 1000;
}

function getWallpaperForTime(latitude, longitude, imagePaths) {
  const now = new Date();
  const times = getTwilightTimes(now, latitude, longitude);

  if (!times) {
    return imagePaths.day;
  }

  const minutes = getCurrentTimeMinutes();
  const deepNight = 2 * 60; // 2 AM in minutes

  if (
    inInterval(
      minutes,
      times.astronomicalTwilightSunrise,
      times.civilTwilightSunrise
    )
  ) {
    return imagePaths.dawn;
  } else if (inInterval(minutes, times.civilTwilightSunrise, times.sunset)) {
    if (inInterval(minutes, times.civilTwilightSunrise, times.sunrise + 2)) {
      return imagePaths.earlyMorning;
    } else {
      return imagePaths.day;
    }
  } else if (
    inInterval(
      minutes,
      times.civilTwilightSunset,
      times.astronomicalTwilightSunset
    )
  ) {
    if (inInterval(minutes, times.sunset - 1, times.civilTwilightSunset)) {
      return imagePaths.evening;
    } else {
      return imagePaths.dusk;
    }
  } else if (inInterval(minutes, times.astronomicalTwilightSunset, deepNight)) {
    return imagePaths.dusk;
  } else {
    return imagePaths.night;
  }
}

function getNextUpdateTime(latitude, longitude) {
  const now = new Date();
  const times = getTwilightTimes(now, latitude, longitude);

  if (!times) {
    return 60 * 60 * 1000; // 1 hour if calculations fail
  }

  const currentMinutes = getCurrentTimeMinutes();
  const timePoints = [
    times.astronomicalTwilightSunrise,
    times.civilTwilightSunrise,
    times.sunrise + 2,
    times.sunset - 1,
    times.civilTwilightSunset,
    times.astronomicalTwilightSunset,
    2, // 2 AM next day
    24 + times.astronomicalTwilightSunrise, // Next day astronomical twilight
  ];

  for (let i = 0; i < timePoints.length; i++) {
    const pointMinutes = timeToMinutes(timePoints[i]);
    if (pointMinutes > currentMinutes) {
      return (pointMinutes - currentMinutes) * 60 * 1000; // Convert to milliseconds
    }
  }

  return 60 * 60 * 1000; // Default to 1 hour
}

// Legacy function aliases for compatibility
function calculateSunriseSet(date, latitude, longitude, zenith) {
  return calculateSunTimes(latitude, longitude, zenith, date);
}
