# 🚀 Mars Tycoon - Mobil Kolonizasyon Simülasyonu

Mars Tycoon, derinlikli kaynak yönetimi simülasyonunu mobil platformun dinamikleriyle sentezleyen, yüksek performans odaklı bir "Eko-Sistem Tycoon" oyunudur. Bu belge, projenin vizyonu, mekanikleri, ekonomik dengeleri ve teknik mimarisini içeren ana referans dökümanıdır.

---

## 🎮 1. Proje Vizyonu ve Temel Tasarım Sütunları

Mars Tycoon, karmaşık hayatta kalma simülasyonunu basitleştirmek yerine, derinliği **Prestige (Miras)** döngüsüne ve kaynak bağımlılığına odaklayarak dönüştürür.

*   **Mutlak Kaynak Bağımlılığı (Interdependence):** Hiçbir kaynak izole değildir. Bir kaynağı kurtarmak için diğerinden vazgeçmek zorunda kalacağınız stratejik "feda" anları.
*   **Kademeli Çöküş (Cascade Failure):** Sistemik hatalar anlık "Game Over" yerine yönetilebilir kriz silsileleri doğurur.
*   **Miras Döngüsü (Legacy Cycle):** Geçici birimlerin (Yöneticiler) feda edilerek kalıcı bina bonuslarına dönüştürülmesi.
*   **Mobil Optimizasyon:** Batarya dostu, kısa seanslara uygun (2-5 dk) ama uzun vadeli (D30+) tutundurma odaklı mimari.

---

## 🏗️ 2. Kaynak Matrisi ve Ekonomik Denge

Mars'ta hiçbir kaynak "havadan" gelmez. Bir kaynağın çıktısı, diğerinin girdisidir.

| Kaynak | Kaynağı | Birincil Kullanım | Kritik Risk |
| :--- | :--- | :--- | :--- |
| **Enerji (⚡)** | Güneş/Rüzgar | Tüm binaların çalışması | Kesinti = Üretim Durur |
| **Oksijen (🌬️)** | MOXIE | Dome Yaşam Desteği | Yokluk = Oyun Biter |
| **Su (💧)** | Moisture Vaporator | Tarım ve Yakıt | Kıtlık = Gıda Durur |
| **Metaller (🏗️)** | Metals Extractor | İnşaat ve Bakım | Eksiklik = Onarım Durur |
| **Beton (🧱)** | Concrete Extractor | İleri Seviye İnşaat | Eksiklik = Genişleme Durur |
| **Gıda (🍎)** | Hydroponic Farm | Nüfus Beslenmesi | Açlık = Moral Kaybı |
| **Atık Kaya (🗑️)** | Madenler | Yan Ürün | Depo Dolarsa = Üretim Durur |
| **İzotop-238** | Premium | Zaman Hızlandırma/Mucize | Zaman Bariyeri (Üretilemez) |

### 🏗️ İnşaat ve Geliştirme
Binalar tamamen fiziksel kaynaklar (Metal ve Beton) kullanılarak inşa edilir. Premium para birimi olan İzotop-238, inşaat süreçlerini hızlandırmak veya kritik kriz anlarında "Mucize" tetiklemek için saklanmalıdır.

### 📊 Matematiksel Formülasyonlar
*   **Net Enerji:** $E_{net} = \sum (P_{üretim} \times I_{ışık}) - \sum C_{tüketim}$ (Geceleri üretim durur).
*   **Oksijen Verimi:** $O_{verim} = \frac{E_{girdi}}{E_{gereken}} \times (1 - R_{aşınma})$.
*   **Bakım Maliyeti:** Seviye arttıkça Metal tüketimi logaritmik olarak artar ($M_{bakım} = B_{maliyet} \times (1 + 0.1 \times L_{seviye})$).

---

## 👨‍💼 3. Yönetici ve Miras (Legacy) Sistemi

Yöneticiler, oyunun hem ana strateji unsuru hem de temel monetizasyon motorudur.

### Tier Hiyerarşisi ve İlerleme
*   **Tier 1-2:** 1 Saat (Alıştırma)
*   **Tier 2-3:** 6 Saat (Bağlılık)
*   **Tier 3-4:** 48 Saat (Stratejik Bariyer)
*   **Tier 4-5:** 14 Gün (**Hard Currency Teşviki**)

### "Tek Mucize" (The Miracle) ve Miras
Tier 5'e ulaşan bir yönetici, kariyerinde **sadece bir kez** mucize kullanabilir ve ardından emekli olur:
*   **Endüstriyel Mucize:** Tüm hasarlı binaları anında onarır. Miras: **+%15 Kalıcı Üretim.**
*   **Moral Mucizesi:** Morali %100 yapar. Miras: **-%20 Moral Kaybı Direnci.**
*   **Lojistik Mucize:** Devasa ikmal paketi indirir. Miras: **+%10 Çevrim Hızı.**

