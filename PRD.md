# Proje: Kişisel Asistan Uygulaması

## Proje Tanımı

Bu proje, kullanıcıların günlük yaşamlarını organize etmelerine yardımcı olacak kapsamlı bir kişisel asistan uygulaması geliştirmeyi amaçlar. Uygulama, notlar almayı, görev listeleri oluşturmayı, hatırlatıcılar eklemeyi, hava durumu bilgilerini göstermeyi, kullanıcıya önerilerde bulunmayı ve çeşitli etkileşimli özellikler sunmayı içerir.

---

## Kullanılacak Teknolojiler ve Widget'lar

- **Navigasyon ve Gezinme**: Scaffold, Drawer, Navigator, MaterialPageRoute
- **Formlar ve Kullanıcı Girdileri**: TextField, Checkbox, RadioButton, DatePicker, TimePicker
- **Liste ve Veri Gösterimi**: ListView, Card, ListTile, Column, Row, Container
- **Etkileşimli Widget'lar**: FloatingActionButton, IconButton, Button, Snackbar, AlertDialog, PopupMenuButton
- **Veri Yönetimi**: StatefulWidget, Provider (Veri yönetimi için)
- **Görsel ve Davranışsal Zenginlik**: Image, Stack, BottomSheet, ExpansionPanel, Dialog, BottomNavigationBar
- **WebView**: WebView (İnternetten bilgi çekme ve gösterme)
- **Özelleştirme**: Özel font kullanımı, tema özelleştirme

---

## Özellikler

### Ana Sayfa

- Kullanıcı, kişisel görevlerini ve notlarını görebileceği bir ana sayfaya yönlendirilir.
- Hava durumu bilgileri ve günün önemli hatırlatıcıları burada görüntülenebilir.
- Kullanıcı, ana sayfada gezinme ve uygulama içinde kolayca geçiş yapabilir.

### Görev ve Notlar

- Kullanıcı, yeni görevler ekleyebilir, var olan görevleri düzenleyebilir veya silebilir.
- Görevler, tamamlanmış ve tamamlanmamış olarak kategorize edilebilir.
- Kullanıcı, görevlerine tarih ve saat ekleyebilir.
- Notlar ekleyebilir, düzenleyebilir ve silinebilir.

### Hatırlatıcılar

- Kullanıcı, belirli bir saatte hatırlatıcı ekleyebilir.
- Hatırlatıcılar, kullanıcıya bildirim olarak hatırlatılır.

### Hava Durumu

- Kullanıcı, şehir ismini girerek hava durumu bilgilerini alabilir.
- Hava durumu simgeleri ve sıcaklık gibi bilgileri görsel olarak gösterebilir.

### Navigasyon ve Ekranlar Arası Geçiş

- Drawer ve BottomNavigationBar kullanarak uygulama içinde gezinme yapılabilir.
- Uygulama, ekranlar arasında veri geçişi yapabilir ve kullanıcıya önerilerde bulunabilir.

### WebView Entegrasyonu

- Kullanıcı, hava durumu bilgilerini ya da diğer bilgileri internet üzerinden çekmek için WebView kullanabilir.

### Kişisel Ayarlar

- Kullanıcı, uygulamanın temasını değiştirebilir, fontları özelleştirebilir.
- Uygulama, kullanıcıya özel bir deneyim sunmak için kişisel ayarlar sayfası içerir.

### Uygulama İkonları ve Animasyonlar

- IconButton ve FloatingActionButton kullanarak interaktif ikonlar eklenebilir.
- Uygulama içerisinde animasyonlar ve görsel efektler kullanılabilir.

---

## Proje Puanlandırma Tablosu

| Değerlendirme Kriteri           | Ağırlık (%) | Açıklama                                                                                                                                                       |
| ------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Uygulama Fonksiyonelliği        | 40%         | Uygulamanın tüm temel işlevlerinin düzgün çalışması. Görev ekleme, notlar, hatırlatıcılar, hava durumu, veri yönetimi ve ekranlar arası geçiş gibi özellikler. |
| Kullanıcı Arayüzü (UI)          | 20%         | Uygulamanın estetik ve kullanıcı dostu tasarımı. Navigasyon, görseller, renk uyumu, fontlar ve genel düzenin profesyonel görünüp görünmediği.                  |
| Kod Düzenliliği ve Yorumlar     | 15%         | Kodun okunabilirliği, düzeni ve açıklayıcı yorumların varlığı. Fonksiyonların ve sınıfların iyi organize edilmiş olması.                                       |
| Veri Yönetimi ve Durum Yönetimi | 10%         | Uygulamanın veri yönetimi (örneğin, görevler, notlar, hatırlatıcılar) ve durum yönetimi (StatefulWidget kullanımı) uygulama içindeki veri akışı.               |
| Ekstra Özellikler (Opsiyonel)   | 10%         | Projeye eklenen yaratıcı ve işlevsel özellikler. Örneğin, animasyonlar, gelişmiş özellikler, dış API entegrasyonu, kullanıcı tercihlerine göre özelleştirme.   |
| Proje Teslimi ve Dokümantasyon  | 5%          | Proje dosyalarının düzgün bir şekilde teslim edilmesi, GitHub kullanımı ve projenin düzgün bir şekilde belgelendirilmiş olması.                                |
