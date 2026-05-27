enum ItemStatus { pass, attention, fail, na }

// Defines how the UI should render the evaluation buttons
enum EvaluationScale { binary, severity, dimensions }

class SubPhotoTarget {
  final String id;
  final String label;
  String? photoPath;
  ItemStatus status;
  String notes;

  SubPhotoTarget({
    required this.id,
    required this.label,
    this.photoPath,
    this.status = ItemStatus.na,
    this.notes = '',
  });
}

class ComponentResult {
  final String id;
  final String title;
  final bool isRoadworthyRelevant;
  final bool isCompulsory;
  bool isNotApplicable;
  final EvaluationScale
  scale; // Determines if it uses Pass/Fail or Nil/Slight/Appreciable
  final List<SubPhotoTarget> photoTargets;

  ComponentResult({
    required this.id,
    required this.title,
    this.isRoadworthyRelevant = false,
    this.isCompulsory = true,
    this.isNotApplicable = false,
    this.scale = EvaluationScale.binary, // Defaults to standard Pass/Fail
    required this.photoTargets,
  });

  ItemStatus get finalStatus {
    if (isNotApplicable) return ItemStatus.na;
    if (photoTargets.any((p) => p.status == ItemStatus.fail))
      return ItemStatus.fail;
    if (photoTargets.any((p) => p.status == ItemStatus.attention))
      return ItemStatus.attention;
    return ItemStatus.pass;
  }

  String get aggregatedNotes {
    return photoTargets
        .where((p) => p.notes.isNotEmpty)
        .map((p) => '${p.label}: ${p.notes}')
        .join(' | ');
  }
}

class TyreResult {
  final String position;
  String make;
  String tyreModel;
  String size;
  String loadSpeedIndex;
  int treadDepthMm;
  ItemStatus status;
  String? photoPath;

  TyreResult({
    required this.position,
    this.make = '',
    this.tyreModel = '',
    this.size = '',
    this.loadSpeedIndex = '',
    this.treadDepthMm = -1,
    this.status = ItemStatus.na,
    this.photoPath,
  });

  void evaluateRoadworthyLimit() {
    if (treadDepthMm == -1) {
      status = ItemStatus.na;
    } else if (treadDepthMm < 1) {
      status = ItemStatus.fail;
    } else if (treadDepthMm <= 3) {
      status = ItemStatus.attention;
    } else {
      status = ItemStatus.pass;
    }
  }
}
