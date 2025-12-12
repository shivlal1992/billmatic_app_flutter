// --------------------------------------------------------------
// FULL UPDATED FILE WITH IMEI / SERIAL NO (placed ABOVE UNIT)
// --------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_invoice_screen.dart'; // ⬅️ IMPORTANT (Added)

const String baseUrl = "http://127.0.0.1:8000/api";

class CreateNewItemScreen extends StatefulWidget {
  final Color primary;
  const CreateNewItemScreen({super.key, required this.primary});

  @override
  State<CreateNewItemScreen> createState() => _CreateNewItemScreenState();
}

class _CreateNewItemScreenState extends State<CreateNewItemScreen>
    with SingleTickerProviderStateMixin {

  // ------------------------------------------------------------------
  // REQUIRED VARIABLES (FIXED THE RED ERROR)
  // ------------------------------------------------------------------
  bool showImeiRow = false;        // ← now IMEI section appears only after click
  List<String> imeiList = [];      // ← stores IMEI numbers
  String inventoryTracking = "Qty";

  late TabController _tabController;

  // BASIC
  TextEditingController nameCtrl = TextEditingController();
  String itemType = "product";

  // PRICING
  String selectedUnit = "PCS";
  TextEditingController salesPriceCtrl = TextEditingController();
  TextEditingController purchasePriceCtrl = TextEditingController();
  String gstPercent = "None";
  TextEditingController hsnCtrl = TextEditingController();

  // STOCK
  TextEditingController openingStockCtrl = TextEditingController();
  DateTime stockAsOfDate = DateTime.now();
  TextEditingController itemCodeCtrl = TextEditingController();
  TextEditingController barcodeCtrl = TextEditingController();

  // CATEGORY
  List<ItemCategory> categories = [];
  String? selectedCategoryId;

  // OTHER
  TextEditingController descriptionCtrl = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCategories();
  }

  // LOAD CATEGORIES
  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final res = await http.get(
      Uri.parse("$baseUrl/item-categories"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        categories = (json["data"] as List)
            .map((e) => ItemCategory.fromJson(e))
            .toList();
      });
    }
  }

  // SAVE ITEM
  Future<void> saveItem() async {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item name is required")),
      );
      return;
    }

    // If inventoryTracking is IMEI, prefer opening stock = number of IMEIs (if user hasn't set opening stock)
    if (inventoryTracking == "IMEI") {
      final count = imeiList.length;
      if (openingStockCtrl.text.trim().isEmpty) {
        openingStockCtrl.text = count.toString();
      }
    }

    setState(() => saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final body = {
        "name": nameCtrl.text.trim(),
        "item_type": itemType,
        // send inventory_tracking_by and imei_list
        "inventory_tracking_by": inventoryTracking == "IMEI" ? "IMEI" : "Qty",
        "imei_list": imeiList, // will be an empty list if none
        "unit": selectedUnit,
        "sales_price": double.tryParse(salesPriceCtrl.text) ?? 0,
        "purchase_price": double.tryParse(purchasePriceCtrl.text) ?? 0,
        "gst_percent": gstPercent == "None" ? 0 : double.tryParse(_extractNumberFromGst(gstPercent)) ?? 0,
        "hsn_code": hsnCtrl.text,
        "opening_stock": double.tryParse(openingStockCtrl.text) ?? 0,
        "stock_as_of_date": DateFormat("yyyy-MM-dd").format(stockAsOfDate),
        "item_code": itemCodeCtrl.text,
        "barcode": barcodeCtrl.text,
        "item_category_id": selectedCategoryId,
        "description": descriptionCtrl.text,
      };

      final res = await http.post(
        Uri.parse("$baseUrl/items"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res.body.toString())));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => saving = false);
    }
  }

  // small helper to extract numeric percent from GST label "GST @ 5%" -> "5"
  String _extractNumberFromGst(String label) {
    final regex = RegExp(r'[-+]?\d*\.?\d+');
    final match = regex.firstMatch(label);
    return match?.group(0) ?? "0";
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0.4,
              foregroundColor: Colors.black,
              title: const Text(
                "Create New Item",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),

            PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: primary,
                  indicatorColor: primary,
                  unselectedLabelColor: Colors.black54,
                  tabs: const [
                    Tab(text: "Pricing"),
                    Tab(text: "Stock"),
                    Tab(text: "Other"),
                    Tab(text: "Party Wise Prices"),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  pricingTab(primary),
                  stockTab(primary),
                  categories.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : otherTab(primary),
                  partyWiseTab(),
                ],
              ),
            ),
          ],
        ),
      ),

      // *********************************************************************
      // UPDATED BOTTOM BUTTONS (Add More Details → Invoice Screen)
      // *********************************************************************
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NEW BUTTON → Add More Details
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateInvoiceScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Add More Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // SAVE Button
            ElevatedButton(
              onPressed: saving ? null : saveItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Save",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
// PRICING TAB (PERFECT BILLBOOK ALIGNMENT)
// ----------------------------------------------------------
  Widget pricingTab(Color primary) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        fieldLabel("Item Name *"),
        textField(nameCtrl, "Ex:Kissan Fruit Jam 500 gm"),
        const SizedBox(height: 25),

        fieldLabel("Item Type"),
        Row(
          children: [
            typeBtn("Product"),
            const SizedBox(width: 12),
            typeBtn("Service"),
          ],
        ),
        const SizedBox(height: 25),

        // ---------------------------------------------------
        // INVENTORY TRACKING (button only first)
        // ---------------------------------------------------
        Row(
          children: [
            const Expanded(
              child: Text(
                "Inventory Tracking By",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ---------- BUTTON (When click → show IMEI row) ----------
            InkWell(
              onTap: () {
                setState(() {
                  showImeiRow = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary),
                ),
                child: Text(
                  "IMEI/Serial No",
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ---------------------------------------------------
        // SHOW THIS ONLY AFTER BUTTON CLICK
        // ---------------------------------------------------
        if (showImeiRow)
          GestureDetector(
            onTap: () async {
              final updated = await Navigator.push<List<String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => ImeiListScreen(initial: imeiList),
                ),
              );
              if (updated != null) setState(() => imeiList = updated);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE7E4F8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, size: 20),
                  const SizedBox(width: 12),
                  const Text(
                    "IMEI/Serial No",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    "${imeiList.length} PCS",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Colors.black54),
                ],
              ),
            ),
          ),

        if (showImeiRow) const SizedBox(height: 25),

        // ---------- UNIT ----------
        fieldLabel("Unit"),
        safeDropdown(
          selectedUnit,
          ["PCS", "KG", "LTR", "BOX"],
              (v) => setState(() => selectedUnit = v!),
        ),
        const SizedBox(height: 25),

        fieldLabel("Sales Price"),
        textField(salesPriceCtrl, "₹ 130", number: true),
        const SizedBox(height: 25),

        fieldLabel("Purchase Price"),
        textField(purchasePriceCtrl, "₹ 115", number: true),
        const SizedBox(height: 25),

        fieldLabel("GST"),
        safeDropdown(
          gstPercent,
          [
            "None",
            "TAX Exempted",
            "GST @ 0%",
            "GST @ 0.1%",
            "GST @ 0.25%",
            "GST @ 1.5%",
            "GST @ 3%",
            "GST @ 5%",
            "GST @ 6%",
            "GST @ 8.9%",
            "GST @ 12% Not Applicable after 22 Sep'25",
            "GST @ 13.8%",
            "GST @ 14% + Cess @ 12%",
            "GST @ 18%",
            "GST @ 28% Not Applicable after 22 Sep'25",
            "GST @ 28% + Cess @5%",
            "GST @ 28% + Cess @ 36%",
            "GST @ 28% + Cess @ 60%",
            "GST @ 40%",
          ],
              (v) => setState(() => gstPercent = v!),
        ),
        const SizedBox(height: 25),

        fieldLabel("HSN"),
        textField(hsnCtrl, "Ex:6704"),
      ],
    );
  }


  // ----------------------------------------------------------
  // STOCK TAB
  // ----------------------------------------------------------
  Widget stockTab(Color primary) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        fieldLabel("Opening Stock"),
        textField(openingStockCtrl, "0", number: true),
        const SizedBox(height: 25),

        fieldLabel("As of Date"),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: stockAsOfDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) setState(() => stockAsOfDate = date);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: boxBox(),
            child: Row(
              children: [
                Text(DateFormat("dd MMM yyyy").format(stockAsOfDate)),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),

        fieldLabel("Item Code"),
        textField(itemCodeCtrl, "ABC123"),
        const SizedBox(height: 25),

        fieldLabel("Barcode"),
        textField(barcodeCtrl, "Scan barcode"),
      ],
    );
  }

  // ----------------------------------------------------------
  // OTHER TAB
  // ----------------------------------------------------------
  Widget otherTab(Color primary) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        fieldLabel("Item Category"),
        safeDropdown(
          selectedCategoryId,
          categories.map((e) => e.id.toString()).toList(),
              (v) => setState(() => selectedCategoryId = v),
          labels: categories.map((e) => e.name).toList(),
        ),
        const SizedBox(height: 25),
        fieldLabel("Item Description"),
        textField(descriptionCtrl, "Description...", maxLines: 3),
      ],
    );
  }

  // PARTY WISE TAB
  Widget partyWiseTab() {
    return const Center(child: Text("Party wise pricing will be added later."));
  }

  // ----------------------------------------------------------
  // UI HELPERS
  // ----------------------------------------------------------
  Widget fieldLabel(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));
  }

  Widget textField(TextEditingController c, String hint,
      {bool number = false, int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget typeBtn(String text) {
    final selected = itemType == text.toLowerCase();
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => itemType = text.toLowerCase()),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.deepPurple.withOpacity(.1) : null,
            border: Border.all(
                color: selected ? Colors.deepPurple : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.deepPurple : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // SAFE DROPDOWN (FULLY FIXED – NEVER CRASHES)
  Widget safeDropdown(
      String? value, List<String> items, Function(String?) onChanged,
      {List<String>? labels}) {
    final String? fixedValue = value != null && items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: boxBox(),
      child: DropdownButton<String>(
        isExpanded: true,
        value: fixedValue,
        underline: const SizedBox(),
        hint: const Text("Select"),
        items: List.generate(items.length, (i) {
          return DropdownMenuItem(
            value: items[i],
            child: Text(labels != null ? labels[i] : items[i]),
          );
        }),
        onChanged: onChanged,
      ),
    );
  }

  BoxDecoration boxBox() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(10),
    );
  }
}

