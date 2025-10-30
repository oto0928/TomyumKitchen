# 🍜 Tomyum Kitchen

<div align="center">
**本格タイ料理の温かい味わいをお届けする、モダンなレストランアプリ**
URL：https://apps.apple.com/jp/app/tomyum-kitchen/id6753083421

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017.0+-blue.svg)](https://developer.apple.com/swiftui/)
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-yellow.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📱 アプリ概要

Tomyum Kitchenは、本格的なタイ料理レストランのための包括的なモバイルアプリケーションです。シンプルでスタイリッシュなデザインと、直感的なユーザー体験を提供します。

### ✨ 主な機能

- 🏠 **ホーム画面** - 美しいヒーローセクションと人気メニューの表示
- 🍽️ **メニュー閲覧** - カテゴリ別の料理一覧と詳細情報
- 🛒 **カート機能** - 注文管理と合計金額の自動計算
- 🎟️ **クーポン** - 割引クーポンの適用と管理
- 📅 **予約システム** - テーブル予約とオンライン注文
- 🏪 **店舗情報** - 営業時間、アクセス、連絡先情報

---

## 📸 スクリーンショット

<div align="center">

### ホーム画面 & メニュー
<img src="TomyumKitchen/Assets.xcassets/README1.imageset/Simulator Screenshot - iPhone 16 Pro - 2025-10-18 at 01.29.25.png" width="250"/> <img src="TomyumKitchen/Assets.xcassets/README2.imageset/Simulator Screenshot - iPhone 16 Pro - 2025-10-18 at 01.29.33.png" width="250"/> <img src="TomyumKitchen/Assets.xcassets/README3.imageset/Simulator Screenshot - iPhone 16 Pro - 2025-10-18 at 01.29.43.png" width="250"/>

### 料理詳細 & カート & 予約
<img src="TomyumKitchen/Assets.xcassets/README4.imageset/Simulator Screenshot - iPhone 16 Pro - 2025-10-18 at 01.29.50.png" width="250"/> <img src="TomyumKitchen/Assets.xcassets/README5.imageset/Simulator Screenshot - iPhone 16 Pro - 2025-10-18 at 01.29.55.png" width="250"/> <img src="TomyumKitchen/Assets.xcassets/README6.imageset/Simulator Screenshot - iPhone 16 Pro - 2025-10-18 at 01.30.08.png" width="250"/>

</div>

---

## 🏗️ 技術スタック

### フロントエンド
- **SwiftUI** - 宣言的UIフレームワーク
- **Combine** - リアクティブプログラミング
- **MVVM アーキテクチャ** - 保守性の高いコード構造

### バックエンド
- **Firebase Firestore** - リアルタイムデータベース
- **Firebase Storage** - 画像ストレージ
- **Firebase Authentication** - ユーザー認証

### デザインシステム
- **カスタムデザインシステム** - 一貫性のあるUI/UX
- **アクセシビリティ対応** - VoiceOver、Dynamic Type対応
- **ダークモード対応** - システム設定に追従

---

## 🚀 セットアップ

### 必要要件

- Xcode 15.0以上
- iOS 17.0以上
- Swift 5.9以上
- CocoaPods または Swift Package Manager

### インストール手順

1. **リポジトリのクローン**
```bash
git clone https://github.com/yourusername/TomyumKitchen.git
cd TomyumKitchen
```

2. **Firebase設定**
   - [Firebase Console](https://console.firebase.google.com/)でプロジェクトを作成
   - `GoogleService-Info.plist`をダウンロード
   - プロジェクトのルートディレクトリに配置

3. **依存関係のインストール**
```bash
# Swift Package Managerを使用（Xcodeが自動的に解決）
open TomyumKitchen.xcodeproj
```

4. **ビルドと実行**
   - Xcodeでプロジェクトを開く
   - ターゲットデバイスを選択
   - `Cmd + R` でビルド＆実行

---

## 📂 プロジェクト構造

```
TomyumKitchen/
├── TomyumKitchen/
│   ├── TomyumKitchenApp.swift      # アプリエントリーポイント
│   ├── ContentView.swift           # メインビューとモデル
│   ├── FirebaseService.swift       # Firebase連携サービス
│   ├── GoogleService-Info.plist    # Firebase設定
│   ├── Assets.xcassets/            # 画像アセット
│   │   ├── AppIcon.appiconset/     # アプリアイコン
│   │   ├── menu/                   # メニュー画像
│   │   └── StoreInteriorImage/     # 店内画像
│   ├── about.yaml                  # アプリ仕様書
│   └── design.yaml                 # デザインシステム仕様
├── AdministratorWebsite/           # 管理者用Webダッシュボード
│   ├── index.html
│   ├── admin-dashboard.js
│   ├── firebase-config.js
│   └── styles.css
└── README.md
```

---

## 🎨 デザインシステム

### カラーパレット

| カラー | 用途 | HEX |
|--------|------|-----|
| **Primary** | メインアクション | `#DC2626` (赤) |
| **Secondary** | サブアクション | `#059669` (緑) |
| **Accent** | アクセント | `#F59E0B` (黄) |
| **Background** | 背景 | `#FFFFFF` / `#1F2937` |
| **Text** | テキスト | `#111827` / `#F9FAFB` |

### タイポグラフィ

- **見出し**: SF Pro Display (Bold)
- **本文**: SF Pro Text (Regular)
- **キャプション**: SF Pro Text (Medium)

### スペーシング

```swift
xs: 4pt   // 小さな余白
s:  8pt   // 標準余白
m:  16pt  // 中程度の余白
l:  24pt  // 大きな余白
xl: 32pt  // 特大余白
```

---

## 🔥 Firebase 構造

### Firestore コレクション

#### `dishes` コレクション
```json
{
  "id": "string",
  "name": "string",
  "category": "string",
  "price": number,
  "imageName": "string",
  "description": "string",
  "spicyLevel": number,
  "isPopular": boolean,
  "detailedDescription": "string",
  "calories": number,
  "cookingTime": number,
  "ingredients": ["string"],
  "allergens": ["string"],
  "nutritionInfo": {
    "protein": number,
    "carbs": number,
    "fat": number,
    "fiber": number
  }
}
```

#### `reservations` コレクション
```json
{
  "id": "string",
  "customerName": "string",
  "phoneNumber": "string",
  "email": "string",
  "date": timestamp,
  "timeSlot": "string",
  "numberOfGuests": number,
  "specialRequests": "string",
  "status": "string",
  "createdAt": timestamp
}
```

#### `orders` コレクション
```json
{
  "id": "string",
  "items": [
    {
      "dish": object,
      "quantity": number
    }
  ],
  "customerInfo": {
    "name": "string",
    "phone": "string",
    "email": "string",
    "address": "string"
  },
  "deliveryTime": "string",
  "appliedCoupon": object,
  "subtotal": number,
  "discount": number,
  "total": number,
  "status": "string",
  "createdAt": timestamp
}
```

---

## 🛠️ 開発ガイド

### コーディング規約

- **Swift Style Guide**: [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)に準拠
- **命名規則**: キャメルケース（変数・関数）、パスカルケース（型）
- **コメント**: 複雑なロジックには必ずコメントを記載

### ブランチ戦略

```
main          # 本番環境
├── develop   # 開発環境
│   ├── feature/xxx  # 新機能開発
│   ├── bugfix/xxx   # バグ修正
│   └── hotfix/xxx   # 緊急修正
```

### コミットメッセージ

```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
style: コードフォーマット
refactor: リファクタリング
test: テスト追加・修正
chore: ビルド・設定変更
```

---

## 📊 管理者ダッシュボード

管理者用Webダッシュボードが`AdministratorWebsite/`に含まれています。

### 機能
- 📋 予約管理
- 🛒 注文管理
- 📊 売上統計
- 🍽️ メニュー管理

### アクセス方法
```bash
cd AdministratorWebsite
open index.html
```

---

## 🧪 テスト

### ユニットテスト
```bash
# Xcodeでテスト実行
Cmd + U
```

### UIテスト
```bash
# UIテストの実行
xcodebuild test -scheme TomyumKitchen -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## 📝 今後の予定

- [ ] Apple Pay統合
- [ ] プッシュ通知機能
- [ ] ロイヤリティプログラム
- [ ] 多言語対応（英語・タイ語）
- [ ] Apple Watch対応
- [ ] ウィジェット機能

---

## 🤝 コントリビューション

プルリクエストを歓迎します！大きな変更の場合は、まずissueを開いて変更内容を議論してください。

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

---

## 👥 開発者

**Tomyum Kitchen Development Team**

- 📧 Email: info@tomyumkitchen.com
- 🌐 Website: [www.tomyumkitchen.com](https://www.tomyumkitchen.com)
- 📱 App Store: [Coming Soon]

---

## 🙏 謝辞

- デザインインスピレーション: モダンなレストランアプリのベストプラクティス
- アイコン: SF Symbols
- 画像: オリジナル店舗写真

---

<div align="center">

**Made with ❤️ and 🌶️ by Tomyum Kitchen Team**

⭐ このプロジェクトが気に入ったら、スターをつけてください！

</div>

