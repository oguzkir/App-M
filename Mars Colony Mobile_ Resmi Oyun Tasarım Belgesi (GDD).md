### Mars Colony Mobile: Resmi Oyun Tasarım Belgesi (GDD)

Bu belge, **Mars Colony Mobile** projesinin mekanik derinliğini, ekonomik stratejilerini ve Godot 4.x tabanlı teknik mimarisini detaylandıran ana referans dökümanıdır. Proje, _Surviving Mars_ deneyimini mobil platforma bir "port" olarak değil, mobil cihaz kısıtlamalarını (batarya, kısa seanslar) stratejik birer avantaja dönüştüren **"Optimize Edilmiş Simülasyon"** olarak kurgulanmıştır.

#### 1\. Proje Vizyonu ve Temel Tasarım Sütunları

Mars Colony Mobile, karmaşık hayatta kalma simülasyonunu "basitleştirmek" yerine, derinliği **Prestige (Miras)** döngüsüne ve kaynak bağımlılığına odaklayarak dönüştürür. Oyuncuyu pasif bir gözlemci değil, sürekli "Yatırım Koruma" ve "Kriz Yönetimi" arasında seçim yapan aktif bir mimar konumuna yerleştirir.**Temel Tasarım Sütunları:**

- **Mutlak Kaynak Bağımlılığı (Interdependence):** Hiçbir kaynak izole değildir. Bu, oyuncunun bir kaynağı kurtarmak için diğerinden vazgeçmesini zorunlu kılarak stratejik "feda" anları yaratır.
- **Kademeli Çöküş (Cascade Failure):** Sistemik hatalar anlık "Game Over" yerine yönetilebilir kriz silsileleri doğurur. Bu mekanik, oyuncunun koloni üzerindeki kontrol hissini test ederek başarısızlık anlarını bile birer oyun mekaniği haline getirir.
- **Miras Döngüsü (Legacy Cycle):** Geçici birimlerin (Yöneticiler) feda edilerek kalıcı bina bonuslarına dönüştürülmesi.
- **Analitik Katman:** Bu döngü, D30 (30 günlük tutundurma) oranlarını artırmak için tasarlanmıştır. Oyuncu, emek verdiği yöneticinin "miras" bırakacağını bildiği için oyundan kopmak yerine yeni bir döngüye girmeyi tercih eder.

#### 2\. Çekirdek Oynanış Döngüsü (Core Loop)

Oyunun ana döngüsü **"İnşa Et -> Kaynak Yönet -> Yönetici Eğit -> Miras Bırak"** ekseni üzerine kuruludur. Oyuncu, kaynak üretimini optimize ederken yöneticilerini Tier 5 (Efsanevi) seviyesine taşıyarak kalıcı kolonizasyon mirasını oluşturmaya çalışır.

##### 2.1. Kaynak Bağımlılık Matrisi ve Tier 1 Başlangıç Değerleri

Her bina, aşağıdaki temel değerler üzerinden sisteme entegre edilir. Mimari, bu değerlerin anlık arz-talep dengesini korumasını ŞART koşar.| Kaynak | Girdi (İhtiyaç) | Çıktı (T1 Değeri) | Yokluk Riski / Kriz || ------ | ------ | ------ | ------ || **Enerji (⚡)** | Güneş/Rüzgar | +10 (Güneş Paneli) | Topyekün sistem çöküşü (Blackout) || **Oksijen (🌬️)** | Enerji + Su | -3 (MOXIE) | Kolonist kaybı / Moral çöküşü || **Su (💧)** | Enerji | -4 (Su Pompası) | Tarım ve O2 üretiminin durması || **Metal (🏗️)** | Maden + Enerji | İnşaat & Bakım | Gelişimin ve onarımın durması || **Gıda (🍎)** | Su + Enerji | Nüfus Doyurma | Kitlesel açlık ve yönetici kaybı |

##### 2.2. Matematiksel Formülasyon: Enerji ve Verimlilik

Sistemin beyni, kaynakların anlık dengesini hesaplayan asenkron denklemlerdir.**Net Enerji Dengesi (** **\$E\_{net}**\$ **):** \$\$E*{net} = \\sum (P*{üretim} \\times I*{ışık}) - \\sum C*{tüketim}\$\$ _Burada_ _\$I_{ışık}_\$ \_Mars gün döngüsüne (0.0 - 1.0) göre değişen çarpandır._ _\$E_{net} < 0*\$ \_olduğunda batarya tüketimi başlar; batarya bittiğinde Kademeli Kapanma Sistemi tetiklenir.***Bina Kondisyonu (** **\$K**\$ **) ve Aşınma:** \$\$K*{yeni} = K*{eski} - (T*{zaman} + O*{olay})\$\$

