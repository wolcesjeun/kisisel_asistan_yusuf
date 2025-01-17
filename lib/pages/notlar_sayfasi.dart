import 'package:flutter/material.dart';
import '../models/not.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotlarSayfasi extends StatefulWidget {
  final List<Not> notlar;
  final Function(List<Not>) onNotlarChanged;

  const NotlarSayfasi({
    super.key,
    required this.notlar,
    required this.onNotlarChanged,
  });

  @override
  State<NotlarSayfasi> createState() => _NotlarSayfasiState();
}

class _NotlarSayfasiState extends State<NotlarSayfasi> {
  void _notEkle() {
    String baslik = '';
    String icerik = '';
    Color renk = Colors.blue;
    NotKategori kategori = NotKategori.kisisel;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Not'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Not başlığı',
                ),
                onChanged: (value) => baslik = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'İçerik',
                  hintText: 'Not içeriği',
                ),
                maxLines: 3,
                onChanged: (value) => icerik = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<NotKategori>(
                value: kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                ),
                items: NotKategori.values.map((k) {
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
              Wrap(
                spacing: 8,
                children: [
                  _buildColorButton(Colors.blue, renk == Colors.blue, (color) {
                    renk = color;
                  }),
                  _buildColorButton(Colors.red, renk == Colors.red, (color) {
                    renk = color;
                  }),
                  _buildColorButton(Colors.green, renk == Colors.green, (color) {
                    renk = color;
                  }),
                  _buildColorButton(Colors.orange, renk == Colors.orange, (color) {
                    renk = color;
                  }),
                  _buildColorButton(Colors.purple, renk == Colors.purple, (color) {
                    renk = color;
                  }),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (baslik.isNotEmpty && icerik.isNotEmpty) {
                final yeniNot = Not(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  baslik: baslik,
                  icerik: icerik,
                  renk: renk,
                  tarih: DateTime.now(),
                  kategori: kategori,
                );

                final yeniListe = [...widget.notlar, yeniNot];
                widget.onNotlarChanged(yeniListe);
                _notlariKaydet(yeniListe);
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color, bool isSelected, Function(Color) onSelect) {
    return GestureDetector(
      onTap: () => setState(() => onSelect(color)),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _notlariKaydet(List<Not> notlar) async {
    final prefs = await SharedPreferences.getInstance();
    final notlarJson = notlar.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('notlar', notlarJson);
  }

  void _notSil(String id) {
    final yeniListe = widget.notlar.where((n) => n.id != id).toList();
    widget.onNotlarChanged(yeniListe);
    _notlariKaydet(yeniListe);
  }

  void _notDuzenle(Not not) {
    String baslik = not.baslik;
    String icerik = not.icerik;
    Color renk = not.renk;
    NotKategori kategori = not.kategori;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notu Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                ),
                controller: TextEditingController(text: baslik),
                onChanged: (value) => baslik = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'İçerik',
                ),
                controller: TextEditingController(text: icerik),
                maxLines: 3,
                onChanged: (value) => icerik = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<NotKategori>(
                value: kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                ),
                items: NotKategori.values.map((k) {
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
              Wrap(
                spacing: 8,
                children: [
                  _buildColorButton(Colors.blue, renk == Colors.blue, (color) {
                    setState(() => renk = color);
                  }),
                  _buildColorButton(Colors.red, renk == Colors.red, (color) {
                    setState(() => renk = color);
                  }),
                  _buildColorButton(Colors.green, renk == Colors.green, (color) {
                    setState(() => renk = color);
                  }),
                  _buildColorButton(Colors.orange, renk == Colors.orange, (color) {
                    setState(() => renk = color);
                  }),
                  _buildColorButton(Colors.purple, renk == Colors.purple, (color) {
                    setState(() => renk = color);
                  }),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (baslik.isNotEmpty && icerik.isNotEmpty) {
                final guncellenmisNot = Not(
                  id: not.id,
                  baslik: baslik,
                  icerik: icerik,
                  renk: renk,
                  tarih: not.tarih,
                  kategori: kategori,
                );

                final yeniListe = widget.notlar.map((n) {
                  return n.id == not.id ? guncellenmisNot : n;
                }).toList();

                widget.onNotlarChanged(yeniListe);
                _notlariKaydet(yeniListe);
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
    return Scaffold(
      body: widget.notlar.isEmpty
          ? const Center(
              child: Text(
                'Henüz not eklenmemiş',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: widget.notlar.length,
              itemBuilder: (context, index) {
                final not = widget.notlar[index];
                return _buildNotCard(not);
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notEkleBtn',
        onPressed: _notEkle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotCard(Not not) {
    return Card(
      color: not.renk.withOpacity(0.2),
      child: InkWell(
        onTap: () => _notDuzenle(not),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      not.baslik,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Notu Sil'),
                          content: const Text('Bu notu silmek istediğinizden emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _notSil(not.id);
                              },
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  not.icerik,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                not.kategori.toString().split('.').last,
                style: TextStyle(
                  color: not.renk,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 