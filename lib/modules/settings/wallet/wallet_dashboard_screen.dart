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
  List<Map<String, dynamic>> _mockTransactions = [];

  @override
  void initState() {
    super.initState();
    _handleBiometricAuth();
    _initMockTransactions();
  }

  void _initMockTransactions() {
    _mockTransactions = [
      {
        'description': 'Physical Security',
        'amount': 3000.00,
        'type': 'credit',
        'status': 'Completed'
      },
      {
        'description': 'Wallet Top-Up',
        'amount': 5000.00,
        'type': 'debit',
        'status': 'Processing'
      },
      {
        'description': 'Digital Protection',
        'amount': 1500.00,
        'type': 'credit',
        'status': 'Completed'
      },
      {
        'description': 'Secured Mobility',
        'amount': 2250.00,
        'type': 'credit',
        'status': 'Completed'
      },
      {
        'description': 'Alarm System',
        'amount': 1800.00,
        'type': 'credit',
        'status': 'Completed'
      },
      {
        'description': 'CCTV Installation',
        'amount': 4500.00,
        'type': 'credit',
        'status': 'Pending'
      },
    ];
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
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFAEA),
        elevation: 0,
        title: const Text(
          "Wallet",
          style: TextStyle(
            fontFamily: 'Objective',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
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
              const SizedBox(height: 24),
              
              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.add,
                    label: "Add Funds",
                    onTap: () {
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
                  ),
                  _buildActionButton(
                    icon: Icons.receipt_outlined,
                    label: "Transaction\nHistory",
                    onTap: () {
                      // This is already shown below, but could navigate to a dedicated screen
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.swap_horiz,
                    label: "Transfer",
                    onTap: () {
                      // Implement transfer functionality
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                "Transaction History",
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              if (_mockTransactions.isEmpty && walletProvider.transactions.isEmpty)
                const Text(
                  "No transactions yet",
                  style: TextStyle(
                    fontFamily: 'Objective',
                    color: Colors.black54,
                  ),
                )
              else
                Column(
                  children: _mockTransactions.isNotEmpty
                      ? _mockTransactions.map(_buildTransactionTile).toList()
                      : walletProvider.transactions.map(_buildTransactionTile).toList(),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Balance",
            style: TextStyle(
              fontFamily: 'Objective',
              fontSize: 16,
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
              color: Colors.black,
            ),
          ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.2);
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Objective',
              fontSize: 12,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(dynamic txn) {
    final isCredit = (txn['type'] ?? "").toLowerCase().contains("credit") || txn['amount'] > 0;
    final String transactionType = _getTransactionType(txn['description'] ?? '');
    final String status = txn['status'] ?? (isCredit ? "Completed" : "Processing");
    final Color statusColor = status.toLowerCase() == "completed" ? Colors.green : 
                             status.toLowerCase() == "processing" ? Colors.blue : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction icon or bullet
          Container(
            margin: const EdgeInsets.only(top: 4, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCredit ? Colors.green : Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionType,
                  style: const TextStyle(
                    fontFamily: 'Objective',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCredit ? "Payment" : "Funding",
                  style: const TextStyle(
                    fontFamily: 'Objective',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₦${txn['amount'].toString()}",
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 14,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade().slideX(begin: 0.1);
  }

  String _getTransactionType(String description) {
    if (description.toLowerCase().contains('physical security')) {
      return 'Physical Security';
    } else if (description.toLowerCase().contains('digital')) {
      return 'Digital Protection';
    } else if (description.toLowerCase().contains('mobility')) {
      return 'Secured Mobility';
    } else if (description.toLowerCase().contains('top-up') || 
              description.toLowerCase().contains('fund')) {
      return 'Wallet Top-Up';
    } else if (description.toLowerCase().contains('alarm')) {
      return 'Alarm System';
    } else if (description.toLowerCase().contains('cctv')) {
      return 'CCTV Installation';
    }
    return description;
  }
}