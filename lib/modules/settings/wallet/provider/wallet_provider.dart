import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import '../../../../shared/helpers/session_manager.dart';

class WalletProvider with ChangeNotifier {
  final String apiUrl = 'http://185.203.216.113:3004/api/v1';

  Future<Map<String, String>> _authHeaders() async {
    final token = await SessionManager.getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  bool _hasWallet = false;
  bool get hasWallet => _hasWallet;
  bool _hasFetchedTransactions = false;
  DateTime? _lastFetchedAt;
  double _availableBalance = 0;
  double get availableBalance => _availableBalance;

  List<dynamic> _transactions = [];
  List<dynamic> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;

    if (!hasListeners) return;

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  Future<void> checkWallet() async {
    try {
      setLoading(true);
      final res = await http.get(
        Uri.parse('$apiUrl/wallet'),
        headers: await _authHeaders(),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json['data'];
        _hasWallet = true;
        _availableBalance = (data['available_balance'] ?? 0).toDouble();
      } else {
        _hasWallet = false;
      }
    } catch (e) {
      _hasWallet = false;
    } finally {
      setLoading(false); 
    }
  }

  /// Creates a wallet for the user
  Future<bool> createWallet({
    required String phoneNumber,
    required String password,
    required String deviceId,
  }) async {
    try {
      setLoading(true);

      final payload = {
        "phone_number": phoneNumber,
        "password": password,
        "device_id": deviceId,
      };

      final res = await http.post(
        Uri.parse('$apiUrl/wallet'),
        headers: await _authHeaders(),
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body)['data'];
        _hasWallet = true;
        _availableBalance = (data['available_balance'] ?? 0).toDouble();
        return true;
      } else {
        debugPrint("❌ Wallet creation failed: ${res.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Wallet creation error: $e");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchTransactions() async {
    // prevent hammering API within 10 seconds
    if (_hasFetchedTransactions && _lastFetchedAt != null) {
      final timeSinceLast = DateTime.now().difference(_lastFetchedAt!);
      if (timeSinceLast.inSeconds < 10) {
        debugPrint("⏳ Too soon to re-fetch transactions.");
        return;
      }
    }

    try {
      debugPrint("🚀 Fetching transactions...");
      setLoading(true);

      final res = await http.get(
        Uri.parse('$apiUrl/wallet/transactions'),
        headers: await _authHeaders(),
      );

      debugPrint("📦 Response status: ${res.statusCode}");
      debugPrint("📦 Response body: ${res.body}");

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final data = json['data'];
        _transactions = data['transactions'] ?? [];
        _hasFetchedTransactions = true;
        _lastFetchedAt = DateTime.now(); // ✅ record the fetch time
        debugPrint("✅ Transactions loaded: ${_transactions.length}");
      } else {
        debugPrint("❌ Unexpected response: ${res.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception in fetchTransactions: $e");
    } finally {
      debugPrint("✅ Done loading transactions");
      setLoading(false);
    }
  }

  Future<void> refreshTransactions() async {
    _hasFetchedTransactions = false;
    await fetchTransactions();
  }

  void reset() {
    _hasWallet = false;
    _availableBalance = 0;
    _transactions = [];
    notifyListeners();
  }
}