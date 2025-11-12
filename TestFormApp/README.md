# TestFormApp - iOS Test Form Management Application

Profesyonel iOS test ve kalite kontrol formu uygulaması. Elektrik panoları, trafolar, jeneratörler gibi ekipmanlar için test formlarını dijitalleştirir.

## Özellikler

✅ **Kategori Bazlı Organizasyon**: Trafo, UPS, RMU, Jeneratör, Panel
✅ **3 Seviye Test Desteği**: L1, L2, L3
✅ **Dinamik Form Rendering**: JSON template'lerden otomatik form oluşturma
✅ **Gelişmiş Bağımlılık Sistemi**:
  - 7 farklı bağımlılık tipi
  - Error/Warning/Info severity seviyeleri
  - Real-time validation
  - Visual feedback ve disabled states
✅ **Bağımlılık Yönetimi**: Uygulama içi bağımlılık editörü
✅ **Problem Kayıtları**: Detaylı issue tracking
✅ **Not Yönetimi**: Form bazlı notlar
✅ **Katılımcı Yönetimi**: İmza desteği (PencilKit)
✅ **PDF Export**: Profesyonel PDF raporları
✅ **İlerleme Takibi**: Tamamlanma yüzdesi
✅ **Auto-Save**: SwiftData ile otomatik kaydetme
✅ **Firebase Integration**: 🆕
  - Cloud Storage ile döküman paylaşımı
  - Firestore ile metadata yönetimi
  - Email/password ve anonymous authentication
  - Tüm kullanıcılar onaylı dökümanlara erişebilir
✅ **Dark Mode**: Tam dark mode desteği

## Teknolojiler

- **iOS 17+**: SwiftUI, SwiftData
- **Mimari**: MVVM Pattern
- **UI**: SF Symbols, Dynamic Type, Accessibility
- **Persistence**: SwiftData (iCloud sync capable)
- **PDF**: UIGraphicsPDFRenderer, PDFKit
- **Signature**: PencilKit
- **Firebase**: Authentication, Firestore, Cloud Storage

## Xcode'da Proje Kurulumu

### Adım 1: Yeni iOS App Projesi Oluşturun

1. Xcode'u açın
2. **File → New → Project**
3. **iOS → App** seçin
4. Proje ayarları:
   - **Product Name**: `TestFormApp`
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: `None` (SwiftData manuel ekleyeceğiz)
   - **Minimum iOS Version**: `17.0`

### Adım 2: Dosya Yapısını Oluşturun

Xcode'da Project Navigator'da (sol panel) aşağıdaki folder yapısını oluşturun:

1. `TestFormApp` klasörüne sağ tık → **New Group**
2. Şu grupları oluşturun:
   ```
   TestFormApp/
   ├── Models
   ├── Managers
   ├── Views
   │   ├── Navigation
   │   ├── FormViews
   │   ├── DependencyManagement
   │   └── Components
   ├── Utilities
   └── Resources
   ```

### Adım 3: Dosyaları Ekleyin

Bu repository'deki dosyaları Xcode projenize kopyalayın:

#### Models Klasörü:
- `Enums.swift`
- `FormTemplate.swift`
- `FilledForm.swift`
- `DependencyModels.swift`

#### Managers Klasörü:
- `FormTemplateManager.swift`
- `FilledFormDataManager.swift`
- `DependencyValidator.swift`

#### Views/Navigation:
- `CategoryListView.swift`
- `TestLevelListView.swift`

#### Views/FormViews:
- `DynamicFormView.swift`
- `InfoSectionView.swift`
- `ChecklistSectionView.swift`
- `ChecklistItemRow.swift`
- `IssueLogSectionView.swift`
- `AttendeesSectionView.swift`
- `NotesSectionView.swift`

#### Views/DependencyManagement:
- `DependencyManagementView.swift`
- `DependencyEditorView.swift`
- `ItemDependencyEditor.swift`
- `AddDependencySheet.swift`
- `DependencyRow.swift`

