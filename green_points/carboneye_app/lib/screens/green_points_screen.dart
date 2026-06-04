import 'package:flutter/material.dart';
import '../services/constants.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import 'redeem_screen.dart';
import 'leaderboard_screen.dart';
import 'user_manual_screen.dart';
import 'faq_screen.dart';
import 'impact_screen.dart';

class GreenPointsScreen extends StatefulWidget {
  final String email;
  const GreenPointsScreen({super.key, required this.email});

  @override
  State<GreenPointsScreen> createState() => _GreenPointsScreenState();
}

class _GreenPointsScreenState extends State<GreenPointsScreen>
    with SingleTickerProviderStateMixin {
  UserModel? _user;
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await ApiService.getUser(widget.email);
    final transactions = await ApiService.getTransactions(widget.email);
    if (mounted) {
      setState(() {
        _user = user;
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        title: const Text(
          'Green Points',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryGreen),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryGreen,
          unselectedLabelColor: textGrey,
          indicatorColor: primaryGreen,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: primaryGreen,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboard(),
                  _buildHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPointsCard(),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildRedeemSection(),
          const SizedBox(height: 16),
          _buildHowItWorks(),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGreen, lightBlue],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Points',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '0.5 pts/gram',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_user?.totalPoints ?? 0}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'points',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                _user?.name ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.badge, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                _user?.studentId ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalWeight = _transactions.fold(
        0.0, (sum, t) => sum + t.weightGrams);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.recycling,
            label: 'Total Recycled',
            value: '${totalWeight.toStringAsFixed(0)}g',
            color: primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.history,
            label: 'Visits',
            value: '${_transactions.length}',
            color: lightBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.stars,
            label: 'Points Earned',
            value: '${_user?.totalPoints ?? 0}',
            color: const Color(0xFFFF8F00),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Redeem Points',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildVoucherTile(
            name: 'NSBM Gift Shop',
            points: 500,
            value: 'Rs. 100',
            icon: Icons.store,
            color: primaryGreen,
          ),
          const Divider(),
          _buildVoucherTile(
            name: 'P&S',
            points: 1000,
            value: 'Rs. 200',
            icon: Icons.shopping_bag,
            color: lightBlue,
          ),
          const Divider(),
          _buildVoucherTile(
            name: 'Finagle',
            points: 750,
            value: 'Rs. 150',
            icon: Icons.coffee,
            color: const Color(0xFF795548),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherTile({
    required String name,
    required int points,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final hasEnough = (_user?.totalPoints ?? 0) >= points;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textDark,
                  ),
                ),
                Text(
                  '$points pts → $value discount',
                  style: const TextStyle(fontSize: 12, color: textGrey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: hasEnough
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RedeemScreen(
                          email: widget.email,
                          voucherType: name.toLowerCase().replaceAll(' ', '_').replaceAll('&', ''),
                          voucherName: name,
                          pointsRequired: points,
                          value: value,
                        ),
                      ),
                    ).then((_) => _loadData())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Redeem', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Tap your NFC card on the bin'),
          _buildStep('2', 'Place plastic waste on the tray'),
          _buildStep('3', 'Camera detects & weighs the plastic'),
          _buildStep('4', 'Earn 0.5 points per gram'),
          _buildStep('5', 'Redeem points for vouchers'),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'More',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickLinkTile(
                  icon: Icons.emoji_events,
                  label: 'Leaderboard',
                  color: const Color(0xFFFF8F00),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeaderboardScreen(email: widget.email),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickLinkTile(
                  icon: Icons.eco,
                  label: 'My Impact',
                  color: primaryGreen,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImpactScreen(email: widget.email),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickLinkTile(
                  icon: Icons.menu_book,
                  label: 'User Manual',
                  color: lightBlue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserManualScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickLinkTile(
                  icon: Icons.help_outline,
                  label: 'FAQ',
                  color: const Color(0xFF7B1FA2),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FaqScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 13, color: textDark)),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.recycling, size: 64, color: accentGreen),
            SizedBox(height: 16),
            Text(
              'No recycling history yet',
              style: TextStyle(fontSize: 16, color: textGrey),
            ),
            SizedBox(height: 8),
            Text(
              'Start recycling to earn points!',
              style: TextStyle(fontSize: 14, color: textGrey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final t = _transactions[index];
        final date = DateTime.tryParse(t.timestamp);
        final dateStr = date != null
            ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
            : t.timestamp;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.recycling, color: primaryGreen, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.binId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 12, color: textGrey),
                    ),
                    Text(
                      '${t.weightGrams.toStringAsFixed(0)}g recycled',
                      style: const TextStyle(fontSize: 12, color: textGrey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${t.pointsEarned.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const Text(
                    'points',
                    style: TextStyle(fontSize: 11, color: textGrey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}