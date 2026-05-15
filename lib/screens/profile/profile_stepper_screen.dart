import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../widgets/common/image_upload_card.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../data/location_data.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
    _addressController = TextEditingController();
    
    // Default to Pankaj Plaza, Dwarka coordinates for preview
    // Default to Pankaj Plaza, Dwarka coordinates for preview
    _currentLatLng = const ll.LatLng(28.5908, 77.0433);

    // Load existing profile data
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _addressDebounce?.cancel();
    _companyNameController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _postalController.dispose();
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Location & Map states
  ll.LatLng? _currentLatLng;
  final MapController _mapController = MapController();
  bool _isLocating = false;
  bool _isSearching = false;
  bool _isLoading = false;
  Timer? _searchDebounce;
  Timer? _addressDebounce;

  // Form Controllers
  late TextEditingController _companyNameController;
  late TextEditingController _websiteController;
  late TextEditingController _descriptionController;
  late TextEditingController _postalController;
  late TextEditingController _addressController;

  // Selection states
  String? _selectedCompanyType;
  String? _selectedIndustry;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedCompanySize;


  final Map<String, String> _countryData = {
    'AF': 'Afghanistan', 'AL': 'Albania', 'DZ': 'Algeria', 'AD': 'Andorra', 'AO': 'Angola', 'AG': 'Antigua and Barbuda', 'AR': 'Argentina', 'AM': 'Armenia', 'AU': 'Australia', 'AT': 'Austria',
    'AZ': 'Azerbaijan', 'BS': 'Bahamas', 'BH': 'Bahrain', 'BD': 'Bangladesh', 'BB': 'Barbados', 'BY': 'Belarus', 'BE': 'Belgium', 'BZ': 'Belize', 'BJ': 'Benin', 'BT': 'Bhutan',
    'BO': 'Bolivia', 'BA': 'Bosnia and Herzegovina', 'BW': 'Botswana', 'BR': 'Brazil', 'BN': 'Brunei', 'BG': 'Bulgaria', 'BF': 'Burkina Faso', 'BI': 'Burundi', 'CV': 'Cabo Verde', 'KH': 'Cambodia',
    'CM': 'Cameroon', 'CA': 'Canada', 'CF': 'Central African Republic', 'TD': 'Chad', 'CL': 'Chile', 'CN': 'China', 'CO': 'Colombia', 'KM': 'Comoros', 'CG': 'Congo', 'CR': 'Costa Rica',
    'HR': 'Croatia', 'CU': 'Cuba', 'CY': 'Cyprus', 'CZ': 'Czech Republic', 'DK': 'Denmark', 'DJ': 'Djibouti', 'DM': 'Dominica', 'DO': 'Dominican Republic', 'EC': 'Ecuador', 'EG': 'Egypt',
    'SV': 'El Salvador', 'GQ': 'Equatorial Guinea', 'ER': 'Eritrea', 'EE': 'Estonia', 'SZ': 'Eswatini', 'ET': 'Ethiopia', 'FJ': 'Fiji', 'FI': 'Finland', 'FR': 'France', 'GA': 'Gabon',
    'GM': 'Gambia', 'GE': 'Georgia', 'DE': 'Germany', 'GH': 'Ghana', 'GR': 'Greece', 'GD': 'Grenada', 'GT': 'Guatemala', 'GN': 'Guinea', 'GW': 'Guinea-Bissau', 'GY': 'Guyana',
    'HT': 'Haiti', 'HN': 'Honduras', 'HU': 'Hungary', 'IS': 'Iceland', 'IN': 'India', 'ID': 'Indonesia', 'IR': 'Iran', 'IQ': 'Iraq', 'IE': 'Ireland', 'IL': 'Israel',
    'IT': 'Italy', 'JM': 'Jamaica', 'JP': 'Japan', 'JO': 'Jordan', 'KZ': 'Kazakhstan', 'KE': 'Kenya', 'KI': 'Kiribati', 'KW': 'Kuwait', 'KG': 'Kyrgyzstan', 'LA': 'Laos',
    'LV': 'Latvia', 'LB': 'Lebanon', 'LS': 'Lesotho', 'LR': 'Liberia', 'LY': 'Libya', 'LI': 'Liechtenstein', 'LT': 'Lithuania', 'LU': 'Luxembourg', 'MG': 'Madagascar', 'MW': 'Malawi',
    'MY': 'Malaysia', 'MV': 'Maldives', 'ML': 'Mali', 'MT': 'Malta', 'MH': 'Marshall Islands', 'MR': 'Mauritania', 'MU': 'Mauritius', 'MX': 'Mexico', 'FM': 'Micronesia', 'MD': 'Moldova',
    'MC': 'Monaco', 'MN': 'Mongolia', 'ME': 'Montenegro', 'MA': 'Morocco', 'MZ': 'Mozambique', 'MM': 'Myanmar', 'NA': 'Namibia', 'NR': 'Nauru', 'NP': 'Nepal', 'NL': 'Netherlands',
    'NZ': 'New Zealand', 'NI': 'Nicaragua', 'NE': 'Niger', 'NG': 'Nigeria', 'KP': 'North Korea', 'MK': 'North Macedonia', 'NO': 'Norway', 'OM': 'Oman', 'PK': 'Pakistan', 'PW': 'Palau',
    'PS': 'Palestine', 'PA': 'Panama', 'PG': 'Papua New Guinea', 'PY': 'Paraguay', 'PE': 'Peru', 'PH': 'Philippines', 'PL': 'Poland', 'PT': 'Portugal', 'QA': 'Qatar', 'RO': 'Romania',
    'RU': 'Russia', 'RW': 'Rwanda', 'KN': 'Saint Kitts and Nevis', 'LC': 'Saint Lucia', 'VC': 'Saint Vincent and the Grenadines', 'WS': 'Samoa', 'SM': 'San Marino', 'ST': 'Sao Tome and Principe', 'SA': 'Saudi Arabia', 'SN': 'Senegal',
    'RS': 'Serbia', 'SC': 'Seychelles', 'SL': 'Sierra Leone', 'SG': 'Singapore', 'SK': 'Slovakia', 'SI': 'Slovenia', 'SB': 'Solomon Islands', 'SO': 'Somalia', 'ZA': 'South Africa', 'KR': 'South Korea',
    'SS': 'South Sudan', 'ES': 'Spain', 'LK': 'Sri Lanka', 'SD': 'Sudan', 'SR': 'Suriname', 'SE': 'Sweden', 'CH': 'Switzerland', 'SY': 'Syria', 'TW': 'Taiwan', 'TJ': 'Tajikistan',
    'TZ': 'Tanzania', 'TH': 'Thailand', 'TL': 'Timor-Leste', 'TG': 'Togo', 'TO': 'Tonga', 'TT': 'Trinidad and Tobago', 'TN': 'Tunisia', 'TR': 'Turkey', 'TM': 'Turkmenistan', 'TV': 'Tuvalu',
    'UG': 'Uganda', 'UA': 'Ukraine', 'AE': 'United Arab Emirates', 'GB': 'United Kingdom', 'US': 'United States', 'UY': 'Uruguay', 'UZ': 'Uzbekistan', 'VU': 'Vanuatu', 'VA': 'Vatican City', 'VE': 'Venezuela',
    'VN': 'Vietnam', 'YE': 'Yemen', 'ZM': 'Zambia', 'ZW': 'Zimbabwe'
  };

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDesktop, context),
                const SizedBox(height: 24),
                _buildSuccessAlert(context),
                const SizedBox(height: 32),
                _buildStepper(currentStep, isDesktop, context),
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

  Widget _buildHeader(bool isDesktop, BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete your business profile to start hiring',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessAlert(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF065F46).withOpacity(0.2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF059669).withOpacity(0.3) : const Color(0xFFDCFCE7)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.checkCircle, size: 18, color: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Profile completed successfully. Your account is under review.',
              style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF15803D), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(int currentStep, bool isDesktop, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(color: theme.colorScheme.onSurface.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ] : [],
      ),
      child: Row(
        children: [
          _buildStepPill(1, 'Basic', currentStep >= 0, currentStep == 0, context),
          _buildStepConnector(currentStep >= 1, context),
          _buildStepPill(2, 'Contact', currentStep >= 1, currentStep == 1, context),
          _buildStepConnector(currentStep >= 2, context),
          _buildStepPill(3, 'Docs', currentStep >= 2, currentStep == 2, context),
        ],
      ),
    );
  }

  Widget _buildStepPill(int num, String label, bool isDone, bool isActive, BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: isDone || isActive
                  ? const LinearGradient(colors: [AppColors.primary, Color(0xFF4F46E5)])
                  : null,
              color: isDone || isActive ? null : theme.dividerColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone && !isActive
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : Text(
                      '$num',
                      style: TextStyle(
                        color: isDone || isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.4),
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
                color: isActive ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool active, BuildContext context) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Theme.of(context).dividerColor.withOpacity(0.1),
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
        // Country Dropdown with Flags
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Country *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 8),
            DropdownSearch<String>(
              items: (filter, loadProps) => _countryData.entries.map((e) => "${e.key} ${e.value}").toList(),
              decoratorProps: DropDownDecoratorProps(
                baseStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Select country',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.light ? Theme.of(context).dividerColor.withOpacity(0.03) : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                menuProps: MenuProps(backgroundColor: Theme.of(context).cardColor),
                searchFieldProps: TextFieldProps(
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Search Country...",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                  ),
                ),
                itemBuilder: (ctx, item, isSelected, isHover) {
                  final code = item.split(' ')[0].toLowerCase();
                  return ListTile(
                    leading: Image.network(
                      'https://flagcdn.com/24x18/$code.png',
                      width: 24,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 24),
                    ),
                    title: Text(item, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  );
                },
              ),
              selectedItem: (_selectedCountry != null && _selectedCountry!.isNotEmpty && _countryData.values.contains(_selectedCountry)) 
                ? "${_countryData.keys.firstWhere((k) => _countryData[k] == _selectedCountry, orElse: () => '')} $_selectedCountry".trim() 
                : null,
              onSelected: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCountry = val.substring(3); // Remove code
                    _selectedState = null;
                    _selectedCity = null;
                  });
                  _onAddressChanged();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildResponsiveFields(isDesktop, [
          // State Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('State *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 8),
              DropdownSearch<String>(
                items: (filter, loadProps) => _selectedCountry == 'India' ? (List<String>.from(LocationData.indiaStatesAndDistricts.keys)..sort()) : [],
                decoratorProps: DropDownDecoratorProps(
                  baseStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Select state',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light ? Theme.of(context).dividerColor.withOpacity(0.03) : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(backgroundColor: Theme.of(context).cardColor),
                  searchFieldProps: TextFieldProps(
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  itemBuilder: (context, item, isSelected, isHover) => ListTile(title: Text(item, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                ),
                selectedItem: _selectedState,
                onSelected: (val) {
                  setState(() {
                    _selectedState = val;
                    _selectedCity = null;
                  });
                  _onAddressChanged();
                },
              ),
            ],
          ),
          // City Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('City *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 8),
              DropdownSearch<String>(
                items: (filter, loadProps) => _selectedState != null ? (List<String>.from(LocationData.indiaStatesAndDistricts[_selectedState]!)..sort()) : [],
                decoratorProps: DropDownDecoratorProps(
                  baseStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Select city',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light ? Theme.of(context).dividerColor.withOpacity(0.03) : Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: MenuProps(backgroundColor: Theme.of(context).cardColor),
                  searchFieldProps: TextFieldProps(
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                  itemBuilder: (context, item, isSelected, isHover) => ListTile(title: Text(item, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                ),
                selectedItem: _selectedCity,
                onSelected: (val) {
                  setState(() => _selectedCity = val);
                  _onAddressChanged();
                },
              ),
            ],
          ),
        ]),
        const SizedBox(height: 20),
        _buildField(
          'Postal Code *', 
          'Enter postal code', 
          controller: _postalController,
          onChanged: (val) => _onAddressChanged(),
        ),
        const SizedBox(height: 20),
        _buildField(
          'Street Address *', 
          'Enter full street address', 
          maxLines: 3, 
          controller: _addressController,
          onChanged: (val) => _onAddressChanged(),
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
              side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLatLng ?? const ll.LatLng(20.5937, 78.9629),
                  initialZoom: _currentLatLng == null ? 5 : 15,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture && position.center != null) {
                      setState(() {
                        _currentLatLng = position.center;
                      });
                    }
                  },
                  onMapEvent: (event) {
                    if (event is MapEventMoveEnd) {
                      if (_currentLatLng != null && !_isLocating && !_isSearching) {
                        _reverseGeocode(_currentLatLng!.latitude, _currentLatLng!.longitude);
                      }
                      _isSearching = false;
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.mindware.admin.admin_app',
                  ),
                  if (_currentLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLatLng!,
                          width: 80,
                          height: 80,
                          child: const Icon(LucideIcons.mapPin, color: Color(0xFFEF4444), size: 40),
                        ),
                      ],
                    ),
                ],
              ),
              if (_isSearching || _isLocating)
                Container(
                  color: Colors.white.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
                ),
            ],
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
          final latLng = ll.LatLng(loc.latitude, loc.longitude);
          setState(() => _currentLatLng = latLng);
          _mapController.move(latLng, 16);
        }
      } catch (e) {
        debugPrint('Search Error: $e');
      }
    });
  }

  void _onAddressChanged() {
    if (_addressDebounce?.isActive ?? false) _addressDebounce!.cancel();
    _addressDebounce = Timer(const Duration(milliseconds: 800), () {
      _searchLocation();
    });
  }

  Future<void> _searchLocation() async {
    final street = _addressController.text.trim();
    final city = _selectedCity ?? '';
    final state = _selectedState ?? '';
    final postalCode = _postalController.text.trim();
    final country = _selectedCountry ?? '';

    // Final full address string as requested by user
    final fullAddress = "$street, $city, $state, $postalCode, $country";
    
    if (fullAddress.trim().isEmpty || fullAddress.replaceAll(',', '').trim().isEmpty) return;

    setState(() => _isSearching = true);
    debugPrint('🔍 [Geocoding] Searching for: $fullAddress');

    try {
      // 1. Try Native Geocoding first (more reliable on mobile)
      try {
        List<Location> locations = await locationFromAddress(fullAddress);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          final position = ll.LatLng(loc.latitude, loc.longitude);
          
          setState(() {
            _currentLatLng = position;
            _isSearching = false;
          });
          
          _mapController.move(position, 15);
          debugPrint('📍 [Geocoding] Found via Native: ${loc.latitude}, ${loc.longitude}');
          return;
        }
      } catch (e) {
        debugPrint('⚠️ [Geocoding] Native fail, trying backend: $e');
      }

      // 2. Fallback to Backend API
      final result = await AuthService().searchLocation(fullAddress);
      if (result['success']) {
        final List data = result['data'];
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());
          if (lat != null && lon != null) {
            final position = ll.LatLng(lat, lon);
            
            setState(() {
              _currentLatLng = position;
            });
            
            _mapController.move(position, 15);
            debugPrint('📍 [Geocoding] Found via Backend: $lat, $lon');
          }
        }
      }
    } catch (e) {
      debugPrint('🚨 [Geocoding] Global Error: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final result = await AuthService().reverseGeocode(lat, lng);
      
      if (result['success']) {
        final data = result['data'];
        final address = data['address'];
        
        final newPostal = address['postcode'] ?? '';
        final newAddress = data['display_name'] ?? '';

        setState(() {
          if (_postalController.text != newPostal) {
            _postalController.text = newPostal;
          }
          if (_addressController.text != newAddress) {
            _addressController.text = newAddress;
          }
          
          if (address['state'] != null) {
            final state = LocationData.indiaStatesAndDistricts.keys.firstWhere(
              (s) => s.toLowerCase() == address['state'].toString().toLowerCase(),
              orElse: () => _selectedState ?? '',
            );
            
            if (state.isNotEmpty) {
              _selectedState = state;
              final district = LocationData.indiaStatesAndDistricts[state]?.firstWhere(
                (d) => d.toLowerCase() == (address['city_district'] ?? address['city'] ?? address['suburb'] ?? '').toString().toLowerCase(),
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
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog or snackbar to enable location
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location services are disabled. Please enable GPS.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them from settings.';
      }

      // 3. Fetch current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = ll.LatLng(position.latitude, position.longitude);

      // 4. Update Map & State
      setState(() {
        _currentLatLng = latLng;
      });
      _mapController.move(latLng, 15);

      // 5. Convert coordinates to address using Native Geocoding
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          
          setState(() {
            // 1. Fill Text Controllers
            _postalController.text = p.postalCode ?? '';
            _addressController.text = "${p.street ?? ''}, ${p.subLocality ?? ''}".replaceAll(', ,', ',').trim();
            
            // 2. Fill Dropdowns (State, City, Country)
            _selectedCountry = p.country ?? 'India';

            if (p.administrativeArea != null) {
              // Try to find matching state in our LocationData keys
              final foundState = LocationData.indiaStatesAndDistricts.keys.firstWhere(
                (s) => s.toLowerCase().contains(p.administrativeArea!.toLowerCase()) || 
                       p.administrativeArea!.toLowerCase().contains(s.toLowerCase()),
                orElse: () => p.administrativeArea!,
              );
              _selectedState = foundState;

              // Try to find matching city in the selected state's districts
              if (LocationData.indiaStatesAndDistricts.containsKey(foundState)) {
                final districts = LocationData.indiaStatesAndDistricts[foundState]!;
                final foundCity = districts.firstWhere(
                  (d) => d.toLowerCase().contains((p.locality ?? p.subAdministrativeArea ?? '').toLowerCase()) ||
                         (p.locality ?? p.subAdministrativeArea ?? '').toLowerCase().contains(d.toLowerCase()),
                  orElse: () => p.locality ?? p.subAdministrativeArea ?? '',
                );
                _selectedCity = foundCity;
              } else {
                _selectedCity = p.locality ?? p.subAdministrativeArea ?? '';
              }
            }
          });
          debugPrint('📍 [Location] Auto-fetched: ${_selectedCity}, ${_selectedState}');
        }
      } catch (e) {
        debugPrint('⚠️ [Location] Native reverse geocode failed: $e');
        // Fallback to existing backend geocoding if native fails
        await _reverseGeocode(position.latitude, position.longitude);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
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

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? headerAction,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: theme.brightness == Brightness.light ? [
          BoxShadow(color: theme.colorScheme.onSurface.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                ),
              ),
              if (headerAction != null) headerAction,
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, {int maxLines = 1, TextEditingController? controller, ValueChanged<String>? onChanged}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withOpacity(0.7))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: theme.brightness == Brightness.light ? theme.dividerColor.withOpacity(0.03) : theme.scaffoldBackgroundColor.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, String placeholder, List<String> items, ValueChanged<String?> onChanged) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.5),
            boxShadow: theme.brightness == Brightness.light ? [
              BoxShadow(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : [],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                placeholder,
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.w500),
              ),
              icon: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Icon(LucideIcons.chevronDown, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ),
              dropdownColor: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              items: items.map((v) => DropdownMenuItem(
                value: v,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    v,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
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
        
        if (_countryData.values.contains(data['country'])) {
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
          final lat = double.tryParse(data['lat'].toString()) ?? 28.5908;
          final lng = double.tryParse(data['lng'].toString()) ?? 77.0433;
          _currentLatLng = ll.LatLng(lat, lng);
          _mapController.move(_currentLatLng!, 15);
        } else {
          // If no lat/lng, try to search from address
          _onAddressChanged();
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