#### Views/Components:
- `CategoryRow.swift`
- `TestReportRow.swift`
- `ProgressBar.swift`

#### Views/ (root):
- `ContentView.swift`

#### Utilities:
- `PDFGenerator.swift`
- `Extensions.swift`

#### Root:
- `TestFormApp.swift` (Ana uygulama dosyası - mevcut olanı değiştirin)

### Adım 4: JSON Template Dosyasını Ekleyin

1. `Resources` grubuna sağ tık → **Add Files to "TestFormApp"**
2. `form_templates.json` dosyasını seçin
3. **IMPORTANT**: "Copy items if needed" işaretli olsun
4. **Target Membership**: `TestFormApp` işaretli olmalı

### Adım 5: Firebase Entegrasyonu (Opsiyonel ama Önerilen)

Firebase ile döküman paylaşım özelliklerini aktifleştirmek için:

1. **[FIREBASE_SETUP.md](FIREBASE_SETUP.md) dosyasını okuyun** - Detaylı kurulum talimatları
2. Firebase SDK paketlerini ekleyin (Swift Package Manager)
3. `GoogleService-Info.plist` dosyasını Firebase Console'dan indirin
4. Firebase Authentication, Firestore ve Storage'ı etkinleştirin

**Firebase olmadan da uygulama çalışır**, ancak:
- ❌ Döküman onaylama ve paylaşma özellikleri çalışmaz
- ❌ "Onaylı Dökümanlar" bölümü kullanılamaz
- ✅ Lokal form oluşturma, düzenleme ve PDF export çalışır

### Adım 6: Build ve Çalıştırma

1. Simulator veya gerçek device seçin (iOS 17+)
2. **Product → Build** (⌘B)
3. **Product → Run** (⌘R)

## Firebase Integration (YENİ! 🔥)

### Özellikler

- **Döküman Onaylama**: Tamamlanmış formlar onaylanıp buluta yüklenir
- **Merkezi Depolama**: Tüm onaylı dökümanlar Firebase Cloud Storage'da
- **Paylaşımlı Erişim**: Tüm kullanıcılar onaylı dökümanlara erişebilir
- **Metadata Yönetimi**: Firestore ile döküman bilgileri saklanır
- **Authentication**: Email/password ve anonymous login desteği

### Kurulum

Detaylı kurulum için **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** dosyasına bakın.

Hızlı özet:
1. Firebase Console'da proje oluşturun
2. iOS uygulaması ekleyin ve `GoogleService-Info.plist` indirin
3. Firebase SDK paketlerini Xcode'a ekleyin:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
4. Authentication, Firestore ve Storage'ı etkinleştirin
5. Security rules'ları yapılandırın

### Kullanım

1. **Giriş Yapma**:
   - Ana ekranda "Onaylı Dökümanlar" → "Giriş Yap"
   - Email/password ile kayıt olun veya anonim giriş yapın

2. **Döküman Onaylama**:
   - Formu %100 tamamlayın
   - Menü (⋯) → "Onayla ve Yükle"
   - Döküman bilgilerini gözden geçirin
   - "Onayla ve Yükle" butonuna tıklayın

3. **Paylaşılan Dökümanları Görüntüleme**:
   - "Onaylı Dökümanlar" bölümüne gidin
   - Kategoriye göre filtreleyin
   - Dökümana tıklayarak PDF'i görüntüleyin
   - Paylaş butonuyla başkalarıyla paylaşın

## JSON Template Yapısı

```json
{
  "formId": "unique_id",
  "category": "UPS",
  "level": "L2",
  "title": "Form Title",
  "sections": [
    {
      "id": "section_id",
      "title": "Section Title",
      "type": "checklist",
      "items": [
        {
          "number": 1,
          "description": "Item description",
          "controlMethod": "Visual Inspection",
          "dependencies": [
            {
              "type": "requires_yes",
              "targetItemNumbers": [2, 3],
              "message": "Warning message",
              "severity": "error"
            }
          ]
        }
      ]
    }
  ]
}
```

## Bağımlılık Tipleri

