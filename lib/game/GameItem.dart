class GameItem {
  final int id;
  final String name; // Original name from API
  final String nameHindi; // Hindi name from API (if available)
  final String type;
  final String image;
  final bool sessionSelection;
  String
  currentDisplayName; // Display name (initially original, then translated)

  GameItem({
    required this.id,
    required this.name,
    this.nameHindi = '',
    required this.type,
    required this.image,
    required this.sessionSelection,
    String?
    currentDisplayName, // Make optional in constructor for initial assignment
  }) : this.currentDisplayName =
           currentDisplayName ??
           name; // Default to original name if not provided

  factory GameItem.fromJson(Map<String, dynamic> json) {
    // Safely extract nameHindi - handle null explicitly
    String nameHindiValue = '';
    if (json['nameHindi'] != null && json['nameHindi'].toString().isNotEmpty) {
      nameHindiValue = json['nameHindi'].toString();
    } else if (json['name_hindi'] != null &&
        json['name_hindi'].toString().isNotEmpty) {
      nameHindiValue = json['name_hindi'].toString();
    } else if (json['gameNameHindi'] != null &&
        json['gameNameHindi'].toString().isNotEmpty) {
      nameHindiValue = json['gameNameHindi'].toString();
    }

    return GameItem(
      id: json['id'] ?? 0,
      name: (json['name'] ?? '').toString(),
      nameHindi: nameHindiValue,
      type: (json['type'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      sessionSelection: json['sessionSelection'] == true,
      // currentDisplayName is initialized in the constructor after fromJson is called
    );
  }

  // Method to update display name
  void updateDisplayName(String newName) {
    currentDisplayName = newName;
  }
}
