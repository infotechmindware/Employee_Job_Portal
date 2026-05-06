import 'package:flutter/material.dart';
import 'post_job_model.dart';
import 'wizard_widgets.dart';

class StepReviewPublish extends StatefulWidget {
  final PostJobModel model;
  final VoidCallback onBack;
  final VoidCallback onPublish;

  const StepReviewPublish({
    super.key,
    required this.model,
    required this.onBack,
    required this.onPublish,
  });

  @override
  State<StepReviewPublish> createState() => _StepReviewPublishState();
}

class _StepReviewPublishState extends State<StepReviewPublish> {
  bool _isPublishing = false;

  String get _salaryDisplay {
    final m = widget.model;
    if (m.salaryType == 'Negotiable') return 'Negotiable';
    if (m.salaryType == 'Fixed') {
      return m.fixedSalary.isNotEmpty
          ? '₹${m.fixedSalary} / ${m.salaryFrequency}'
          : 'Not specified';
    }
    if (m.minSalary.isNotEmpty && m.maxSalary.isNotEmpty) {
      return '₹${m.minSalary} – ₹${m.maxSalary} / ${m.salaryFrequency}';
    }
    return 'Not specified';
  }

  String get _locationDisplay {
    final parts = <String>[
      if (widget.model.city.isNotEmpty) widget.model.city,
      if (widget.model.state.isNotEmpty) widget.model.state,
      if (widget.model.country.isNotEmpty) widget.model.country,
    ];
    return parts.isNotEmpty ? parts.join(', ') : 'Not specified';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Completion indicator ──────────────────────
          _buildCompletionCard(),

          const SizedBox(height: 16),

          // ── Job Preview Card ──────────────────────────
          WizardCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimary.withOpacity(0.9),
                        const Color(0xFF7C6FFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'M',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: kPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.jobTitle.isNotEmpty
                                      ? m.jobTitle
                                      : 'Job Title',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mindware Infotech Pvt. Ltd.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (m.employmentType.isNotEmpty)
                            _previewBadge(m.employmentType,
                                Icons.work_outline_rounded),
                          if (m.workplaceType.isNotEmpty)
                            _previewBadge(
                                m.workplaceType, Icons.home_work_outlined),
                          if (m.industry.isNotEmpty)
                            _previewBadge(m.industry, Icons.category_outlined),
                        ],
                      ),
                    ],
                  ),
                ),

                // Body details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key stats grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        children: [
                          _statTile(
                            Icons.currency_rupee_rounded,
                            'Salary',
                            _salaryDisplay,
                            const Color(0xFFF0FDF4),
                            const Color(0xFF16A34A),
                          ),
                          _statTile(
                            Icons.bar_chart_rounded,
                            'Experience',
                            m.experience.isNotEmpty
                                ? m.experience
                                : 'Not specified',
                            const Color(0xFFEFF6FF),
                            kPrimary,
                          ),
                          _statTile(
                            Icons.schedule_rounded,
                            'Timings',
                            m.jobTimings.isNotEmpty
                                ? m.jobTimings
                                : 'Not specified',
                            const Color(0xFFFFF7ED),
                            const Color(0xFFD97706),
                          ),
                          _statTile(
                            Icons.groups_rounded,
                            'Openings',
                            '${m.openings} position${m.openings > 1 ? 's' : ''}',
                            const Color(0xFFF5F3FF),
                            const Color(0xFF7C3AED),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _reviewRow(
                          Icons.location_on_outlined, 'Location',
                          _locationDisplay),
                      if (m.hiringUrgency.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _reviewRow(Icons.bolt_rounded, 'Urgency',
                            m.hiringUrgency),
                      ],
                      if (m.jobLanguage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _reviewRow(Icons.language_rounded, 'Language',
                            m.jobLanguage),
                      ],
                      if (m.hasBonus) ...[
                        const SizedBox(height: 12),
                        _reviewRow(Icons.star_rounded, 'Bonus', 'Included',
                            valueColor: const Color(0xFF16A34A)),
                      ],

                      // Skills
                      if (m.skills.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Required Skills',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: m.skills
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: kPrimary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color: kPrimary.withOpacity(0.25)),
                                    ),
                                    child: Text(
                                      s,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: kPrimary,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],

                      // Benefits
                      if (m.benefits.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Benefits',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: m.benefits
                              .map((b) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color: const Color(0xFFBBF7D0)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            size: 12,
                                            color: Color(0xFF16A34A)),
                                        const SizedBox(width: 4),
                                        Text(
                                          b,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF166534),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],

                      // Description Preview
                      if (m.description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Divider(color: kBorder, height: 1),
                        const SizedBox(height: 16),
                        const Text(
                          'Job Description',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          m.description.length > 200
                              ? '${m.description.substring(0, 200)}...'
                              : m.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: kTextSub,
                            height: 1.6,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      const Divider(color: kBorder, height: 1),
                      const SizedBox(height: 16),

                      // Recruiter info
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kPrimary, Color(0xFF7C6FFF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'MR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mindware Recruiter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: kText,
                                  ),
                                ),
                                Text(
                                  'HR Manager · Mindware Infotech',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: kTextSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Text(
                              '● Active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Publish Buttons ───────────────────────────
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
                  label: 'Publish Job',
                  icon: Icons.rocket_launch_rounded,
                  isLoading: _isPublishing,
                  onTap: () async {
                    setState(() => _isPublishing = true);
                    await Future.delayed(const Duration(seconds: 2));
                    setState(() => _isPublishing = false);
                    widget.onPublish();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined,
                  size: 16, color: kTextSub),
              label: const Text(
                'Save as Draft',
                style: TextStyle(color: kTextSub, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    final m = widget.model;
    int filled = 0;
    if (m.jobTitle.isNotEmpty) filled++;
    if (m.industry.isNotEmpty) filled++;
    if (m.employmentType.isNotEmpty) filled++;
    if (m.city.isNotEmpty) filled++;
    if (m.experience.isNotEmpty) filled++;
    if (m.description.isNotEmpty) filled++;
    final total = 6;
    final pct = (filled / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: pct == 100
                ? const Color(0xFFBBF7D0)
                : kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: pct / 100,
                  strokeWidth: 5,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct == 100
                        ? const Color(0xFF16A34A)
                        : kPrimary,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: pct == 100
                      ? const Color(0xFF16A34A)
                      : kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pct == 100
                      ? 'Profile complete! Ready to publish.'
                      : 'Job profile $pct% complete',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$filled of $total key fields filled',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSub,
                  ),
                ),
              ],
            ),
          ),
          if (pct == 100)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 28,
            ),
        ],
      ),
    );
  }

  Widget _previewBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(
      IconData icon, String title, String value, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: kTextSub),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: kTextSub,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? kText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
