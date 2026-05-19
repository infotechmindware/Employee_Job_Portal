import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import 'widgets/auth_layout.dart';
import '../../providers/auth_provider.dart';
import '../../services/employer_auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // New Controllers
  final _contactPersonController = TextEditingController();
  final _gstinController = TextEditingController();
  final _websiteController = TextEditingController();
  final _pinCodeController = TextEditingController();

  // Phone Tab Controllers
  final _phoneCompanyNameController = TextEditingController();
  final _phoneMobileController = TextEditingController();
  final _phoneEmailController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  final _phonePasswordController = TextEditingController();

  final _employerAuthService = EmployerAuthService();

  bool _obscurePhonePassword = true;
  bool _isSubmitting = false;
  bool _isSendingPhoneOtp = false;
  bool _isPhoneOtpSent = false;
  int _phoneTimerSeconds = 60;
  bool _canResendPhoneOtp = true;
  Timer? _phoneTimer;
  
  bool _isEmailLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  
  // New Dropdown selection states
  String? _selectedRegisterAs;
  String? _selectedIndustryType;
  String? _selectedCompanyType;
  String? _selectedCompanySize;

  // New Dropdown options lists
  final List<String> _registerAsOptions = [
    'Company / Business',
    'Individual',
    'Consultancy',
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

  final List<String> _companySizes = [
    '1-10',
    '11-50',
    '51-200',
    '201-500',
    '501-1000',
    '1000+'
  ];
  
  // OTP related state
  bool _isOtpSent = false;
  bool _isSendingOtp = false;
  int _timerSeconds = 60;
  bool _canResendOtp = true;
  Timer? _timer;

  // Real-time validation state — green only after valid input
  bool _emailValid = false;
  bool _passwordValid = false;
  bool _confirmPasswordValid = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  // --- Validation helpers ---
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return email.isNotEmpty && regex.hasMatch(email);
  }

  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasDigit => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecialChar => RegExp(r'[!@#\$%\^&\*_]').hasMatch(_passwordController.text);
  bool get _hasValidLength {
    final len = _passwordController.text.length;
    return len >= 8 && len <= 20;
  }
  bool get _isNotCommon {
    const common = ['password123', 'password', '12345678', 'qwerty123', 'abc12345'];
    return _passwordController.text.isNotEmpty && !common.contains(_passwordController.text.toLowerCase());
  }
  bool get _allPasswordReqsMet => _hasLowercase && _hasUppercase && _hasDigit && _hasSpecialChar && _hasValidLength && _isNotCommon;

  String get _passwordStrengthLabel {
    if (_passwordController.text.isEmpty) return '';
    int score = [_hasLowercase, _hasUppercase, _hasDigit, _hasSpecialChar, _hasValidLength, _isNotCommon].where((e) => e).length;
    if (score <= 2) return 'Weak';
    if (score <= 4) return 'Fair';
    if (score <= 5) return 'Good';
    return 'Strong';
  }

  Color get _passwordStrengthColor {
    switch (_passwordStrengthLabel) {
      case 'Weak': return const Color(0xFFEF4444);
      case 'Fair': return const Color(0xFFF59E0B);
      case 'Good': return const Color(0xFF3B82F6);
      case 'Strong': return const Color(0xFF16A34A);
      default: return Colors.grey;
    }
  }

  void _validateEmail() {
    setState(() {
      if (_emailController.text.isNotEmpty) _emailTouched = true;
      _emailValid = _isValidEmail(_emailController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      if (_passwordController.text.isNotEmpty) _passwordTouched = true;
      _passwordValid = _allPasswordReqsMet;
      // Re-validate confirm password when password changes
      if (_confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordValid = _confirmPasswordController.text == _passwordController.text;
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      if (_confirmPasswordController.text.isNotEmpty) _confirmPasswordTouched = true;
      _confirmPasswordValid = _confirmPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text == _passwordController.text;
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactPersonController.dispose();
    _gstinController.dispose();
    _websiteController.dispose();
    _pinCodeController.dispose();
    _phoneCompanyNameController.dispose();
    _phoneMobileController.dispose();
    _phoneEmailController.dispose();
    _phoneOtpController.dispose();
    _phonePasswordController.dispose();
    _timer?.cancel();
    _phoneTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
      _canResendOtp = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() {
          _canResendOtp = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    
    try {
      final res = await _employerAuthService.sendEmailOtp(
        email: _emailController.text.trim(),
      );

      if (res['success']) {
        setState(() => _isOtpSent = true);
        _startTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Email OTP sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Failed to send Email OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingOtp = false);
      }
    }
  }

  void _sendPhoneOtp() async {
    final phone = _phoneMobileController.text.trim();
    if (phone.isEmpty || phone.length != 10 || double.tryParse(phone) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isSendingPhoneOtp = true);

    try {
      final res = await _employerAuthService.sendPhoneOtp(
        phone: phone,
      );

      if (res['success']) {
        setState(() => _isPhoneOtpSent = true);
        _startPhoneTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Phone OTP sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Failed to send Phone OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingPhoneOtp = false);
      }
    }
  }

  void _startPhoneTimer() {
    _canResendPhoneOtp = false;
    _phoneTimerSeconds = 60;
    _phoneTimer?.cancel();
    _phoneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_phoneTimerSeconds > 0) {
          _phoneTimerSeconds--;
        } else {
          _canResendPhoneOtp = true;
          _phoneTimer?.cancel();
        }
      });
    });
  }

  void _handleRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Conditions')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_nameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _otpController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _contactPersonController.text.isEmpty ||
        _selectedRegisterAs == null ||
        _selectedIndustryType == null ||
        _selectedCompanyType == null ||
        _selectedCompanySize == null ||
        _pinCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields including OTP')),
      );
      return;
    }

    if (_mobileController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primary Mobile Number must be exactly 10 digits')),
      );
      return;
    }

    if (_pinCodeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pin Code must be exactly 6 digits')),
      );
      return;
    }

    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters long')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final registerAsValue = _selectedRegisterAs == 'Company / Business'
          ? 'company'
          : (_selectedRegisterAs == 'Consultancy' ? 'consultancy' : 'individual');

      final res = await _employerAuthService.registerEmployer(
        companyName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _mobileController.text.trim(),
        fullName: _contactPersonController.text.trim(),
        registerAs: registerAsValue,
        industry: _selectedIndustryType!,
        companyType: _selectedCompanyType!,
        companySize: _selectedCompanySize!,
        gstin: _gstinController.text.trim(),
        website: _websiteController.text.trim(),
        pincode: _pinCodeController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        emailOtp: _otpController.text.trim(),
      );

      if (res['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Registration successful! Logging in...'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Auto login after registration
        final loginSuccess = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (loginSuccess && mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handlePhoneRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Conditions')),
      );
      return;
    }

    final companyName = _phoneCompanyNameController.text.trim();
    final phone = _phoneMobileController.text.trim();
    final email = _phoneEmailController.text.trim();
    final otp = _phoneOtpController.text.trim();
    final password = _phonePasswordController.text;

    if (companyName.isEmpty || phone.isEmpty || email.isEmpty || otp.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields including OTP')),
      );
      return;
    }

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mobile number must be exactly 10 digits')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters long')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await _employerAuthService.registerEmployerPhone(
        phone: phone,
        otp: otp,
        companyName: companyName,
        email: email,
        password: password,
      );

      if (res['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Registration successful! Logging in...'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Auto login after registration
        final loginSuccess = await ref.read(authProvider.notifier).login(
          email,
          password,
        );

        if (loginSuccess && mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      infoPanel: _buildInfoPanel(),
      formPanel: _buildFormPanel(context),
      infoOnLeft: true,
    );
  }

  Widget _buildInfoPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.star, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'SUCCESS STORIES',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Real People,\nReal Careers Built Here',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Join thousands of professionals who found their dream roles\nthrough Mindware\'s trusted network.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        _buildSuccessCard('Priya Sharma', 'Senior UX Designer - Bangalore', 'P', const Color(0xFF8B5CF6)),
        const SizedBox(height: 16),
        _buildSuccessCard('Rahul Mehta', 'Backend Engineer - Mumbai', 'R', const Color(0xFF06B6D4)),
        const SizedBox(height: 16),
        _buildSuccessCard('Ananya Iyer', 'Product Manager - Hyderabad', 'A', const Color(0xFFF59E0B)),
        const SizedBox(height: 64),
        
        // Progress indicators
        Row(
          children: [
            Container(width: 32, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Container(width: 32, height: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Container(width: 32, height: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(LucideIcons.chevronLeft, size: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(LucideIcons.chevronRight, size: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessCard(String name, String role, String initial, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(role, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.check, size: 14, color: Color(0xFF059669)),
                SizedBox(width: 4),
                Text('Hired', style: TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mindware', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Recruitment Platform', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Create your employer account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Join our trusted recruitment platform - it's free.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isEmailLogin = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isEmailLogin ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _isEmailLogin ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Email Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isEmailLogin = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isEmailLogin ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: !_isEmailLogin ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                    ),
                    alignment: Alignment.center,
                    child: const Text('Mobile OTP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        if (_isEmailLogin) ...[
          _buildLabel('Your Company Name'),
          const SizedBox(height: 8),
          _buildTextField('Enter company name', controller: _nameController),
          const SizedBox(height: 16),
          
          _buildLabel('Official Email Address'),
          const SizedBox(height: 8),
          _buildTextField('official@company.com', 
            isSuccess: _emailTouched && _emailValid, 
            controller: _emailController,
            readOnly: _isOtpSent,
          ),
          const SizedBox(height: 4),
          Text("We'll use this to create your account. You can add more details after registration.", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 16),
          
          _buildLabel('Mobile'),
          const SizedBox(height: 8),
          _buildTextField('10-digit mobile number', controller: _mobileController),
          const SizedBox(height: 16),

          _buildLabel('Contact Person Name'),
          const SizedBox(height: 8),
          _buildTextField('Enter contact person name', controller: _contactPersonController),
          const SizedBox(height: 16),

          _buildLabel('Register As'),
          const SizedBox(height: 8),
          _buildDropdownField('Company / Business', _selectedRegisterAs, _registerAsOptions, (val) {
            setState(() {
              _selectedRegisterAs = val;
            });
          }),
          const SizedBox(height: 16),

          _buildLabel('Industry Type'),
          const SizedBox(height: 8),
          _buildDropdownField('Select Industry Type', _selectedIndustryType, _industries, (val) {
            setState(() {
              _selectedIndustryType = val;
            });
          }),
          const SizedBox(height: 16),

          _buildLabel('Company Type'),
          const SizedBox(height: 8),
          _buildDropdownField('Select Company Type', _selectedCompanyType, _companyTypes, (val) {
            setState(() {
              _selectedCompanyType = val;
            });
          }),
          const SizedBox(height: 16),

          _buildLabel('Company Size'),
          const SizedBox(height: 8),
          _buildDropdownField('Select Company Size', _selectedCompanySize, _companySizes, (val) {
            setState(() {
              _selectedCompanySize = val;
            });
          }),
          const SizedBox(height: 16),

          const Text('GSTIN (Optional)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          _buildTextField('Enter GST number', controller: _gstinController),
          const SizedBox(height: 16),

          const Text('Company Website (Optional)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          _buildTextField('https://www.company.com', controller: _websiteController),
          const SizedBox(height: 16),

          _buildLabel('Pin Code'),
          const SizedBox(height: 8),
          _buildTextField('6-digit pin code', controller: _pinCodeController),
          const SizedBox(height: 16),

          _buildLabel('Email OTP'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField('6-digit OTP', controller: _otpController),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: (_isSendingOtp || !_canResendOtp) ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E7FF),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _isSendingOtp 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        _isOtpSent 
                          ? (_canResendOtp ? 'Resend OTP' : 'Resend in ${_timerSeconds}s') 
                          : 'Send OTP',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildLabel('Password'),
          const SizedBox(height: 8),
          _buildPasswordField('••••••••', true, isSuccess: _passwordTouched && _passwordValid, controller: _passwordController),
          const SizedBox(height: 8),
          
          // Password Requirements — dynamic
          if (_passwordTouched) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_passwordStrengthLabel.isNotEmpty)
                  Text(_passwordStrengthLabel, style: TextStyle(color: _passwordStrengthColor, fontWeight: FontWeight.bold, fontSize: 12)),
                Text('${_passwordController.text.length}/20 characters', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _allPasswordReqsMet ? const Color(0xFFF0FDF4) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Password Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildReqItem('At least one lowercase letter (a-z)', _hasLowercase),
                  _buildReqItem('At least one uppercase letter (A-Z)', _hasUppercase),
                  _buildReqItem('At least one number (0-9)', _hasDigit),
                  _buildReqItem('At least one special character (!@#\$%^\&*_)', _hasSpecialChar),
                  _buildReqItem('Between 8 and 20 characters (NIST recommended)', _hasValidLength),
                  _buildReqItem('Not a common password (e.g. "password123")', _isNotCommon),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          _buildLabel('Confirm Password'),
          const SizedBox(height: 8),
          _buildPasswordField('Re-enter your password', false, isSuccess: _confirmPasswordTouched && _confirmPasswordValid, controller: _confirmPasswordController),
          if (_confirmPasswordTouched && _confirmPasswordController.text.isNotEmpty && !_confirmPasswordValid)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Passwords do not match', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
            ),
          const SizedBox(height: 24),
          
          _buildDivider('Or continue with'),
          const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildSocialBtn('assets/images/google.webp')),
            const SizedBox(width: 16),
            Expanded(child: _buildSocialBtn('assets/images/fb.jpg')),
            const SizedBox(width: 16),
            Expanded(child: _buildSocialBtn('assets/images/link.jpg')),
            const SizedBox(width: 16),
            Expanded(child: _buildSocialBtn('assets/images/microsoft.jpg')),
          ],
        ),
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreeToTerms,
                  onChanged: (v) {
                    setState(() {
                      _agreeToTerms = v ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    children: [
                      TextSpan(text: 'Terms and Conditions', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ]
                  )
                )
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ] else ...[
          // Mobile OTP Form
          _buildLabel('Company Name'),
          const SizedBox(height: 8),
          _buildTextField('Your company name', controller: _phoneCompanyNameController),
          const SizedBox(height: 16),
          
          _buildLabel('Primary Mobile Number'),
          const SizedBox(height: 8),
          _buildTextField('Enter 10-digit mobile number', controller: _phoneMobileController),
          const SizedBox(height: 16),
          
          _buildLabel('Email Address'),
          const SizedBox(height: 8),
          _buildTextField('Enter official email address', controller: _phoneEmailController),
          const SizedBox(height: 16),

          _buildLabel('Password'),
          const SizedBox(height: 8),
          _buildPasswordField('Enter password (min. 8 characters)', true, controller: _phonePasswordController, isPhone: true),
          const SizedBox(height: 24),
          
          _buildLabel('OTP'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField('6-digit OTP', controller: _phoneOtpController),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isSendingPhoneOtp || !_canResendPhoneOtp ? null : _sendPhoneOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E7FF),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isSendingPhoneOtp
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                      )
                    : Text(
                        _canResendPhoneOtp ? 'Send OTP' : 'Resend in ${_phoneTimerSeconds}s',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreeToTerms,
                  onChanged: (v) {
                    setState(() {
                      _agreeToTerms = v ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    children: [
                      TextSpan(text: 'Terms and Conditions', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ]
                  )
                )
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handlePhoneRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSubmitting ? const Color(0xFF93A5F8) : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Create With OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        
        const SizedBox(height: 32),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReqItem(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(LucideIcons.checkCircle, size: 14, color: met ? const Color(0xFF16A34A) : Colors.grey),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: TextStyle(color: met ? const Color(0xFF16A34A) : Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isSuccess = false, TextEditingController? controller, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: hint.contains('OTP') || hint.contains('mobile') || hint.contains('Mobile') || hint.contains('pin') || hint.contains('Pin') || hint.contains('GST') || hint.contains('number') ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : (isSuccess ? const Color(0xFFF0FDF4) : AppColors.background),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isSuccess ? const Color(0xFF86EFAC) : Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isSuccess ? const Color(0xFF86EFAC) : AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String placeholder, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      icon: const Icon(LucideIcons.chevronDown, size: 18, color: Colors.grey),
      dropdownColor: Colors.white,
      items: items.map((v) => DropdownMenuItem(
        value: v,
        child: Text(
          v,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPasswordField(String hint, bool isFirst, {bool isSuccess = false, TextEditingController? controller, bool isPhone = false}) {
    bool obscure = isPhone ? _obscurePhonePassword : (isFirst ? _obscurePassword : _obscureConfirmPassword);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: isSuccess ? const Color(0xFFF0FDF4) : AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isSuccess ? const Color(0xFF86EFAC) : Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isSuccess ? const Color(0xFF86EFAC) : AppColors.primary),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? LucideIcons.eyeOff : LucideIcons.eye,
            size: 18,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (isPhone) {
                _obscurePhonePassword = !_obscurePhonePassword;
              } else if (isFirst) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey[200])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey[200])),
      ],
    );
  }

  Widget _buildSocialBtn(String imagePath) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        imagePath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      ),
    );
  }
}
