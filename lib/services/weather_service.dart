import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';

class WeatherService {
  static final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  String? _sonSecilenSehir;

  static final WeatherService _instance = WeatherService._internal();
  
  factory WeatherService() {
    return _instance;
  }

  WeatherService._internal();

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisleri devre dışı.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Konum izinleri kalıcı olarak reddedildi.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> getCurrentCity() async {
    try {
      Position position = await _getCurrentLocation();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ?? 'Bilinmeyen Şehir';
      }
      return 'Bilinmeyen Şehir';
    } catch (e) {
      throw Exception('Şehir bilgisi alınamadı: $e');
    }
  }

  Future<Weather> getWeatherData() async {
    try {
      if (_sonSecilenSehir != null) {
        return await getWeatherDataByCity(_sonSecilenSehir!);
      }

      Position position = await _getCurrentLocation();
      String city = await getCurrentCity();
      
      final response = await http.get(Uri.parse(
        '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric&lang=tr'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data, city);
      } else {
        throw Exception('Hava durumu bilgisi alınamadı');
      }
    } catch (e) {
      throw Exception('Hava durumu bilgisi alınamadı: $e');
    }
  }

  String getWeatherIcon(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  Future<Weather> getWeatherDataByCity(String cityName) async {
    try {
      _sonSecilenSehir = cityName;
      final response = await http.get(Uri.parse(
        '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric&lang=tr'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data, cityName);
      } else {
        throw Exception('Hava durumu bilgisi alınamadı');
      }
    } catch (e) {
      throw Exception('Hava durumu bilgisi alınamadı: $e');
    }
  }

  void resetSonSecilenSehir() {
    _sonSecilenSehir = null;
  }

  String getWeatherDetailUrl(String city) {
    // OpenWeatherMap'in web sitesine yönlendirme
    return 'https://openweathermap.org/find?q=$city';
  }
} 