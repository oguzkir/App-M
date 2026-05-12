# 🏗️ Mars Tycoon - Bina Teknik Spesifikasyonları

Bu dosya, oyundaki tüm binaların üretim, tüketim, maliyet ve ölçeklendirme formüllerini içerir.

## 📊 Genel Formülasyonlar

Tüm binalar için geçerli olan ortak matematiksel model:

1.  **Üretim Formülü (Effective Production):**
    `Final_Üretim = (Temel_Üretim * Tier_Çarpanı) * Miras_Bonusu * Yönetici_Bonusu * Moral_Çarpanı`
    *   **Tier Çarpanı:** Seviye başına logaritmik artış: `2^(Tier - 1)` (Tier 1 = x1, Tier 5 = x16)
    *   **Yönetici Bonusu:** Yönetici yeteneğine göre (Örn: +%10 boost için 1.1 çarpanı).

2.  **Tüketim Formülü (Effective Consumption):**
    `Final_Tüketim = (Temel_Tüketim * Tier_Çarpanı) * Enerji_Tasarruf_Bonusu`
    *   **Tier Çarpanı (Tüketim):** Üretimden biraz daha verimlidir: `1.8^(Tier - 1)` (Üretim x16 artarken, tüketim yaklaşık x10 artar).

3.  **Yükseltme Maliyeti (Upgrade Cost):**
    `Maliyet = Baz_Maliyet * (Upgrade_Çarpanı ^ Mevcut_Tier)`

---

## 🏢 Bina Listesi

| Bina Adı | Tip | Üretim (P) | Tüketim (C) | Öncelik (P1-5) | Baz Maliyet |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Solar Panel** | Enerji | 10.0 Enerji | - | 1 | 150 |
| **Wind Turbine** | Enerji | 12.0 Enerji | - | 1 | 200 |
| **Power Accumulator** | Depo | 500.0 Kapasite | - | 1 | 400 |
| **MOXIE** | Yaşam | 2.0 Oksijen | 3.0 En. + 1.0 Su | 1 | 250 |
| **Electrolyzer** | Yaşam | 6.0 Oksijen | 8.0 En. + 4.0 Su | 1 | 500 |
| **Moisture Vaporator** | Kaynak | 5.0 Su | 2.0 Enerji | 2 | 200 |
| **Water Extractor** | Kaynak | 15.0 Su | 4.0 Enerji | 2 | 300 |
| **Hydroponic Farm** | Gıda | 4.0 Yemek | 2.0 En. + 3.0 Su | 2 | 400 |
| **Metals Extractor** | Sanayi | 3.0 Metal | 4.0 Enerji | 3 | 300 |
| **Concrete Extractor** | Sanayi | 2.0 Beton | 4.0 En. + 2.0 Su | 3 | 500 |
| **Universal Depot** | Depo | 500.0 Kapasite* | - | 3 | 100 |
| **Dumping Site** | Depo | 1000.0 Atık Kap. | - | 3 | 50 |

---

## 🗑️ Atık Yönetimi (Waste Rock)

Metal, Beton ve Su (Extractor) üretimi sırasında atık kaya açığa çıkar.

*   **Üretim Durması:** Eğer atık kapasitesi (Dumping Site) dolarsa, atık çıkaran binaların üretimi anında durur.
*   **İç Kapasite:** Her üretim binasının 50 birimlik kısıtlı iç atık deposu vardır.
| **Research Lab** | Bilim | 1.0 Teknoloji | 5.0 En. + 1.0 Su | 4 | 600 |

---

## ⚙️ Sistem Mekanikleri

*   **Cascade Failure (Kademeli Çöküş):** Enerji deposu tükendiğinde, binalar öncelik seviyesine göre (P4 -> P3 -> P2) kapanır. P1 binaları kritik yaşam desteği için açık kalmaya çalışır.
*   **XP ve Gelişim:** Binaya atanan yöneticiler saniyede 1 XP kazanır. Tier 5 olan bir yönetici "Mucize" tetikleyebilir.
---

## 🤝 Yönetici Gereksinimleri

Binalar sadece kendi sektörlerindeki yöneticiler tarafından tam verimle yönetilebilir.

| Bina Grubu | Gereken Yönetici Sektörü |
| :--- | :--- |
| Sanayi (Panel, Maden, Beton) | **Endüstriyel** |
| Yaşam (Oksijen, Su, Çiftlik) | **Sivil** |
| Bilim (Lab) | **Bilim/Lojistik** |
