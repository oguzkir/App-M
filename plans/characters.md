# 👨‍💼 Mars Tycoon - Yönetici (Character) Spesifikasyonları

Bu dosya, oyundaki tüm yöneticilerin gelişim süreçlerini, nadirlik seviyelerini, uzmanlık alanlarını ve Miras/Mucize sistemlerini içerir.

## 📊 Gelişim ve Tier Sistemi

Yöneticiler Tier 1'den başlar ve çalıştıkça tecrübe (XP) kazanarak Tier 5'e kadar yükselebilirler.

| Seviye | XP Gereksinimi | Tanım |
| :--- | :--- | :--- |
| **Tier 1** | 300 XP (5 dk) | Çaylak |
| **Tier 2** | 600 XP (10 dk) | Deneyimli |
| **Tier 3** | 1200 XP (20 dk) | Uzman |
| **Tier 4** | 2400 XP (40 dk) | Üst Düzey |
| **Tier 5** | Max | Efsanevi (Mucize Aktif) |

*Not: XP gereksinimleri her seviyede 2 katına çıkar.*

---

## 🏗️ Sektörler ve Uzmanlık Alanları

| Sektör | Uzmanlık Alanı | Mucize Etkisi (T5) |
| :--- | :--- | :--- |
| **Endüstriyel** | Üretim ve Enerji | Anında Blackout onarımı + Kaynak paketleri |
| **Sivil** | Moral ve Yaşam | %100 Koloni Morali + Homesickness sıfırlama |
| **Lojistik** | Ekonomi ve İkmal | Ücretsiz İzotop + Devasa Kredi desteği |

---

## 💎 Nadirlik ve Ağırlıklar (Gacha)

Yeni yönetici işe alırken (Hiring) kullanılan olasılık oranları:

*   **Common (%70):** Standart bonuslar (P1-P2).
*   **Rare (%20):** Gelişmiş stres direnci ve üretim çarpanı.
*   **Epic (%8):** Kritik bina bonusları ve hızlı XP kazanımı.
*   **Legendary (%2):** Devasa Miras potansiyeli ve eşsiz Mucizeler.

---

## ⚙️ Miras (Legacy) ve Emeklilik

Yöneticiler sadece uzman oldukları sektörlerde yeterince deneyim kazanıp (Tier yükseltip) emekli olduklarında, o sektöre özgü **kalıcı bir Miras** bırakırlar.

| Yönetici Sektörü | Bırakabileceği Miras Türleri | Etki |
| :--- | :--- | :--- |
| **Endüstriyel** | Enerji Tasarrufu / Üretim Artışı | Binanın enerji ihtiyacı düşer veya ana çıktısı artar. |
| **Sivil** | Su Verimliliği / Moral Desteği | Binanın su tüketimi azalır veya koloni moraline pasif katkı sağlar. |
| **Lojistik/Bilim** | Teknoloji Sinerjisi / Bakım Kolaylığı | Araştırma hızı artar veya binanın aşınma hızı (wear) azalır. |

### 🚀 Emeklilik Şartları
1.  **Deneyim:** Yönetici en az Tier 2 seviyesine ulaşmış olmalıdır.
2.  **Sektör Uyumu:** Sadece uyumlu olduğu binada çalıştığı süre boyunca "Miras Puanı" biriktirir.
3.  **Zorunlu Emeklilik:** Stres %100 olduğunda veya T5 sonrası Mucize kullanıldığında Miras binaya işlenir ve yönetici listeden silinir.

---

## 🤝 Yönetici-Bina Uyumu (Affinity System)

Her yönetici sadece uzman olduğu sektöre ait binalara atanabilir. Yanlış eşleşme durumunda atama engellenir.

| Yönetici Sektörü | Atanabileceği Binalar |
| :--- | :--- |
| **Endüstriyel** | Güneş Paneli, Batarya, Metal Madeni, Beton Santrali |
| **Sivil** | Oksijen Jeneratörü, Su Pompası, Mars Çiftliği |
| **Bilim/Lojistik** | Araştırma Laboratuvarı, (Gelecek binalar) |

### 📈 Verimlilik Formülü (Güncellenmiş)
`Uretim = Baz_Uretim * (Yonetici_Boost + Sektor_Combo_Bonusu)`
*Eğer sektör uyumu yoksa atama yapılamaz.*