- **Analitik Katman:** Kondisyonun verime etkisi, oyuncuyu "Bakım" için Metal harcamaya iter. Bu, kaynak birikimini engelleyen bir "sink" mekanizmasıdır ve oyun sonu (late-game) enflasyonunu önler.

#### 3\. Teknik Mimari: Godot 4.x ve Sinyal Tabanlı Yapı

Mimari, düşük batarya tüketimi ve yüksek performans için **Event-Driven (Olay Güdümlü)** bir yapı sergilemelidir. Her karede (frame) veri sorgulayan "polling" yönteminden kaçınılmalıdır.

##### 3.1. EventBus ve Resource Tabanlı Veri Yönetimi

- **Signal-Based Logic:** Enerji seviyesi %25'e düştüğünde, ResourceManager bir sinyal yayar. Sadece bu sinyali dinleyen UI ve Bina sistemleri tepki verir. Bu, CPU yükünü %60 oranında azaltır.
- **Resource (.tres) Kullanımı:** Her bina ve yönetici verisi birer Godot Resource dosyası olarak saklanmalıdır. Bu, "Object Pooling" mantığıyla bellek yönetimini optimize eder ve yüzlerce binanın aynı anda minimum RAM ile işlenmesini sağlar.

##### 3.2. Izgara Sistemi ve Enerji Dağıtımı

- **TileMapLayer:** Zemin, Altyapı (Kablo/Boru) ve Yapılar olarak 3 katmanlı bir grid yapısı kullanılacaktır.
- **BFS (Breadth-First Search) / Flood Fill:** Enerji dağıtımı, bir kaynaktan (Güneş Paneli) başlayarak bağlı kablolar üzerinden "Flood Fill" algoritması ile hesaplanacaktır.
- **Teknik Talimat:** Bağlantı kontrolü sadece grid_changed sinyali tetiklendiğinde (yeni bina/kablo inşası veya yıkımı) çalıştırılmalıdır.

#### 4\. Yönetici Sistemi ve Miras (Legacy) Mekaniği

Yöneticiler, oyunun hem ana strateji unsuru hem de temel monetizasyon motorudur. Sadece pasif bonuslar değil, aktif kriz yönetimi araçlarıdır.

##### 4.1. Tier Hiyerarşisi ve Bekleme Duvarları (Wait Walls)

İlerleme süreleri, oyuncuyu **İzotop-238** harcamaya teşvik edecek şekilde logaritmik olarak artar:

- **T1 -> T2:** 1 Saat (Alıştırma)
- **T2 -> T3:** 6 Saat (Bağlılık)
- **T3 -> T4:** 48 Saat (Stratejik Bariyer)
- **T4 -> T5:** 14 Gün ( **Hard Currency Teşviki** )

##### 4.2. "Tek Mucize" (The Miracle) ve Miras Seçimi

Tier 5 seviyesine ulaşan bir yönetici, kariyerinde **sadece bir kez** mucize kullanabilir ve ardından emekli olur.

- **Sanayi Dehası:** 24 saatlik enerji tüketimini sıfırlar. Emeklilikte: **+%15 Kalıcı Üretim Mirası.**
- **Halkın Kahramanı:** Global Morali %100 yapar. Emeklilikte: **\-%20 Moral Kaybı Direnci Mirası.**
- **Lojistik Uzmanı:** Acil durum kaynak paketi indirir. Emeklilikte: **+%10 Çevrim Hızı Mirası.Sektör Kombosu:** Bir sektördeki 3 bina aynı tip mirasa (Örn: 3 Sanayi Mirası) sahip olursa, o sektörde **+%25 Global Verim** tetiklenir.
- **Analitik Katman:** Bu mekanik, rastgele ilerleme yerine "Koleksiyon" motivasyonunu tetikler ve oyuncunun belirli bir binada belirli bir yöneticiyi eğitmek için defalarca deneme yapmasını (Gacha sirkülasyonu) sağlar.

#### 5\. Felaketler, Kriz Yönetimi ve Karar Anları

Felaketler, oyunun durağanlığını kıran ve oyuncunun "Yatırım Koruma" refleksini test eden akış düzenleyicilerdir.

