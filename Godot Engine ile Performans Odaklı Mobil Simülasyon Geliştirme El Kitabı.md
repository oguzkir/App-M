### Godot Engine ile Performans Odaklı Mobil Simülasyon Geliştirme El Kitabı

Bu kılavuz, mobil platformlarda yüksek performanslı, batarya dostu ve derinlikli simülasyon oyunları geliştirmek için gereken mimari prensipleri, Godot Engine 4.x ekosisteminin sunduğu optimizasyon teknikleriyle sentezleyerek sunar.

#### 1\. Giriş: Mobil Simülasyonda Batarya Dostu Yaklaşım

Mobil oyun geliştirmede en büyük kısıtlama donanım gücü değil, ısı ve enerji yönetimidir. Godot Engine'in **hafif yapısı** ve **düşük sistem kaynakları** kullanımı, karmaşık bir Mars kolonisi simülasyonu için idealdir; ancak yanlış bir mimari, işlemciyi sürekli ham hesaplamalarla yorarak bataryayı hızla tüketir. Profesyonel bir sistem mimarı için hedef, "her karede hesaplama" (polling) yerine "sadece gerektiğinde hesaplama" (event-driven) olmalıdır.Mobil simülasyonun ana hedefleri:

- **Performans:** Cihazın ısınmasını önlemek için GPU üzerindeki Draw Call sayısını ve CPU döngülerini minimize etmek.
- **İlerleme Hissiyatı (Progression):** Oyuncuya kısa seanslarda dahi (2-5 dakika) anlamlı bir gelişim sunmak.
- **Süreklilik:** Oyuncu çevrimdışıyken dahi Unix Timestamp üzerinden gerçek zamanlı ilerleme sağlamak.
- **Verimlilik:** Gereksiz \_process çağrılarından kaçınarak kaynak yönetimini olay anlarına (inşa, yıkım, kriz) bağlamak._Veri yönetimi bu denli kritikken, sistemin kalbi olan haberleşme mimarisini 'Olay Tabanlı' bir yapıya oturtmak, performansın ilk kuralıdır._

#### 2\. Sinyal (Signal) Tabanlı Mimari: 'Event-Driven' Verimliliği

Geleneksel \_process(delta) kullanımı, saniyede 60 kez HUD güncellenmesi veya kaynak kontrolü yapılması demektir; bu da mobil cihazda bir "ısı tuzağı"dır. Bunun yerine, bir **EventBus** ve **ResourceManager** Singleton (Autoload) yapısı kullanarak, hesaplamalar sadece tetikleyici bir olay (örneğin bir kablonun döşenmesi) gerçekleştiğinde çalıştırılmalıdır.**Mimari Tavsiyesi:** HUD (Kaynak Barları) asla her karede güncellenmemelidir. Bunun yerine, ResourceManager bir sinyal yaymalı ve UI tarafındaki değerler lerp veya Tween aracılığıyla, sinyal geldiği anda akıcı bir şekilde güncellenmelidir.

##### Polling (Sürekli Kontrol) ve Signal-Based (Olay Tabanlı) Karşılaştırması

Özellik,Polling (Sürekli Kontrol),Signal-Based (Olay Tabanlı)

İşlemci (CPU) Yükü,Çok Yüksek (Her karede kontrol),Minimum (Sadece olay anında)

Batarya Tüketimi,Hızlı (Isınmaya neden olur),Minimum (Batarya dostu)

UI Güncelleme,Sürekli veri okuma,Sinyal tetiklemeli Tween/lerp

Mimari Yapı,Spagetti (İç içe geçmiş),Modüler ve Bağımsız (Decoupled)

_Veri akışını sinyallere bağladıktan sonra, bu verilerin görsel dünyadaki karşılığını optimize edilmiş katmanlar üzerinde organize etmek gerekir._

#### 3\. TileMap Katman Mantığı ve Sektörel Sinerji

Godot 4.x'in **TileMapLayer** yapısı, binaların ve altyapının organizasyonu için mükemmel bir GPU optimizasyonu sağlar. Doğru katman yönetimi, Draw Call sayısını düşürürken karmaşık inşa kurallarını basitleştirir.

##### Katman Organizasyonu (Layer Index)

- **Zemin (Layer 0):** Mars yüzeyi görselleri. Tamamen statiktir.
- **Altyapı (Layer 1):** Enerji kabloları ve borular. Yapılar bu katmandaki verilerin üzerine inşa edilebilir (tile işgal etmez).
- **Yapılar (Layer 2):** Güneş panelleri, madenler ve domelar. Çakışma kontrolleri buradadır.
- **İşaretçiler (Layer 3):** Seçim çerçeveleri, uyarı ikonları (Düşük Enerji vb.) ve geçici VFX.

##### Sektörel Sinerji Mimarisi (Sector Synergy)

Simülasyon derinliği için binalar sadece rastgele dizilmemelidir. **Sektörel Sinerji** sisteminde, bir bölgeye (Zone) aynı tipte mirasa (Legacy) sahip 3 bina (Örn: 3 adet "Sanayi Dehası") yerleştirildiğinde bir **Combo** tetiklenir ve o sektördeki toplam verimlilik **+%25** artar._Harita üzerindeki bu yapısal düzen, altyapıdan akan kaynakların matematiksel yükünü yönetmek için bir temel oluşturur._

#### 4\. Kaynak Yönetimi ve Enerji Ağı Matematiği

