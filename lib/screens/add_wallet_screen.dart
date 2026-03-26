import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/wallet.dart';
import '../widgets/inset_grouped_list.dart';
import '../providers/transaction_provider.dart';

class AddWalletScreen extends StatefulWidget {
  final Wallet? wallet;

  const AddWalletScreen({super.key, this.wallet});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'Bank';
  int _selectedColor = 0xFF1F2937; // Default dark blue/gray
  bool _isLoading = false;

  final List<String> _walletTypes = ['Bank', 'E-Wallet', 'Cash'];
  
  final List<int> _colors = [
    0xFF1F2937, // Charcoal
    0xFF2563EB, // Blue
    0xFF059669, // Green
    0xFFDC2626, // Red
    0xFFD97706, // Orange
    0xFF7C3AED, // Purple
    0xFF475569, // Slate
  ];

  @override
  void initState() {
    super.initState();
    if (widget.wallet != null) {
      _nameController.text = widget.wallet!.name;
      _selectedType = widget.wallet!.type;
      _selectedColor = widget.wallet!.colorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      final provider = Provider.of<WalletProvider>(context, listen: false);

      if (widget.wallet != null) {
        final updatedWallet = widget.wallet!.copyWith(
          name: _nameController.text.trim(),
          type: _selectedType,
          colorValue: _selectedColor,
        );
        await provider.updateWallet(updatedWallet);
      } else {
        final newWallet = Wallet(
          name: _nameController.text.trim(),
          type: _selectedType,
          colorValue: _selectedColor,
        );
        await provider.addWallet(newWallet);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _deleteWallet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card?'),
        content: const Text('Are you sure? Associated transactions will NOT be deleted, but they will be unassigned from this card.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted && widget.wallet != null) {
      setState(() { _isLoading = true; });
      try {
        await Provider.of<WalletProvider>(context, listen: false).deleteWallet(widget.wallet!.id!);
        // Refresh transactions to reflect orphaned data smoothly
        await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.wallet != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Card' : 'Add Card'),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    InsetGroupedList(
                      headerText: 'CARD DETAILS',
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Wallet Name',
                              hintText: 'e.g., Chase Sapphire, PayPal...',
                              border: InputBorder.none,
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const Divider(height: 1, indent: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: InputBorder.none,
                            ),
                            items: _walletTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) => setState(() => _selectedType = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    InsetGroupedList(
                      headerText: 'CARD COLOR',
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _colors.map((color) {
                              final isSelected = _selectedColor == color;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = color),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Color(color),
                                    shape: BoxShape.circle,
                                    border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
                                  ),
                                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _saveWallet,
                        child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(isEditing ? 'Save Changes' : 'Add Card', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isLoading ? null : _deleteWallet,
                          child: const Text('Delete Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
