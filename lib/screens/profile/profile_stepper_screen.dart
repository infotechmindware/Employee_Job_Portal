import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/common/image_upload_card.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../data/location_data.dart';

class ProfileStepperScreen extends ConsumerStatefulWidget {
  const ProfileStepperScreen({super.key});

  @override
  ConsumerState<ProfileStepperScreen> createState() => _ProfileStepperScreenState();
}

class _ProfileStepperScreenState extends ConsumerState<ProfileStepperScreen> {
  @override
  void initState() {
    super.initState();
    _selectedCountry = 'India';
  }

  // Selection states
  String? _selectedCompanyType;
  String? _selectedIndustry;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedCompanySize;


  final List<String> _countries = [
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia', 'Austria',
    'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan',
    'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cambodia',
    'Cameroon', 'Canada', 'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 'Congo', 'Costa Rica',
    'Croatia', 'Cuba', 'Cyprus', 'Czech Republic', 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt',
    'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Fiji', 'Finland', 'France', 'Gabon',
    'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana',
    'Haiti', 'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel',
    'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait', 'Kyrgyzstan', 'Laos',
    'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar', 'Malawi',
    'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico', 'Micronesia', 'Moldova',
    'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nauru', 'Nepal', 'Netherlands',
    'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea', 'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palau',
    'Palestine', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal', 'Qatar', 'Romania',
    'Russia', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal',
    'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'South Korea',
    'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland', 'Syria', 'Taiwan', 'Tajikistan',
    'Tanzania', 'Thailand', 'Timor-Leste', 'Togo', 'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu',
    'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela',
    'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe'
  ];

  final List<String> _companyTypes = [
    'Proprietorship',
    'Partnership',
    'Private Limited',
    'Public Limited',
    'Limited Liability Partnership (LLP)',
    'One Person Company (OPC)',
    'Government / PSU',
    'Non-Profit (NGO / Trust)',
    'Startup',
    'Freelancer / Individual'
  ];

  final List<String> _industries = [
    'IT/Software',
    'Finance',
    'Healthcare',
    'Education',
    'Manufacturing',
    'Retail',
    'Real Estate',
    'Hospitality',
    'Other'
  ];

