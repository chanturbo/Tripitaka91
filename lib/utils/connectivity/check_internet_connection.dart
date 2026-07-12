import 'package:http/http.dart' as http;
import 'package:tripitaka91/utils/constants/api_constants.dart';

/// Actually probes the backend instead of inferring connectivity from a
/// cached login, so remote-vs-local data source selection downstream
/// (widget.online) reflects real reachability.
Future<bool> checkInternetConnection() async {
  try {
    final response = await http
        .get(Uri.parse(tURLmain))
        .timeout(const Duration(seconds: 5));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
