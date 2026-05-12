# 🔬 Mars Tycoon - Teknoloji Ağacı (Research Tree) Spesifikasyonları

Bu dosya, Araştırma Laboratuvarı'nda üretilen Teknoloji Puanları (TP) ile açılabilecek geliştirmeleri, yeni bina kilitlerini ve global bonusları içerir.

## 📊 Araştırma ve TP Üretimi

Teknoloji Puanları, **Research Lab** binaları tarafından üretilir. TP üretimi binaların Tier seviyesine ve atanan yöneticinin Bilim yeteneğine göre ölçeklenir.

*   **Baz Üretim (T1):** 1 TP / Saniye.
*   **Tier 5 Üretim:** 16 TP / Saniye (Miras ve Yönetici bonusları hariç).

---

## 🏗️ Teknoloji Kategorileri

### 1. Endüstriyel Geliştirmeler (Industrial)
Üretim verimliliği ve inşaat hızı üzerine odaklanır.

| Teknoloji Adı | Maliyet (TP) | Ön Koşul | Etki |
| :--- | :--- | :--- | :--- |
| **Gelişmiş Madencilik** | 500 | - | Metals Extractor üretimi +%10 |
| **Beton Polimerizasyonu** | 1,200 | Gelişmiş Madencilik | Concrete Extractor verimi +%15 |
| **Otomatik Onarım Botları** | 5,000 | T3 Maden | Bina aşınma hızı -%20 |
| **Endüstriyel Otomasyon** | 15,000 | T4 Beton | Tüm sanayi binaları verimi +%10 |

### 2. Yaşam Desteği ve Koloni (Life Support)
Oksijen, su ve moral dengesini iyileştirir.

| Teknoloji Adı | Maliyet (TP) | Ön Koşul | Etki |
| :--- | :--- | :--- | :--- |
| **Nem Buharlaştırıcılar** | 600 | - | Moisture Vaporator üretimi +%15 |
| **Yüksek Verimli MOXIE** | 2,500 | Nem Buharlaştırıcı | MOXIE su tüketimi -%10 |
| **Mars Seraları** | 7,500 | T3 Moisture Vaporator | **YENİ BİNA:** Hydroponic Farm |
| **Atmosferik Kubbe** | 25,000 | T5 Oksijen | Global Moral Kaybı -%30 |

### 3. Enerji ve Lojistik (Energy & Logistics)
Şebeke kapasitesi ve depolama üzerine odaklanır.

| Teknoloji Adı | Maliyet (TP) | Ön Koşul | Etki |
| :--- | :--- | :--- | :--- |
| **Grafen Bataryalar** | 800 | - | Power Accumulator kapasitesi +%25 |
| **Solar Panel Kaplama** | 3,500 | Grafen Bataryalar | Kum fırtınası verim kaybı -%50 |
| **Şebeke BFS Optimizasyonu** | 10,000 | T4 Batarya | Kablosuz enerji iletimi (Menzil: 1 tile) |
| **Nükleer Füzyon** | 50,000 | T5 Research Lab | **YENİ BİNA:** Füzyon Reaktörü (Devasa Enerji) |

---

## 🏛️ Sektör Sinerjileri (Sinergy Upgrades)

Bu teknolojiler, Sektör Kombosu (3 bina yan yana) aktif olduğunda gelen bonusları güçlendirir.

*   **Sinerji Odaklama (T2):** Sektör kombosu bonusunu %25'ten %30'a çıkarır. (Maliyet: 4,000 TP)
*   **Miras Rezonansı (T4):** Binadaki kalıcı miras bonuslarını %20 daha etkili kılar. (Maliyet: 20,000 TP)

---

## ⚙️ Teknoloji Kilit Açma Kuralları
1.  Bir teknolojiyi araştırmak için gereken TP miktarı anında düşülür.
2.  Bazı teknolojiler için belirli binaların minimum bir Tier seviyesine (Örn: T3 Maden) ulaşmış olması gerekir.
3.  Araştırma süreci oyun kapalıyken de devam eder (Offline Progress).
