import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_sara/SetMPIN/SetPinScreen.dart';

import '../../../../ulits/ColorsR.dart';
import '../../../Helper/Toast.dart';
import '../../../l10n/app_localizations.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  final storage = GetStorage();
  String mobile = '';

  @override
  void initState() {
    super.initState();
    mobile = storage.read('mobile') ?? '';
  }

  void _onRegister(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (username.isEmpty) {
      popToast(
        l10n?.pleaseEnterUsername ?? "Enter username",
        3,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }
    if (password.length < 6) {
      popToast(
        l10n?.passwordMustBeAtLeast6Characters ??
            "Password must be at least 6 characters",
        3,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }
    if (password != confirm) {
      popToast(
        l10n?.passwordsDoNotMatch ?? "Passwords do not match",
        3,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }

    storage.write('username', username);
    storage.write('password', password);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SetPinScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFE082),
      body: Column(
        children: [
          const SizedBox(height: 40),

          /// WHITE CONTAINER
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE082),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// IMAGE
                    Image.asset(
                      "assets/images/img_3.png",
                      height: 140,
                    ),

                    const SizedBox(height: 16),

                    /// TITLE
                    Text(
                      l10n?.createNewAccount ?? "CREATE NEW ACCOUNT",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F4C81),
                      ),
                    ),

                    const SizedBox(height: 25),



                    /// USERNAME
                    _inputCard(
                      icon: Icons.person,
                      hint: l10n?.username ?? "Username",
                      controller: _usernameController,
                    ),

                    const SizedBox(height: 20),

                    /// PASSWORD
                    _inputCard(
                      icon: Icons.lock,
                      hint: l10n?.password ?? "Password",
                      controller: _passwordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 20),

                    /// CONFIRM PASSWORD
                    _inputCard(
                      icon: Icons.lock_outline,
                      hint: l10n?.confirmPassword ?? "Confirm password",
                      controller: _confirmPasswordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 40),

                    /// REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => _onRegister(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3882F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          l10n?.registerAndLogin ?? "Register & Login",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    /// keyboard space
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// COMMON INPUT CARD (DITTO STYLE)
  Widget _inputCard({
    required IconData icon,
    required String hint,
    TextEditingController? controller,
    bool isPassword = false,
    bool enabled = true,
  }) {
    return Card(
      color: Color(0xffeeeeee),
      elevation: 6,
      //  shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3882F6)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                enabled: enabled,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
