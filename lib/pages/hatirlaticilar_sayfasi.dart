import 'package:flutter/material.dart';
import '../models/hatirlatici.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HatirlaticilarSayfasi extends StatefulWidget {
  final List<Hatirlatici> hatirlaticilar;
  final Function(List<Hatirlatici>) onHatirlaticilarChanged;

  const HatirlaticilarSayfasi({
    super.key,
    required this.hatirlaticilar,
    required this.onHatirlaticilarChanged,
  });

  @override
  State<HatirlaticilarSayfasi> createState() => _HatirlaticilarSayfasiState();
}

class _HatirlaticilarSayfasiState extends State<HatirlaticilarSayfasi> {
  void _hatirlaticiEkle() {
    String baslik = '';
    String? aciklama;
    DateTime tarih = DateTime.now();
    TimeOfDay saat = TimeOfDay.now();
    HatirlaticiOncelik oncelik = HatirlaticiOncelik.orta;
    HatirlaticiTekrar tekrar = HatirlaticiTekrar.birKez;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Hatırlatıcı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Hatırlatıcı başlığı',
                ),
                onChanged: (value) => baslik = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Hatırlatıcı açıklaması',
                ),
                maxLines: 2,
                onChanged: (value) => aciklama = value.isEmpty ? null : value,
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
                    setState(() => tarih = secilen);
                  }
                },
              ),
              ListTile(
                title: const Text('Saat'),
                subtitle: Text(
                  '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final secilen = await showTimePicker(
                    context: context,
                    initialTime: saat,
                  );
                  if (secilen != null) {
                    setState(() => saat = secilen);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HatirlaticiOncelik>(
                value: oncelik,
                decoration: const InputDecoration(
                  labelText: 'Öncelik',
                ),
                items: HatirlaticiOncelik.values.map((o) {
                  return DropdownMenuItem(
                    value: o,
                    child: Text(o.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    oncelik = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HatirlaticiTekrar>(
                value: tekrar,
                decoration: const InputDecoration(
                  labelText: 'Tekrar',
                ),
                items: HatirlaticiTekrar.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    tekrar = value;
                  }
                },
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
              if (baslik.isNotEmpty) {
                final hatirlaticiTarih = DateTime(
                  tarih.year,
                  tarih.month,
                  tarih.day,
                  saat.hour,
                  saat.minute,
                );

                // Seçilen tarih geçmişte mi kontrol et
                if (hatirlaticiTarih.isBefore(DateTime.now()) && tekrar == HatirlaticiTekrar.birKez) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Geçersiz Tarih'),
                      content: const Text('Lütfen gelecekte bir tarih ve saat seçin. Geçmiş bir zamana hatırlatıcı ekleyemezsiniz.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                final yeniHatirlatici = Hatirlatici(
                  id: (DateTime.now().millisecondsSinceEpoch % 100000).toString(),
                  baslik: baslik,
                  aciklama: aciklama,
                  tarih: hatirlaticiTarih,
                  oncelik: oncelik,
                  tekrar: tekrar,
                );

                final yeniListe = [...widget.hatirlaticilar, yeniHatirlatici];
                widget.onHatirlaticilarChanged(yeniListe);
                _hatirlaticilariKaydet(yeniListe);
                
                // Bildirimi planla
                NotificationService.instance.planlaHatirlatici(
                  id: int.parse(yeniHatirlatici.id),
                  baslik: yeniHatirlatici.baslik,
                  aciklama: yeniHatirlatici.aciklama ?? '',
                  tarih: yeniHatirlatici.tarih,
                  tekrar: yeniHatirlatici.tekrar,
                );

                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _hatirlaticilariKaydet(List<Hatirlatici> hatirlaticilar) async {
    final prefs = await SharedPreferences.getInstance();
    final hatirlaticilarJson = hatirlaticilar.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList('hatirlaticilar', hatirlaticilarJson);
  }

  void _hatirlaticiSil(String id) {
    // Bildirimi iptal et
    NotificationService.instance.iptalHatirlatici(int.parse(id) % 100000);

    final yeniListe = widget.hatirlaticilar.where((h) => h.id != id).toList();
    widget.onHatirlaticilarChanged(yeniListe);
    _hatirlaticilariKaydet(yeniListe);
  }

  void _hatirlaticiDuzenle(Hatirlatici hatirlatici) {
    String baslik = hatirlatici.baslik;
    String? aciklama = hatirlatici.aciklama;
    DateTime tarih = hatirlatici.tarih;
    TimeOfDay saat = TimeOfDay(hour: hatirlatici.tarih.hour, minute: hatirlatici.tarih.minute);
    HatirlaticiOncelik oncelik = hatirlatici.oncelik;
    HatirlaticiTekrar tekrar = hatirlatici.tekrar;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatıcıyı Düzenle'),
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
                  labelText: 'Açıklama (Opsiyonel)',
                ),
                controller: TextEditingController(text: aciklama),
                maxLines: 2,
                onChanged: (value) => aciklama = value.isEmpty ? null : value,
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
                    setState(() => tarih = DateTime(
                      secilen.year,
                      secilen.month,
                      secilen.day,
                      saat.hour,
                      saat.minute,
                    ));
                  }
                },
              ),
              ListTile(
                title: const Text('Saat'),
                subtitle: Text(
                  '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final secilen = await showTimePicker(
                    context: context,
                    initialTime: saat,
                  );
                  if (secilen != null) {
                    setState(() {
                      saat = secilen;
                      tarih = DateTime(
                        tarih.year,
                        tarih.month,
                        tarih.day,
                        secilen.hour,
                        secilen.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HatirlaticiOncelik>(
                value: oncelik,
                decoration: const InputDecoration(
                  labelText: 'Öncelik',
                ),
                items: HatirlaticiOncelik.values.map((o) {
                  return DropdownMenuItem(
                    value: o,
                    child: Text(o.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    oncelik = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HatirlaticiTekrar>(
                value: tekrar,
                decoration: const InputDecoration(
                  labelText: 'Tekrar',
                ),
                items: HatirlaticiTekrar.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    tekrar = value;
                  }
                },
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
              if (baslik.isNotEmpty) {
                // Tarih kontrolü
                if (tarih.isBefore(DateTime.now()) && tekrar == HatirlaticiTekrar.birKez) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Geçersiz Tarih'),
                      content: const Text('Lütfen gelecekte bir tarih ve saat seçin. Geçmiş bir zamana hatırlatıcı ekleyemezsiniz.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                // Eski bildirimi iptal et
                NotificationService.instance.iptalHatirlatici(
                  int.parse(hatirlatici.id),
                );

                final guncellenmisHatirlatici = Hatirlatici(
                  id: (int.parse(hatirlatici.id) % 100000).toString(),
                  baslik: baslik,
                  aciklama: aciklama,
                  tarih: tarih,
                  oncelik: oncelik,
                  tekrar: tekrar,
                );

                final yeniListe = widget.hatirlaticilar.map((h) {
                  return h.id == hatirlatici.id ? guncellenmisHatirlatici : h;
                }).toList();

                widget.onHatirlaticilarChanged(yeniListe);
                _hatirlaticilariKaydet(yeniListe);

                // Yeni bildirimi planla
                NotificationService.instance.planlaHatirlatici(
                  id: int.parse(guncellenmisHatirlatici.id),
                  baslik: guncellenmisHatirlatici.baslik,
                  aciklama: guncellenmisHatirlatici.aciklama ?? '',
                  tarih: guncellenmisHatirlatici.tarih,
                  tekrar: guncellenmisHatirlatici.tekrar,
                );

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
    final aktifHatirlaticilar = widget.hatirlaticilar.where((h) => h.aktif).toList();
    final gecmisHatirlaticilar = widget.hatirlaticilar.where((h) => !h.aktif).toList();

    return Scaffold(
      body: ListView(
        children: [
          if (aktifHatirlaticilar.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Aktif Hatırlatıcılar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...aktifHatirlaticilar.map((hatirlatici) => _buildHatirlaticiItem(hatirlatici)),
          ],
          if (gecmisHatirlaticilar.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Geçmiş Hatırlatıcılar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...gecmisHatirlaticilar.map((hatirlatici) => _buildHatirlaticiItem(hatirlatici)),
          ],
          if (widget.hatirlaticilar.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Henüz hatırlatıcı eklenmemiş',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'hatirlaticiEkleBtn',
        onPressed: _hatirlaticiEkle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHatirlaticiItem(Hatirlatici hatirlatici) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(
          Icons.circle,
          color: hatirlatici.oncelik == HatirlaticiOncelik.yuksek
              ? Colors.red
              : hatirlatici.oncelik == HatirlaticiOncelik.orta
                  ? Colors.orange
                  : Colors.green,
          size: 12,
        ),
        title: Text(hatirlatici.baslik),
        subtitle: Text(
          '${hatirlatici.tarih.day}/${hatirlatici.tarih.month}/${hatirlatici.tarih.year} ${hatirlatici.tarih.hour.toString().padLeft(2, '0')}:${hatirlatici.tarih.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _hatirlaticiDuzenle(hatirlatici),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hatırlatıcıyı Sil'),
                    content: const Text('Bu hatırlatıcıyı silmek istediğinizden emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _hatirlaticiSil(hatirlatici.id);
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
    );
  }
} 