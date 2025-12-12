import 'package:flutter/material.dart';
import '../../models/business_details_model.dart';
import 'step_invoice_format.dart';

class StepGST extends StatefulWidget {
  final BusinessDetailsModel model;

  const StepGST({super.key, required this.model});

  @override
  State<StepGST> createState() => _StepGSTState();
}

class _StepGSTState extends State<StepGST> {
  bool? _gstRegistered;

  final TextEditingController _gst = TextEditingController();
  final TextEditingController _panCin = TextEditingController(); // PAN / CIN
  final TextEditingController _tradeUdyam = TextEditingController(); // 🔥 NEW FIELD

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF4C3FF0);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        foregroundColor: Colors.black,
        title: const Text(""),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Is your Business GST\nRegistered?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            const Text(
              "Automatically fill business details by adding gst number",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _buildOptionCard("Yes", true, primary),
                const SizedBox(width: 16),
                _buildOptionCard("No", false, primary),
              ],
            ),

            const SizedBox(height: 20),

            // GST Number (only when Yes)
            if (_gstRegistered == true) ...[
              const Text("GST Number",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              TextField(
                controller: _gst,
                decoration: InputDecoration(
                  hintText: "Eg: 22AAAAA0000A1Z5",
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],

            // ====================================================================
            // PAN / CIN + TRADE LICENSE / UDYAM (ONLY IF GST = NO)
            // ====================================================================
            if (_gstRegistered == false) ...[
              const Text(
                "Business / Personal PAN or Company CIN",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _panCin,
                decoration: InputDecoration(
                  hintText: "Enter PAN Number or CIN",
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Trade License / Udyam Registration Number",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _tradeUdyam,
                decoration: InputDecoration(
                  hintText: "Enter Trade License or Udyam Number",
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],

            Text(
              "Add Referral Code",
              style: TextStyle(
                color: primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            Row(
              children: const [
                Icon(Icons.lock_outline, color: Colors.green, size: 18),
                SizedBox(width: 6),
                Text(
                  "Your data is safe.",
                  style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "We do not share your data.",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _gstRegistered == null
                    ? null
                    : () {
                  widget.model.gstRegistered = _gstRegistered!;
                  widget.model.gstNumber =
                  _gstRegistered == true ? _gst.text : null;
                  widget.model.panCin =
                  _gstRegistered == false ? _panCin.text : null;

                  // 🔥 NEW FIELD ADDED
                  widget.model.tradeLicenseOrUdyam =
                  _gstRegistered == false ? _tradeUdyam.text : null;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StepInvoiceFormat(model: widget.model),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _gstRegistered == null ? Colors.purple.shade100 : primary,

                  foregroundColor:
                  _gstRegistered == null ? Colors.grey.shade600 : Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _gstRegistered == null
                        ? Colors.grey.shade600
                        : Colors.white, // ✅ WHITE WHEN ACTIVE
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

          ],
        ),
      ),
    );
  }

  // WIDGET FOR RADIO-LIKE CARDS
  Widget _buildOptionCard(String label, bool value, Color primary) {
    final isSelected = _gstRegistered == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _gstRegistered = value);
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primary : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
