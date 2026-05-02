import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../widgets/common/image_upload_card.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
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
    _companyNameController = TextEditingController();
    _websiteController = TextEditingController();
    _descriptionController = TextEditingController();
    _postalController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    
    // Default to Pankaj Plaza, Dwarka coordinates for preview
    _currentLatLng = const LatLng(28.5908, 77.0433);

    // Load existing profile data
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _postalController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Location & Map states
  LatLng? _currentLatLng;
  GoogleMapController? _mapController;
  bool _isLocating = false;
  bool _isLoading = false;
  Timer? _searchDebounce;

  // Form Controllers
  late TextEditingController _companyNameController;
  late TextEditingController _websiteController;
  late TextEditingController _descriptionController;
  late TextEditingController _postalController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

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
    '1-10',
    '11-50',
    '51-200',
    '201-500',
    '501-1000',
    '1000+'
  ];
  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final currentStep = navState.profileStep;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SingleChildScrollView(
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
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
              _buildField('Company Name *', 'Enter company name', controller: _companyNameController),
              _buildField('Website', 'https://mindware.com', controller: _websiteController),
            ]),
            const SizedBox(height: 20),
            _buildField('Company Description', 'Leading software solutions...', maxLines: 4, controller: _descriptionController),
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
          _buildField('Postal Code *', 'Enter postal code', controller: _postalController),
          _buildField('Official Email *', 'contact@company.com', controller: _emailController),
        ]),
        const SizedBox(height: 20),
        _buildField(
          'Street Address *', 
          'Enter full street address', 
          maxLines: 3, 
          controller: _addressController,
          onChanged: (val) => _searchLocationFromAddress(val),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLocating ? null : _handleUseMyLocation,
            icon: _isLocating 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(LucideIcons.navigation, size: 16),
            label: Text(_isLocating ? 'Locating...' : 'Use my location'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: const Color(0xFF6366F1),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _currentLatLng == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.map, size: 32, color: Color(0xFF94A3B8)),
                      SizedBox(height: 8),
                      Text('Map Preview', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentLatLng!, zoom: 17),
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: (position) {
                    setState(() {
                      _currentLatLng = position.target;
                    });
                  },
                  onCameraIdle: () {
                    if (_currentLatLng != null && !_isLocating) {
                      _reverseGeocode(_currentLatLng!.latitude, _currentLatLng!.longitude);
                    }
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('current'),
                      position: _currentLatLng!,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setState(() {
                          _currentLatLng = newPosition;
                        });
                        _reverseGeocode(newPosition.latitude, newPosition.longitude);
                      },
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                ),
        ),
      ],
    );
  }

  // Bonus: Search location from typed address
  void _searchLocationFromAddress(String address) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 800), () async {
      if (address.length < 5) return;
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          final latLng = LatLng(loc.latitude, loc.longitude);
          setState(() => _currentLatLng = latLng);
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
        }
      } catch (e) {
        debugPrint('Search Error: $e');
      }
    });
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final newPostal = place.postalCode ?? '';
        final newAddress = [
          if (place.street != null && place.street!.isNotEmpty) place.street,
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality,
        ].join(', ');

        setState(() {
          if (_postalController.text != newPostal) {
            _postalController.text = newPostal;
          }
          if (_addressController.text != newAddress) {
            _addressController.text = newAddress;
          }
          if (place.administrativeArea != null) {
            final state = LocationData.indiaStatesAndDistricts.keys.firstWhere(
              (s) => s.toLowerCase() == place.administrativeArea!.toLowerCase(),
              orElse: () => _selectedState ?? '',
            );
            if (state.isNotEmpty) {
              _selectedState = state;
              final district = LocationData.indiaStatesAndDistricts[state]?.firstWhere(
                (d) => d.toLowerCase() == (place.subAdministrativeArea ?? place.locality ?? '').toLowerCase(),
                orElse: () => _selectedCity ?? '',
              );
              if (district != null && district.isNotEmpty) _selectedCity = district;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
    }
  }

  Future<void> _handleUseMyLocation() async {
    setState(() => _isLocating = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Location permissions are denied.';
      }
      
      if (permission == LocationPermission.deniedForever) throw 'Location permissions are permanently denied.';

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLatLng = latLng;
        _isLocating = false;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
      
      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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

  Widget _buildField(String label, String hint, {int maxLines = 1, TextEditingController? controller, ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
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

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final authService = AuthService();
    final result = await authService.getProfile();
    
    // DEBUG: Check if address fields exist in API response
    debugPrint("API Profile Response: ${jsonEncode(result)}");
    
    if (result['success']) {
      final data = result['data'];
      setState(() {
        _companyNameController.text = data['company_name'] ?? '';
        _websiteController.text = data['website'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _postalController.text = data['postal_code'] ?? '';
        _emailController.text = data['email'] ?? '';
        _addressController.text = data['street_address'] ?? '';
        
        // Defensive checks for dropdown values
        if (_companyTypes.contains(data['company_type'])) {
          _selectedCompanyType = data['company_type'];
        }
        if (_industries.contains(data['industry'])) {
          _selectedIndustry = data['industry'];
        }
        if (_companySizes.contains(data['company_size'])) {
          _selectedCompanySize = data['company_size'];
        }
        
        if (_countries.contains(data['country'])) {
          _selectedCountry = data['country'];
        } else {
          _selectedCountry = 'India';
        }

        // Only set State if it exists in the current Country's data (if India)
        if (_selectedCountry == 'India' && LocationData.indiaStatesAndDistricts.containsKey(data['state'])) {
          _selectedState = data['state'];
          // Only set City if it exists in the selected State's data
          if (LocationData.indiaStatesAndDistricts[_selectedState!]!.contains(data['city'])) {
            _selectedCity = data['city'];
          }
        }

        if (data['lat'] != null && data['lng'] != null) {
          _currentLatLng = LatLng(
            double.tryParse(data['lat'].toString()) ?? 28.5908,
            double.tryParse(data['lng'].toString()) ?? 77.0433,
          );
        }
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);
    
    final profileState = ref.read(profileProvider);
    final Map<String, String> fields = {
      'company_name': _companyNameController.text,
      'website': _websiteController.text,
      'description': _descriptionController.text,
      'company_type': _selectedCompanyType ?? '',
      'industry': _selectedIndustry ?? '',
      'company_size': _selectedCompanySize ?? '',
      'country': _selectedCountry ?? '',
      'state': _selectedState ?? '',
      'city': _selectedCity ?? '',
      'postal_code': _postalController.text,
      'email': _emailController.text,
      'street_address': _addressController.text,
      'lat': _currentLatLng?.latitude.toString() ?? '',
      'lng': _currentLatLng?.longitude.toString() ?? '',
    };

    final Map<String, File> files = {};
    if (profileState.businessLicense != null) files['business_license'] = profileState.businessLicense!;
    if (profileState.gstCertificate != null) files['gst_certificate'] = profileState.gstCertificate!;
    if (profileState.additionalProof != null) files['additional_proof'] = profileState.additionalProof!;

    final result = await AuthService().updateProfile(fields, files: files);
    
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      if (result['success']) {
        ref.read(navigationProvider.notifier).setIndex(101); // Redirect to success/dashboard
      }
    }
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        return _companyNameController.text.isNotEmpty &&
               _selectedCompanyType != null &&
               _selectedIndustry != null &&
               _selectedCompanySize != null;
      case 1:
        return _selectedCountry != null &&
               _selectedState != null &&
               _selectedCity != null &&
               _postalController.text.isNotEmpty &&
               _emailController.text.isNotEmpty &&
               _addressController.text.isNotEmpty &&
               _currentLatLng != null;
      case 2:
        final profileState = ref.watch(profileProvider);
        // Requirement: At least business license and GST are usually mandatory
        return profileState.businessLicense != null &&
               profileState.gstCertificate != null;
      default:
        return false;
    }
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
              onPressed: _isStepValid(currentStep) ? () {
                if (currentStep < 2) {
                  ref.read(navigationProvider.notifier).setProfileStep(currentStep + 1);
                } else {
                  _submitProfile();
                }
              } : null,
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
              onPressed: _isStepValid(currentStep) ? () {
                if (currentStep < 2) {
                  ref.read(navigationProvider.notifier).setProfileStep(currentStep + 1);
                } else {
                  _submitProfile();
                }
              } : null,
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
