import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import 'transfer_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserModel _user;
  List<Transaction> _transactions = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _loading = true);
    final bal = await AuthService.getBalance();
    final txs = await AuthService.getTransactions();
    if (mounted) {
      setState(() {
        if (bal != null) _user = _user.copyWith(balance: bal);
        _transactions = txs;
        _loading = false;
      });
    }
  }

  void _logout() async {
    await AuthService.clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      backgroundColor: kGreyLight,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: kDark,
        child: CustomScrollView(
          slivers: [
            // ─── Custom App Bar ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: kYellow,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: Text('Thragg Bank',
                    style: GoogleFonts.spaceGrotesk(
                      color: kDark, fontWeight: FontWeight.w900, fontSize: 20,
                    )),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: kDark),
                  onPressed: _logout,
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Card ────────────────────────────────────────────────
                    _BalanceCard(user: _user, fmt: fmt),
                    const SizedBox(height: 32),

                    // ─── Quick Actions ──────────────────────────────────────
                    Row(
                      children: [
                        _QuickAction(
                          icon: Icons.send_rounded,
                          label: 'Transfer',
                          onTap: () async {
                            final refresh = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TransferScreen(user: _user)),
                            );
                            if (refresh == true) _refreshData();
                          },
                        ),
                        const SizedBox(width: 16),
                        _QuickAction(icon: Icons.qr_code_scanner_rounded, label: 'Scan', onTap: () {}),
                        const SizedBox(width: 16),
                        _QuickAction(icon: Icons.more_horiz_rounded, label: 'More', onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // ─── Transactions Header ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Activity',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18, fontWeight: FontWeight.w800, color: kDark,
                            )),
                        TextButton(
                          onPressed: () {},
                          child: Text('See All', style: GoogleFonts.dmSans(color: kYellowDark, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ─── Transactions List ───────────────────────────────────────────
            if (_loading && _transactions.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: kDark)))
            else if (_transactions.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 48, color: kGrey.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No transactions yet', style: GoogleFonts.dmSans(color: kGrey)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _TransactionTile(tx: _transactions[index], fmt: fmt),
                  childCount: _transactions.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final UserModel user;
  final NumberFormat fmt;
  const _BalanceCard({required this.user, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: kDark.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance', style: GoogleFonts.dmSans(color: kWhite.withOpacity(0.6), fontSize: 14)),
          const SizedBox(height: 8),
          Text(fmt.format(user.balance),
              style: GoogleFonts.spaceGrotesk(color: kYellow, fontSize: 36, fontWeight: FontWeight.w800)),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ACCOUNT HOLDER', style: GoogleFonts.dmSans(color: kWhite.withOpacity(0.4), fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(user.fullName.toUpperCase(), style: GoogleFonts.dmSans(color: kWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ACCOUNT NUMBER', style: GoogleFonts.dmSans(color: kWhite.withOpacity(0.4), fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(user.accountNumber, style: GoogleFonts.dmSans(color: kWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              Icon(icon, color: kDark, size: 28),
              const SizedBox(height: 10),
              Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: kDark)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  final NumberFormat fmt;
  const _TransactionTile({required this.tx, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: tx.isCredit ? kSuccess.withOpacity(0.1) : kDanger.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.isCredit ? Icons.add_rounded : Icons.remove_rounded,
              color: tx.isCredit ? kSuccess : kDanger,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: kDark)),
                Text(DateFormat('MMM dd, hh:mm a').format(tx.createdAt),
                    style: GoogleFonts.dmSans(fontSize: 12, color: kGrey)),
              ],
            ),
          ),
          Text(
            (tx.isCredit ? '+' : '-') + fmt.format(tx.amount),
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              color: tx.isCredit ? kSuccess : kDark,
            ),
          ),
        ],
      ),
    );
  }
}
