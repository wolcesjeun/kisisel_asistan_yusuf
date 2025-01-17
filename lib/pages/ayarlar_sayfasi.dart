import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/font_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AyarlarSayfasi extends StatefulWidget {
  const AyarlarSayfasi({super.key});

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  String _secilenDil = 'Türkçe';
  final List<String> _diller = ['Türkçe', 'English'];

  @override
  void initState() {
    super.initState();
    _ayarlariYukle();
  }

  Future<void> _ayarlariYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _secilenDil = prefs.getString('dil') ?? 'Türkçe';
    });
  }

  Future<void> _ayarlariKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dil', _secilenDil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            'Tema Ayarları',
            [
              SwitchListTile(
                title: const Text('Koyu Tema'),
                subtitle: const Text('Koyu temayı aktif et'),
                value: ThemeService().isDark,
                onChanged: (value) {
                  setState(() {
                    ThemeService().toggleTheme();
                  });
                },
              ),
            ],
          ),
          _buildSection(
            'Font Ayarları',
            [
              ListTile(
                title: const Text('Font Boyutu'),
                subtitle: Slider(
                  value: FontService().fontBoyutu,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: FontService().fontBoyutu.toStringAsFixed(1),
                  onChanged: (value) {
                    FontService().setFontSize(value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            'Dil Ayarları',
            [
              ListTile(
                title: const Text('Uygulama Dili'),
                subtitle: DropdownButton<String>(
                  value: _secilenDil,
                  isExpanded: true,
                  items: _diller.map((String dil) {
                    return DropdownMenuItem<String>(
                      value: dil,
                      child: Text(dil),
                    );
                  }).toList(),
                  onChanged: (String? yeniDeger) {
                    if (yeniDeger != null) {
                      setState(() {
                        _secilenDil = yeniDeger;
                      });
                      _ayarlariKaydet();
                    }
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            'Uygulama Hakkında',
            [
              ListTile(
                title: const Text('Versiyon'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Geliştirici'),
                subtitle: const Text('Yusuf'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
} 