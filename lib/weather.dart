// Current weather of one city
class Weather {
  final String city;
  final double temp;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String icon;

  Weather({
    required this.city,
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  // Create a Weather object from the api json
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      temp: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }

  // Get the image url of the weather icon
  String getIconUrl() {
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}

// Forecast = Weather + the time it is predicted for
class Forecast extends Weather {
  final DateTime time;

  Forecast({
    required super.city,
    required super.temp,
    required super.condition,
    required super.humidity,
    required super.windSpeed,
    required super.icon,
    required this.time,
  });

  // Create a Forecast from one item of the forecast list
 
  factory Forecast.fromJson(Map<String, dynamic> json, String city) {
    return Forecast(
      city: city,
      temp: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      icon: json['weather'][0]['icon'],
      time: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
    );
  }

  // Get the time as text, for example "Fri 18:00"
  String getTimeText() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final day = days[time.weekday - 1];
    final hour = time.hour.toString().padLeft(2, '0');
    return '$day $hour:00';
  }
}
