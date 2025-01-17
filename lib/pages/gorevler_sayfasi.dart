import 'package:flutter/material.dart';
import '../models/gorev.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GorevlerSayfasi extends StatefulWidget {
  final List<Gorev> gorevler;
  final Function(List<Gorev>) onGorevlerChanged;

  const GorevlerSayfasi({
    super.key,
    required this.gorevler,
    required this.onGorevlerChanged,
  });

  @override
  State<GorevlerSayfasi> createState() => _GorevlerSayfasiState();
}

class _GorevlerSayfasiState extends State<GorevlerSayfasi> {
  void _gorevEkle() {
    String baslik = '';
    GorevKategori kategori = GorevKategori.kisisel;
    DateTime tarih = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Görev'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı',
                hintText: 'Örn: Alışveriş yap',
              ),
              onChanged: (value) => baslik = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GorevKategori>(
              value: kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
              ),
              items: GorevKategori.values.map((k) {
                return DropdownMenuItem(
                  value: k,
                  child: Text(k.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  kategori = value;
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tarih'),
              subtitle: Text(
                '${tarih.day}/${tarih.month}/${tarih.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final secilen = await showDatePicker(
                  context: context,
                  initialDate: tarih,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (secilen != null) {
                  tarih = secilen;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (baslik.isNotEmpty) {
                final yeniGorev = Gorev(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  baslik: baslik,
                  tarih: tarih,
                  kategori: kategori,
                );

                final yeniListe = [...widget.gorevler, yeniGorev];
                widget.onGorevlerChanged(yeniListe);
                _gorevleriKaydet(yeniListe);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _gorevleriKaydet(List<Gorev> gorevler) async {
    final prefs = await SharedPreferences.getInstance();
    final gorevlerJson = gorevler.map((g) => jsonEncode(g.toJson())).toList();
    await prefs.setStringList('gorevler', gorevlerJson);
  }

  void _gorevSil(String id) {
    final yeniListe = widget.gorevler.where((g) => g.id != id).toList();
    widget.onGorevlerChanged(yeniListe);
    _gorevleriKaydet(yeniListe);
  }

  void _gorevDuzenle(Gorev gorev) {
    String baslik = gorev.baslik;
    GorevKategori kategori = gorev.kategori;
    DateTime tarih = gorev.tarih;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı',
              ),
              controller: TextEditingController(text: baslik),
              onChanged: (value) => baslik = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GorevKategori>(
              value: kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
              ),
              items: GorevKategori.values.map((k) {
                return DropdownMenuItem(
                  value: k,
                  child: Text(k.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  kategori = value;
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tarih'),
              subtitle: Text(
                '${tarih.day}/${tarih.month}/${tarih.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final secilen = await showDatePicker(
                  context: context,
                  initialDate: tarih,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (secilen != null) {
                  tarih = secilen;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (baslik.isNotEmpty) {
                final guncellenmisGorev = Gorev(
                  id: gorev.id,
                  baslik: baslik,
                  tamamlandi: gorev.tamamlandi,
                  tarih: tarih,
                  kategori: kategori,
                );

                final yeniListe = widget.gorevler.map((g) {
                  return g.id == gorev.id ? guncellenmisGorev : g;
                }).toList();

                widget.onGorevlerChanged(yeniListe);
                _gorevleriKaydet(yeniListe);
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tamamlanmamisGorevler = widget.gorevler.where((g) => !g.tamamlandi).toList();
    final tamamlanmisGorevler = widget.gorevler.where((g) => g.tamamlandi).toList();

    return Scaffold(
      body: ListView(
        children: [
          if (tamamlanmamisGorevler.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Yapılacaklar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...tamamlanmamisGorevler.map((gorev) => _buildGorevItem(gorev)),
          ],
          if (tamamlanmisGorevler.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tamamlananlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...tamamlanmisGorevler.map((gorev) => _buildGorevItem(gorev)),
          ],
          if (widget.gorevler.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Henüz görev eklenmemiş',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'gorevEkleBtn',
        onPressed: _gorevEkle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGorevItem(Gorev gorev) {
    return Dismissible(
      key: Key(gorev.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _gorevSil(gorev.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: ListTile(
          leading: Checkbox(
            value: gorev.tamamlandi,
            onChanged: (value) {
              if (value != null) {
                final guncellenmisGorev = Gorev(
                  id: gorev.id,
                  baslik: gorev.baslik,
                  tamamlandi: value,
                  tarih: gorev.tarih,
                  kategori: gorev.kategori,
                );

                final yeniListe = widget.gorevler.map((g) {
                  return g.id == gorev.id ? guncellenmisGorev : g;
                }).toList();

                widget.onGorevlerChanged(yeniListe);
                _gorevleriKaydet(yeniListe);
              }
            },
          ),
          title: Text(
            gorev.baslik,
            style: TextStyle(
              decoration: gorev.tamamlandi ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            gorev.kategori.toString().split('.').last,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _gorevDuzenle(gorev),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Görevi Sil'),
                      content: const Text('Bu görevi silmek istediğinizden emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _gorevSil(gorev.id);
                          },
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 