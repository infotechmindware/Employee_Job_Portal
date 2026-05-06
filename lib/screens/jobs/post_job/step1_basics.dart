import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'post_job_model.dart';
import 'wizard_widgets.dart';
import '../../../services/location_service.dart';

class StepJobBasics extends StatefulWidget {
  final PostJobModel model;
  final VoidCallback onContinue;

  const StepJobBasics({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<StepJobBasics> createState() => _StepJobBasicsState();
}

class _StepJobBasicsState extends State<StepJobBasics> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _addressCtrl;

  final List<String> _industries = [
    'Technology', 'Finance', 'Healthcare', 'Education',
    'Manufacturing', 'Retail', 'Marketing', 'Legal',
    'Hospitality', 'Construction', 'Media', 'Other',
  ];

  final List<String> _employmentTypes = [
    'Full-time', 'Part-time', 'Contract', 'Freelance', 'Internship',
  ];

  List<String> _countries = [];
  List<String> _states = [];
  List<String> _cities = [];

  bool _isLoadingCountries = false;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  final List<String> _languages = [
    'English', 'Hindi', 'Punjabi', 'Bengali', 'Tamil', 'Telugu', 'Marathi', 
    'Gujarati', 'Kannada', 'Malayalam', 'Urdu', 'Spanish', 'French', 'German'
  ];

  final List<String> _workplaceTypes = ['Onsite', 'Remote', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.model.jobTitle);
    _addressCtrl = TextEditingController(text: widget.model.address);
    
    // Initialize default if empty
    if (widget.model.country.isEmpty) widget.model.country = 'India';
    if (widget.model.jobLanguage.isEmpty) widget.model.jobLanguage = 'English';

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingCountries = true);
    final countries = await LocationService.getCountries();
    setState(() {
      _countries = countries;
      _isLoadingCountries = false;
    });

