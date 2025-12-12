import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../models/business_details_model.dart';
import 'step_business_type.dart';

class StepCityBilling extends StatefulWidget {
  final BusinessDetailsModel model;

  const StepCityBilling({super.key, required this.model});

  @override
  State<StepCityBilling> createState() => _StepCityBillingState();
}

class _StepCityBillingState extends State<StepCityBilling> {
  String? _city;
  String? _billing;
  String? _language;

  List<String> _cities = [];
  List<String> _filteredCities = [];

  final _languages = ["English", "Hindi", "Tamil", "Kannada"];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  // ---------------------- LOAD ALL INDIA CITIES ----------------------
  Future<void> _loadCities() async {
    final jsonString =
    await rootBundle.loadString("assets/data/india_cities.json");
    final List data = json.decode(jsonString);

    setState(() {
      _cities = data.map((e) => e.toString()).toList();
      _filteredCities = _cities;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF4C3FF0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enter Business Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: _cities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- CITY --------------------
            const SizedBox(height: 10),
            const Text(
              "Which City *",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // 🔥 REPLACED WITH SEARCHABLE MODAL SELECTOR
            InkWell(
              onTap: () => _openCitySelector(context),
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(
                  _city ?? "Search Cities",
                  style: TextStyle(
                    fontSize: 16,
                    color: _city == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ----------------- BILLING ------------------
            const Text(
              "Select your billing requirement*",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            _billingCard(
              title: "Basic Billing on Android App",
              value: "Basic Billing on Android App",
              icon: Icons.phone_iphone,
            ),

            _billingCard(
              title:
              "Billing, Stock Keeping, Collections on Laptop & App",
              value: "Billing + Stock Keeping",
              icon: Icons.devices,
            ),

            const SizedBox(height: 30),

            // ----------------- LANGUAGE ------------------
            const Text(
              "What language do you like to talk in?",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField(
              value: _language,
              decoration: InputDecoration(
                hintText: "Select Language",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _languages
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _language = v),
            ),

            const SizedBox(height: 30),

            // ---------------- SAFE MESSAGE ----------------
            Row(
              children: const [
                Icon(Icons.lock, size: 16, color: Colors.green),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Your data is safe. We do not share your data.",
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ------------------ CONTINUE BUTTON ------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_city != null &&
                    _billing != null &&
                    _language != null)
                    ? () {
                  widget.model.city = _city;
                  widget.model.billingRequirement = _billing;
                  widget.model.language = _language;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StepBusinessType(model: widget.model),
                    ),
                  );
                }
                    : null,
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
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------
  // ⭐ CITY SELECTOR BOTTOM SHEET (NEW)
  // --------------------------------------------------------------------
  void _openCitySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        TextEditingController manualCityController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search City",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            _filteredCities = _cities
                                .where((city) =>
                                city.toLowerCase().contains(query.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Result list OR message
                    Expanded(
                      child: _filteredCities.isNotEmpty
                          ? ListView.builder(
                        itemCount: _filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = _filteredCities[index];
                          return ListTile(
                            title: Text(city),
                            onTap: () {
                              setState(() => _city = city);
                              Navigator.pop(context);
                            },
                          );
                        },
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "City not found",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C3FF0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: () {
                              // open manual input box
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: const Text("Enter City Name"),
                                    content: TextField(
                                      controller: manualCityController,
                                      decoration: const InputDecoration(
                                        hintText: "Type your city",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (manualCityController.text.trim().isNotEmpty) {
                                            setState(() {
                                              _city = manualCityController.text.trim();
                                            });
                                            Navigator.pop(context); // close dialog
                                            Navigator.pop(context); // close bottom sheet
                                          }
                                        },
                                        child: const Text("Save"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text(
                              "City not found? Add manually",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  // --------------------------------------------------------------------
  // BILLING OPTION CARD UI — EXACT SCREENSHOT STYLE
  // --------------------------------------------------------------------
  Widget _billingCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final selected = _billing == value;

    return InkWell(
      onTap: () => setState(() => _billing = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4C3FF0) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4C3FF0)),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Radio<String>(
              value: value,
              groupValue: _billing,
              activeColor: const Color(0xFF4C3FF0),
              onChanged: (v) => setState(() => _billing = v),
            ),
          ],
        ),
      ),
    );
  }
}
