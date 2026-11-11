import 'package:url_launcher/url_launcher.dart';
import 'package:vkart_shared/vkart_shared.dart';

class MapService {
  static Future<void> openMap(AddressModel address, {double? lat, double? lon}) async {
    Uri url;
    if (lat != null && lon != null) {
      // Use coordinates if available
      url = Uri.parse('google.navigation:q=$lat,$lon');
    } else {
      // Fallback to formatted address
      final query = Uri.encodeComponent(address.displayText);
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
