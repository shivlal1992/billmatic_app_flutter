import 'package:flutter/material.dart';
import 'create_invoice_screen.dart'; // ⬅️ add this import

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int navIndex = 0;

  final Color primary = const Color(0xFF4C3FF0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===============================
      // APP BAR
      // ===============================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            const Text(
              "CENTRAL WARE HOUSING ...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            const Spacer(),
            Icon(Icons.calculate_outlined, color: primary, size: 26),
            const SizedBox(width: 10),
            Icon(Icons.card_giftcard, color: Colors.orange, size: 26),
            const SizedBox(width: 10),
            Icon(Icons.document_scanner_outlined, color: Colors.red, size: 26),
            const SizedBox(width: 12),
          ],
        ),
      ),

      // ===============================
      // BODY CONTENT
      // ===============================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Now generate GST e-Invoice & e-Way Bills on Mobile easily!\n\nTRY NOW ➜",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/invoice_sample.png",
                    height: 90,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Row: To Collect + To Pay
            Row(
              children: [
                _buildAmountCard("₹ 2,923", "To Collect", Colors.green),
                const SizedBox(width: 12),
                _buildAmountCard("₹ 0", "To Pay", Colors.red),
              ],
            ),

            const SizedBox(height: 12),

            // Row: Stock Value + Week Sale
            Row(
              children: [
                _buildSimpleCard("Stock Value", "Value of Items"),
                const SizedBox(width: 12),
                _buildSimpleCard("₹ 2,723", "This week's sale"),
              ],
            ),

            const SizedBox(height: 12),

            // Row: Total Balance + Reports
            Row(
              children: [
                _buildSimpleCard("Total Balance", "Cash + Bank Balance"),
                const SizedBox(width: 12),
                _buildSimpleCard("Reports", "Sales, Party, GST..."),
              ],
            ),

            const SizedBox(height: 24),

            // Subscription
            ListTile(
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.workspace_premium, color: Colors.orange),
              title: const Text(
                "myBillBook Subscription Plan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const SizedBox(height: 10),

            const Text(
              "Transactions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Spacer(),
                Text(
                  "LAST 365 DAYS",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Transaction Card
            _buildTransactionCard(
              name: "Samu",
              invoice: "Invoice #4",
              date: "08 Dec • 7 day(s) to due",
              amount: "₹ 300",
              status: "Unpaid",
            ),

            const SizedBox(height: 12),

            // Action Buttons: Received Payment / + / +Bill-Invoice
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _roundAction("Received Payment", Colors.black87, null),
                _roundPlus(),
                _roundAction(
                  "+ Bill / Invoice",
                  primary,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateInvoiceScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // ===============================
      // BOTTOM NAVIGATION
      // ===============================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navIndex,
        onTap: (index) => setState(() => navIndex = index),
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Parties"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Items"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "For You"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),
    );
  }

  // ===============================
  //  Widgets
  // ===============================

  Widget _buildAmountCard(String amount, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(amount,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCard(String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String name,
    required String invoice,
    required String date,
    required String amount,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(invoice, style: const TextStyle(color: Colors.blue)),
          Text(date, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(amount,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status,
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text("₹ Record Manually",
                  style: TextStyle(color: Colors.blue)),
              Spacer(),
              Text("Share Payment Link",
                  style: TextStyle(color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundAction(String text, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _roundPlus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
