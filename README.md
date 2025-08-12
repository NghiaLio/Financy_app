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

---

### 📁 Cấu trúc thư mục
```
lib/
├── main.dart
├── core/ (config, token, constants)
├── data/ (models, services, api)
├── features/
│   ├── auth/
│   ├── accounts/
│   ├── transactions/
│   └── categories/
└── widgets/
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
- [ ] Dashboard báo cáo
- [x] Offline mode (guest)
- [ ] Tự động sync khi login lại

---

### 📡 API endpoint config
lib/core/constants.dart:
```dart
const baseUrl = 'http://localhost:3000';
```

---

### ▶️ Chạy ứng dụng
```bash
flutter pub get
flutter run
```

---

### ⏳ TODO tiếp theo
- [ ] Báo cáo tổng thu/chi
- [ ] Tự động refresh token
- [ ] Tích hợp ngân hàng sau

---

📌 Ghi chú:
- App hiện tại đang ở giai đoạn 1: CRUD + Auth
- Giai đoạn 2: thêm sync, ngân hàng, báo cáo nâng cao

