import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/auth_service.dart';

class TransferScreen extends StatefulWidget {
  final UserModel user;
  const TransferScreen({super.key, required this.user});
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _accountCtrl = TextEditingController();
  final _amountCtrl  = TextEditingController();
  final _descCtrl    = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _accountCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (_accountCtrl.text.isEmpty) {
      setState(() => _error = 'Enter recipient account number'); return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount'); return;
    }
    if (amount > widget.user.balance) {
      setState(() => _error = 'Insufficient funds'); return;
    }

    setState(() { _loading = true; _error = null; });
    final result = await AuthService.transfer(
      toAccount:   _accountCtrl.text.trim().toUpperCase(),
      amount:      amount,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
    setState(() => _loading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      _showSuccess(amount, result['new_balance']);
    } else {
      setState(() => _error = result['error']);
    }
  }

  void _showSuccess(double amount, double newBal) {
    final fmt = NumberFormat.currency(symbol: '\$');
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: kSuccess.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: kSuccess, size: 36),
          ),
          const SizedBox(height: 20),
          Text('Transfer Successful!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22, fontWeight: FontWeight.w800, color: kDark,
            )),
          const SizedBox(height: 8),
          Text('${fmt.format(amount)} sent successfully.',
            style: GoogleFonts.dmSans(color: kGrey, fontSize: 15)),
          const SizedBox(height: 8),
          Text('New balance: ${fmt.format(newBal)}',
            style: GoogleFonts.dmSans(
              color: kDark, fontSize: 15, fontWeight: FontWeight.w600,
            )),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close sheet
                Navigator.pop(context, true); // back to home w/ refresh
              },
              child: const Text('Done'),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$');
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Send Money',
          style: GoogleFonts.spaceGrotesk(
            color: kDark, fontWeight: FontWeight.w800,
          )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: kYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kYellow, width: 1.5),
              ),
              child: Row(children: [
                const Icon(Icons.account_balance_wallet_rounded, color: kYellowDark, size: 20),
                const SizedBox(width: 10),
                Text('Available: ',
                  style: GoogleFonts.dmSans(color: kGrey, fontSize: 14)),
                Text(fmt.format(widget.user.balance),
                  style: GoogleFonts.spaceGrotesk(
                    color: kDark, fontWeight: FontWeight.w700, fontSize: 16,
                  )),
              ]),
            ),
            const SizedBox(height: 28),

            _Label('Recipient Account Number'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _accountCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'TBK-XXXX-XXXX-XXXX',
                prefixIcon: Icon(Icons.credit_card_rounded, color: kGrey),
              ),
            ),
            const SizedBox(height: 20),

            _Label('Amount (USD)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money_rounded, color: kGrey),
              ),
            ),
            const SizedBox(height: 20),

            _Label('Description (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Rent, groceries...',
                prefixIcon: Icon(Icons.notes_rounded, color: kGrey),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kDanger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, color: kDanger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                    style: GoogleFonts.dmSans(color: kDanger, fontSize: 13))),
                ]),
              ),
            ],

            const SizedBox(height: 36),
            SizedBox(
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _send,
                icon: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: kDark))
                    : const Icon(Icons.send_rounded, size: 20),
                label: const Text('Send Money'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: kDark,
    ));
}
