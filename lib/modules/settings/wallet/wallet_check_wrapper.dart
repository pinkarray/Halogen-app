import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/wallet_provider.dart';
import 'create_wallet_screen.dart';
import 'wallet_dashboard_screen.dart';

class WalletCheckWrapper extends StatefulWidget {
  const WalletCheckWrapper({super.key});

  @override
  State<WalletCheckWrapper> createState() => _WalletCheckWrapperState();
}

class _WalletCheckWrapperState extends State<WalletCheckWrapper> {
  @override
  void initState() {
    super.initState();
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    walletProvider.checkWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        if (walletProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (walletProvider.hasWallet) {
          return const WalletDashboardScreen();
        } else {
          return const CreateWalletScreen();
        }
      },
    );
  }
}