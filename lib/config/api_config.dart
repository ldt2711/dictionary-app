import 'package:uuid/uuid.dart';

class ApiConfig {
  // IP mặc định nếu không tìm thấy (fallback)
  static const String _ngrokUrl = "https://lunchtime-stoning-elves.ngrok-free.dev";

  static String get baseUrl {
    // Với Ngrok, cả Web, Android Emulator và Điện thoại thật đều dùng chung 1 link
    return "$_ngrokUrl/api";
  }
  
  // Tạo một session_id duy nhất cho mỗi lần mở app
  static final String sessionId = const Uuid().v4(); 
}