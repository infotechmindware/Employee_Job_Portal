import 'package:flutter/material.dart';
import 'post_job_model.dart';
import 'wizard_widgets.dart';
import 'step1_basics.dart';
import 'step2_details.dart';
import 'step3_pay.dart';
import 'step4_description.dart';
import 'step5_review.dart';

class PostJobWizard extends StatefulWidget {
  const PostJobWizard({super.key});

  @override
  State<PostJobWizard> createState() => _PostJobWizardState();
}

class _PostJobWizardState extends State<PostJobWizard>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final PostJobModel _model = PostJobModel();
  late final PageController _pageController;
  late AnimationController _animController;

  final List<_StepMeta> _steps = const [
    _StepMeta(label: 'Basics', icon: Icons.work_outline_rounded),
    _StepMeta(label: 'Details', icon: Icons.tune_rounded),
    _StepMeta(label: 'Pay', icon: Icons.payments_outlined),
    _StepMeta(label: 'Info', icon: Icons.description_outlined),
    _StepMeta(label: 'Review', icon: Icons.rocket_launch_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _steps.length) return;
    _animController.reverse().then((_) {
      setState(() => _currentStep = step);
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _animController.forward();
    });
  }

  void _onPublish() {
    Navigator.of(context).pop(); // Close wizard
    _showSuccessBottomSheet();
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuccessSheet(
        jobTitle: _model.jobTitle.isNotEmpty ? _model.jobTitle : 'New Job',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // ── Fixed Top Section ────────────────────────
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              color: kSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAppBar(),
                _buildStepIndicator(),
              ],
            ),
          ),

          // ── Scrollable Content ───────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StepJobBasics(
                  model: _model,
                  onContinue: () => _goToStep(1),
                ),
                StepJobDetails(
                  model: _model,
                  onContinue: () => _goToStep(2),
                  onBack: () => _goToStep(0),
                ),
                StepPayBenefits(
                  model: _model,
                  onContinue: () => _goToStep(3),
                  onBack: () => _goToStep(1),
                ),
                StepJobDescription(
                  model: _model,
                  onContinue: () => _goToStep(4),
                  onBack: () => _goToStep(2),
                ),
                StepReviewPublish(
                  model: _model,
                  onBack: () => _goToStep(3),
                  onPublish: _onPublish,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: kText, size: 22),
            onPressed: () => _showExitDialog(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Text(
            'Step ${_currentStep + 1} of ${_steps.length} • ${_steps[_currentStep].label}',
            style: const TextStyle(
              fontSize: 14,
              color: kText,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Draft saved successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Save Draft',
              style: TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Connecting Line
          Positioned(
            top: 17,
            left: 20,
            right: 20,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Active Progress Line
          Positioned(
            top: 17,
            left: 20,
            right: 20,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final progressWidth = (width / (_steps.length - 1)) * _currentStep;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: progressWidth,
                    height: 2,
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
          // Step Icons and Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_steps.length, (i) {
              final isCompleted = i < _currentStep;
              final isActive = i == _currentStep;

              return GestureDetector(
                onTap: i <= _currentStep ? () => _goToStep(i) : null,
                child: SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isActive || isCompleted ? kPrimary : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive || isCompleted ? kPrimary : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                              : Icon(
                                  _steps[i].icon,
                                  size: 16,
                                  color: isActive || isCompleted ? Colors.white : const Color(0xFF64748B),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _steps[i].label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                          color: isActive ? kPrimary : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Discard Job Post?',
          style: TextStyle(fontWeight: FontWeight.w800, color: kText),
        ),
        content: const Text(
          'Your progress will be lost. Do you want to save as draft or discard?',
          style: TextStyle(color: kTextSub, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: kTextSub)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Discard',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Draft saved!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Draft',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Step metadata helper
// ─────────────────────────────────────────────────
class _StepMeta {
  final String label;
  final IconData icon;
  const _StepMeta({required this.label, required this.icon});
}

// ─────────────────────────────────────────────────
//  Success bottom sheet
// ─────────────────────────────────────────────────
class _SuccessSheet extends StatelessWidget {
  final String jobTitle;
  const _SuccessSheet({required this.jobTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, Color(0xFF7C6FFF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '🎉 Job Published!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: kText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"$jobTitle" is now live and visible to candidates.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: kTextSub,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Applications will appear in your dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: kTextSub.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: kBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('View Jobs',
                      style: TextStyle(color: kText)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Dashboard',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