    if (widget.model.country.isNotEmpty) {
      await _loadStates(widget.model.country);
      if (widget.model.state.isNotEmpty) {
        await _loadCities(widget.model.country, widget.model.state);
      }
    }
  }

  Future<void> _loadStates(String country) async {
    setState(() {
      _isLoadingStates = true;
      _states.clear();
      widget.model.state = '';
      widget.model.city = '';
    });
    final states = await LocationService.getStates(country);
    setState(() {
      _states = states;
      _isLoadingStates = false;
    });
  }

  Future<void> _loadCities(String country, String state) async {
    setState(() {
      _isLoadingCities = true;
      _cities.clear();
      widget.model.city = '';
    });
    final cities = await LocationService.getCities(country, state);
    setState(() {
      _cities = cities;
      _isLoadingCities = false;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Posting Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                const WizardLabel('Posting Country'),
                const SizedBox(height: 8),
                _buildSearchableDropdown(
                  items: _countries,
                  selectedItem: widget.model.country,
                  isLoading: _isLoadingCountries,
                  onChanged: (v) async {
                    final newCountry = v ?? '';
                    setDialogState(() {
                      widget.model.country = newCountry;
                      widget.model.state = ''; 
                      widget.model.city = '';
                    });
                    setState(() {});
                    if (newCountry.isNotEmpty) {
                      setDialogState(() {}); // Show loading in dialog
                      await _loadStates(newCountry);
                      setDialogState(() {}); // Show data in dialog
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WizardLabel('State'),
                          const SizedBox(height: 8),
                          _buildSearchableDropdown(
                            items: _states,
                            selectedItem: widget.model.state,
                            isLoading: _isLoadingStates,
                            enabled: widget.model.country.isNotEmpty,
                            hint: widget.model.country.isEmpty ? 'Country' : 'State',
                            onChanged: (v) async {
                              final newState = v ?? '';
                              setDialogState(() {
                                widget.model.state = newState;
                                widget.model.city = '';
                              });
                              setState(() {});
                              if (newState.isNotEmpty) {
                                setDialogState(() {}); // Show loading
                                await _loadCities(widget.model.country, newState);
                                setDialogState(() {}); // Show data
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WizardLabel('City'),
                          const SizedBox(height: 8),
                          _buildSearchableDropdown(
                            items: _cities,
                            selectedItem: widget.model.city,
                            isLoading: _isLoadingCities,
                            enabled: widget.model.state.isNotEmpty,
                            hint: widget.model.state.isEmpty ? 'State' : 'City',
                            onChanged: (v) {
                              setDialogState(() => widget.model.city = v ?? '');
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const WizardLabel('Language'),
                const SizedBox(height: 8),
                _buildSearchableDropdown(
                  items: _languages,
                  selectedItem: widget.model.jobLanguage,
                  onChanged: (v) {
                    setDialogState(() => widget.model.jobLanguage = v ?? 'English');
                    setState(() {});
                  },
                ),
                
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: kBorder),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: kTextSub)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WizardPrimaryButton(
                        label: 'Save Settings',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required List<String> items,
    required String selectedItem,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
    bool enabled = true,
    String? hint,
  }) {
    return DropdownSearch<String>(
      enabled: enabled && !isLoading,
      items: (filter, loadProps) => items,
      selectedItem: selectedItem.isEmpty ? null : selectedItem,
      onSelected: onChanged,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          filled: true,
          fillColor: enabled ? const Color(0xFFF8FAFC) : Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: isLoading ? 'Loading data...' : (hint ?? 'Select option'),
          hintStyle: TextStyle(color: kTextSub.withOpacity(0.5), fontSize: 14),
          suffixIconColor: kPrimary,
          suffixIcon: isLoading 
            ? Container(
                padding: const EdgeInsets.all(12),
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
              ) 
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kPrimary, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 350),
        menuProps: MenuProps(
          elevation: 16,
          shadowColor: kPrimary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        searchFieldProps: TextFieldProps(
          cursorColor: kPrimary,
          decoration: InputDecoration(
            hintText: 'Search here...',
            hintStyle: const TextStyle(fontSize: 14, color: kTextSub),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: kPrimary),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kPrimary, width: 1),
            ),
          ),
        ),
        itemBuilder: (context, item, isSelected, isHighlighted) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? kPrimary.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? kPrimary : kText,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, size: 18, color: kPrimary),
              ],
            ),
          );
        },
        emptyBuilder: (context, searchEntry) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_off_rounded, size: 32, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try searching something else',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Posting Preferences ──────────────────────
            _buildPostingPreferences(),

            const SizedBox(height: 16),

            // ── Job Information ──────────────────────────
            WizardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    Icons.work_outline_rounded,
                    'Job Information',
                  ),
                  const SizedBox(height: 20),
                  const WizardLabel('Job Title'),
                  const SizedBox(height: 8),
                  WizardTextField(
                    hint: 'e.g. Senior Flutter Developer',
                    controller: _titleCtrl,
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  const WizardLabel('Industry / Category'),
                  const SizedBox(height: 8),
                  WizardDropdown(
                    value: widget.model.industry,
                    items: _industries,
                    hint: 'Select industry',
                    onChanged: (v) => setState(() => widget.model.industry = v ?? ''),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Employment Type ───────────────────────────
            WizardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    Icons.access_time_rounded,
                    'Employment Type',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _employmentTypes.map((type) {
                      final Map<String, IconData> icons = {
                        'Full-time': Icons.calendar_today_rounded,
                        'Part-time': Icons.timelapse_rounded,
                        'Contract': Icons.description_outlined,
                        'Freelance': Icons.laptop_mac_rounded,
                        'Internship': Icons.school_outlined,
                      };
                      return WizardChip(
                        label: type,
                        selected: widget.model.employmentType == type,
                        icon: icons[type],
                        onTap: () =>
                            setState(() => widget.model.employmentType = type),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Location ─────────────────────────────────
            WizardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    Icons.location_on_outlined,
                    'Location',
                  ),
                  const SizedBox(height: 20),
                  const WizardLabel('Country'),
                  const SizedBox(height: 8),
                  _buildSearchableDropdown(
                    items: _countries,
                    selectedItem: widget.model.country,
                    isLoading: _isLoadingCountries,
                    onChanged: (v) async {
                      final newCountry = v ?? '';
                      setState(() {
                        widget.model.country = newCountry;
                        widget.model.state = '';
                        widget.model.city = '';
                      });
                      if (newCountry.isNotEmpty) {
                        await _loadStates(newCountry);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const WizardLabel('State'),
                            const SizedBox(height: 8),
                            _buildSearchableDropdown(
                              items: _states,
                              selectedItem: widget.model.state,
                              isLoading: _isLoadingStates,
                              enabled: widget.model.country.isNotEmpty,
                              hint: widget.model.country.isEmpty ? 'Country' : 'State',
                              onChanged: (v) async {
                                final newState = v ?? '';
                                setState(() {
                                  widget.model.state = newState;
                                  widget.model.city = '';
                                });
                                if (newState.isNotEmpty) {
                                  await _loadCities(widget.model.country, newState);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const WizardLabel('City'),
                            const SizedBox(height: 8),
                            _buildSearchableDropdown(
                              items: _cities,
                              selectedItem: widget.model.city,
                              isLoading: _isLoadingCities,
                              enabled: widget.model.state.isNotEmpty,
                              hint: widget.model.state.isEmpty ? 'State' : 'City',
                              onChanged: (v) {
                                setState(() => widget.model.city = v ?? '');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const WizardLabel('Address', required: false),
                  const SizedBox(height: 8),
                  WizardTextField(
                    hint: 'Office address (optional)',
                    controller: _addressCtrl,
                    prefixIcon: Icons.map_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Openings + Workplace ──────────────────────
            WizardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    Icons.groups_outlined,
                    'Additional Details',
                  ),
                  const SizedBox(height: 20),
                  const WizardLabel('Number of Openings'),
                  const SizedBox(height: 12),
                  _buildOpeningsSelector(),
                  const SizedBox(height: 24),
                  const WizardLabel('Workplace Type'),
                  const SizedBox(height: 12),
                  Row(
                    children: _workplaceTypes.map((type) {
                      final Map<String, IconData> icons = {
                        'Onsite': Icons. business_rounded,
                        'Remote': Icons.home_work_outlined,
                        'Hybrid': Icons.compare_arrows_rounded,
                      };
                      final selected = widget.model.workplaceType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                              () => widget.model.workplaceType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                              right: type != 'Hybrid' ? 10 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? kPrimary.withOpacity(0.08)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? kPrimary : kBorder,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  icons[type],
                                  size: 24,
                                  color: selected ? kPrimary : kTextSub,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected ? kPrimary : kTextSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Continue button ────────────────────────────
            WizardPrimaryButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onTap: () {
                widget.model.jobTitle = _titleCtrl.text.trim();
                widget.model.address = _addressCtrl.text.trim();
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onContinue();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostingPreferences() {
    return WizardCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.public_rounded, size: 20, color: kPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posting for ${widget.model.country}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Language: ${widget.model.jobLanguage}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showSettingsDialog,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text(
              'Change',
              style: TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
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

  Widget _buildOpeningsSelector() {
    return Row(
      children: [
        _openingBtn(
          icon: Icons.remove_rounded,
          onTap: () {
            if (widget.model.openings > 1) {
              setState(() => widget.model.openings--);
            }
          },
        ),
        const SizedBox(width: 16),
        Text(
          '${widget.model.openings}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const SizedBox(width: 16),
        _openingBtn(
          icon: Icons.add_rounded,
          onTap: () => setState(() => widget.model.openings++),
          filled: true,
        ),
        const SizedBox(width: 16),
        Text(
          widget.model.openings == 1 ? 'position' : 'positions',
          style: const TextStyle(fontSize: 14, color: kTextSub),
        ),
      ],
    );
  }

  Widget _openingBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled ? kPrimary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: filled ? kPrimary : kBorder,
            width: 1.5,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Icon(icon,
            size: 20, color: filled ? Colors.white : kTextSub),
      ),
    );
  }
}
