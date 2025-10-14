# Tomyum Kitchen 管理者ダッシュボード

## 概要
Tomyum Kitchenアプリの予約・注文データを管理するためのWebベースの管理者ダッシュボードです。

## 機能
- 📊 **リアルタイム統計**: 今日の予約数、注文数、売上、アクティブ予約数を表示
- 📅 **予約管理**: 最新の予約情報を一覧表示
- 🛒 **注文管理**: 最新の注文情報を一覧表示
- 🔄 **自動更新**: 30秒ごとにデータを自動更新
- 📱 **レスポンシブデザイン**: モバイル・タブレット・デスクトップに対応

## ファイル構成
```
AdministratorWebsite/
├── index.html              # メインHTMLファイル
├── styles.css             # スタイルシート
├── admin-dashboard.js      # JavaScript機能
├── firebase-config.js     # Firebase設定ファイル
└── README.md              # このファイル
```

## セットアップ手順

### 1. Firebase設定
1. Firebase Console (https://console.firebase.google.com/) にアクセス
2. プロジェクト設定 > 全般 > アプリ > Webアプリを追加
3. 設定値をコピーして `firebase-config.js` に貼り付け
4. `index.html` の `firebaseConfig` を更新

### 2. Firestoreルール設定
Firestore Database > ルールで以下のルールを設定：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 管理者用の読み取り専用アクセス
    match /{document=**} {
      allow read: if true; // 本番環境では適切な認証を設定
    }
  }
}
```

### 3. データ構造
アプリから以下のコレクションにデータが保存されます：

#### reservations コレクション
```javascript
{
  customerName: string,
  phone: string,
  email: string,
  partySize: number,
  date: timestamp,
  timeSlot: string,
  specialRequests: string,
  status: string,
  createdAt: timestamp
}
```

#### orders コレクション
```javascript
{
  customerInfo: {
    name: string,
    phone: string,
    email: string,
    address: string
  },
  items: array,
  subtotal: number,
  discount: number,
  total: number,
  status: string,
  deliveryTime: string,
  deliveryInstructions: string,
  createdAt: timestamp
}
```

## 使用方法

### 1. ローカルサーバーで実行
```bash
# Python 3の場合
python -m http.server 8000

# Node.jsの場合
npx http-server

# ブラウザでアクセス
http://localhost:8000
```

### 2. Webサーバーにデプロイ
- GitHub Pages
- Netlify
- Vercel
- Firebase Hosting

## カスタマイズ

### スタイルの変更
`styles.css` のCSS変数を変更することで、色やスペーシングを調整できます：

```css
:root {
    --primary-red: #dc2626;
    --background-gray: #f8f9fa;
    --spacing-md: 1rem;
    /* その他の変数 */
}
```

### 更新間隔の変更
`admin-dashboard.js` の `startAutoRefresh()` メソッドで更新間隔を変更できます：

```javascript
// 60秒ごとに更新
setInterval(() => {
    if (this.isInitialized) {
        this.loadAllData();
    }
}, 60000);
```

## セキュリティ考慮事項

### 本番環境での推奨事項
1. **認証の実装**: Firebase Authenticationを使用して管理者認証を実装
2. **Firestoreルールの強化**: 適切なアクセス制御を設定
3. **HTTPSの使用**: 本番環境では必ずHTTPSを使用
4. **IP制限**: 必要に応じてアクセス可能なIPアドレスを制限

### Firestoreルール例（認証付き）
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if request.auth != null && 
                     request.auth.token.admin == true;
    }
  }
}
```

## トラブルシューティング

### よくある問題

#### 1. データが表示されない
- Firebase設定が正しいか確認
- Firestoreルールで読み取り権限があるか確認
- ブラウザのコンソールでエラーを確認

#### 2. 自動更新が動作しない
- JavaScriptが有効になっているか確認
- ネットワーク接続を確認
- Firebase SDKの読み込みを確認

#### 3. スタイルが適用されない
- CSSファイルのパスが正しいか確認
- ブラウザのキャッシュをクリア

## ライセンス
このプロジェクトはMITライセンスの下で公開されています。

## サポート
問題や質問がある場合は、プロジェクトのIssuesページで報告してください。
