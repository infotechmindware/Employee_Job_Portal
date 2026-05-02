import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import 'widgets/auth_layout.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).forgotPassword(email);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset link sent! Please check your email.')),
        );
      }
    } else {
      if (mounted) {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to send reset link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      infoPanel: _buildInfoPanel(),
      formPanel: _buildFormPanel(context),
      infoOnLeft: false,
    );
  }

  Widget _buildInfoPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Reset Your\nAccess Securely\n& Quickly.',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "We'll send you a secure, time-limited link to reset\nyour password. Your account stays fully protected\nthroughout the process.",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        _buildInfoCard(
          LucideIcons.lock,
          'Encrypted Reset Links',
          'Every link is uniquely generated with 256-bit encryption and tied to your account only.',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          LucideIcons.clock,
          'Expires Automatically',
          'Reset links expire after 15 minutes to prevent unauthorized use, even if forwarded.',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          LucideIcons.shieldCheck,
          'No Account Disruption',
          'Your account remains active and all your data stays safe during the reset process.',
        ),
        const SizedBox(height: 48),
        const Text(
          'HOW IT WORKS',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 24),
        _buildStepItem('1', 'Enter your registered email address'),
        const SizedBox(height: 16),
        _buildStepItem('2', 'Check your inbox for the reset link'),
        const SizedBox(height: 16),
        _buildStepItem('3', 'Click the link and set a new password'),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(color: Color(0xFF334155), fontSize: 15)),
      ],
    );
  }

  Widget _buildFormPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mindware InfoTech', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Connecting Talent with Opportunities', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 64),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.key, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCOUNT RECOVERY',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                ),
                Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "No worries! Enter your registered email address below\nand we'll send you a secure link to reset your password.",
          style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 48),
        
        // Step Indicator
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 350) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepIndicator('1', 'Enter Email', true),
                  const SizedBox(height: 8),
                  _buildStepIndicator('2', 'Check Inbox', false),
                  const SizedBox(height: 8),
                  _buildStepIndicator('3', 'Reset Password', false),
                ],
              );
            }
            return Row(
              children: [
                _buildStepIndicator('1', 'Enter Email', true),
                Expanded(child: Container(height: 2, color: Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 4))),
                _buildStepIndicator('2', 'Check Inbox', false),
                Expanded(child: Container(height: 2, color: Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 4))),
                _buildStepIndicator('3', 'Reset Password', false),
              ],
            );
          }
        ),
        const SizedBox(height: 48),
        
        const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'admin@company.com',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(LucideIcons.mail, size: 18, color: Colors.grey),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Green info box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.lock, color: Color(0xFF16A34A), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reset link is encrypted & expires in 15 minutes',
                  style: TextStyle(color: Color(0xFF16A34A), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: ref.watch(authProvider).isLoading ? null : _handleResetPassword,
            icon: ref.watch(authProvider).isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(LucideIcons.mail, size: 18),
            label: Text(
              ref.watch(authProvider).isLoading ? 'Sending...' : 'Send Reset Link',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.arrowLeft, size: 16, color: Colors.grey),
            label: const Text('Back to Login', style: TextStyle(color: Colors.grey)),
          ),
        ),
        
        const SizedBox(height: 64),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          runSpacing: 8,
          children: [
            Text('© 2025 Mindware InfoTech', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            Text('Secure · Encrypted · Protected', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator(String num, String label, bool active) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            num,
            style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black87 : Colors.grey,
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
