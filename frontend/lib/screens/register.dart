import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedUserType = 'customer';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.register(
        username: _emailController.text.trim(), // Use email as username
        email: _emailController.text.trim(),
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        userType: _selectedUserType,
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
      );

      debugPrint('Register result: $result');
      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration successful! Please login.')),
        );
        Navigator.pop(context); // Go back to login
      } else {
        // Handle validation errors
        String errorMessage = 'Registration failed';
        if (result['errors'] != null && result['errors'] is Map) {
          final errors = result['errors'] as Map<String, dynamic>;
          if (errors.containsKey('username')) {
            errorMessage = 'Username already exists';
          } else if (errors.containsKey('email')) {
            errorMessage = 'Email already exists';
          } else if (errors.containsKey('non_field_errors')) {
            errorMessage = errors['non_field_errors'][0];
          }
        } else if (result['error'] != null) {
          errorMessage = result['error'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final horizontalPadding = ResponsiveUtils.responsivePadding(
      context,
      mobile: 20,
      tablet: 36,
      desktop: 48,
    );
    final titleFontSize = ResponsiveUtils.responsiveFontSize(
      context,
      mobile: 28,
      tablet: 36,
      desktop: 38,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                    : const [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                // Back button positioned at top-left
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                    onPressed: () {
                      // Ensure navigation back to previous screen
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        // Fallback: Push to login or home if no route to pop
                        // Adjust this based on your app's navigation structure
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: ResponsiveUtils.getContentWidth(context,
                              maxWidth: 500)),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                  height: ResponsiveUtils.responsivePadding(
                                      context,
                                      mobile: 40,
                                      tablet: 50,
                                      desktop: 60)),
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1.0,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join us to find the best parking spots',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                  height: ResponsiveUtils.responsivePadding(
                                      context,
                                      mobile: 32,
                                      tablet: 40,
                                      desktop: 48)),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _ModernTextField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      prefixIcon: Icons.person_outline_rounded,
                                      validator: (v) => v?.isEmpty == true
                                          ? 'Required'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _ModernTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.alternate_email_rounded,
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return 'Required';
                                        if (!RegExp(
                                                r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                            .hasMatch(v)) {
                                          return 'Invalid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _ModernTextField(
                                      controller: _phoneController,
                                      label: 'Phone Number',
                                      keyboardType: TextInputType.phone,
                                      prefixIcon: Icons.phone_android_rounded,
                                      validator: (v) => v?.isEmpty == true
                                          ? 'Required'
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedUserType,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'customer',
                                            child: Text('Customer')),
                                        DropdownMenuItem(
                                            value: 'vendor',
                                            child: Text('Slot Vendor')),
                                      ],
                                      onChanged: (val) => setState(
                                          () => _selectedUserType = val!),
                                      decoration: InputDecoration(
                                        labelText: 'I am a...',
                                        prefixIcon: const Icon(
                                            Icons.badge_outlined,
                                            size: 22),
                                        filled: true,
                                        fillColor: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.06)
                                            : Colors.black
                                                .withValues(alpha: 0.04),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _ModernTextField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      obscureText: _obscurePassword,
                                      prefixIcon: Icons.lock_outline_rounded,
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                      ),
                                      validator: (v) =>
                                          (v != null && v.length < 6)
                                              ? 'Min 6 characters'
                                              : null,
                                    ),
                                    const SizedBox(height: 16),
                                    _ModernTextField(
                                      controller: _confirmPasswordController,
                                      label: 'Confirm Password',
                                      obscureText: _obscureConfirmPassword,
                                      prefixIcon: Icons.lock_outline_rounded,
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined),
                                        onPressed: () => setState(() =>
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword),
                                      ),
                                      validator: (v) {
                                        if (v != _passwordController.text)
                                          return 'Passwords do not match';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: ResponsiveUtils.responsivePadding(
                                      context,
                                      mobile: 24,
                                      tablet: 32,
                                      desktop: 40)),
                              _GradientButton(
                                isLoading: _isLoading,
                                onPressed: _isLoading ? null : _handleRegister,
                                label: 'Register',
                              ),
                              SizedBox(
                                  height: ResponsiveUtils.responsivePadding(
                                      context,
                                      mobile: 24,
                                      tablet: 32,
                                      desktop: 40)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton(
      {required this.isLoading, required this.onPressed, required this.label});

  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4)),
          ),
        ),
      ),
    );
  }
}
