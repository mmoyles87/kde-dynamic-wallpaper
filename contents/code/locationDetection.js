// locationDetection.js - Location detection utilities
// .pragma library

// Check if geolocation is available
function isGeolocationAvailable() {
  // We can always attempt automatic location detection
  // Priority: IP-based → GeoClue2 → Timezone estimation
  return true;
}

// Get location using IP-based geolocation service
function getLocationFromIP(callback) {
  console.log("Attempting IP-based geolocation...");

  // Use a reliable, free IP geolocation service
  const ipApiUrl =
    "http://ip-api.com/json/?fields=status,message,lat,lon,city,country,timezone";

  const xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function () {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      try {
        if (xhr.status === 200) {
          const response = JSON.parse(xhr.responseText);

          if (
            response.status === "success" &&
            response.lat !== undefined &&
            response.lon !== undefined
          ) {
            const location = {
              lat: parseFloat(response.lat),
              lon: parseFloat(response.lon),
              source: "IP geolocation",
              city: response.city || "Unknown",
              country: response.country || "Unknown",
              timezone: response.timezone || "Unknown",
            };

            console.log(
              "IP geolocation successful:",
              location.city + ", " + location.country,
              "(" + location.lat + ", " + location.lon + ")"
            );

            if (callback) callback(location);
            return;
          } else {
            console.log(
              "IP geolocation failed:",
              response.message || "Unknown error"
            );
          }
        } else {
          console.log("IP geolocation request failed with status:", xhr.status);
        }
      } catch (e) {
        console.log("Error parsing IP geolocation response:", e.toString());
      }

      // If IP geolocation fails, callback with null
      if (callback) callback(null);
    }
  };

  xhr.open("GET", ipApiUrl, true);
  xhr.send();
}

// Check if GeoClue2 is available
function isGeoClue2Available() {
  try {
    // Try to check if GeoClue2 service is available
    // This is a simplified check - in a real implementation you'd use D-Bus
    const process = Qt.createQmlObject(
      "import QtQuick 2.0; import Qt.labs.platform 1.1; StandardPaths {}",
      Qt.application,
      "geoclue-check"
    );

    // For now, we'll assume it might be available but implement it as a secondary option
    // This would need proper D-Bus integration in a real implementation
    return false; // Disable for now until we implement D-Bus calls
  } catch (e) {
    return false;
  }
}

// Get location from GeoClue2 (placeholder for D-Bus implementation)
function getLocationFromGeoClue2(callback) {
  console.log("Attempting GeoClue2 geolocation...");

  // This would require D-Bus integration which is complex in QML
  // For now, we'll implement this as a placeholder that fails gracefully
  // In a full implementation, this would:
  // 1. Connect to org.freedesktop.GeoClue2 service
  // 2. Create a client
  // 3. Request location
  // 4. Parse the response

  console.log("GeoClue2 not implemented yet - requires D-Bus integration");
  if (callback) callback(null);
}

// Get location from system services with multiple fallbacks
function requestAutomaticLocation(callback) {
  console.log("Starting automatic location detection...");

  // Try IP-based geolocation first (most reliable and widely available)
  getLocationFromIP(function (ipLocation) {
    if (ipLocation && isValidCoordinate(ipLocation.lat, ipLocation.lon)) {
      console.log("Using IP-based location:", ipLocation.source);
      if (callback) callback(ipLocation);
      return;
    }

    console.log("IP-based geolocation failed, trying GeoClue2...");

    // Try GeoClue2 as secondary option
    if (isGeoClue2Available()) {
      getLocationFromGeoClue2(function (geoclueLocation) {
        if (
          geoclueLocation &&
          isValidCoordinate(geoclueLocation.lat, geoclueLocation.lon)
        ) {
          console.log(
            "Using GeoClue2 location:",
            geoclueLocation.source || "GeoClue2"
          );
          if (callback) callback(geoclueLocation);
          return;
        }

        console.log("GeoClue2 failed, falling back to timezone estimation...");

        // Fall back to timezone-based estimation
        const timezoneLocation = getLocationFromTimezone();
        if (
          timezoneLocation &&
          isValidCoordinate(timezoneLocation.lat, timezoneLocation.lon)
        ) {
          timezoneLocation.source = "Timezone estimation";
          console.log("Using timezone-based location estimation");
          if (callback) callback(timezoneLocation);
        } else {
          console.log("All location detection methods failed");
          if (callback) callback(null);
        }
      });
    } else {
      console.log(
        "GeoClue2 not available, falling back to timezone estimation..."
      );

      // Fall back to timezone-based estimation
      const timezoneLocation = getLocationFromTimezone();
      if (
        timezoneLocation &&
        isValidCoordinate(timezoneLocation.lat, timezoneLocation.lon)
      ) {
        timezoneLocation.source = "Timezone estimation";
        console.log("Using timezone-based location estimation");
        if (callback) callback(timezoneLocation);
      } else {
        console.log("All location detection methods failed");
        if (callback) callback(null);
      }
    }
  });
}

