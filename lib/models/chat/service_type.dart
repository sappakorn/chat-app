class Types {
  final String icon;
  final String value;
  final String? label_th;
  final String? label_en;
  final String? label_ch;

  Types({
    required this.icon,
    required this.value,
    this.label_th = "สอบถามเกี่ยวกับสินค้า",
    this.label_en = "", 
    this.label_ch = "", 
  });

  factory Types.fromJson(Map<String, dynamic> json) {
    return Types(
      icon: json['icon'] ?? '', 
      value: json['value'] ?? '',
      label_th: json['label_th'] ?? 'Unknown',
      label_en: json['label_en'] ?? '',
      label_ch: json['label_ch'] ?? '',
    );
  }
}

