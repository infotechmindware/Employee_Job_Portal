import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import 'widgets/auth_layout.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isEmailLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

    if (_nameController.text.isEmpty || _mobileController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).registerEmployer(
      fullName: _nameController.text,
      mobile: _mobileController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Logging in...')),
        );
        
        // Auto login after registration
        final loginSuccess = await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

        if (loginSuccess && mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } else {
      if (mounted) {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Registration failed')),
        );
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LucideIcons.chevronLeft, size: 16, color: Colors.grey),
              label: const Text('Back to Home', style: TextStyle(color: Colors.grey)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ),
        const SizedBox(height: 24),
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
          _buildLabel('Full Name'),
          const SizedBox(height: 8),
          _buildTextField('Enter your full name', controller: _nameController),
          const SizedBox(height: 16),
          
          _buildLabel('Mobile Number'),
          const SizedBox(height: 8),
          _buildTextField('Enter mobile number', controller: _mobileController),
          const SizedBox(height: 16),
          
          _buildLabel('Email Address'),
          const SizedBox(height: 8),
          _buildTextField('Enter your email address', isSuccess: _emailTouched && _emailValid, controller: _emailController),
          const SizedBox(height: 4),
          Text("We'll use this to create your account. You can add more details after registration.", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
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
              onPressed: ref.watch(authProvider).isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: ref.watch(authProvider).isLoading
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
          _buildLabel('Full Name'),
          const SizedBox(height: 8),
          _buildTextField('Your full name'),
          const SizedBox(height: 16),
          
          _buildLabel('Primary Mobile Number'),
          const SizedBox(height: 8),
          _buildTextField('Enter mobile number'),
          const SizedBox(height: 16),
          
          const Text('Additional Mobile Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          _buildTextField('Optional second number'),
          const SizedBox(height: 16),
          
          const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          _buildTextField('Optional email address'),
          const SizedBox(height: 24),
          
          _buildLabel('OTP'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField('6-digit OTP'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E7FF),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Send OTP', style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF93A5F8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Create With OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(String hint, {bool isSuccess = false, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
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
      ),
    );
  }

  Widget _buildPasswordField(String hint, bool isFirst, {bool isSuccess = false, TextEditingController? controller}) {
    bool obscure = isFirst ? _obscurePassword : _obscureConfirmPassword;
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
              if (isFirst) {
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
