enum ItemStatus { pass, attention, fail }

class ComponentResult {
  final String title;
  ItemStatus status;
  String notes;
  List<String> photoPaths;
  bool isRoadworthyRelevant;

  ComponentResult({
    required this.title,
    this.status = ItemStatus.pass,
    this.notes = '',
    this.photoPaths = const [],
    this.isRoadworthyRelevant = false,
  });
}

class TyreResult {
  final String position; // e.g., "Front Left", "Rear Right"
  int treadDepthMm;
  ItemStatus status;
  String notes;

  TyreResult({
    required this.position,
    this.treadDepthMm = 8,
    this.status = ItemStatus.pass,
    this.notes = '',
  });

  void evaluateRoadworthyLimit() {
    if (treadDepthMm <= 0) {
      status = ItemStatus.fail;
    } else if (treadDepthMm <= 1) {
      status = ItemStatus.attention;
    } else {
      status = ItemStatus.pass;
    }
  }
}
