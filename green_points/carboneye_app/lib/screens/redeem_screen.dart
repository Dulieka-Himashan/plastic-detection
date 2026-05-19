import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/constants.dart';
import '../services/api_service.dart';

class RedeemScreen extends StatefulWidget {
  final String email;
  final String voucherType;
  final String voucherName;
  final int pointsRequired;
  final String value;

  const RedeemScreen({
    super.key,
    required this.email,
    required this.voucherType,
    required this.voucherName,
    required this.pointsRequired,
    required this.value,
  });

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  bool _isLoading = false;
  String? _voucherCode;
  String? _error;
  bool _redeemed = false;

  Future<void> _redeem() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ApiService.redeemPoints(
      email: widget.email,
      voucherType: widget.voucherType,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result != null && result['voucher_code'] != null) {
        setState(() {
          _voucherCode = result['voucher_code'];
          _redeemed = true;
        });
      } else {
        setState(() {
          _error = result?['error'] ?? 'Redemption failed';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        title: const Text(
          'Redeem Voucher',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryGreen),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _redeemed ? _buildSuccess() : _buildConfirm(),
      ),
    );
  }

  Widget _buildConfirm() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.card_giftcard, color: primaryGreen, size: 52),
        ),
        const SizedBox(height: 24),
        Text(
          widget.voucherName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
        const Text(
          'discount voucher',
          style: TextStyle(fontSize: 14, color: textGrey),
        ),
        const SizedBox(height: 32),
        Container(
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
            children: [
              _buildDetailRow('Voucher', widget.voucherName),
              const Divider(),
              _buildDetailRow('Value', widget.value),
              const Divider(),
              _buildDetailRow('Points Required', '${widget.pointsRequired} pts'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _redeem,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Confirm Redemption (${widget.pointsRequired} pts)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: primaryGreen, size: 48),
        ),
        const SizedBox(height: 16),
        const Text(
          'Voucher Redeemed!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Show this QR code at ${widget.voucherName}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: textGrey),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              QrImageView(
                data: _voucherCode!,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                _voucherCode!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.value} at ${widget.voucherName}',
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textGrey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }
}