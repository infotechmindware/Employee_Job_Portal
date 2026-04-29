import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_colors.dart';

class ProfileStepperScreen extends ConsumerStatefulWidget {
  const ProfileStepperScreen({super.key});

  @override
  ConsumerState<ProfileStepperScreen> createState() => _ProfileStepperScreenState();
}

class _ProfileStepperScreenState extends ConsumerState<ProfileStepperScreen> {
  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final currentStep = navState.profileStep;
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            _buildVerificationStatus(),
            const SizedBox(height: 32),
            _buildStepperProgress(currentStep, isDesktop),
            const SizedBox(height: 32),
            _buildStepContent(currentStep, isDesktop),
            const SizedBox(height: 32),
            _buildActionButtons(currentStep, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.checkCircle, size: 20, color: Color(0xFF16A34A)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thank you for completing your profile. Your account is under review.',
              style: TextStyle(color: Color(0xFF15803D), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperProgress(int currentStep, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepItem(1, 'Basic Info', currentStep >= 0, currentStep == 0, isDesktop),
            _buildStepLine(currentStep >= 1, isDesktop),
            _buildStepItem(2, 'Address', currentStep >= 1, currentStep == 1, isDesktop),
            _buildStepLine(currentStep >= 2, isDesktop),
            _buildStepItem(3, 'Documents', currentStep >= 2, currentStep == 2, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int number, String label, bool isCompleted, bool isActive, bool isDesktop) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF6366F1) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isCompleted ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), width: 2),
          ),
          child: Center(
            child: isCompleted && !isActive
                ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                : Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.white : const Color(0xFF94A3B8),
                    ),
                  ),
          ),
        ),
        if (isDesktop || isActive) ...[
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
              color: isActive || isCompleted ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted, bool isDesktop) {
    return Container(
      width: isDesktop ? 40 : 20,
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 8),
      color: isCompleted ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildStepContent(int step, bool isDesktop) {
    switch (step) {
      case 0:
        return _buildBasicInfoStep(isDesktop);
      case 1:
        return _buildAddressStep(isDesktop);
      case 2:
        return _buildDocumentsStep(isDesktop);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(LucideIcons.building, 'Company Information'),
          const SizedBox(height: 32),
          _buildResponsiveRow(
            isDesktop,
            [
              _buildTextField('Company Name *', 'Mindware info tech sd'),
              _buildTextField('Website', 'https://chatgpt.com/c/69f1b735-5a1c-8321-aaad-7dc'),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Company Description', 'hello sanjay', maxLines: 4),
          const SizedBox(height: 24),
          _buildResponsiveRow(
            isDesktop,
            [
              _buildDropdown('Company Type *', 'Select Company Type'),
              _buildDropdown('Industry Type *', 'Finance'),
            ],
          ),
          const SizedBox(height: 24),
          _buildResponsiveRow(
            isDesktop,
            [
              _buildDropdown('Company Size *', '11-50 employees'),
              _buildFileUploadField('Company Logo'),
            ],
          ),
          const SizedBox(height: 48),
          _buildStepHeader(LucideIcons.mail, 'Contact Information'),
          const SizedBox(height: 32),
          _buildResponsiveRow(
            isDesktop,
            [
              _buildTextField('Email *', 'suject1@gmail.com'),
              _buildTextField('Mobile Number *', '9334748028'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(LucideIcons.mapPin, 'Address'),
          const SizedBox(height: 32),
          _buildDropdown('Country *', 'India'),
          const SizedBox(height: 24),
          _buildResponsiveRow(
            isDesktop,
            [
              _buildTextField('State *', 'Jharkhand'),
              _buildTextField('City *', 'Bokaro'),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Postal Code *', '825315'),
          const SizedBox(height: 24),
          _buildTextField('Street Address *', 'Village: Karri-khurd, Post: Konar Dam, Dist: Bokaro', maxLines: 3),
          const SizedBox(height: 32),
          _buildMapPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(LucideIcons.fileCheck, 'Document Verification'),
          const SizedBox(height: 32),
          _buildResponsiveRow(
            isDesktop,
            [
              _buildDocumentUploadCard('Business License *', 'Choose file or drag here'),
              Column(
                children: [
                  _buildTextField('Tax ID / GST Certificate *', 'GST Number / Tax ID'),
                  const SizedBox(height: 12),
                  _buildFileUploadSimple('Choose file or drag here'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildResponsiveRow(
            isDesktop,
            [
              _buildDocumentUploadCard('Address Proof *', 'Choose file or drag here'),
              _buildDocumentUploadCard('Additional Documents', 'Choose file or drag here'),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Checkbox(value: true, onChanged: (v) {}),
              const Expanded(
                child: Text(
                  'I agree to the Terms and Conditions and Privacy Policy *',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(bool isDesktop, List<Widget> children) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 24), child: c))).toList(),
      );
    }
    return Column(
      children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 24), child: c)).toList(),
    );
  }

  Widget _buildStepHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6366F1)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 16),
              items: [selected].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))))).toList(),
              onChanged: (v) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Text('Choose File', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ),
            const SizedBox(width: 12),
            const Text('No file chosen', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.fileUp, size: 32, color: Color(0xFF6366F1)),
              const SizedBox(height: 8),
              Text(hint, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const Text('Max 2 MB', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSimple(String hint) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.upload, size: 14, color: Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Text(hint, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.map, size: 48, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text('Interactive Map Placeholder', style: TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(int currentStep, bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              if (currentStep > 0)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ElevatedButton(
                      onPressed: () => ref.read(navigationProvider.notifier).setProfileStep(currentStep - 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF475569),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (currentStep < 2) {
                      ref.read(navigationProvider.notifier).setProfileStep(currentStep + 1);
                    } else {
                      ref.read(navigationProvider.notifier).setIndex(101);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(currentStep == 2 ? 'Submit' : 'Next'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => ref.read(navigationProvider.notifier).setIndex(0),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => ref.read(navigationProvider.notifier).setIndex(0),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
        ),
        Row(
          children: [
            if (currentStep > 0)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton(
                  onPressed: () => ref.read(navigationProvider.notifier).setProfileStep(currentStep - 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Back'),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                if (currentStep < 2) {
                  ref.read(navigationProvider.notifier).setProfileStep(currentStep + 1);
                } else {
                  ref.read(navigationProvider.notifier).setIndex(101);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                elevation: 0,
              ),
              child: Text(currentStep == 2 ? 'Submit for Verification' : 'Next'),
            ),
          ],
        ),
      ],
    );
  }
}
