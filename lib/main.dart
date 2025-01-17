import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/notification_service.dart';
import 'services/weather_service.dart';
import 'services/theme_service.dart';
import 'models/weather.dart';
import 'models/gorev.dart';
import 'models/not.dart';
import 'models/hatirlatici.dart';
import 'pages/gorevler_sayfasi.dart';
import 'pages/notlar_sayfasi.dart';
import 'pages/hatirlaticilar_sayfasi.dart';
import 'pages/ayarlar_sayfasi.dart';
import 'pages/web_view_sayfasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'services/font_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ThemeService(), FontService()]),
      builder: (context, _) {
        final baseTheme = ThemeService().tema;
    return MaterialApp(
          title: 'Kişisel Asistan',
          theme: baseTheme.copyWith(
            textTheme: baseTheme.textTheme.copyWith(
              bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
                fontSize: (baseTheme.textTheme.bodyLarge?.fontSize ?? 14) * FontService().fontBoyutu,
              ),
              bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
                fontSize: (baseTheme.textTheme.bodyMedium?.fontSize ?? 14) * FontService().fontBoyutu,
              ),
              titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
                fontSize: (baseTheme.textTheme.titleLarge?.fontSize ?? 20) * FontService().fontBoyutu,
              ),
              titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
                fontSize: (baseTheme.textTheme.titleMedium?.fontSize ?? 16) * FontService().fontBoyutu,
              ),
              labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
                fontSize: (baseTheme.textTheme.labelLarge?.fontSize ?? 14) * FontService().fontBoyutu,
              ),
            ),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Weather? _weather;
  bool _isLoadingWeather = false;
  String? _weatherError;
  List<Gorev> _gorevler = [];
  List<Not> _notlar = [];
  List<Hatirlatici> _hatirlaticilar = [];

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Görevleri yükle
    final gorevlerJson = prefs.getStringList('gorevler') ?? [];
    setState(() {
      _gorevler = gorevlerJson
          .map((json) => Gorev.fromJson(jsonDecode(json)))
          .toList();
    });

    // Notları yükle
    final notlarJson = prefs.getStringList('notlar') ?? [];
    setState(() {
      _notlar = notlarJson
          .map((json) => Not.fromJson(jsonDecode(json)))
          .toList();
    });

    // Hatırlatıcıları yükle
    final hatirlaticilarJson = prefs.getStringList('hatirlaticilar') ?? [];
    setState(() {
      _hatirlaticilar = hatirlaticilarJson
          .map((json) => Hatirlatici.fromJson(jsonDecode(json)))
          .toList();
    });
  }

  void _loadWeatherData() async {
    try {
      setState(() {
        _isLoadingWeather = true;
        _weatherError = null;
      });

      final weather = await WeatherService().getWeatherData();
      
      setState(() {
        _weather = weather;
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _weatherError = e.toString();
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişisel Asistan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Kişisel Asistan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Ana Sayfa'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Görevler'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Notlar'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Hatırlatıcılar'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AyarlarSayfasi(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          GorevlerSayfasi(
            gorevler: _gorevler,
            onGorevlerChanged: (List<Gorev> yeniGorevler) {
              setState(() {
                _gorevler = yeniGorevler;
              });
            },
          ),
          NotlarSayfasi(
            notlar: _notlar,
            onNotlarChanged: (List<Not> yeniNotlar) {
              setState(() {
                _notlar = yeniNotlar;
              });
            },
          ),
          HatirlaticilarSayfasi(
            hatirlaticilar: _hatirlaticilar,
            onHatirlaticilarChanged: (List<Hatirlatici> yeniHatirlaticilar) {
              setState(() {
                _hatirlaticilar = yeniHatirlaticilar;
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Hatırlatıcılar',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _buildWeatherCard(),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildTasksCard(),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildRemindersCard(),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildNotesCard(),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Hero(
      tag: 'weather_card',
      child: Card(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0.8, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: const Text(
                        'Hava Durumu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.location_city, size: 18),
                          onPressed: _showCityChangeDialog,
                          tooltip: 'Şehir Değiştir',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.my_location, size: 18),
                          onPressed: () {
                            WeatherService().resetSonSecilenSehir();
                            _loadWeatherData();
                          },
                          tooltip: 'Konumu Kullan',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: _loadWeatherData,
                          tooltip: 'Yenile',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        if (_weather != null)
                          IconButton(
                            icon: const Icon(Icons.open_in_new, size: 18),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewSayfasi(
                                    url: WeatherService().getWeatherDetailUrl(_weather!.city),
                                    baslik: '${_weather!.city} Hava Durumu',
                                  ),
                                ),
                              );
                            },
                            tooltip: 'Detaylı Hava Durumu',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_isLoadingWeather)
                  const Center(child: CircularProgressIndicator())
                else if (_weatherError != null)
                  Center(
                    child: Text(
                      _weatherError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                else if (_weather != null)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _weather!.city,
                                style: const TextStyle(fontSize: 24),
                              ),
                              Text(
                                '${_weather!.temperature.round()}°C',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(_weather!.description),
                            ],
                          ),
                          Image.network(
                            WeatherService().getWeatherIcon(_weather!.iconCode),
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Hissedilen'),
                              Text('${_weather!.feelsLike.round()}°C'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Nem'),
                              Text('${_weather!.humidity}%'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Rüzgar'),
                              Text('${_weather!.windSpeed} km/s'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCityChangeDialog() {
    String yeniSehir = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şehir Değiştir'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Şehir Adı',
            hintText: 'Örn: Istanbul',
          ),
          onChanged: (value) => yeniSehir = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (yeniSehir.isNotEmpty) {
                WeatherService().getWeatherDataByCity(yeniSehir).then((weather) {
                  setState(() {
                    _weather = weather;
                  });
                }).catchError((error) {
                  setState(() {
                    _weatherError = error.toString();
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksCard() {
    final gorevSayisi = _gorevler.length;
    final tamamlananGorevSayisi = _gorevler.where((g) => g.tamamlandi).length;

    return Hero(
      tag: 'tasks_card',
      child: Card(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0.8, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Günlük Görevler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (gorevSayisi == 0)
                    const Center(
                      child: Text(
                        'Henüz görev eklenmemiş',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween<double>(
                            begin: 0.0,
                            end: gorevSayisi > 0 ? tamamlananGorevSayisi / gorevSayisi : 0,
                          ),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.grey[200],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$tamamlananGorevSayisi/$gorevSayisi görev tamamlandı',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemindersCard() {
    final bugunHatirlaticilar = _hatirlaticilar
        .where((h) => h.tarih.year == DateTime.now().year &&
            h.tarih.month == DateTime.now().month &&
            h.tarih.day == DateTime.now().day)
        .toList();

    return Hero(
      tag: 'reminders_card',
      child: Card(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0.8, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Önemli Hatırlatıcılar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (bugunHatirlaticilar.isEmpty)
                    const Center(
                      child: Text(
                        'Bugün için hatırlatıcı yok',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: bugunHatirlaticilar
                          .take(3)
                          .map((h) => ListTile(
                                title: Text(h.baslik),
                                subtitle: Text(
                                    '${h.tarih.hour.toString().padLeft(2, '0')}:${h.tarih.minute.toString().padLeft(2, '0')}'),
                                leading: Icon(
                                  Icons.circle,
                                  color: h.oncelik == HatirlaticiOncelik.yuksek
                                      ? Colors.red
                                      : h.oncelik == HatirlaticiOncelik.orta
                                          ? Colors.orange
                                          : Colors.green,
                                  size: 12,
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Hero(
      tag: 'notes_card',
      child: Card(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0.8, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Son Eklenen Notlar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_notlar.isEmpty)
                    const Center(
                      child: Text(
                        'Henüz not eklenmemiş',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _notlar
                          .take(3)
                          .map((n) => ListTile(
                                title: Text(n.baslik),
                                subtitle: Text(n.icerik),
                                leading: Icon(
                                  Icons.circle,
                                  color: n.renk,
                                  size: 12,
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
