enum ItemStatus { pending, pass, attention, fail }

class ComponentResult {
  final String title;
  ItemStatus status;
  String notes;
  List<String> photoPaths;
  bool isRoadworthyRelevant;
  int rating = 0; // <--- ADD "= 0" HERE TO FIX THE ERROR

  ComponentResult({
    required this.title,
    this.status = ItemStatus.pending,
    this.notes = '',
    this.photoPaths = const [],
    this.isRoadworthyRelevant = false,
    this.rating = 0,
  });
}

class TyreResult {
  final String position; 
  int treadDepthMm;      
  ItemStatus status;
  String notes;
  
  // NEW: Deep Inspection Specs
  String size;
  String loadSpeedIndex;
  String make;
  String tyreModel;

  TyreResult({
    required this.position,
    this.treadDepthMm = 0, 
    this.status = ItemStatus.pending,
    this.notes = '',
    this.size = '',
    this.loadSpeedIndex = '',
    this.make = '',
    this.tyreModel = '',
  });

  void evaluateRoadworthyLimit() {
    // If it's less than 1mm, it's illegal. If they haven't filled out the make/model, hold it as pending.
    if (treadDepthMm <= 0) {
      status = ItemStatus.fail;
    } else if (treadDepthMm <= 1) {
      status = ItemStatus.attention;
    } else if (size.isEmpty || make.isEmpty) {
      status = ItemStatus.pending; // Gatekeeper lock: forces them to fill the text fields
    } else {
      status = ItemStatus.pass;
    }
  }
}