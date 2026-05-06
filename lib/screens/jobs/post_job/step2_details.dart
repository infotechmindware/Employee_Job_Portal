import 'package:flutter/material.dart';
import 'post_job_model.dart';
import 'wizard_widgets.dart';

class StepJobDetails extends StatefulWidget {
  final PostJobModel model;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepJobDetails({
    super.key,
    required this.model,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<StepJobDetails> createState() => _StepJobDetailsState();
}

class _StepJobDetailsState extends State<StepJobDetails> {
  late TextEditingController _jobTimingsCtrl;
  late TextEditingController _interviewTimingsCtrl;

  final List<String> _languages = [
    'English', 'Hindi', 'Marathi', 'Tamil', 'Telugu',
    'Bengali', 'Gujarati', 'Kannada', 'Malayalam',
  ];

  final List<String> _experienceLevels = [
    'Fresher', '0–1 yr', '1–3 yrs', '3–5 yrs', '5–8 yrs', '8+ yrs',
  ];

  final List<String> _urgencyOptions = [
    'Immediate', 'Within 1 Week', 'Within 2 Weeks',
    'Within a Month', 'No Urgency',
  ];

  @override
  void initState() {
    super.initState();
    _jobTimingsCtrl = TextEditingController(text: widget.model.jobTimings);
    _interviewTimingsCtrl = TextEditingController(text: widget.model.interviewTimings);
  }

  @override
  void dispose() {
    _jobTimingsCtrl.dispose();
    _interviewTimingsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Language ─────────────────────────────────
          WizardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.language_rounded, 'Language & Experience'),
                const SizedBox(height: 20),
                const WizardLabel('Job Language'),
                const SizedBox(height: 8),
                WizardDropdown(
                  value: widget.model.jobLanguage,
                  items: _languages,
                  hint: 'Select language',
                  onChanged: (v) =>
                      setState(() => widget.model.jobLanguage = v ?? 'English'),
                ),
                const SizedBox(height: 24),
                const WizardLabel('Experience Required'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _experienceLevels.map((exp) {
                    return WizardChip(
                      label: exp,
                      selected: widget.model.experience == exp,
                      onTap: () =>
                          setState(() => widget.model.experience = exp),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Urgency ───────────────────────────────────
          WizardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.bolt_rounded, 'Hiring Urgency'),
                const SizedBox(height: 16),
                ...List.generate(_urgencyOptions.length, (i) {
                  final option = _urgencyOptions[i];
                  final selected = widget.model.hiringUrgency == option;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => widget.model.hiringUrgency = option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? kPrimary.withOpacity(0.07)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? kPrimary : kBorder,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  selected ? kPrimary : Colors.transparent,
                              border: Border.all(
                                color: selected ? kPrimary : kBorder,
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? const Icon(Icons.check_rounded,
                                    size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected ? kPrimary : kText,
                            ),
                          ),
                          const Spacer(),
                          if (i == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Text(
                                'Hot',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Timings ───────────────────────────────────
          WizardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Icons.schedule_rounded, 'Timings'),
                const SizedBox(height: 20),
                const WizardLabel('Job Timings'),
                const SizedBox(height: 8),
                WizardTextField(
                  hint: 'e.g. 9:00 AM – 6:00 PM',
                  controller: _jobTimingsCtrl,
                  prefixIcon: Icons.access_time_rounded,
                ),
                const SizedBox(height: 16),
                const WizardLabel('Interview Timings'),
                const SizedBox(height: 8),
                WizardTextField(
                  hint: 'e.g. Mon-Fri, 10 AM – 5 PM',
                  controller: _interviewTimingsCtrl,
                  prefixIcon: Icons.event_available_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Buttons ───────────────────────────────────
          Row(
            children: [
              Expanded(
                flex: 2,
                child: WizardBackButton(onTap: widget.onBack),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: WizardPrimaryButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () {
                    widget.model.jobTimings = _jobTimingsCtrl.text.trim();
                    widget.model.interviewTimings =
                        _interviewTimingsCtrl.text.trim();
                    widget.onContinue();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: kPrimary),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
      ],
    );
  }
}
