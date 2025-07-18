import 'package:flutter/material.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/core/theme/styling.dart';

Future<void> showEmailPasswordDialog(BuildContext context) async {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: padding_24,
        child: Padding(
          padding: EdgeInsets.only(
            top: 32,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Almost Done!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Let’s save your details so you can get live updates and track your orders.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey700),
              ),
              const SizedBox(height: 32),
              // Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: borderRadius_12),
                ),
              ),
              const SizedBox(height: 16),
              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: borderRadius_12),
                ),
              ),
              const SizedBox(height: 16),
              // Optional Phone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Create Account"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).whenComplete(() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
  });
}
