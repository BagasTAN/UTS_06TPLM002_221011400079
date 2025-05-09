import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // Inisialisasi untuk bahasa Indonesia
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas UTS Cuaca',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cuaca Real-Time'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double lat = 55.0111;
  final double lon = 15.0569;
  final String cityName = 'Jakarta';
  final String apiKey =
      'e96955ec-2ce2-11f0-9b8b-0242ac130003-e9695678-2ce2-11f0-9b8b-0242ac130003';

  double? temperature;
  String? weatherSummary;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final url = Uri.parse(
        'https://api.stormglass.io/v2/weather/point?lat=$lat&lng=$lon&params=airTemperature,cloudCover');

    try {
      final response = await http.get(url, headers: {
        'Authorization': apiKey,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hours = data['hours'][0];

        setState(() {
          temperature = hours['airTemperature']['noaa'];
          double cloud = hours['cloudCover']['noaa'];
          weatherSummary = cloud < 30
              ? 'Cerah'
              : cloud < 60
              ? 'Berawan'
              : 'Mendung';
        });
      } else {
        print('Gagal fetch cuaca. Kode: ${response.statusCode}');
      }
    } catch (e) {
      print('Error mengambil data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: temperature == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cityName,
              style: const TextStyle(fontSize: 100, fontWeight: FontWeight.w100),
            ),
            Text(
              date,
              style: const TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text(
              '${temperature?.toStringAsFixed(1)} °C',
              style: const TextStyle(fontSize: 60, color: Colors.indigoAccent),
            ),
            Text(
              '$weatherSummary',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchWeather,
        tooltip: 'Refresh Cuaca',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
