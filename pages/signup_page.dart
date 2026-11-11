
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate registration form
  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration form is valid! Account creation coming soon.',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  // Navigate back to login
  void _backToLogin() {
    Navigator.pop(context);
  }

  // Reusable input label
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  // Reusable input decoration
  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.textGray,
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: AppColors.textGray,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: AppColors.primaryGreen,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),

                    // Back button
                    IconButton(
                      onPressed: _backToLogin,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Application branding
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.primaryGreen,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Budget Buddy',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          Text(
                            'Your money, your control.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Signup heading
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Join Budget Buddy and start managing your money.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Signup form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Full name
                          _buildLabel('Full Name'),

                          const SizedBox(height: 7),

                          TextFormField(
                            controller: nameController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            decoration: _buildInputDecoration(
                              hint: 'Enter your full name',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your full name.';
                              }

                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Email address
                          _buildLabel('Email Address'),

                          const SizedBox(height: 7),

                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _buildInputDecoration(
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter your email.';
                              }

                              final emailPattern = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );

                              if (!emailPattern.hasMatch(value.trim())) {
                                return 'Please enter a valid email.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password
                          _buildLabel('Password'),

                          const SizedBox(height: 7),

                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: _buildInputDecoration(
                              hint: 'Create a password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 19,
                                  color: AppColors.textGray,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password.';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirm password
                          _buildLabel('Confirm Password'),

                          const SizedBox(height: 7),

                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            decoration: _buildInputDecoration(
                              hint: 'Confirm your password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 19,
                                  color: AppColors.textGray,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password.';
                              }

                              if (value != passwordController.text) {
                                return 'Passwords do not match.';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) => _createAccount(),
                          ),

                          const SizedBox(height: 25),

                          // Create account button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _createAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(9),
                                ),
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Login navigation
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGray,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _backToLogin,
                                  child: const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Decorative bottom illustration
                    const Center(
                      child: Icon(
                        Icons.savings_rounded,
                        size: 55,
                        color: AppColors.primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        'Start saving. Build better habits.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
