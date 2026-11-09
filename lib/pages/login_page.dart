import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /*// Validate and process login form
  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }*/

  // TESTING LOGIN - Automatically enter HomePage
  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  // Display forgot password message
  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password recovery feature coming soon!')),
    );
  }

  // Navigate to signup page
  void _openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
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
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 25,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Application branding
                    const SizedBox(height: 10),

                    const Text(
                      'Budget Buddy',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'Your money, your control.',
                      style: TextStyle(fontSize: 11, color: AppColors.textGray),
                    ),

                    const SizedBox(height: 40),

                    // Login form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email label
                          _buildLabel('Email Address'),

                          const SizedBox(height: 7),

                          // Email field
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _buildInputDecoration(
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
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

                          // Password label
                          _buildLabel('Password'),

                          const SizedBox(height: 7),

                          // Password field
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            decoration: _buildInputDecoration(
                              hint: 'Enter your password',
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
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password.';
                              }

                              if (value.length < 6) {
                                return 'Password must be at least 6 characters.';
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) => _login(),
                          ),

                          const SizedBox(height: 8),

                          // Remember Me and Forgot Password
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppColors.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 5),

                              const Text(
                                'Remember Me',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textGray,
                                ),
                              ),

                              const Spacer(),

                              TextButton(
                                onPressed: _forgotPassword,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 13),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 13),

                          // Signup navigation
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGray,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: _openSignup,
                                  child: const Text(
                                    'Sign Up',
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

                    // Custom BudgetBuddy mascot
                    const SizedBox(height: 25),

                    const BudgetBuddyMascot(),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Reusable field label
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

  // Reusable text field decoration
  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textGray),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textGray),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

// ==========================================
// CUSTOM BUDGET BUDDY MASCOT
// ==========================================

class BudgetBuddyMascot extends StatelessWidget {
  const BudgetBuddyMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 155,
      child: CustomPaint(painter: _MascotPainter()),
    );
  }
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    final greenPaint = Paint()..color = const Color(0xFF23845C);

    final darkGreenPaint = Paint()..color = const Color(0xFF155C40);

    final lightGreenPaint = Paint()..color = const Color(0xFF91C95C);

    final whitePaint = Paint()..color = Colors.white;

    // Draw left leaf
    canvas.save();
    canvas.translate(centerX - 25, 32);
    canvas.rotate(-0.65);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: 27, height: 15),
      lightGreenPaint,
    );

    canvas.restore();

    // Draw right leaf
    canvas.save();
    canvas.translate(centerX + 25, 32);
    canvas.rotate(0.65);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: 27, height: 15),
      lightGreenPaint,
    );

    canvas.restore();

    // Draw top leaf
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, 19), width: 16, height: 25),
      lightGreenPaint,
    );

    // Draw mascot body
    canvas.drawCircle(Offset(centerX, 91), 46, greenPaint);

    // Draw arms
    final armPaint = Paint()
      ..color = const Color(0xFF23845C)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX - 36, 90),
      Offset(centerX - 55, 73),
      armPaint,
    );

    canvas.drawLine(
      Offset(centerX + 36, 90),
      Offset(centerX + 55, 73),
      armPaint,
    );

    // Draw hands
    canvas.drawCircle(Offset(centerX - 56, 71), 7, lightGreenPaint);

    canvas.drawCircle(Offset(centerX + 56, 71), 7, lightGreenPaint);

    // Draw left eye
    canvas.drawCircle(Offset(centerX - 15, 83), 5, whitePaint);

    canvas.drawCircle(Offset(centerX - 14, 84), 2.5, darkGreenPaint);

    // Draw right eye
    canvas.drawCircle(Offset(centerX + 15, 83), 5, whitePaint);

    canvas.drawCircle(Offset(centerX + 16, 84), 2.5, darkGreenPaint);

    // Draw smile
    final smilePaint = Paint()
      ..color = darkGreenPaint.color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final smilePath = Path()
      ..moveTo(centerX - 12, 101)
      ..quadraticBezierTo(centerX, 115, centerX + 12, 101);

    canvas.drawPath(smilePath, smilePaint);

    // Draw cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFF91C95C).withValues(alpha: 0.8);

    canvas.drawCircle(Offset(centerX - 25, 99), 4, cheekPaint);

    canvas.drawCircle(Offset(centerX + 25, 99), 4, cheekPaint);

    // Draw small decorative leaves
    canvas.drawCircle(Offset(centerX - 73, 133), 8, lightGreenPaint);

    canvas.drawCircle(Offset(centerX + 73, 133), 8, lightGreenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
