import 'package:flutter/material.dart';

enum HatirlaticiOncelik {
  dusuk,
  orta,
  yuksek
}

enum HatirlaticiTekrar {
  birKez,
  gunluk,
  haftalik,
  aylik
}

class Hatirlatici {
  String id;
  String baslik;
  String? aciklama;
  DateTime tarih;
  HatirlaticiOncelik oncelik;
  HatirlaticiTekrar tekrar;
  bool aktif;

  Hatirlatici({
    required this.id,
    required this.baslik,
    this.aciklama,
    required this.tarih,
    required this.oncelik,
    required this.tekrar,
    this.aktif = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'aciklama': aciklama,
      'tarih': tarih.toIso8601String(),
      'oncelik': oncelik.index,
      'tekrar': tekrar.index,
      'aktif': aktif,
    };
  }

  factory Hatirlatici.fromJson(Map<String, dynamic> json) {
    return Hatirlatici(
      id: json['id'],
      baslik: json['baslik'],
      aciklama: json['aciklama'],
      tarih: DateTime.parse(json['tarih']),
      oncelik: HatirlaticiOncelik.values[json['oncelik']],
      tekrar: HatirlaticiTekrar.values[json['tekrar']],
      aktif: json['aktif'],
    );
  }
} 