import 'package:flutter/material.dart';
import '../../models/business_details_model.dart';
import 'step_gst.dart';

class StepIndustry extends StatefulWidget {
  final BusinessDetailsModel model;

  const StepIndustry({super.key, required this.model});

  @override
  State<StepIndustry> createState() => _StepIndustryState();
}

class _StepIndustryState extends State<StepIndustry> {
  String? _selected;
  String _searchQuery = "";

  final List<Map<String, dynamic>> industryGroups = [
    {
      "header": "Popular Industries",
      "items": [
        {
          "title": "Electronics",
          "subtitle": "ACs, TVs, Laptops, Geysers, Washing machines"
        },
        {
          "title": "FMCG",
          "subtitle": "Rice, Oils, Dals, Tea, Beverages, Cosmetics"
        },
        {
          "title": "Garment/Clothing",
          "subtitle": "T-shirts, Shirts, Pants, Suits, Sarees, Dresses"
        },
        {
          "title": "Hardware",
          "subtitle": "Pipes, PVC tubes, Pumps, Fittings, Bolts"
        },
        {
          "title": "Mobile and accessories",
          "subtitle": "Smartphones, Chargers, Earphones"
        },
      ]
    },

    {
      "header": "Services",
      "items": [
        {
          "title": "Accounting and Financial Services",
          "subtitle": "GST filing, GST returns, Income tax filing"
        },
        {"title": "Consulting", "subtitle": ""},
        {"title": "Doctor / Clinic / Hospital", "subtitle": ""},
        {"title": "Education-Schooling/Coaching", "subtitle": ""},
        {"title": "Event planning and management", "subtitle": ""},
        {
          "title": "Fitness - Gym and Spa",
          "subtitle": "Fitness centres, Yoga studios, Nutrition, Dance studios"
        },
        {
          "title": "Home services",
          "subtitle": "Plumbing, Painting, Carpentry, Electrician, Cleaning"
        },
        {"title": "Hotels and Hospitality", "subtitle": ""},
        {"title": "Other services", "subtitle": ""},
        {
          "title": "Photography",
          "subtitle": "Passport photos, Wedding photos, Photoshoots"
        },
        {
          "title": "Real estate - Rentals and Lease",
          "subtitle": ""
        },
        {"title": "Restaurants/ Cafe/ Catering", "subtitle": ""},
        {"title": "Salon", "subtitle": "Beauty parlour, Spa"},
        {
          "title": "Service Centres",
          "subtitle": "Auto repairs, Mobile repairs, Laptop repairs, Cycle repairs"
        },
        {"title": "Tailoring/ Boutique", "subtitle": ""},
        {"title": "Tours and Travel", "subtitle": ""},
        {"title": "Transport and Logistics", "subtitle": ""},
      ]
    },

    {
      "header": "All Industries",
      "items": [
        {
          "title": "Agriculture",
          "subtitle": "Grains, Fertilisers, Seeds, Pesticides, Poultry"
        },
        {
          "title": "Automobile",
          "subtitle": "Tyres, Spare parts, Lubricants, Accessories"
        },
        {"title": "Battery", "subtitle": "Inverter, UPS"},
        {
          "title": "Broadband/ cable/ internet",
          "subtitle": "Settop box, Routers, Cables, Wifi"
        },
        {
          "title": "Building Material and Construction",
          "subtitle": "Sand, Concrete, Bricks, Cement"
        },
        {"title": "Cleaning and Pest Control", "subtitle": ""},
        {"title": "Dairy (Milk)", "subtitle": "Milk, Ghee, Paneer, Lassi"},
        {
          "title": "Electrical works",
          "subtitle": "Wires, Switches, Fanbox, Bulbs, Coils"
        },
        {
          "title": "Engineering",
          "subtitle": "Rolling shutters, Fabrications, Grills, Gates, Steel"
        },
        {
          "title": "Footwear",
          "subtitle": "Sandals, Shoes, Slippers, Boots"
        },
        {"title": "Fruits and Vegetables", "subtitle": ""},
        {
          "title": "Furniture",
          "subtitle": "Mattress, Cupboards, Chair, Sofas, Tables, Beds"
        },
        {
          "title": "General Store(Kirana)",
          "subtitle": "Snacks, Household items, Daily needs"
        },
        {
          "title": "Gift Shop",
          "subtitle": "Gift boxes, Greeting cards, Keychains"
        },
        {
          "title": "Information Technology",
          "subtitle": "Softwares, Printers, Computers"
        },
        {
          "title": "Interiors",
          "subtitle": "Modular kitchen, Wardrobe interiors, Curtains, Blinds"
        },
        {
          "title": "Safety Equipments",
          "subtitle": "Helmets, Belts, Alarms, Extinguishers, Detectors"
        },
        {"title": "Scrap", "subtitle": "Iron scrap, Plastic scrap, Metal scrap"},
        {
          "title": "Sports Equipments",
          "subtitle": "Bats, Rackets, Tennis balls, Swimwear"
        },
        {
          "title": "Stationery",
          "subtitle": "Books, Pencils, Pens, Dusters, Envelopes"
        },
        {
          "title": "Textiles",
          "subtitle": "Mats, Yarn, Fabrics, Handlooms, Dyes"
        },
        {
          "title": "Tiles/Sanitary Ware",
          "subtitle":
          "Tiles, Marbles, Ceramics, Sanitary tanks, Wash basins, Fittings"
        },
        {
          "title": "Utensils",
          "subtitle": "Cookers, Bowls, Tawa, Spoons, Glasses"
        },
        {"title": "Meat", "subtitle": ""},
        {
          "title": "Medical Devices",
          "subtitle":
          "Medical Equipment, Surgical Instruments, Hospital Supplies"
        },
        {
          "title": "Medicine(Pharma)",
          "subtitle":
          "Medicine, Chemist , Biomedical, Medical equipments"
        },
        {"title": "Oil And Gas", "subtitle": ""},
        {
          "title": "Opticals",
          "subtitle": "Glasses, Lenses, Frames, Sunglasses"
        },
        {"title": "Others", "subtitle": ""},
        {
          "title": "Packaging",
          "subtitle": "Polythene covers, Bubble wraps and Protection sheets"
        },
        {"title": "Paints", "subtitle": "Wall paints, Primer, Putty, Textures"},
        {"title": "Plywood", "subtitle": ""},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: const Text(
          "Select Industry",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "It helps us customize app according to your industry",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search by Industry Type",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ========================= FIXED LISTVIEW =========================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              physics: const BouncingScrollPhysics(),
              itemCount: industryGroups.length,
              itemBuilder: (context, gIndex) {
                final group = industryGroups[gIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      color: Colors.grey.shade100,
                      child: Text(
                        group["header"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    ...List.generate(group["items"].length, (i) {
                      final item = group["items"][i];

                      final title = item["title"].toString().toLowerCase();
                      final subtitle = item["subtitle"].toString().toLowerCase();

                      if (_searchQuery.isNotEmpty &&
                          !title.contains(_searchQuery) &&
                          !subtitle.contains(_searchQuery)) {
                        return const SizedBox.shrink();
                      }

                      final isSelected =
                          _selected == item["title"].toString().trim();

                      return InkWell(
                        onTap: () {
                          setState(() =>
                          _selected = item["title"].toString().trim());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                              BorderSide(width: 0.5, color: Colors.black12),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["title"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item["subtitle"] != "")
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          item["subtitle"],
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color: isSelected
                                        ? primary
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                                    : null,
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () {
                  widget.model.industry = _selected;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StepGST(model: widget.model)),
                  );
                },

                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  // 🔥 SAME COLORS AS "ENTER BUSINESS DETAILS"
                  backgroundColor:
                  _selected == null ? Colors.purple.shade100 : const Color(0xFF4C3FF0),
                  foregroundColor: Colors.white,
                ),

                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}