##### 5.1. Kademeli Kapanma Hiyerarşisi (Cascade Priority)

Enerji tamamen tükendiğinde sistem, aşağıdaki sabit öncelik listesine göre binaları devre dışı bırakır:| Öncelik | Kategori | Örnek Bina | Etki || ------ | ------ | ------ | ------ || **4 (İlk Kapanan)** | Lüks & Araştırma | Lab, Gözlemevi | Teknoloji durur || **3** | Sanayi | Metal Madeni | Onarım durur || **2** | Gıda | Çiftlik | Açlık başlar || **1 (En Kritik)** | Yaşam Desteği | Batarya, MOXIE | **Koloni Ölümü** |

##### 5.2. Global Moral vs. Manager Stress

- **Global Moral:** Koloninin genel sağlık durumudur. Üretim hızını doğrudan etkiler ( \$Üretim \\times \\frac{Moral}{100}\$ ).
- **Manager Stress (Homesickness):** Binaların hasar alması veya "Rasyonel/Sert" kararlar verilmesi yöneticinin stresini artırır. Stres %100 olduğunda yönetici Tier 5'e ulaşamadan istifa eder.
- **Analitik Katman:** Oyuncu, binayı kurtarmak (Sert Seçenek) ile yöneticiyi korumak (İnsancıl Seçenek) arasında bırakılarak "Kayıptan Kaçınma" (Loss Aversion) psikolojisi üzerinden manipüle edilir.

#### 6\. Mobil Ekonomi ve Monetizasyon Stratejisi

"Harmonious Monetization" modeli, oyuncuyu cezalandırmadan ilerleme arzusunu ödüllendirir.

##### 6.1. İzotop-238 Ekonomisi

Ana premium para birimi olan İzotop-238, zamanın paraya dönüşümüdür.

- **Dönüşüm Oranı:** 1 İzotop ≈ 30-60 Dakikalık bekleme süresine eşittir.
- **Gacha (Market) Oranları:** Common (%70), Rare (%20), Epic (%8), Legendary (%2).
- **Daily Deals:** 24 saatlik FOMO slotları, oyuncuyu her gün marketi kontrol etmeye zorlar.

##### 6.2. Reklam Entegrasyonu (Rewarded Video)

Reklamlar, "Zaman Satın Alma" aracı olarak konumlandırılır:

- **2x Ödül:** Görev sonu ödüllerini katlar.
- **Hızlı Reboot:** Blackout sonrası sistemi %50 enerjiyle anında ayağa kaldırır.

#### 7\. Güvenlik ve Kullanıcı Deneyimi (UX)

##### 7.1. Anti-Cheat ve Zaman Doğrulaması

- **Time Travel Koruması:** Offline ilerleme hesaplanırken cihaz saati yerine Network-Time API doğrulaması kullanılır. Cihaz saati, son kaydedilen **Unix Timestamp** değerinden eskiyse veya tutarsızsa ilerleme dondurulur.
- **AES-256 Şifreleme:** Yerel .save dosyaları donanım anahtarıyla şifrelenerek kaynak manipülasyonu engellenir.

##### 7.2. UI/UX "Juice"

- **Safe Area:** Godot DisplayServer.get_display_safe_area() kullanılarak çentik (notch) koruması otomatik sağlanmalıdır.
- **Tweening:** Kaynak barlarının dolma animasyonları asenkron Tween kütüphanesiyle yumuşatılarak "Growth Feel" (Büyüme Hissi) pekiştirilir.

#### 8\. Onboarding: "Mars'a İniş" Tutorial

İlk 5 dakikalık (FTUE) akış, oyuncuyu "Gereklilik" üzerinden sisteme bağlar:

- **İniş:** Oyuncu kısıtlı Metal ve Enerji ile başlar.
- **İnşa:** Güneş Paneli (Enerji) ve Metal Madeni inşası zorunlu adımlarla öğretilir.
- **Yönetici Atama:** İlk yönetici madene atanır; İzotop ile "Anında Bitirme" mekaniği deneyimletilir.
- **İlk Kriz:** Küçük bir sızıntı tetiklenir; oyuncu "Tamir Et" (Metal) veya "Hızlı Onarım" (İzotop) arasında seçim yaparak "Risk/Maliyet" dengesini öğrenir.
- **Miras Vizyonu:** Tier 5 bir yöneticinin neye benzeyeceği bir "flash-forward" veya rüya sekansıyla gösterilerek uzun vadeli hedef belirlenir.