---

## ⚠️ 4. Kademeli Çöküş (Cascade Failure) Analizi

Enerji bittiğinde sistem, koloninin kalbini korumak için önem sırasına göre kararır:
1.  **Uyarı:** Enerji %25'e düştüğünde alarm verilir.
2.  **Kısmi Kapanma (P5):** Araştırma ve Lüks yapılar feda edilir.
3.  **Kritik Kayıp (P4-P3):** Madenler ve Sanayi tesisleri durur.
4.  **Topyekün Karanlık (P1):** Yaşam desteği ve Enerji altyapısı çöker.
5.  **Kurtarma:** Reklam izleyerek veya İzotop harcayarak sistemi %50 enerji ile **Reboot** edebilirsiniz.

---

## 🛠️ 5. Teknik Mimari (Godot 4.x)

Düşük batarya tüketimi ve yüksek performans için tasarlanmıştır.

*   **Sinyal Tabanlı (Event-Driven):** `_process(delta)` kullanımı minimize edilmiştir. UI ve sistemler sadece veri değiştiğinde (Signal/Observer) güncellenir.
*   **Resource Tabanlı Veri:** Binalar ve yöneticiler hafif `.tres` dosyaları olarak yönetilir (Object Pooling).
*   **TileMap Katmanları:**
    *   **L0 (Zemin):** Statik yüzey.
    *   **L1 (Altyapı):** Kablo/Boru (Breadth-First Search algoritmasıyla enerji iletimi).
    *   **L2 (Yapılar):** Fonksiyonel binalar.
*   **Güvenlik:**
    *   **Anti-Cheat:** Cihaz saati hilelerine karşı Network-Time API ve Unix Timestamp doğrulaması.
    *   **Şifreleme:** Kayıt dosyaları **AES-256** ile şifrelenir.

---

## 🚀 6. Onboarding: "Mars'a İniş"

İlk 5 dakikalık (FTUE) akış:
1.  **İniş:** Kısıtlı Metal ve Enerji ile başlangıç.
2.  **İnşa:** Güneş Paneli ve Metal Madeni inşasının öğretilmesi.
3.  **Yönetici Atama:** İlk yöneticinin madene atanması ve XP kazanımı.
4.  **Miras Vizyonu:** Tier 5 bir yöneticinin potansiyeli gösterilerek uzun vadeli hedef belirlenir.

---

## 📈 7. Proje İlerleme Durumu ve Teknik Hafıza

Bu bölüm, `chat_history.md` analizinden çıkarılan güncel durumu ve teknik kararları özetler.

### ✅ Tamamlananlar (Done)
*   **Core Loop:** İnşa Et -> Kaynak Yönet -> Yönetici Eğit -> Miras döngüsü kurgulandı.
*   **Ekonomi:** Enerji, Oksijen, Su, Metal, Gıda ve İzotop-238 bağımlılıkları belirlendi.
*   **Teknik Mimari:** Sinyal tabanlı yapı, Unix Timestamp ile offline ilerleme ve AES-256 şifreli kayıt sistemi.
*   **Yönetici Sistemi:** Tier 1-5 gelişimi, "Tek Mucize" (Miracle) mekaniği ve kalıcı "Miras" (Legacy) bonusları.
*   **Dünya Olayları:** Kum fırtınası, radyasyon gibi dinamik krizler.
*   **Sektör Sistemi:** Sanayi, Yaşam ve Bilim bölgeleri ile "Sektör Kombosu" sinerjisi.
*   **Cila (Juice):** Tween animasyonları, VFX/SFX havuzlama ve mobil SafeArea desteği.

### 📝 Bekleyen İşler (Pending)
*   **Sektör Kombosu Görselleştirmesi:** Sinerji aktif olduğunda oluşacak Shader/VFX efektleri.
*   **Gelişmiş Teknoloji Ağacı:** Araştırma Laboratuvarı'nda üretilen puanların kullanımı.
*   **Tutorial (FTUE):** "Mars'a İniş" senaryosu (Proje sonunda yapılacak).
*   **Monetizasyon:** RV ve IAP entegrasyonu (Proje sonunda yapılacak).

### 💡 Önemli Dersler ve Best Practices
*   **Zaman Hesaplama:** `_process` içinde timer çalıştırmak yerine her zaman Unix Timestamp kullanılmalı (pil dostu).
*   **UI Güncelleme:** HUD her karede değil, sadece sinyal geldiğinde güncellenmeli.
*   **Enerji Ağı:** Karmaşık BFS kontrolleri her karede değil, sadece grid değiştiğinde çalışmalı.
*   **Hile Koruması:** Cihaz saati yerine API tabanlı zaman doğrulaması şarttır.

---
*Unutmayın: En iyi mobil mimari, oyuncunun hissettiği derinliği en düşük enerji tüketimiyle sunabilen mimaridir.*
