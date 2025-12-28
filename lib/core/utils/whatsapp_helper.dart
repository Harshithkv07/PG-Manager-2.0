import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  // Format phone number for WhatsApp (remove spaces, dashes, etc.)
  static String _formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Add country code if not present (assuming India +91)
    if (!cleaned.startsWith('+')) {
      if (cleaned.length == 10) {
        cleaned = '+91$cleaned';
      } else if (!cleaned.startsWith('91')) {
        cleaned = '+91$cleaned';
      } else {
        cleaned = '+$cleaned';
      }
    }
    
    return cleaned;
  }

  // Send welcome message to student
  static Future<bool> sendWelcomeMessage(String phone, String name, int roomNumber) async {
    final formattedPhone = _formatPhoneNumber(phone);
    final message = 'Hello $name! Welcome to our PG. You have been assigned Room $roomNumber. '
        'We hope you have a comfortable stay with us. Feel free to reach out if you need anything!';
    
    return await _sendWhatsAppMessage(formattedPhone, message);
  }

  // Send rent reminder
  static Future<bool> sendRentReminder(String phone, String name, int roomNumber) async {
    final formattedPhone = _formatPhoneNumber(phone);
    final message = 'Hi $name, gentle reminder that rent for Room $roomNumber is pending. '
        'Please make the payment at your earliest convenience. Thank you!';
    
    return await _sendWhatsAppMessage(formattedPhone, message);
  }

  // Send custom message
  static Future<bool> sendCustomMessage(String phone, String message) async {
    final formattedPhone = _formatPhoneNumber(phone);
    return await _sendWhatsAppMessage(formattedPhone, message);
  }

  // Core method to send WhatsApp message
  static Future<bool> _sendWhatsAppMessage(String phone, String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://wa.me/$phone?text=$encodedMessage';
    
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
