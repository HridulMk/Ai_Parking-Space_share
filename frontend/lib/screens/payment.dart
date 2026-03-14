import 'package:flutter/material.dart';

import '../services/parking_service.dart';
import 'qr_code.dart';

class PaymentScreen extends StatefulWidget {
  final String slotName;
  final String slotId;
  final int reservationId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.slotName,
    required this.slotId,
    required this.reservationId,
    this.amount = 4.80,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPayment = 'card';
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final result = await ParkingService.payReservation(widget.reservationId);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result['success'] == true) {
        final reservation = result['reservation'] as Map<String, dynamic>;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => QRCodeScreen(
              slotName: widget.slotName,
              slotId: widget.slotId,
              reservationPk: widget.reservationId,
              reservationCode: reservation['reservation_id']?.toString() ?? 'PKG${widget.reservationId}',
              qrData: reservation['qr_code']?.toString(),
              initialStatus: reservation['status']?.toString() ?? 'reserved',
              initialFinalFee: reservation['final_fee'] == null
                  ? null
                  : double.tryParse(reservation['final_fee'].toString()),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']?.toString() ?? 'Payment failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        elevation: 0,
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reservation Summary',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Slot:', style: TextStyle(color: Colors.white70)),
                      Text(
                        widget.slotName,
                        style: TextStyle(color: Colors.cyanAccent.shade200, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stage:', style: TextStyle(color: Colors.white70)),
                      Text('Reservation fee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Booking Fee:',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rs ${widget.amount.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.tealAccent.shade100, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Method',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _PaymentMethodTile(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              selected: _selectedPayment == 'card',
              onTap: () => setState(() => _selectedPayment = 'card'),
            ),
            const SizedBox(height: 10),
            _PaymentMethodTile(
              icon: Icons.wallet,
              title: 'Digital Wallet',
              selected: _selectedPayment == 'wallet',
              onTap: () => setState(() => _selectedPayment = 'wallet'),
            ),
            const SizedBox(height: 10),
            _PaymentMethodTile(
              icon: Icons.phone_android,
              title: 'Mobile Payment',
              selected: _selectedPayment == 'mobile',
              onTap: () => setState(() => _selectedPayment = 'mobile'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent.shade700,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    )
                  : const Text('Confirm Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.cyanAccent.withValues(alpha: 0.1) : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.cyanAccent : Colors.grey.shade800,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.cyanAccent : Colors.white70, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.cyanAccent : Colors.white70,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? Colors.cyanAccent : Colors.white54,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
