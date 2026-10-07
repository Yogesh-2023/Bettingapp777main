import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_sara/l10n/app_localizations.dart';

class BankDetailsFragment extends StatefulWidget {
  const BankDetailsFragment({super.key});

  @override
  State<BankDetailsFragment> createState() => _BankDetailsFragmentState();
}

class _BankDetailsFragmentState extends State<BankDetailsFragment> {
  final nameController = TextEditingController();
  final accNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    accNumberController.dispose();
    ifscController.dispose();
    bankNameController.dispose();
    branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const primaryColor = Color(0xFF3882F6);
    const secondaryColor = Color(0xFF0F4C81);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 18),
            ),
          ),
        ),
        title: Text(
          l10n?.bankDetails ?? "BANK DETAILS",
          style: GoogleFonts.poppins(
            color: secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: "Manage Your Bank",
              subtitle: "Enter your bank details for secure withdrawals. Please ensure all information is accurate.",
            ),
            const SizedBox(height: 32),
            
            _buildInputField(
              label: l10n?.accountHolderName ?? "Account Holder Name",
              hint: "Enter full name",
              controller: nameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            
            _buildInputField(
              label: l10n?.accountNumber ?? "Account Number",
              hint: "Enter your account number",
              controller: accNumberController,
              icon: Icons.account_balance_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            
            _buildInputField(
              label: l10n?.ifscCode ?? "IFSC Code",
              hint: "Enter 11-digit IFSC",
              controller: ifscController,
              icon: Icons.code,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            
            _buildInputField(
              label: l10n?.bankName ?? "Bank Name",
              hint: "e.g. State Bank of India",
              controller: bankNameController,
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: 20),
            
            _buildInputField(
              label: l10n?.branchName ?? "Branch Name",
              hint: "Enter branch office name",
              controller: branchController,
              icon: Icons.location_on_outlined,
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement save logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n?.addBank ?? "ADD BANK ACCOUNT",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F4C81),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF3882F6), size: 22),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF3882F6), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
