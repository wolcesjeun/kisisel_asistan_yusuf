import 'package:flutter/material.dart';

enum NotKategori {
  kisisel,
  isleIlgili,
  alisveris,
  saglik,
  diger
}

class Not {
  String id;
  String baslik;
  String icerik;
  Color renk;
  DateTime tarih;
  NotKategori kategori;

  Not({
    required this.id,
    required this.baslik,
    required this.icerik,
    required this.renk,
    required this.tarih,
    required this.kategori,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'icerik': icerik,
      'renk': renk.value,
      'tarih': tarih.toIso8601String(),
      'kategori': kategori.index,
    };
  }

  factory Not.fromJson(Map<String, dynamic> json) {
    return Not(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      baslik: json['baslik'] ?? 'Başlıksız Not',
      icerik: json['icerik'] ?? '',
      renk: Color(json['renk'] ?? Colors.blue.value),
      tarih: json['tarih'] != null ? DateTime.parse(json['tarih']) : DateTime.now(),
      kategori: NotKategori.values[json['kategori'] ?? 0],
    );
  }
} 