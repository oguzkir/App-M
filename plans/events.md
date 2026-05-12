# 🌪️ Mars Tycoon - Dünya Olayları (World Events) Spesifikasyonları

Bu dosya, Mars yüzeyinde gerçekleşen rastgele olayların mekaniklerini, olasılıklarını ve koloni üzerindeki etkilerini içerir.

## 📊 Olay Döngüsü ve Olasılıklar

Olaylar `WorldEventManager` tarafından her 5 dakikada bir (300 saniye) kontrol edilir.

*   **Olay Tetiklenme Şansı:** %15
*   **Olay Süresi:** 30 - 120 Saniye (Rastgele)
*   **Huzur Döngüsü:** Bir olay bittikten sonra en az 10 dakika boyunca yeni bir olay tetiklenmez.

---

## 🌪️ Olay Kategorileri

### 1. Kum Fırtınası (Sandstorm) - %40 Olasılık
Güneş ışığını keser ve dış mekanizmalara zarar verir.

*   **Görsel Etki:** Ekran turuncu/kahverengi bir toz tabakasıyla kaplanır. Görüş mesafesi düşer.
*   **Teknik Etki:** 
    *   `solar_efficiency`: 0.1 (Güneş panelleri %10 verimle çalışır).
    *   `building_wear`: 2.0 (Bina aşınma hızı 2 katına çıkar).
*   **Strateji:** Bataryaların dolu olması kritiktir.

### ☢️ 2. Radyasyon Patlaması (Radiation Flare) - %25 Olasılık
Güneşten gelen yüksek enerjili parçacıklar personeli ve elektroniği etkiler.

*   **Görsel Etki:** Ekranda hafif bir parazitlenme ve morumsu bir parlama oluşur.
*   **Teknik Etki:**
    *   `manager_stress`: 3.0 (Yöneticiler 3 kat daha hızlı stres biriktirir).
    *   `moral_loss`: 1.5 (Koloni morali 1.5 kat daha hızlı düşer).
*   **Strateji:** Yöneticileri sığınağa (unassign) çekmek mantıklı olabilir.

### ☄️ 3. Meteor Yağmuru (Meteor Shower) - %20 Olasılık
Rastgele binalara fiziksel hasar verir.

*   **Görsel Etki:** Gökyüzünden düşen ateş topları ve zeminde sarsıntı (Screenshake).
*   **Teknik Etki:**
    *   `random_damage`: 50.0 (Rastgele 1-3 binanın kondisyonu anında %50 düşer).
*   **Strateji:** Acil onarım için Metal stoklamak gerekir.

### 🚀 4. İkmal Gemisi (Supply Ship) - %15 Olasılık (Pozitif Olay)
Dünya'dan gelen acil durum yardımı ve ticaret fırsatı.

*   **Görsel Etki:** Haritanın kenarında bir iniş kapsülü ve mavi bir ışık.
*   **Teknik Etki:**
    *   `market_discount`: 0.5 (İşe alım ve upgrade maliyetleri %50 azalır).
    *   `free_isotopes`: 10 (Hediye İzotop).
*   **Strateji:** Biriktirilen TP ve Kredileri harcamak için en iyi zaman.

---

## 🛠️ Olay Etki Formülasyonu

Olaylar sırasında binaların verimliliği şu şekilde hesaplanır:

`Olay_Verimi = Normal_Verim * active_event_effects.get("multiplier", 1.0)`

## ⚙️ Gelecek Geliştirmeler
*   **Erken Uyarı Sistemi:** Araştırma ile açılan radarlar sayesinde olay gelmeden 30 sn önce uyarı bildirimi.
*   **Olay Savunma Binaları:** Meteor bataryaları veya Manyetik Kalkanlar.
