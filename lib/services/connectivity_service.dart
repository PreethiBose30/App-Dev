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
  static bool _slowProbeRunning = false;

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
    if (hasInterface && !reachable) unawaited(_slowProbe());
    return _isOnline;
  }

  /// The quick ping failed although the phone has a network. The usual
  /// reason is a server that is asleep (free hosting spins down when idle)
  /// and needs up to a minute to wake. Wait for it once in the background
  /// and flip to online when it answers, so pending uploads still sync
  /// without the user having to toggle their connection.
  static Future<void> _slowProbe() async {
    if (_slowProbeRunning) return;
    _slowProbeRunning = true;
    try {
      final reachable = await ApiClient.pingBackend(timeout: const Duration(seconds: 75));
      if (reachable && !_isOnline) {
        _isOnline = true;
        _statusController.add(true);
      }
    } finally {
      _slowProbeRunning = false;
    }
  }
}
