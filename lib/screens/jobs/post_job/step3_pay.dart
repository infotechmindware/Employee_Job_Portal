import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'post_job_model.dart';
import 'wizard_widgets.dart';

class StepPayBenefits extends StatefulWidget {
  final PostJobModel model;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepPayBenefits({
    super.key,
    required this.model,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<StepPayBenefits> createState() => _StepPayBenefitsState();
}

class _StepPayBenefitsState extends State<StepPayBenefits> {
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _fixedCtrl;
  late TextEditingController _skillInputCtrl;
  late FocusNode _skillFocusNode;

  final List<String> _frequencies = [
    'Monthly', 'Yearly', 'Weekly', 'Daily', 'Hourly',
  ];

  final List<String> _benefitOptions = [
    'Health Insurance', 'PF/ESIC', 'Paid Leave',
    'Performance Bonus', 'Travel Allowance', 'Work From Home',
    'Flexible Hours', 'Meal Allowance', 'Gratuity', 'Stock Options',
  ];

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(text: widget.model.minSalary);
    _maxCtrl = TextEditingController(text: widget.model.maxSalary);
    _fixedCtrl = TextEditingController(text: widget.model.fixedSalary);
    _skillInputCtrl = TextEditingController();
    _skillFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _fixedCtrl.dispose();
    _skillInputCtrl.dispose();
    _skillFocusNode.dispose();
    super.dispose();
  }

  void _addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isNotEmpty && !widget.model.skills.contains(trimmed)) {
      setState(() {
        widget.model.skills.add(trimmed);
        _skillInputCtrl.clear();
      });
    }
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
          // ── Salary ────────────────────────────────────
          WizardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                    Icons.payments_outlined, 'Salary & Compensation'),
                const SizedBox(height: 20),
                const WizardLabel('Salary Type'),
                const SizedBox(height: 12),
                // Salary type segmented tabs
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['Range', 'Fixed', 'Negotiable']
                        .map((type) {
                      final selected = widget.model.salaryType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                              () => widget.model.salaryType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected ? kPrimary : kTextSub,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                if (widget.model.salaryType == 'Range') ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const WizardLabel('Min Salary (₹)'),
                            const SizedBox(height: 8),
                            WizardTextField(
                              hint: '30,000',
                              controller: _minCtrl,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.currency_rupee_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const WizardLabel('Max Salary (₹)'),
                            const SizedBox(height: 8),
                            WizardTextField(
                              hint: '60,000',
                              controller: _maxCtrl,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.currency_rupee_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else if (widget.model.salaryType == 'Fixed') ...[
                  const WizardLabel('Fixed Salary (₹)'),
                  const SizedBox(height: 8),
                  WizardTextField(
                    hint: 'e.g. 45,000',
                    controller: _fixedCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.currency_rupee_rounded,
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kPrimary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: kPrimary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Salary will be discussed during the interview process.',
                            style: TextStyle(
                              fontSize: 13,
                              color: kPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (widget.model.salaryType != 'Negotiable') ...[
                  const SizedBox(height: 20),
                  const WizardLabel('Frequency'),
                  const SizedBox(height: 8),
                  WizardDropdown(
                    value: widget.model.salaryFrequency,
                    items: _frequencies,
                    onChanged: (v) => setState(
                        () => widget.model.salaryFrequency = v ?? 'Monthly'),
                  ),
                ],

                const SizedBox(height: 20),
                const WizardLabel('Performance Bonus', required: false),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildBonusToggle('Yes', true),
                    const SizedBox(width: 12),
                    _buildBonusToggle('No', false),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Benefits ──────────────────────────────────
          WizardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                    Icons.card_giftcard_rounded, 'Benefits'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _benefitOptions.map((b) {
                    final selected = widget.model.benefits.contains(b);
                    return WizardChip(
                      label: b,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          if (selected) {
                            widget.model.benefits.remove(b);
                          } else {
                            widget.model.benefits.add(b);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Skills ────────────────────────────────────
          WizardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                    Icons.psychology_outlined, 'Required Skills'),
                const SizedBox(height: 16),
                // Tag input
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillInputCtrl,
                          focusNode: _skillFocusNode,
                          style: const TextStyle(
                              fontSize: 14, color: kText),
                          decoration: const InputDecoration(
                            hintText: 'Type a skill and press Enter...',
                            hintStyle:
                                TextStyle(color: kTextHint, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8),
                          ),
                          onSubmitted: _addSkill,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _addSkill(_skillInputCtrl.text);
                          _skillFocusNode.requestFocus();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.model.skills.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.model.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: kPrimary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              skill,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(
                                  () => widget.model.skills.remove(skill)),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: kPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
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
                    widget.model.minSalary = _minCtrl.text.trim();
                    widget.model.maxSalary = _maxCtrl.text.trim();
                    widget.model.fixedSalary = _fixedCtrl.text.trim();
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

  Widget _buildBonusToggle(String label, bool value) {
    final selected = widget.model.hasBonus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => widget.model.hasBonus = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? kPrimary.withOpacity(0.08) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? kPrimary : kBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? kPrimary : kTextSub,
            ),
          ),
        ),
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