1. **requires_yes**: Hedef maddeler EVET olmalı
2. **requires_no**: Hedef maddeler HAYIR olmalı
3. **requires_not_na**: Hedef maddeler N/A olmamalı
4. **requires_any_yes**: En az biri EVET olmalı
5. **requires_all_yes**: Tümü EVET olmalı
6. **blocked_if_yes**: Hedef EVET ise engelle
7. **blocked_if_no**: Hedef HAYIR ise engelle

## Severity Seviyeleri

- **error**: Kullanıcı devam edemez (kırmızı)
- **warning**: Uyarı verilir, devam edilebilir (turuncu)
- **info**: Bilgilendirme (mavi)

## Kullanım

### Yeni Form Oluşturma

1. Ana ekranda kategori seçin (UPS, Trafo, vb.)
2. Test seviyesini seçin (L1, L2, L3)
3. "Yeni Test" butonuna tıklayın
4. Ekipman bilgilerini doldurun
5. Checklist maddelerini işaretleyin
6. Problem varsa kayıt ekleyin
7. Notlar ekleyin
8. Katılımcı bilgileri ve imzaları ekleyin
9. Kaydet veya PDF oluştur

### Bağımlılık Yönetimi

1. Ayarlar → Bağımlılık Yönetimi
2. Template seçin
3. Maddeye tıklayın
4. "+" ile yeni bağımlılık ekleyin
5. Tip, hedef maddeler, mesaj ve severity seçin
6. Kaydet

## Veri Saklama

- SwiftData ile lokal storage
- iCloud sync desteği (opsiyonel)
- Otomatik kaydetme
- PDF export ile dış paylaşım

## Geliştirme Notları

### Yeni Template Ekleme

1. `form_templates.json` dosyasını düzenleyin
2. Yeni template JSON objesi ekleyin
3. Uygulamayı yeniden build edin

### Özelleştirme

- **Renkler**: `Extensions.swift` → `Color` extension
- **PDF Layout**: `PDFGenerator.swift`
- **Validation Logic**: `DependencyValidator.swift`

## Mimari

```
┌─────────────────┐
│  TestFormApp    │ (Main entry point)
└────────┬────────┘
         │
    ┌────┴────┐
    │ Managers │ (FormTemplateManager, FilledFormDataManager)
    └────┬────┘
         │
    ┌────┴────┐
    │  Models  │ (FormTemplate, FilledForm, Dependencies)
    └────┬────┘
         │
    ┌────┴────┐
    │  Views   │ (SwiftUI Views)
    └──────────┘
```

## Örnek Kullanım Senaryoları

### 1. UPS L2 Test Raporu
- Ekipman bilgileri doldurulur
- Başlangıç koşulları kontrol edilir (11 madde)
- Öncül testler yapılır (2 madde)
- Tespitler işaretlenir (31 madde)
- Bağımlılıklar otomatik kontrol edilir
- PDF rapor oluşturulur

### 2. Problem Takibi
- Test sırasında problem tespit edilir
- Problem kaydı oluşturulur
- Sorumluluk atanır
- Termin tarihi belirlenir
- Onay süreci takip edilir

## Troubleshooting

### JSON yüklenmiyor
- `form_templates.json` dosyasının Target Membership'inin işaretli olduğundan emin olun
- JSON syntax'ının doğru olduğunu kontrol edin
- Clean Build Folder (⌘⇧K) yapıp tekrar build edin

### SwiftData hatası
- iOS 17+ simulator/device kullandığınızdan emin olun
- Schema tanımlarını kontrol edin

### PDF oluşturulmuyor
- Permission kontrolleri
- UIGraphicsPDFRenderer import'ları

## Lisans

Bu proje test ve eğitim amaçlıdır.

## İletişim

Sorularınız için issue açabilirsiniz.

---

**Geliştirici Notları:**
- Tüm String'ler Türkçe
- Comments İngilizce
- Clean Code prensipleri
- MVVM Architecture
- No force unwraps
- Comprehensive error handling
