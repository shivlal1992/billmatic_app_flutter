import 'package:flutter/material.dart';
import '../../models/business_details_model.dart';
import 'step_industry.dart';

class StepBusinessType extends StatefulWidget {
  final BusinessDetailsModel model;

  const StepBusinessType({super.key, required this.model});

  @override
  State<StepBusinessType> createState() => _StepBusinessTypeState();
}

class _StepBusinessTypeState extends State<StepBusinessType> {
  // MULTIPLE SELECT LIST
  List<String> _selectedTypes = [];

  final _types = [
    "Retailer",
    "Wholesaler",
    "Distributor",
    "Manufacturer",
    "Services"
  ];

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4C3FF0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Type of Business",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            // BUSINESS TYPE CHECKBOX CARDS
            ..._types.map((t) => _businessTypeCard(t)).toList(),

            const Spacer(),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTypes.isEmpty
                    ? null
                    : () {
                  // Save MULTIPLE VALUES instead of one
                  widget.model.businessType = _selectedTypes;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StepIndustry(model: widget.model)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primary,
                  disabledBackgroundColor: Colors.purple.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // BUSINESS TYPE CARD — MULTIPLE SELECT ENABLED
  // ----------------------------------------------------------------------
  Widget _businessTypeCard(String text) {
    final isSelected = _selectedTypes.contains(text);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTypes.remove(text);
          } else {
            _selectedTypes.add(text);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4C3FF0) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? const Color(0xFF4C3FF0) : Colors.black54,
              size: 24,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
