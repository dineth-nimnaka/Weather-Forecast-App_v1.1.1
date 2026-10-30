import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather.dart';

class WeatherService {
  //   OpenWeatherMap api key 
  final String apiKey = 'de26f06150de2366d776ce68620c81df';

  // Get the current weather of a city
  Future<Weather> getWeather(String cityName) async {
    final json = await fetchJson('weather', cityName);
    return Weather.fromJson(json);
  }

  // Get the next 24 hours forecast (8 items, 3 hours )
  Future<List<Forecast>> getForecast(String cityName) async {
    final json = await fetchJson('forecast', cityName);
    final String city = json['city']['name'];
    final List items = json['list'];
    return items.take(8).map((item) => Forecast.fromJson(item, city)).toList();
  }

  // Build the api url for  $type = "weather" or "forecast"
  Uri buildUrl(String type, String cityName) {
    return Uri.https('api.openweathermap.org', '/data/2.5/$type', {
      'q': cityName,
      'units': 'metric',
      'appid': apiKey,
    });
  }

  // Call the api and return the json data
  Future<Map<String, dynamic>> fetchJson(String type, String cityName) async {
    final response = await sendRequest(buildUrl(type, cityName));
    checkResponse(response);
    return jsonDecode(response.body);
  }

  // Send the request and give a clear error if there  no internet
  Future<http.Response> sendRequest(Uri url) async {
    try {
      return await http.get(url);
    } catch (e) {
      throw Exception('No internet connection');
    }
  }

  // Throw a clear error if the api did not return success
  void checkResponse(http.Response response) {
    if (response.statusCode == 404) {
      throw Exception('City not found');
    }
    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }
  }
}
