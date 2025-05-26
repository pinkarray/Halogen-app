import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider/wallet_provider.dart';
import 'widgets/fund_wallet_modal.dart';
import 'pin_auth_screen.dart';

class WalletDashboardScreen extends StatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  State<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends State<WalletDashboardScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _handleBiometricAuth();
  }

  Future<void> _handleBiometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool("biometric_enabled") ?? false;

    if (!enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _authenticated = true);
          Provider.of<WalletProvider>(context, listen: false).fetchTransactions();
        }
      });
      return;
    }

    try {
      final isAvailable = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();

      if (!isAvailable || !isSupported) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _authenticated = true);
            Provider.of<WalletProvider>(context, listen: false).fetchTransactions();
          }
        });
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate to access your wallet',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (didAuthenticate) {
          setState(() => _authenticated = true);
          Provider.of<WalletProvider>(context, listen: false).fetchTransactions();
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PinAuthScreen()));
        }
      });
    } catch (e) {
      debugPrint("Biometric auth error: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PinAuthScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    if (!_authenticated) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Authentication required",
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Objective',
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

      if (walletProvider.isLoading) {
        return const Scaffold(
          backgroundColor: Color(0xFFFFFAEA),
          body: Center(child: CircularProgressIndicator()),
        );
      }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My Wallet",
          style: TextStyle(
            fontFamily: 'Objective',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C2B66),
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => walletProvider.refreshTransactions(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(walletProvider.availableBalance),
              const SizedBox(height: 20),

              // Add Money Button
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => FundWalletModal(
                      onConfirm: (amount) {
                        print("💰 Add ₦$amount to wallet");
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Money",
                  style: TextStyle(
                    fontFamily: 'Objective',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C2B66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "Transaction History",
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C2B66),
                ),
              ),
              const SizedBox(height: 10),

              if (walletProvider.transactions.isEmpty)
                const Text(
                  "No transactions yet",
                  style: TextStyle(
                    fontFamily: 'Objective',
                    color: Colors.black54,
                  ),
                )
              else
                Column(
                  children: walletProvider.transactions.map(_buildTransactionTile).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Available Balance",
            style: TextStyle(
              fontFamily: 'Objective',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₦${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              fontFamily: 'Objective',
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Color(0xFF1C2B66),
            ),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.2);
  }

  Widget _buildTransactionTile(dynamic txn) {
    final isCredit = (txn['type'] ?? "").toLowerCase().contains("credit") || txn['amount'] > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              txn['description'] ?? 'Transaction',
              style: const TextStyle(
                fontFamily: 'Objective',
                fontSize: 14,
                color: Color(0xFF1C2B66),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${isCredit ? '+' : '-'}₦${txn['amount'].toString()}",
            style: TextStyle(
              fontFamily: 'Objective',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    ).animate().fade().slideX(begin: 0.2);
  }
}
