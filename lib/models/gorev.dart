import 'package:flutter/material.dart';

enum GorevKategori {
  kisisel,
  isleIlgili,
  alisveris,
  saglik,
  diger
}

class Gorev {
  String id;
  String baslik;
  bool tamamlandi;
  DateTime tarih;
  GorevKategori kategori;

  Gorev({
    required this.id,
    required this.baslik,
    this.tamamlandi = false,
    required this.tarih,
    required this.kategori,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'tamamlandi': tamamlandi,
      'tarih': tarih.toIso8601String(),
      'kategori': kategori.index,
    };
  }

  factory Gorev.fromJson(Map<String, dynamic> json) {
    return Gorev(
      id: json['id'],
      baslik: json['baslik'],
      tamamlandi: json['tamamlandi'],
      tarih: DateTime.parse(json['tarih']),
      kategori: GorevKategori.values[json['kategori']],
    );
  }
} 