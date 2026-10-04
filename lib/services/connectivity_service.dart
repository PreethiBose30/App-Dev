import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_client.dart';

/// Wi-Fi/mobile-data being up doesn't mean the backend is reachable
/// (captive portal, VPN, server down) -- so "online" here means both the
/// OS reports a network interface AND a real ping to /api/health
/// succeeded, not just the former.
class ConnectivityService {
  static final _statusController = StreamController<bool>.broadcast();
  static Stream<bool> get onStatusChange => _statusController.stream;

  static bool _isOnline = false;
  static bool get isOnline => _isOnline;

  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static Timer? _debounce;

  static void start() {
    if (_subscription != null) return;
    _subscription = Connectivity().onConnectivityChanged.listen((_) {
      // Debounce: a flapping interface can fire several change events in a
      // row: only bother pinging the backend once things settle.
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), refresh);
    });
    refresh();
  }

  static void stop() {
    _subscription?.cancel();
    _subscription = null;
    _debounce?.cancel();
  }

  /// Re-checks reachability right now and broadcasts if it changed. Safe to
  /// call manually (e.g. a pull-to-refresh) as well as from the listener
  /// above.
  static Future<bool> refresh() async {
    final results = await Connectivity().checkConnectivity();
    final hasInterface = !results.contains(ConnectivityResult.none);

    final reachable = hasInterface ? await ApiClient.pingBackend() : false;

    if (reachable != _isOnline) {
      _isOnline = reachable;
      _statusController.add(_isOnline);
    }
    return _isOnline;
  }
}
