import 'package:flutter/material.dart';
import 'package:wemapgl/wemapgl.dart';
import 'language_vi.dart';

String key = 'key=${Configuration.weMapKey}';

///Color code of WEMAP
Color primaryColor = Color.fromRGBO(0, 113, 188, 1);

///Direction
Uri apiDirection(String from, String to, String type) => Uri.parse(
    "https://apis.wemap.asia/route-api/route?point=$from&point=$to&type=json&locale=vi&vehicle=$type&weighting=fastest&points_encoded=false&elevation=false&$key");

///Voice
Uri apiVoice(String string) =>
    Uri.parse("https://vmap.vn/voice?address=$string");

///Search SDK
Uri apiSearch(String input, LatLng latLng, WeMapGeocoder geocoder) {
  Configuration.validateWeMapKey();
  switch (geocoder) {
    case WeMapGeocoder.Nominatim:
      return Uri.parse(
          "https://apis.wemap.asia/geocode-2/search.php?q=$input&lat=${latLng.latitude}&lon=${latLng.longitude}&location_bias_scale=2&polygon_geojson=1&format=geojson&$key");
      break;
    case WeMapGeocoder.Photon:
      return Uri.parse(
          'https://apis.wemap.asia/geocode-3/api?q=$input&lat=${latLng.latitude}&lon=${latLng.longitude}&location_bias_scale=2&$key');
      break;
    default:
      return Uri.parse(
          'https://apis.wemap.asia/geocode-1/autocomplete?text=$input&focus.point.lat=${latLng.latitude}&focus.point.lon=${latLng.longitude}&location_bias_scale=2&$key');
      break;
  }
}

///Reverse
Uri apiReverse(LatLng latLng) {
  Configuration.validateWeMapKey();
  return Uri.parse(
      "https://apis.wemap.asia/geocode-1/reverse?point.lat=${latLng.latitude}&point.lon=${latLng.longitude}&$key");
}

///Locality
Uri apiLocality(LatLng latLng) => Uri.parse(
    "https://apis.wemap.asia/geocode-1/reverse?point.lat=${latLng.latitude}&point.lon=${latLng.longitude}&$key&layers=locality");

///Lookup SDK
Uri apiLookup(int osmID) {
  Configuration.validateWeMapKey();
  return Uri.parse("https://apis.wemap.asia/we-tools/lookup?id=W$osmID&$key");
}

///Weather
Uri apiWeather(LatLng latLng) {
  Configuration.validateOpenWeatherKey();
  return Uri.parse(
      'http://openweathermap.org/data/2.5/weather?lat=${latLng.latitude}&lon=${latLng.longitude}&appid=${Configuration.openWeatherKey}&units=metric');
}

Uri apiWeatherForecast(int cityId) {
  Configuration.validateOpenWeatherKey();
  return Uri.parse(
      'https://openweathermap.org/data/2.5/forecast/hourly?appid=b6907d289e10d714a6e88b30761fae22&id=$cityId&units=metric');
}

///Explore
Uri apiExplore(String type, LatLng latLng) {
  Configuration.validateWeMapKey();
  String url;
  String baseUrl =
      'https://apis.wemap.asia/we-tools/explore?lat=${latLng.latitude}&lon=${latLng.longitude}&$key';
  switch (type) {
    case 'cafe':
      url = '$baseUrl&k=amenity&v=cafe&limit=20&d=1000';
      break;
    case 'fuel':
      url = '$baseUrl&k=amenity&v=fuel&limit=20&d=1000';
      break;
    case 'restaurant':
      url = '$baseUrl&k=amenity&v=restaurant&limit=20&d=1000';
      break;
    case 'bar':
      url = '$baseUrl&k=amenity&v=nightclub&limit=20&d=10000';
      break;
    case 'pharmacy':
      url = '$baseUrl&k=amenity&v=pharmacy&limit=20&d=1000';
      break;
    case 'school':
      url = '$baseUrl&k=amenity&v=school&limit=20&d=1000';
      break;
    case 'hotel':
      url = '$baseUrl&k=tourism&v=hotel&limit=20&d=1000';
      break;
    case 'library':
      url = '$baseUrl&k=amenity&v=library&limit=20&d=1000';
      break;
    default:
      url =
          'https://apis.wemap.asia/we-tools/explore?$key&lat=21.0381165&lon=105.7820646&k=amenity&v=cafe&limit=20&d=1000';
      break;
  }
  return Uri.parse(url);
}

///AQI
Uri apiAQI() {
  Configuration.validateWeMapKey();
  return Uri.parse(
      'http://api2.fairnet.vn/kit/byNetwork?networkId=5c99d82895a37642f6df6553');
}

Uri apiKitAQI(int kitID) {
  Configuration.validateWeMapKey();
  return Uri.parse('http://api2.fairnet.vn/kit/$kitID');
}

Uri apiAnalysisByHourKit() {
  Configuration.validateWeMapKey();
  return Uri.parse('http://api2.fairnet.vn/data/analysisbyhour');
}

Uri apiAnalysisByHourAQI(String kidID, String startTime, String finishTime) {
  Configuration.validateWeMapKey();
  return Uri.parse(
      'http://api2.fairnet.vn/data/AQI?KitID=$kidID&startTime=$startTime&finishTime=$finishTime');
}

Color aqiColor(int aqi) {
  if (aqi >= -1 && aqi <= 50)
    return Color(0xff73e503);
  else if (aqi <= 100)
    return Color(0xfffefa02);
  else if (aqi <= 150)
    return Color(0xffed7d05);
  else if (aqi <= 200)
    return Color(0xffe82910);
  else if (aqi <= 300) return Color(0xff8f3f97);
  return Color(0xff7e1323);
}

String aqiRate(int aqi) {
  if (aqi >= -1 && aqi <= 50)
    return wemap_aqiGood;
  else if (aqi <= 100)
    return wemap_aqiMorderate;
  else if (aqi <= 150)
    return wemap_aqiUnhealthySensitive;
  else if (aqi <= 200)
    return wemap_aqiUnhealthy;
  else if (aqi <= 300) return wemap_aqiVeryUnhealthy;
  return wemap_aqiHazardous;
}
