# 📱 Dictionary App (Flutter)

## 🚀 Giới thiệu

Ứng dụng từ điển mobile:

* Tra từ
* Hiển thị nghĩa
* Kết nối API từ backend

---

## 🛠️ Công nghệ

* Flutter
* Dart
* HTTP package

---

## 📦 Yêu cầu hệ thống

* Flutter SDK
* Android Studio hoặc VS Code
* Emulator hoặc thiết bị thật

---

## ⚙️ Cài đặt & chạy

### 1. Clone project

```bash
git clone dictionary-app
cd dictionary_app
```

---

### 2. Cài dependencies

```bash
flutter pub get
```

---

### 3. Cấu hình API URL

Mở file:

```
lib/config/api_config.dart
```

---

### 4. Sửa URL theo môi trường

#### Android Emulator:

```dart
static const String baseUrl = "http://10.0.2.2:8000";
```

#### Flutter Web:

```dart
static const String baseUrl = "http://localhost:8000";
```

#### Máy thật:

```dart
static const String baseUrl = "http://<IP_MÁY>:8000";
```

---

## ▶️ Chạy ứng dụng

```bash
flutter run
```

---

## 📁 Cấu trúc project

```
lib/
│
├── config/
│   └── api_config.dart
│
├── services/
│   └── api_service.dart
│
├── models/
│
├── screens/
│
└── main.dart
```

---

## 🔗 Kết nối với backend

Đảm bảo backend đang chạy:

```
http://localhost:8000
```

---

## ⚠️ Lỗi thường gặp

### ❌ Không gọi được API

* Backend chưa chạy
* Sai baseUrl
* Sai port

---

### ❌ Android không có internet

Thêm vào:

```
android/app/src/main/AndroidManifest.xml
```

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 🔥 Tips

* Luôn chạy backend trước
* Dùng Postman test API trước khi gọi từ app

---

## 👨‍💻 Tác giả

* Nhóm 4 người 
