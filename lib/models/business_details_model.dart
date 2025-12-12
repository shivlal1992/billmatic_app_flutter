class BusinessDetailsModel {
  String? city;
  String? billingRequirement;
  String? language;

  // Supports multiple business types
  List<String>? businessType;

  String? industry;
  bool gstRegistered = false;
  String? gstNumber;
  String? invoiceFormat;

  // For PAN or CIN when GST = No
  String? panCin;

  // 🔥 NEW FIELD — Trade License / Udyam Registration
  String? tradeLicenseOrUdyam;

  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "billing_requirement": billingRequirement,
      "language": language,
      "business_type": businessType,
      "industry": industry,
      "gst_registered": gstRegistered,

      "gst_number": gstRegistered ? gstNumber : null,

      // For GST = No users
      "pan_cin": !gstRegistered ? panCin : null,

      // 🔥 NEW FIELD SENT TO API
      "trade_license_or_udyam": !gstRegistered ? tradeLicenseOrUdyam : null,

      "invoice_format": invoiceFormat,
    };
  }
}
