import 'package:flutter/material.dart';
import 'weather.dart';
import 'weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final cityController = TextEditingController();
  final weatherService = WeatherService();

  bool isLoading = false;
  String errorMessage = '';
  String lastCity = 'Colombo';
  Weather? currentWeather;
  List<Forecast> forecasts = [];

  @override
  void initState() {
    super.initState();
    loadWeatherForCity('Colombo'); // show a default city when the app opens
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  // 

  // Load weather + forecast for a city and update the screen
  Future<void> loadWeatherForCity(String cityName) async {
    cityName = cityName.trim();
    if (cityName.isEmpty) {
      showError('Please enter a city name');
      return;
    }

    lastCity = cityName;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await fetchAndShowWeather(cityName);
    } catch (error) {
      showError(cleanErrorText(error));
    }

    setState(() => isLoading = false);
  }

  // Get the data from the service and store it
  Future<void> fetchAndShowWeather(String cityName) async {
    final weather = await weatherService.getWeather(cityName);
    final forecastList = await weatherService.getForecast(cityName);
    setState(() {
      currentWeather = weather;
      forecasts = forecastList;
    });
  }

  // Clear old data and show an error message
  void showError(String message) {
    setState(() {
      currentWeather = null;
      forecasts = [];
      errorMessage = message;
    });
  }

  // Remove the "Exception: " prefix from an error
  String cleanErrorText(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  // Screen 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  // Blue app bar with the title
  AppBar buildAppBar() {
    return AppBar(
      title: const Text('Weather Forecast App'),
      centerTitle: true,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  // Search bar on top, results below
  Widget buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          buildSearchBar(),
          const SizedBox(height: 16),
          buildResultArea(),
        ],
      ),
    );
  }

  // Text field + Search button
  Widget buildSearchBar() {
    return Row(
      children: [
        Expanded(child: buildSearchField()),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => loadWeatherForCity(cityController.text),
          child: const Text('Search'),
        ),
      ],
    );
  }

  // Text field where the user types a city name
  Widget buildSearchField() {
    return TextField(
      controller: cityController,
      onSubmitted: loadWeatherForCity,
      decoration: const InputDecoration(
        hintText: 'Enter city name',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
      ),
    );
  }

  // Show loading, error, or the weather 
  Widget buildResultArea() {
    if (isLoading) {
      return const CircularProgressIndicator();
    }
    if (errorMessage.isNotEmpty) {
      return buildErrorView();
    }
    final weather = currentWeather;
    if (weather == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        buildCurrentWeatherCard(weather),
        buildForecastList(),
      ],
    );
  }

  // Red error text + Retry button
  Widget buildErrorView() {
    return Column(
      children: [
        Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => loadWeatherForCity(lastCity),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  // White card with the current weather
  Widget buildCurrentWeatherCard(Weather weather) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              weather.city,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            buildTemperatureRow(weather),
            Text(weather.condition, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            buildHumidityAndWindRow(weather),
          ],
        ),
      ),
    );
  }

  // Weather icon + temperature
  Widget buildTemperatureRow(Weather weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(weather.getIconUrl(), width: 80, height: 80),
        Text(
          '${weather.temp.round()}°C',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Humidity and wind speed side by side
  Widget buildHumidityAndWindRow(Weather weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Humidity: ${weather.humidity}%'),
        Text('Wind: ${weather.windSpeed} m/s'),
      ],
    );
  }

  // "Forecast" title + one row for each forecast
  Widget buildForecastList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Forecast',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (final forecast in forecasts) buildForecastRow(forecast),
      ],
    );
  }

  // One white card: time  icon + temperature  condition
  Widget buildForecastRow(Forecast forecast) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(forecast.getTimeText()),
            Row(
              children: [
                Image.network(forecast.getIconUrl(), width: 40, height: 40),
                Text(
                  '${forecast.temp.round()}°C',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(forecast.condition),
          ],
        ),
      ),
    );
  }
}
