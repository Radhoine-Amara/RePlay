// FILE: lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../home/home_screen.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    // Validate inputs
    if (_userNameController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your username');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter your email');
      return;
    }
    
    // Validate email format
    final email = _emailController.text.trim().toLowerCase();
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _showErrorSnackbar('Please enter a valid email address');
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showErrorSnackbar('Please enter your password');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showErrorSnackbar('Password must be at least 6 characters');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackbar('Passwords do not match');
      return;
    }

    int? phoneNum;
    if (_phoneController.text.trim().isNotEmpty) {
      phoneNum = int.tryParse(_phoneController.text.trim());
      if (phoneNum == null) {
        _showErrorSnackbar('Please enter a valid phone number');
        return;
      }
    }

    context.read<AuthCubit>().register(
      email: email,
      password: _passwordController.text,
      userName: _userNameController.text.trim(),
      phoneNum: phoneNum,
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _showSuccessSnackbar('Account created successfully!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (state is AuthError) {
          _showErrorSnackbar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videogame_asset,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    AppStrings.registerSubtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Username TextField
                  CustomTextField(
                    controller: _userNameController,
                    enabled: !isLoading,
                    hintText: AppStrings.username,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 15),

                  // Email TextField
                  CustomTextField(
                    controller: _emailController,
                    enabled: !isLoading,
                    hintText: AppStrings.email,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  // Phone TextField (Optional)
                  CustomTextField(
                    controller: _phoneController,
                    enabled: !isLoading,
                    hintText: AppStrings.phoneOptional,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),

                  // Password TextField
                  CustomTextField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    hintText: AppStrings.password,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password TextField
                  CustomTextField(
                    controller: _confirmPasswordController,
                    enabled: !isLoading,
                    hintText: AppStrings.confirmPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: isLoading ? null : _handleSignUp,
                      text: AppStrings.createAccount,
                      isLoading: isLoading,
                      backgroundColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Already have an account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.alreadyHaveAccount,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          AppStrings.login,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