Simülasyonda enerji, oksijen ve metal arasındaki bağımlılık zinciri (Interdependence), oyunun zorluk eğrisini belirler. Enerji ağındaki bağlantıları kontrol etmek için her saniye hesaplama yapmak yerine, sadece şebeke değiştiğinde (yeni bina/kablo) çalışan bir **Flood Fill** algoritması kullanılmalıdır.

##### Temel Sistem Formülleri

**Net Enerji Dengesi:** \$\$E*{net} = \\sum P*{üretim} - \\sum C*{tüketim}\$\$**Oksijen Verimliliği (** \*\*\$O*{verim}**\$ **):** \$\$O*{verim} = \\frac{E*{girdi}}{E*{gereken}} \\times (1 - R*{aşınma})\$\$**Bakım Maliyeti (\*\* **\$M\_{bakım}**\$ **):** Binanın Metal tüketimi seviye arttıkça şu formülle katlanır: \$\$M*{bakım} = B*{maliyet} \\times (1 + 0.1 \\times L\_{seviye})\$\$

##### Mimari Uyarı: Kademeli Felaket (Cascade Failure)

Eksiye düşen enerji, bataryalar bittiğinde bir **Total Blackout** tetikler. Bu durumda tüm sistemler önem sırasına göre söner. Oyuncuya bu krizden çıkış için **Rewarded Ad** (Ödüllü Reklam) izleyerek enerjinin %50'sini anında geri kazanma şansı (Reboot) sunulmalıdır._Ekonomik dengeler kurulduğunda, bu süreçleri yönetecek personelin yaşam döngüsü ve "Miras" mekanizması devreye girer._

#### 5\. Yönetici (Manager) ve Miras (Legacy) Döngüsü

Yöneticiler T1'den (Çaylak) T5'e (Efsane) kadar gelişebilir. Ancak Mars acımasızdır; her yöneticinin bir **"Dünya Özlemi" (Homesickness)** ve **"Psikolojik Baskı" (Stress)** sayacı vardır. Bu sayaçlar dolduğunda yönetici emekli olmak ister.

- **Tek Mucize Mekaniği:** Sadece Tier 5 yöneticiler kariyerlerinde bir kez devasa bir bonus (Mucize) tetikleyebilir.
- **Miras (Legacy):** Mucize sonrası emekli olan yönetici, binaya kalıcı bir **Miras** bırakır. Oyuncu, **İzotop (Premium)** harcayarak hangi mirasın (Üretim Hızı, Enerji Tasarrufu veya Moral) kalıcı olacağını seçer.**Miras Türleri:**
- **Sanayi Dehası:** Binada kalıcı üretim hızı artışı.
- **Halkın Kahramanı:** Bölgesel moral kaybını yavaşlatma.
- **Lojistik Uzmanı:** Kaynak çevrim hızını artırma._Yönetici sirkülasyonu ve izotop harcamaları arttıkça, bu kritik verilerin hilelere karşı korunması şarttır._

#### 6\. Güvenlik ve Anti-Cheat: Kayıt Yönetimi

Mobil platformlarda "Zaman Yolculuğu" (cihaz saatini ileri alma) en yaygın hiledir. Bunu engellemek için **Unix Timestamp** kullanılmalı ve uygulama açılışında gerçek zaman asenkron olarak bir sunucu API'si ile doğrulanmalıdır.**Güvenlik Adımları:**

- **Binary/Resource Şifreleme:** JSON yerine Godot'nun FileAccess.open_encrypted_with_pass metodunu kullanarak kayıtları **Binary** formatta şifreleyin. Bu, "İzotop" miktarının elle değiştirilmesini önler.
- **Kritik Kayıt Stratejisi:** CPU'yu yormamak için her saniye değil; sadece satın alma (IAP), bina tamamlama veya görev bitişi gibi kritik anlarda kayıt yapın.
- **Discovery Ticket (Keşif Bileti):** En yüksek değerli yöneticileri (Legendary) garanti eden bu IAP kalemi, oyunun ana gelir kaynağı olarak "Hile Direnci" yüksek bir sunucu doğrulamasıyla korunmalıdır._Güvenlik ve teknik altyapı tamamlandığında, sistemin son katmanı olan kullanıcı deneyimi ve 'Juice' aşamasına geçilir._

#### 7\. Sonuç: Mimari Bütünlük ve 'Game Feel'

Başarılı bir mobil simülasyon, görünmez ama kusursuz çalışan bir sistemler bütünüdür. Sinyal mimarisiyle kazanılan performans, "Juice" (görsel tatmin) olarak oyuncuya geri verilmelidir. Pencerelerin enerji durumuna göre sönmesi veya bir kriz anında UI'ın kırmızıya bürünmesi, mimarinin verimliliği sayesinde akıcı bir şekilde gerçekleşir.Geliştiricinin odaklanması gereken 3 öncelik:

- **Olay Odaklılık:** İşlemciyi sadece veri değiştiğinde çalıştırın.
- **Sürdürülebilir Ekonomi:** **"Death Spiral"** riskini (Moral < 40) yöneterek, oyuncuyu sürekli bir kurtarma ve ilerleme döngüsünde tutun.
- **Hile Direnci:** Oyuncunun emeğini ve premium ekonomiyi (İzotoplar) şifreli ikili dosyalarla koruyun.**Unutmayın: En iyi mobil mimari, oyuncunun hissettiği derinliği en düşük enerji tüketimiyle sunabilen mimaridir.**