// Estimate location from timezone (rough approximation)
function getLocationFromTimezone() {
  // Since Intl is not available in QML, we'll use Date object timezone offset
  // This is less precise but still gives us a rough location estimate
  const now = new Date();
  const timezoneOffset = now.getTimezoneOffset(); // minutes from UTC

  console.log("Timezone offset (minutes from UTC):", timezoneOffset);
  console.log(
    "Detected timezone: UTC" +
      (timezoneOffset > 0 ? "-" : "+") +
      Math.abs(timezoneOffset / 60)
  );

  // Map timezone offsets to approximate coordinates
  // Negative offset means ahead of UTC (east), positive means behind UTC (west)
  const offsetMap = {
    // UTC-12 to UTC-8 (Pacific)
    720: { lat: 21.3099, lon: -157.8581, name: "Hawaii (UTC-10)" },
    660: { lat: 61.2181, lon: -149.9003, name: "Alaska (UTC-9)" },
    600: { lat: 47.6062, lon: -122.3321, name: "Seattle (UTC-8)" },
    540: {
      lat: 47.6062,
      lon: -122.3321,
      name: "Pacific Standard Time (UTC-8)",
    },

    // UTC-7 to UTC-5 (North America)
    480: { lat: 39.7392, lon: -104.9903, name: "Denver (UTC-7)" },
    420: {
      lat: 39.7392,
      lon: -104.9903,
      name: "Mountain Standard Time (UTC-7)",
    },
    360: { lat: 41.8781, lon: -87.6298, name: "Chicago (UTC-6)" },
    300: { lat: 41.8781, lon: -87.6298, name: "Central Standard Time (UTC-6)" },
    240: { lat: 40.7128, lon: -74.006, name: "New York (UTC-5)" },
    180: { lat: 40.7128, lon: -74.006, name: "Eastern Standard Time (UTC-5)" },

    // UTC-4 to UTC-1 (Atlantic/South America)
    120: { lat: 10.4806, lon: -66.9036, name: "Caracas (UTC-4)" },
    60: { lat: 28.2916, lon: -16.6291, name: "Azores (UTC-1)" },

    // UTC+0 to UTC+3 (Europe/Africa)
    0: { lat: 51.5074, lon: -0.1278, name: "London (UTC+0)" },
    "-60": { lat: 48.8566, lon: 2.3522, name: "Paris (UTC+1)" },
    "-120": { lat: 52.52, lon: 13.405, name: "Berlin (UTC+2)" },
    "-180": { lat: 41.9028, lon: 12.4964, name: "Rome (UTC+3)" },

    // UTC+4 to UTC+7 (Middle East/Central Asia)
    "-240": { lat: 25.2048, lon: 55.2708, name: "Dubai (UTC+4)" },
    "-300": { lat: 41.2995, lon: 69.2401, name: "Tashkent (UTC+5)" },
    "-360": { lat: 28.7041, lon: 77.1025, name: "Delhi (UTC+6)" },
    "-420": { lat: 13.7563, lon: 100.5018, name: "Bangkok (UTC+7)" },

    // UTC+8 to UTC+12 (East Asia/Pacific)
    "-480": { lat: 31.2304, lon: 121.4737, name: "Shanghai (UTC+8)" },
    "-540": { lat: 35.6762, lon: 139.6503, name: "Tokyo (UTC+9)" },
    "-600": { lat: -33.8688, lon: 151.2093, name: "Sydney (UTC+10)" },
    "-660": { lat: -36.8485, lon: 174.7633, name: "Auckland (UTC+11)" },
    "-720": { lat: -18.1416, lon: 178.4419, name: "Fiji (UTC+12)" },
  };

  // Find the closest timezone offset match
  let closestOffset = "0";
  let minDifference = Math.abs(timezoneOffset - 0);

  for (const offset in offsetMap) {
    const difference = Math.abs(timezoneOffset - parseInt(offset));
    if (difference < minDifference) {
      minDifference = difference;
      closestOffset = offset;
    }
  }

  if (offsetMap[closestOffset]) {
    const location = offsetMap[closestOffset];
    console.log(
      "Found location for timezone offset",
      closestOffset,
      ":",
      location.name,
      location.lat,
      location.lon
    );
    return { lat: location.lat, lon: location.lon };
  }

  // Ultimate fallback - use timezone offset to estimate region
  let estimatedLat = 0;
  let estimatedLon = 0;

  // Simple longitude estimation based on timezone offset
  // Each hour difference is roughly 15 degrees longitude
  estimatedLon = -(timezoneOffset / 60) * 15;

  // Clamp longitude to valid range
  if (estimatedLon > 180) estimatedLon = 180;
  if (estimatedLon < -180) estimatedLon = -180;

  // Default latitude to temperate zone (most populated areas)
  estimatedLat = 40;

  console.log(
    "Using estimated location based on timezone offset:",
    estimatedLat,
    estimatedLon
  );
  return { lat: estimatedLat, lon: estimatedLon };
}

// Validate coordinates
function isValidCoordinate(lat, lon) {
  return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
}

// Format coordinates for display
function formatCoordinates(lat, lon) {
  const latDir = lat >= 0 ? "N" : "S";
  const lonDir = lon >= 0 ? "E" : "W";
  return `${Math.abs(lat).toFixed(3)}°${latDir}, ${Math.abs(lon).toFixed(
    3
  )}°${lonDir}`;
}
