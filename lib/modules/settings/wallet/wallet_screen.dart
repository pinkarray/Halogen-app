import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/helpers/session_manager.dart';
import '../../../shared/widgets/custom_button.dart';
import '../wallet/provider/wallet_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isLoading = true;
  String _phoneNumber = '';
  String _deviceId = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await SessionManager.getUserModel();
    if (mounted) {
      setState(() {
        _phoneNumber = user?.phoneNumber ?? '';
        _deviceId = user?.deviceId ?? '';
        _password = ''; // This should be securely handled
      });
      _checkWallet();
    }
  }

  Future<void> _checkWallet() async {
    final provider = Provider.of<WalletProvider>(context, listen: false);
    await provider.checkWallet();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (provider.hasWallet) {
        _fetchTransactions();
      }
    }
  }

  Future<void> _createWallet() async {
    setState(() => _isLoading = true);
    
    final provider = Provider.of<WalletProvider>(context, listen: false);
    final success = await provider.createWallet(
      phoneNumber: _phoneNumber,
      password: _password,
      deviceId: _deviceId,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet created successfully')),
        );
        _fetchTransactions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create wallet')),
        );
      }
    }
  }

  Future<void> _fetchTransactions() async {
    final provider = Provider.of<WalletProvider>(context, listen: false);
    await provider.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : provider.hasWallet 
          ? _buildWalletContent(provider)
          : _buildCreateWalletContent(),
    );
  }

  Widget _buildWalletContent(WalletProvider provider) {
    return RefreshIndicator(
      onRefresh: _fetchTransactions,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(provider),
            const SizedBox(height: 24),
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Objective',
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionsList(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B66),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Objective',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₦${provider.availableBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Objective',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(WalletProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Objective',
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = provider.transactions[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(
              transaction['type'] == 'credit' ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction['type'] == 'credit' ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            transaction['description'] ?? 'Transaction',
            style: const TextStyle(
              fontFamily: 'Objective',
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            transaction['date'] ?? '',
            style: TextStyle(
              fontFamily: 'Objective',
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          trailing: Text(
            '₦${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              fontFamily: 'Objective',
              fontWeight: FontWeight.bold,
              color: transaction['type'] == 'credit' ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateWalletContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Color(0xFF1C2B66),
          ),
          const SizedBox(height: 24),
          const Text(
            'You don\'t have a wallet yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Objective',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Create a wallet to manage your payments and transactions',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Objective',
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Wallet',
            onPressed: _createWallet,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}