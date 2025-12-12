import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Map invoiceData;
  const InvoicePreviewScreen({super.key, required this.invoiceData});

  @override
  Widget build(BuildContext context) {

    final party = invoiceData["party"] ?? {};
    final items = invoiceData["items"] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Invoice Created"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ⭐ Invoice Box Frame
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // BUSINESS NAME
                Text(
                  "CENTRAL WARE HOUSING CORP. LTD.",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text("GSTIN ${party["gst_number"] ?? ""}"),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Invoice No: ${invoiceData["invoice_number"]}"),
                        Text("Invoice Date: ${_format(invoiceData["invoice_date"])}"),
                        Text("Due Date: ${_format(invoiceData["due_date"])}"),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),

                // BILL TO
                Text("Bill To", style: title),
                Text(party["party_name"] ?? ""),
                Text("${party["billing_city"]}, ${party["billing_state"]} - ${party["billing_pincode"]}"),
                Text("Mobile: ${party["contact_number"] ?? ""}"),
                const SizedBox(height: 20),

                // ITEMS TABLE
                const Text("Items", style: title),
                const SizedBox(height: 8),

                Table(
                  border: TableBorder.all(color: Colors.black38),
                  columnWidths: const {
                    0: FixedColumnWidth(40),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(50),
                    3: FixedColumnWidth(60),
                    4: FixedColumnWidth(60),
                  },
                  children: [
                    // Header row
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade300),
                      children: [
                        cell("No", bold: true),
                        cell("Item", bold: true),
                        cell("Qty", bold: true),
                        cell("Rate", bold: true),
                        cell("Total", bold: true),
                      ],
                    ),

                    // Dynamic item rows
                    ...List.generate(items.length, (i) {
                      final it = items[i];
                      return TableRow(
                        children: [
                          cell("${i + 1}"),
                          cell(it["description"]),
                          cell("${it["qty"]}"),
                          cell("₹ ${it["price"]}"),
                          cell("₹ ${it["line_total"]}"),
                        ],
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 22),

                // TOTAL SUMMARY
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Subtotal: ₹ ${invoiceData["subtotal"]}", style: summary),
                      Text("Tax: ₹ ${invoiceData["total_tax"]}", style: summary),
                      Text(
                        "Grand Total: ₹ ${invoiceData["grand_total"]}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 25),

          // PAYMENT STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                party["party_name"] ?? "",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹ ${invoiceData["grand_total"]}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 6),
          const Text("Unpaid", style: TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(height: 20),

          // SHARE PAYMENT LINK BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.share),
              label: const Text("Share Payment Link"),
              onPressed: () {},
            ),
          ),
        ],
      ),

      // FOOTER BUTTONS
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            bottomBtn(Icons.print, "Print"),
            bottomBtn(Icons.download, "Download"),
            bottomBtn(Icons.share, "Share"),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Done"),
            ),
          ],
        ),
      ),
    );
  }

  static String _format(String? dt) {
    if (dt == null) return "";
    return DateFormat("dd/MM/yyyy").format(DateTime.parse(dt));
  }
}

// ---------------------------
// BELOW CLASS (REQUIRED)
// ---------------------------

const title = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
const summary = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);

// Cell widget for table
Widget cell(String text, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.all(6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
}

// Bottom icon button
Widget bottomBtn(IconData icon, String text) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 28),
      const SizedBox(height: 4),
      Text(text),
    ],
  );
}
