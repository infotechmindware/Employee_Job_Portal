import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';

class DocumentVerificationScreen extends ConsumerWidget {
  const DocumentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop, context),
            const SizedBox(height: 32),
            _buildStatusHeader(context),
            const SizedBox(height: 32),
            _buildRequiredDocuments(context),
            const SizedBox(height: 32),
            _buildUploadedDocuments(context, isDesktop, profile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents Verification',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Verify your identity and business credentials',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Verification Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
              ),
              const Spacer(),
              const Icon(LucideIcons.shieldCheck, color: Color(0xFF6366F1), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF78350F).withOpacity(0.2) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFFF59E0B).withOpacity(0.3) : const Color(0xFFFDE68A).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 14, color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309)),
                const SizedBox(width: 8),
                Text(
                  'Pending Review',
                  style: TextStyle(color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309), fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your KYC documents are currently being reviewed by our compliance team. This process usually takes 2-3 business days.',
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocuments(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [AppColors.primary.withOpacity(0.05), AppColors.primary.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Documents',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          _buildBulletItem('Business License / Registration Certificate', LucideIcons.building, context),
          _buildBulletItem('Tax ID / GST Certificate', LucideIcons.fileText, context),
          _buildBulletItem('Address Proof (Utility Bill / Rent Agreement)', LucideIcons.mapPin, context),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text, IconData icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedDocuments(BuildContext context, bool isDesktop, ProfileState profile) {
    final List<Map<String, dynamic>> docs = [];
    if (profile.businessLicense != null) {
      docs.add({'type': 'Business License', 'file': profile.businessLicense, 'name': 'license.jpg'});
    }
    if (profile.gstCertificate != null) {
      docs.add({'type': 'GST Certificate', 'file': profile.gstCertificate, 'name': 'gst_cert.jpg'});
    }
    if (profile.additionalProof != null) {
      docs.add({'type': 'Additional Proof', 'file': profile.additionalProof, 'name': 'additional_proof.jpg'});
    }

    if (docs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Uploaded Documents',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
        ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(40),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Icon(LucideIcons.fileX, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(
                  'No documents uploaded yet',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Documents',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 2 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 180,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) => _buildDocCard(context, docs[index]),
        ),
      ],
    );
  }

  Widget _buildDocCard(BuildContext context, Map<String, dynamic> doc) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['type']!,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc['name']!,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _viewDocument(context, doc['file'] as File, doc['type'] as String),
                  icon: Icon(LucideIcons.eye, size: 18, color: AppColors.primary),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const Spacer(),
          Divider(height: 24, color: theme.dividerColor.withOpacity(0.05)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploaded: Just now',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? const Color(0xFF78350F).withOpacity(0.2) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.brightness == Brightness.dark ? const Color(0xFFF59E0B).withOpacity(0.3) : const Color(0xFFFDE68A).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.clock, size: 10, color: theme.brightness == Brightness.dark ? const Color(0xFFF59E0B) : const Color(0xFFB45309)),
                    const SizedBox(width: 4),
                    Text(
                      'Pending',
                      style: TextStyle(color: theme.brightness == Brightness.dark ? const Color(0xFFF59E0B) : const Color(0xFFB45309), fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _viewDocument(BuildContext context, File file, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, color: Colors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        file,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Close Preview', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
