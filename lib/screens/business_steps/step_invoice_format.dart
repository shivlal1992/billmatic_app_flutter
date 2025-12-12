import 'package:flutter/material.dart';
import '../../models/business_details_model.dart';
import '../../services/api_service.dart';
import '../home_screen.dart';

class StepInvoiceFormat extends StatefulWidget {
  final BusinessDetailsModel model;

  const StepInvoiceFormat({super.key, required this.model});

  @override
  State<StepInvoiceFormat> createState() => _StepInvoiceFormatState();
}

class _StepInvoiceFormatState extends State<StepInvoiceFormat> {
  String selectedSize = "A4 Size";
  int selectedTemplate = 1; // default template
  bool _loading = false;

  final primary = const Color(0xFF4C3FF0);

  // 10 template preview images
  final List<String> templates = List.generate(
    10,
        (i) => "assets/invoices/template_${i + 1}.png",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        foregroundColor: Colors.black,
        title: const Text(
          "Select your Invoice Format",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // ==========================================
          //  A4 / A5 / Thermal Selector
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildSizeButton("A4 Size"),
                const SizedBox(width: 10),
                _buildSizeButton("A5 Size"),
                const SizedBox(width: 10),
                _buildSizeButton("Thermal Printer Size"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ==========================================
          //  HORIZONTAL TEMPLATE SELECTOR (10 styles)
          // ==========================================
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final isSelected = selectedTemplate == index + 1;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedTemplate = index + 1);
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primary : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        templates[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Show selected template number
          Center(
            child: Column(
              children: [
                Text(
                  "Style ${selectedTemplate}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${selectedTemplate}/10",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ==========================================
          //  LARGE PREVIEW AREA
          // ==========================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    templates[selectedTemplate - 1],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ==========================================
          // SAVE BUTTON
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _loading ? Colors.purple.shade100 : primary,
                  foregroundColor: Colors.white, // ✅ WHITE TEXT WHEN ENABLED
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: _loading
                    ? null
                    : () async {
                  setState(() => _loading = true);

                  widget.model.invoiceFormat =
                  "$selectedSize - Template $selectedTemplate";

                  final res = await ApiService.submitBusinessDetails(
                      widget.model.toJson());

                  setState(() => _loading = false);

                  if (res['success'] == true) {
                    Navigator.pushReplacementNamed(
                        context, HomeScreen.routeName);
                  }
                },

                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Create bill with this format",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // ✅ WHITE COLOR TEXT
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // =========================================================
  // Size Button (A4 / A5 / Thermal)
  // =========================================================
  Widget _buildSizeButton(String label) {
    final bool selected = selectedSize == label;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => selectedSize = label);
        },
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? primary.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? primary : Colors.grey.shade400,
              width: selected ? 2 : 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? primary : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