  final List<String> _companySizes = [
    '1-10 employees',
    '11-50 employees',
    '51-200 employees',
    '201-500 employees',
    '501-1000 employees',
    '1000+ employees'
  ];
  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final currentStep = navState.profileStep;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDesktop),
            const SizedBox(height: 24),
            _buildSuccessAlert(),
            const SizedBox(height: 32),
            _buildStepper(currentStep, isDesktop),
            const SizedBox(height: 32),
            _buildStepContent(currentStep, isDesktop),
            const SizedBox(height: 40),
            _buildActionButtons(currentStep, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Complete your business profile to start hiring',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.checkCircle, size: 18, color: Color(0xFF16A34A)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Profile completed successfully. Your account is under review.',
              style: TextStyle(color: Color(0xFF15803D), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(int currentStep, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _buildStepPill(1, 'Basic', currentStep >= 0, currentStep == 0),
          _buildStepConnector(currentStep >= 1),
          _buildStepPill(2, 'Contact', currentStep >= 1, currentStep == 1),
          _buildStepConnector(currentStep >= 2),
          _buildStepPill(3, 'Docs', currentStep >= 2, currentStep == 2),
        ],
      ),
    );
  }

  Widget _buildStepPill(int num, String label, bool isDone, bool isActive) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: isDone || isActive
                  ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)])
                  : null,
              color: isDone || isActive ? null : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone && !isActive
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : Text(
                      '$num',
                      style: TextStyle(
                        color: isDone || isActive ? Colors.white : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool active) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStepContent(int step, bool isDesktop) {
    switch (step) {
      case 0:
        return _buildCompanyInfo(isDesktop);
      case 1:
        return _buildContactInfo(isDesktop);
      case 2:
        return _buildDocumentsInfo(isDesktop);
      default:
        return const SizedBox();
    }
  }

  Widget _buildCompanyInfo(bool isDesktop) {
    return Column(
      children: [
        _buildFormCard(
          title: 'Company Information',
          icon: LucideIcons.building,
          children: [
            _buildResponsiveFields(isDesktop, [
              _buildField('Company Name *', 'Mindware info tech sd'),
              _buildField('Website', 'https://mindware.com'),
            ]),
            const SizedBox(height: 20),
            _buildField('Company Description', 'Leading software solutions...', maxLines: 4),
            const SizedBox(height: 20),
            _buildResponsiveFields(isDesktop, [
              _buildDropdown(
                'Company Type *',
                _selectedCompanyType,
                'Select Company Type',
                _companyTypes,
                (val) => setState(() => _selectedCompanyType = val),
              ),
              _buildDropdown(
                'Industry *',
                _selectedIndustry,
                'Select Industry',
                _industries,
                (val) => setState(() => _selectedIndustry = val),
              ),
            ]),
            const SizedBox(height: 20),
            _buildResponsiveFields(isDesktop, [
              _buildDropdown(
                'Company Size *',
                _selectedCompanySize,
                'Select size',
                _companySizes,
                (val) => setState(() => _selectedCompanySize = val),
              ),
              ImageUploadCard(
                label: 'Company Logo',
                subLabel: 'PNG or JPG (1:1 Ratio)',
                onImageSelected: (file) {},
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfo(bool isDesktop) {
    return _buildFormCard(
      title: 'Address',
      icon: LucideIcons.mapPin,
      children: [
        _buildDropdown(
          'Country *',
          _selectedCountry,
          'Select country',
          _countries,
          (val) {
            setState(() {
              _selectedCountry = val;
              _selectedState = null;
              _selectedCity = null;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildResponsiveFields(isDesktop, [
          _buildDropdown(
            'State *',
            _selectedState,
            _selectedCountry == 'India' ? 'Select state' : 'Not available',
            _selectedCountry == 'India' ? (List<String>.from(LocationData.indiaStatesAndDistricts.keys)..sort()) : [],
            (val) {
              setState(() {
                _selectedState = val;
                _selectedCity = null;
              });
            },
          ),
          _buildDropdown(
            'District / City *',
            _selectedCity,
            _selectedState == null ? 'Select state first' : 'Select district',
            _selectedState != null ? (List<String>.from(LocationData.indiaStatesAndDistricts[_selectedState]!)..sort()) : [],
            (val) => setState(() => _selectedCity = val),
          ),
        ]),
        const SizedBox(height: 20),
        _buildResponsiveFields(isDesktop, [
          _buildField('Postal Code *', 'Enter postal code'),
          _buildField('Official Email *', 'contact@company.com'),
        ]),
        const SizedBox(height: 20),
        _buildField('Street Address *', 'Enter full street address', maxLines: 3),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.navigation, size: 16),
          label: const Text('Use my location'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            foregroundColor: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.map, size: 32, color: Color(0xFF94A3B8)),
                SizedBox(height: 8),
                Text('Map Preview', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsInfo(bool isDesktop) {
    return _buildFormCard(
      title: 'Identity Verification',
      icon: LucideIcons.shieldCheck,
      children: [
        const Text(
          'Upload official business registration documents for verification.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
        ),
        const SizedBox(height: 24),
        _buildResponsiveFields(isDesktop, [
          ImageUploadCard(
            label: 'Business License *',
            subLabel: 'PDF, PNG or JPG',
            onImageSelected: (file) {
              ref.read(profileProvider.notifier).setBusinessLicense(file);
            },
          ),
          ImageUploadCard(
            label: 'GST Certificate *',
            subLabel: 'Official tax document',
            onImageSelected: (file) {
              ref.read(profileProvider.notifier).setGstCertificate(file);
            },
          ),
        ]),
        const SizedBox(height: 20),
        ImageUploadCard(
          label: 'Additional Proof',
          subLabel: 'Address proof or certification',
          onImageSelected: (file) {
            ref.read(profileProvider.notifier).setAdditionalProof(file);
          },
        ),
      ],
    );
  }

  Widget _buildFormCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF6366F1)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, String placeholder, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B), // Darker text as per "app text"
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Better white background
            borderRadius: BorderRadius.circular(12), // Matching app field radius
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5), // Cleaner border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                placeholder,
                style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
              icon: Container(
                margin: const EdgeInsets.only(right: 8),
                child: const Icon(LucideIcons.chevronDown, size: 18, color: Color(0xFF64748B)),
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              items: items.map((v) => DropdownMenuItem(
                value: v,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    v,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildResponsiveFields(bool isDesktop, List<Widget> children) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList(),
      );
    }
    return Column(
      children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 20), child: c)).toList(),
    );
  }

  Widget _buildActionButtons(int currentStep, bool isDesktop) {
    if (!isDesktop) {
      return Column(
        children: [
          Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                if (currentStep < 2) {
                  ref.read(navigationProvider.notifier).setProfileStep(currentStep + 1);
                } else {
                  ref.read(navigationProvider.notifier).setIndex(101);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                currentStep == 2 ? 'Submit Profile' : 'Continue',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
          if (currentStep > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => ref.read(navigationProvider.notifier).setProfileStep(currentStep - 1),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: const Color(0xFF64748B),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        if (currentStep > 0)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => ref.read(navigationProvider.notifier).setProfileStep(currentStep - 1),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                foregroundColor: const Color(0xFF64748B),
              ),
              child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                if (currentStep < 2) {
                  ref.read(navigationProvider.notifier).setProfileStep(currentStep + 1);
                } else {
                  ref.read(navigationProvider.notifier).setIndex(101);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                currentStep == 2 ? 'Submit Profile' : 'Continue',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
