import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class DocumentVerificationScreen extends StatelessWidget {
  const DocumentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),
            _buildStatusHeader(),
            const SizedBox(height: 32),
            _buildRequiredDocuments(),
            const SizedBox(height: 32),
            _buildUploadedDocuments(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verification Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 14, color: Color(0xFF854D0E)),
                SizedBox(width: 8),
                Text('Pending Review', style: TextStyle(color: Color(0xFF854D0E), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your KYC documents are under review. You will be notified once the review is complete.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocuments() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Required Documents', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          _buildBulletItem('Business License / Registration Certificate'),
          _buildBulletItem('Tax ID / GST Certificate'),
          _buildBulletItem('Address Proof (Utility Bill / Rent Agreement)'),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.dot, size: 20, color: Color(0xFF2563EB)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedDocuments(bool isDesktop) {
    final docs = [
      {'type': 'Business License', 'file': 'image (3).png', 'date': 'Apr 29, 2026'},
      {'type': 'Tax Id', 'file': 'a415c429-ff74-4584-a98b-2720d5f739a2.jpg', 'date': 'Apr 29, 2026'},
      {'type': 'Address Proof', 'file': 'image (2).png', 'date': 'Apr 29, 2026'},
      {'type': 'Other', 'file': 'WhatsApp Image 2026-04-29 at 12.42.21 PM.jpeg', 'date': 'Apr 29, 2026'},
      {'type': 'Business License', 'file': 'a415c429-ff74-4584-a98b-2720d5f739a2.jpg', 'date': 'Apr 29, 2026'},
      {'type': 'Tax Id', 'file': 'a415c429-ff74-4584-a98b-2720d5f739a2.jpg', 'date': 'Apr 29, 2026'},
      {'type': 'Address Proof', 'file': 'c415c429-ff74-4584-a98b-2720d5f739a2.jpg', 'date': 'Apr 29, 2026'},
      {'type': 'Other', 'file': 'WhatsApp Image 2026-04-29 at 12.42.21 PM.jpeg', 'date': 'Apr 29, 2026'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Uploaded Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 2 : 1,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            mainAxisExtent: 140,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) => _buildDocCard(docs[index]),
        ),
      ],
    );
  }

  Widget _buildDocCard(Map<String, String> doc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  doc['type']!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View', style: TextStyle(fontSize: 13, color: Color(0xFF6366F1))),
              ),
            ],
          ),
          Text(doc['file']!, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('Uploaded: ${doc['date']}', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(4)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 12, color: Color(0xFF854D0E)),
                SizedBox(width: 4),
                Text('Pending', style: TextStyle(color: Color(0xFF854D0E), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
