# 🌍 Mars Tycoon - Terraforming Spesifikasyonları

Bu dosya, Mars'ın yaşanabilir bir dünyaya dönüştürülme sürecindeki aşamaları, binaları ve global etkileri içerir.

## 📊 Dönüşüm Parametreleri

Mars'ın terraforming süreci 4 ana parametre üzerinden ilerler:

| Parametre | Üretici Binalar | Ana Etki |
| :--- | :--- | :--- |
| **Sıcaklık** | Surface Heater, Core Heat Pump | Bina aşınma hızı azalır. |
| **Su / Nem** | Small/Large Lake | Moisture Vaporator verimi artar. |
| **Atmosfer** | GHG Factory, Magnetic Shield | Radyasyon fırtınaları durur. |
| **Bitki Örtüsü** | Forestation Plant | Devasa Koloni Morali bonusu. |

---

## 🏗️ Terraforming Binaları

| Bina Adı | Katkı | Tüketim | Maliyet |
| :--- | :--- | :--- | :--- |
| **Surface Heater** | +0.01% Sıcaklık | 15 Enerji | 800 |
| **Small Lake** | +0.02% Su | 10 Su | 1000 |
| **Lake** | +0.05% Su | 25 Su | 2500 |
| **Large Lake** | +0.15% Su | 60 Su | 6000 |

---

## ⚙️ Kritik Eşikler ve Etkileri

Terraforming ilerledikçe Mars'ın anayasası değişir:

*   **%50 Atmosfer:** Meteor yağmuru hasarı %50 azalır.
*   **%80 Atmosfer:** Radyasyon Patlamaları tamamen durur.
*   **%40 Sıcaklık + %40 Su:** Bitki örtüsü (Forestation) başlatılabilir.
*   **%100 Hepsi:** Mars artık yaşanabilir! (End Game).

---

## ❄️ Mars'ın Direnci (Decay)
Mars her zaman eski haline dönmeye çalışır. Eğer ısıtıcılar veya atmosfer fabrikaları durursa, Sıcaklık ve Atmosfer değerleri saniyede **-0.001%** hızla düşmeye başlar. Süreç sürekli aktif tutulmalıdır.