// ----------------------------------------------------------
// IMEI / SERIAL NO SCREEN (NEW)
// ----------------------------------------------------------
class ImeiListScreen extends StatefulWidget {
  final List<String>? initial;
  const ImeiListScreen({super.key, this.initial});

  @override
  State<ImeiListScreen> createState() => _ImeiListScreenState();
}

class _ImeiListScreenState extends State<ImeiListScreen> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = (widget.initial ?? []).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add IMEI/Serial No"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // placeholder illustration area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Icon(Icons.qr_code, size: 70, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text("Your IMEI/Serial No will appear here", style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                Text("You can add IMEI/Serial No by scanning numbers or manually typing",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13), textAlign: TextAlign.center),
              ],
            ),
          ),

          const SizedBox(height: 18),
          // buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openAddManually,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Manually"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _scanToAdd,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scan to Add"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text("No IMEI/Serial added yet"))
                : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final v = _items[i];
                return ListTile(
                  title: Text(v),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() => _items.removeAt(i));
                    },
                  ),
                );
              },
            ),
          ),
          // bottom bar with count and save
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text("${_items.length} PCS", style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _items);
                  },
                  child: const Text("Save"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // opens a dialog with a multi-line input - user can paste multiple IMEIs separated by newline
  void _openAddManually() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add IMEI/Serial (one per line)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: "123456789012345\n987654321098765\n...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final text = ctrl.text.trim();
                          if (text.isEmpty) {
                            Navigator.pop(ctx);
                            return;
                          }
                          final lines = text
                              .split(RegExp(r'[\r\n]+'))
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                          setState(() {
                            _items.addAll(lines);
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text("Add"),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // placeholder for scan; shows snackbar (implement scanner as needed)
  void _scanToAdd() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Scan feature not implemented in this build.")),
    );
  }
}

// ----------------------------------------------------------
// CATEGORY MODEL
// ----------------------------------------------------------
class ItemCategory {
  final int id;
  final String name;
  ItemCategory({required this.id, required this.name});

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
