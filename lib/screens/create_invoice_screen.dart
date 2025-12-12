import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'party_flow_screens.dart';
import 'add_items_screen.dart';
import 'invoice_preview_screen.dart';


const String baseUrl = 'http://127.0.0.1:8000/api';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final Color primary = const Color(0xFF4C3FF0);

  String invoiceNumberDisplay = "Invoice #1";
  String invoiceCode = "INV-1";
  DateTime invoiceDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(const Duration(days: 7));

  PartyModel? selectedParty;

  List<InvoiceItem> items = [];
  double subtotal = 0;
  double totalTax = 0;
  double grandTotal = 0;

  String placeOfSupply = "Maharashtra";

  bool _loading = false;

  final dateFormatter = DateFormat('dd MMM yyyy');

  // ------------------------------------------------------------------
  // ⭐ UPDATE PART → AUTO FETCH LAST INVOICE NUMBER
  // ------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _fetchLastInvoiceNumber();
  }

  Future<void> _fetchLastInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/invoices/last-number"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        int lastNo = data["last_number"] ?? 0;
        int newNo = lastNo + 1;

        setState(() {
          invoiceCode = "INV-$newNo";
          invoiceNumberDisplay = "Invoice #$newNo";
        });
      }
    } catch (e) {
      debugPrint("Error fetching invoice number: $e");
    }
  }
  // ------------------------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        foregroundColor: Colors.black,
        title: const Text(
          "Create Bill / Invoice",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildInvoiceHeader(),
                const SizedBox(height: 20),
                _buildPartySection(),
                const SizedBox(height: 24),
                _buildItemsSection(),

                // ⭐ ADDED → Add More Details
                const SizedBox(height: 12),
                addMoreDetailsSection(),
                const SizedBox(height: 24),

                _buildTotalSection(),
              ],
            ),
          ),

          // Bottom button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loading ? null : _generateBill,
                    child: _loading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Generate Bill",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      "Your data is safe.",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      " Only you can see this data",
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ⭐ ADDED UI: Add More Details Section
  // ------------------------------------------------------------
  Widget addMoreDetailsSection() {
    return GestureDetector(
      onTap: showAddMoreDetailsSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Add more details",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 3),
            Text(
              "Additional charges, Round off…",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ⭐ ADDED: Bottom Sheet → More Options
  // ------------------------------------------------------------
  void showAddMoreDetailsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "More Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              optionTile(
                icon: Icons.add_circle_outline,
                title: "Additional Charges",
                subtitle: "Add packing, delivery charges etc.",
                onTap: () {
                  Navigator.pop(context);
                  openAdditionalChargesSheet();
                },
              ),

              optionTile(
                icon: Icons.percent,
                title: "Discount",
                subtitle: "Add invoice-level discount",
                onTap: () {
                  Navigator.pop(context);
                  openDiscountSheet();
                },
              ),

              optionTile(
                icon: Icons.calculate_outlined,
                title: "Round Off",
                subtitle: "Round the final invoice amount",
                onTap: () {
                  Navigator.pop(context);
                  openRoundOffSheet();
                },
              ),

              optionTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "Apply TCS",
                subtitle: "Apply TCS for this invoice",
                onTap: () {
                  Navigator.pop(context);
                  openTcsSheet();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper
  Widget optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple, size: 28),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      onTap: onTap,
    );
  }

  // ------------------------------------------------------------
  // ⭐ ADDED: Additional Charges Sheet
  // ------------------------------------------------------------
  void openAdditionalChargesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Additional Charges", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextField(
                decoration: const InputDecoration(
                  labelText: "Charge Name (e.g. Packing)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(onPressed: () {}, child: const Text("Apply")),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ⭐ ADDED: Discount Sheet
  // ------------------------------------------------------------
  void openDiscountSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Discount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextField(
                decoration: const InputDecoration(
                  labelText: "Discount Amount or %",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(onPressed: () {}, child: const Text("Apply")),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ⭐ ADDED: Round Off Sheet
  // ------------------------------------------------------------
  void openRoundOffSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Round Off", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text("Enable automatic round-off for final bill."),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ⭐ ADDED: TCS Sheet
  // ------------------------------------------------------------
  void openTcsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Apply TCS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "TCS %",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(onPressed: () {}, child: const Text("Apply")),
            ],
          ),
        );
      },
    );
  }

  // ------------------------ UI pieces ------------------------

  Widget _buildInvoiceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Invoice number + edit button
        Row(
          children: [
            Text(
              invoiceNumberDisplay,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3F3D56)),
            ),
            const Spacer(),
            SizedBox(
              height: 34,
              child: OutlinedButton(
                onPressed: _editInvoiceDates,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "EDIT",
                  style: TextStyle(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${dateFormatter.format(invoiceDate)}  -  7 day(s) to due",
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildPartySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PARTY NAME *",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _openSelectPartySheet,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedParty?.partyName ?? "Search/Create Party",
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedParty == null
                          ? Colors.black38
                          : Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed:
            selectedParty == null ? null : () => _editExistingParty(),
            child: const Text(
              "+ Edit Party",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4C3FF0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Place of supply row (like your later screenshot)
        if (selectedParty != null) ...[
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                "Place of Supply",
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(width: 6),
              Text(
                "- $placeOfSupply",
                style: const TextStyle(color: Colors.black54),
              ),
              const Spacer(),
              TextButton(
                onPressed: _editPlaceOfSupply,
                child: const Text(
                  "EDIT",
                  style: TextStyle(
                    color: Color(0xFF4C3FF0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          )
        ],
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ITEMS",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _openItemsPlaceholder, // for now, just placeholder
          child: Container(
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F1FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Add Items",
              style: TextStyle(
                color: Color(0xFF4C3FF0),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Total Amount",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Spacer(),
            const Text(
              "₹ ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              grandTotal.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------ Actions ------------------------

  Future<void> _editInvoiceDates() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        invoiceDate = picked;
        dueDate = picked.add(const Duration(days: 7));
      });
    }
  }

  Future<void> _openSelectPartySheet() async {
    final PartyModel? result = await showModalBottomSheet<PartyModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SelectPartySheet(primary: primary),
    );

    if (result != null) {
      setState(() {
        selectedParty = result;
      });
    }
  }

  // editing existing party can simply reopen CreateNewPartyScreen with initial data
  Future<void> _editExistingParty() async {
    if (selectedParty == null) return;

    final updated = await Navigator.push<PartyModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNewPartyScreen(
          primary: primary,
          initialParty: selectedParty,
        ),
      ),
    );

    if (updated != null) {
      setState(() => selectedParty = updated);
    }
  }

  Future<void> _editPlaceOfSupply() async {
    final controller = TextEditingController(text: placeOfSupply);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Place of Supply"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "State",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("OK")),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => placeOfSupply = result);
    }
  }

  void _openItemsPlaceholder() async {
    final updatedItems = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemsScreen(existingItems: items),
      ),
    );

    if (updatedItems != null) {
      setState(() {
        items = updatedItems;
        grandTotal = items.fold(0, (sum, e) => sum + (e.qty * e.price));
      });
    }
  }


  Future<void> _generateBill() async {
    if (selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a party first.")),
      );
      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add items")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? "";

      final body = {
        "invoice_number": invoiceCode,
        "invoice_date": DateFormat('yyyy-MM-dd').format(invoiceDate),
        "due_date": DateFormat('yyyy-MM-dd').format(dueDate),
        "party_id": selectedParty!.id,
        "place_of_supply": placeOfSupply,
        "notes": "Thank you for your business",
        "items": items.map((e) => e.toApiJson()).toList(),
      };

      final res = await http.post(
        Uri.parse("$baseUrl/invoices"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {

        // SUCCESS → GO TO INVOICE PREVIEW
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvoicePreviewScreen(invoiceData: data["data"]),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${res.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

}

// ------------------------------------------------------------
// Models used by invoice & parties
// ------------------------------------------------------------

class PartyModel {
  final int id;
  final String partyName;
  final String? contactNumber;
  final String? partyType;

  PartyModel({
    required this.id,
    required this.partyName,
    this.contactNumber,
    this.partyType,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'] as int,
      partyName: json['party_name'] ?? '',
      contactNumber: json['contact_number']?.toString(),
      partyType: json['party_type']?.toString(),
    );
  }
}

class InvoiceItem {
  final int itemId;
  final String description;
  final double qty;
  final String unit;
  final double price;
  final double discount;
  final double gstPercent;

  InvoiceItem({
    required this.itemId,
    required this.description,
    required this.qty,
    required this.unit,
    required this.price,
    this.discount = 0,
    this.gstPercent = 0,
  });

  Map<String, dynamic> toApiJson() {
    return {
      "item_id": itemId,
      "description": description,
      "qty": qty,
      "unit": unit,
      "price": price,
      "discount": discount,
      "gst_percent": gstPercent,
    };
  }
}
