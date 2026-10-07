import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:new_sara/SetMPIN/SetNewPinScreen.dart';
import 'package:new_sara/HomeScreen/HomeScreen.dart';
import 'package:new_sara/components/AppNameBold.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../Helper/Toast.dart';
import '../ulits/ColorsR.dart';
import '../ulits/Constents.dart';

class LoginWithMpinScreen extends StatefulWidget {
  const LoginWithMpinScreen({super.key});

  @override
  State<LoginWithMpinScreen> createState() => _LoginWithMpinScreenState();
}

class _LoginWithMpinScreenState extends State<LoginWithMpinScreen> {
  final TextEditingController mpinController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  final storage = GetStorage();
  bool isLoading = false;
  bool isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    // Add listener to automatically login when 4 digits are entered
    mpinController.addListener(_handleMpinInput);
  }

  // Handle MPIN input to auto-login when 4 digits are entered
  void _handleMpinInput() {
    final enteredMpin = mpinController.text.trim();
    if (enteredMpin.length == 4) {
      // Add a small delay to ensure the UI updates before login
      Future.delayed(const Duration(milliseconds: 100), () {
        _loginWithMpin();
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      final biometrics = await auth.getAvailableBiometrics();

      if (isAvailable && isDeviceSupported && biometrics.isNotEmpty) {
        setState(() {
          isBiometricAvailable = true;
        });
      }
    } catch (e) {
      log("Biometric availability check error: $e");
    }
  }

  // Implement the _tryBiometricAuth method with full functionality
  Future<void> _tryBiometricAuth() async {
    try {
      final isAvailable = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      final biometrics = await auth.getAvailableBiometrics();

      final l10n = AppLocalizations.of(context);
      if (!isAvailable || !isDeviceSupported || biometrics.isEmpty) {
        _showSnackBar(
          l10n?.biometricAuthenticationNotAvailable ?? 'Biometric authentication not available or supported',
        );
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: l10n?.scanYourFingerprintToVerify ?? 'Scan your fingerprint to verify',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

     // final l10n = AppLocalizations.of(context);
      if (authenticated) {
        _validateSavedMpinAndNavigate();
      } else {
        _showSnackBar(
          l10n?.biometricAuthenticationFailed ?? 'Biometric authentication failed',
        );
      }
    } catch (e) {
      log("Biometric error: $e");
      final l10n = AppLocalizations.of(context);
      _showSnackBar(
        l10n?.biometricError(e.toString()) ?? 'Biometric error: $e',
      );
    }
  }

  void _onSetPinPressed() async {
    final l10n = AppLocalizations.of(context);
    final mobileNo = storage.read('mobile');
    if (mobileNo == null || mobileNo.toString().isEmpty) {
      popToast(
        l10n?.mobileNumberNotAvailable ?? "Mobile number not found",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }

    // Navigate directly to SetNewPinScreen without sending OTP
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SetNewPinScreen(mobile: mobileNo)),
    );
  }

  /// Login using entered mPIN
  Future<void> _loginWithMpin() async {
    final l10n = AppLocalizations.of(context);
    final enteredMpin = mpinController.text.trim();

    if (enteredMpin.isEmpty) {
      _showSnackBar(l10n?.pleaseEnterYourMpin ?? 'Please enter your mPIN');
      return;
    }

    // Retrieve registerId and accessToken from GetStorage
    final String registerId = storage.read('registerId');
    final String accessToken = storage.read('accessToken');
    final String deviceId = storage.read('deviceId') ?? '';
    final String deviceName = storage.read('deviceName') ?? '';

    log("Register Id: $registerId");
    log("Access Token: $accessToken");

    if (registerId == null || registerId.isEmpty) {
      _showSnackBar(
        l10n?.registrationIdNotFoundPleaseReregister ?? 'Registration ID not found. Please re-register.',
      );
      return;
    }

    if (accessToken == null || accessToken.isEmpty) {
      _showSnackBar(
        l10n?.accessTokenNotFoundPleaseRelogin ?? 'Access token not found. Please re-login.',
      );
      return;
    }

    try {
      final url = Uri.parse('${Constant.apiEndpoint}verify-mpin');
      final response = await http.post(
        url,
        headers: {
          'deviceId':
              deviceId, // Replace with actual device ID logic if available
          'deviceName':
              deviceName, // Replace with actual device name logic if available
          'accessStatus': '1',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "registerId": registerId,
          "pinNo": int.tryParse(enteredMpin), // MPIN is expected as an integer
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        log("MPIN Verification Response: $responseData");
        // Assuming the API returns a success status or similar
        if (responseData['status'] == true) {
          // Adjust based on actual API response structure
          _showSnackBar(l10n?.loginSuccessful ?? 'Login successful!');
          await fetchAndSaveUserDetails(
            registerId,
          ); // Fetch user details after successful MPIN verification
          _navigateToHome();
        } else {
          invalidMpinDialog(context);
        }
      } else {
        log(
          "❌ MPIN Verification Failed: ${response.statusCode} => ${response.body}",
        );
        _showSnackBar(
          l10n?.failedToVerifyMpinPleaseTryAgainLater ?? 'Failed to verify mPIN. Please try again later.',
        );
      }
    } catch (e) {
      log("❌ Exception during MPIN verification: $e");
      _showSnackBar(
        l10n?.errorOccurredDuringMpinVerification(e.toString()) ?? 'An error occurred during mPIN verification: $e',
      );
    }
  }

  /// Validate saved mPIN (used after biometric success)
  Future<void> _validateSavedMpinAndNavigate() async {
    final l10n = AppLocalizations.of(context);
    final String? registerId = storage.read('registerId');
    if (registerId == null || registerId.isEmpty) {
      _showSnackBar(
        l10n?.registrationIdNotFoundPleaseReregister ?? 'Registration ID not found. Please re-register.',
      );
      return;
    }
    await fetchAndSaveUserDetails(registerId);
    _navigateToHome(); // Biometric passed and mPIN exists
  }

  Future<void> fetchAndSaveUserDetails(String registerId) async {
    final storage = GetStorage();
    final url = Uri.parse('${Constant.apiEndpoint}user-details-by-register-id');
    String accessToken = storage.read('accessToken') ?? '';

    log("Register Id: $registerId");
    log("Access Token: $accessToken");

    try {
      final response = await http.post(
        url,
        headers: {
          'deviceId': 'qwert',
          'deviceName': 'sm2233',
          'accessStatus': '1',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"registerId": registerId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final info = responseData['info'];
        log("User details: $info");

        // Save individual fields to GetStorage, ensuring walletBalance is stored as String
        storage.write('userId', info['userId']);
        storage.write('fullName', info['fullName']);
        storage.write('emailId', info['emailId']);
        storage.write('mobileNo', info['mobileNo']);
        storage.write('mobileNoEnc', info['mobileNoEnc']);
        // FIX: Convert walletBalance to String before saving
        storage.write('walletBalance', info['walletBalance']?.toString());
        storage.write('profilePicture', info['profilePicture']);
        storage.write('accountStatus', info['accountStatus']);
        storage.write('betStatus', info['betStatus']);

        log("✅ User details saved to GetStorage:");
        info.forEach((key, value) => log('$key: $value'));
      } else {
        print(
          "❌ Failed to fetch user details: ${response.statusCode} => ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Exception fetching user details: $e");
    }
  }

  /// Navigate to Home screen
  void _navigateToHome() {
    storage.write('is_logged_in', true); // Set login status
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    mpinController.removeListener(_handleMpinInput);
    mpinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE082),
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ⭐ TOP GRADIENT BACKGROUND (Like screenshot)
        decoration: const BoxDecoration(
       color: Color(0xFFFFE082)
        ),

        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),



              const SizedBox(height: 80),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 30,
                  ),

                  // ⭐ BIG WHITE CONTAINER ROUND TOP
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE082),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⭐ LOGIN WITH MPIN TEXT
                        Text(
                          AppLocalizations.of(context)?.loginWithMpin ?? "Login with MPIN",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F4C81),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ⭐ TEXTFIELD LIKE SCREENSHOT
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Color(0xffFCFCFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: mpinController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: AppLocalizations.of(context)?.mpinHint ?? "MPIN",
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ⭐ LOGIN BUTTON EXACT LIKE SCREENSHOT
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3882F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _loginWithMpin,
                            child: Text(
                              AppLocalizations.of(context)?.login ?? "Login",
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ⭐ CENTER FORGOT MPIN
                        Center(
                          child: GestureDetector(
                            onTap: _onSetPinPressed,
                            child: Text(
                              AppLocalizations.of(context)?.forgotMpin ?? "Forgot MPIN?",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ⭐ BIOMETRIC ICON CENTER
                        if (isBiometricAvailable)
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _tryBiometricAuth,
                                  child: const Icon(
                                    Icons.fingerprint,
                                    size: 60,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void invalidMpinDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ❌ Orange Cross Icon
              CircleAvatar(
                backgroundColor: const Color(0xFF3882F6),
                radius: 35,
                child: const Icon(Icons.close, size: 45, color: Colors.white),
              ),

              const SizedBox(height: 18),

              // ❗ Invalid MPIN Text
              Text(
                l10n?.invalidMpin ?? "Invalid MPIN",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1c2134),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                l10n?.pleaseEnterCorrectMpin ?? "Please enter correct MPIN",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              // ✅ OK Button
              SizedBox(
                width: 130,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3882F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n?.ok ?? "OK",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
