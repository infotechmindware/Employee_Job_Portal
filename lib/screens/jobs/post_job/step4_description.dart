import 'package:flutter/material.dart';
import 'post_job_model.dart';
import 'wizard_widgets.dart';

class StepJobDescription extends StatefulWidget {
  final PostJobModel model;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepJobDescription({
    super.key,
    required this.model,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<StepJobDescription> createState() => _StepJobDescriptionState();
}

class _StepJobDescriptionState extends State<StepJobDescription> {
  late TextEditingController _descCtrl;
  late TextEditingController _qualInputCtrl;
  late FocusNode _qualFocusNode;
  bool _isGenerating = false;

  final List<String> _aiTemplates = [
    'We are looking for a talented and experienced {title} to join our dynamic team. The ideal candidate should have strong technical skills and a passion for innovation.',
    'Join our growing team as a {title}. You will play a key role in designing, developing, and maintaining our core systems while collaborating with cross-functional teams.',
    'We are hiring a {title} who is driven, creative, and passionate about delivering high-quality work. You will work closely with product and engineering teams.',
  ];

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.model.description);
    _qualInputCtrl = TextEditingController();
    _qualFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qualInputCtrl.dispose();
    _qualFocusNode.dispose();
    super.dispose();
  }

  void _generateDescription() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    final template = _aiTemplates[DateTime.now().second % _aiTemplates.length];
    final title = widget.model.jobTitle.isNotEmpty
        ? widget.model.jobTitle
        : 'Professional';

    final generated = '''${template.replaceAll('{title}', title)}

Key Responsibilities:
• Design and develop scalable, high-quality solutions
• Collaborate with cross-functional teams to define and ship new features
• Write clean, maintainable, and well-documented code
• Participate in code reviews and technical discussions
• Troubleshoot and resolve technical issues efficiently

Requirements:
• ${widget.model.experience.isNotEmpty ? widget.model.experience : '2–4 years'} of relevant experience
• Strong problem-solving and communication skills
• Ability to work independently and in a team environment
• ${widget.model.skills.isNotEmpty ? widget.model.skills.take(3).join(', ') : 'Relevant technical skills'} required''';

    setState(() {
      _descCtrl.text = generated;
      _isGenerating = false;
    });
  }

  void _addQualification(String qual) {
    final trimmed = qual.trim();
    if (trimmed.isNotEmpty && !widget.model.qualifications.contains(trimmed)) {
      setState(() {
        widget.model.qualifications.add(trimmed);
        _qualInputCtrl.clear();
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
          // ── AI Generate Banner ────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimary.withOpacity(0.85),
                  const Color(0xFF7C6FFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 22, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI-Powered Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Auto-generate a professional job description',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isGenerating ? null : _generateDescription,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kPrimary,
                            ),
                          )
                        : const Text(
                            'Generate',
                            style: TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Description Editor ────────────────────────
          WizardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                    Icons.description_outlined, 'Job Description'),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini toolbar
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                          border: Border(
                            bottom: BorderSide(
                                color: kBorder, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            _toolbarBtn(Icons.format_bold, () {}),
                            _toolbarBtn(Icons.format_italic, () {}),
                            _toolbarBtn(Icons.format_list_bulleted, () {}),
                            _toolbarBtn(Icons.format_list_numbered, () {}),
                            const Spacer(),
                            Text(
                              '${_descCtrl.text.length} chars',
                              style: const TextStyle(
                                  fontSize: 11, color: kTextSub),
                            ),
                          ],
                        ),
                      ),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 12,
                        style: const TextStyle(
                          fontSize: 14,
                          color: kText,
                          height: 1.6,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText:
                              'Write a compelling job description...\n\nInclude:\n• Role overview\n• Key responsibilities\n• Requirements & qualifications',
                          hintStyle: TextStyle(
                              color: kTextHint, fontSize: 13, height: 1.6),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Qualifications ────────────────────────────
          WizardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                    Icons.school_outlined, 'Qualifications'),
                const SizedBox(height: 16),
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
                          controller: _qualInputCtrl,
                          focusNode: _qualFocusNode,
                          style: const TextStyle(
                              fontSize: 14, color: kText),
                          decoration: const InputDecoration(
                            hintText:
                                'e.g. B.E./B.Tech, MBA, BCA...',
                            hintStyle: TextStyle(
                                color: kTextHint, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 8),
                          ),
                          onSubmitted: _addQualification,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _addQualification(_qualInputCtrl.text);
                          _qualFocusNode.requestFocus();
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
                if (widget.model.qualifications.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.model.qualifications.map((q) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: kPrimary.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_outlined,
                                size: 13, color: kPrimary),
                            const SizedBox(width: 5),
                            Text(
                              q,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() =>
                                  widget.model.qualifications.remove(q)),
                              child: const Icon(Icons.close_rounded,
                                  size: 14, color: kPrimary),
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
                  label: 'Preview',
                  icon: Icons.visibility_outlined,
                  onTap: () {
                    widget.model.description = _descCtrl.text.trim();
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

  Widget _toolbarBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: Icon(icon, size: 15, color: kTextSub),
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
