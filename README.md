## 📱 Frontend (Flutter) - README-frontend.md

### 📦 Mô tả dự án

Ứng dụng Flutter giúp người dùng quản lý tài chính cá nhân. Cho phép đăng nhập bằng Google, tạo ví/tài khoản, ghi nhận thu chi, đặt ngân sách, theo dõi báo cáo. Hỗ trợ dùng offline (guest mode) và đồng bộ sau khi đăng nhập.

---

### 🚀 Công nghệ sử dụng

- Flutter 3.x
- Dio (API client)
- Firebase Auth (Google Sign-in)
- Bloc/Cubit (State management)
- Hive (dữ liệu offline, dữ liệu key value)
- Local Notification

---
### 📱 Video demo & cài đặt ứng dụng
Video demo, file APK có sẵn tại đây:  
👉 [Google Drive](https://drive.google.com/drive/folders/1Fe48WZxZOVdHyJiVlq2p4rmDCrmMPfyp)

---

### 📋 Yêu cầu hệ thống

- Flutter SDK 3.0.0 trở lên
- Dart 3.0.0 trở lên
- Android Studio / VS Code
- iOS Simulator (cho macOS) hoặc Android Emulator
- Node.js (cho backend development)

---

### 🔧 Cài đặt & Thiết lập

#### 1. Clone repository

```bash
git clone <repository-url>
cd Financy_app
```

#### 2. Cài đặt dependencies

```bash
flutter pub get
```

#### 3. Thiết lập Firebase

- Tạo project Firebase mới
- Thêm ứng dụng Android/iOS
- Tải `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
- Cấu hình Google Sign-In

#### 4. Cấu hình môi trường

Tạo file `.env` trong thư mục gốc:

```env
API_BASE_URL=http://localhost:3000
FIREBASE_PROJECT_ID=your-project-id
```
---

### 📁 Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point của ứng dụng
├── myApp.dart               # Cấu hình app chính
├── app/                     # Cấu hình ứng dụng
│   ├── cubit/              # App-level state management
│   ├── router/             # Định tuyến ứng dụng
│   ├── services/           # Dịch vụ chung
│   │   ├── Local/         # Local services (notifications, settings)
│   │   └── Server/        # Server services (Dio client, auth interceptor)
│   └── theme/             # Cấu hình theme
├──
├── core/                   # Core utilities
│   └── constants/         # Constants (colors, icons, language options)
├── features/              # Các tính năng chính
│   ├── Account/          # Quản lý tài khoản/ví
│   │   ├── cubit/       # State management
│   │   ├── models/      # Data models
│   │   ├── repo/        # Repository layer
│   │   └── screen/      # UI screens
│   ├── auth/            # Xác thực người dùng
│   ├── Categories/      # Quản lý danh mục
│   ├── notification/    # Thông báo
│   ├── transactions/    # Giao dịch thu chi
│   └── Users/           # Quản lý người dùng
├──
├── shared/               # Shared components
│   ├── utils/           # Utility functions
│   └── widgets/         # Shared widgets
├──
├── l10n/                # Internationalization
│   ├── app_en.arb       # English translations
│   ....
│   ├── app_vi.arb       # Vietnamese translations
│   └── l10n.dart        # Localization configuration
```

---

### 🏗️ Kiến trúc hệ thống

```mermaid
graph TD
   subgraph "📱 Flutter App"
       UI[UI Layer]
       Cubit[Bloc/Cubit State Management]
       LocalDB[Hive/SQLite]
       SecureStore[flutter_secure_storage]
       DioClient[Dio HTTP Client]
   end

   subgraph "☁️ Backend API"
       API[REST API - Node.js/NestJS]
       Auth[JWT Auth Service]
       DB[(PostgreSQL/MongoDB)]
   end

   subgraph "🔹 Firebase"
       GoogleAuth[Google Sign-In]
   end

   UI --> Cubit
   Cubit --> LocalDB
   Cubit --> DioClient
   DioClient --> API
   API --> Auth
   API --> DB
   UI --> SecureStore
   GoogleAuth --> Auth
```

### 🔐 Xác thực & token

- Đăng nhập bằng Google → lấy idToken → gửi backend → nhận accessToken
- accessToken được lưu bằng flutter_secure_storage
- Dio được cấu hình sẵn Authorization: Bearer token

Ví dụ:

```dart
void setToken(String? token) {
  if (token != null) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  } else {
    dio.options.headers.remove('Authorization');
  }
}
```

---

### 📱 Chức năng đã có

- [x] Google Sign-in + JWT
- [x] Quản lý trạng thái auth (cubit)
- [x] CRUD Account (hiện tại là thủ công)
- [x] Giao diện account + chi tiết + xoá/sửa
- [x] Transaction list + add
- [x] Categories CRUD
- [x] Dashboard báo cáo
- [x] Offline mode (guest)
- [x] Local Notification
- [ ] Tự động sync khi login lại

---

### ▶️ Chạy ứng dụng

#### Development

```bash
flutter pub get
flutter run
```
---



📌 Ghi chú:

- App hiện tại đang ở giai đoạn 1: CRUD + Auth
- Giai đoạn 2: ngân hàng, báo cáo nâng cao


