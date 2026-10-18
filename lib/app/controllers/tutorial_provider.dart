import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tutorialController.dart';

final tutorialControllerProvider = Provider<TutorialController>((ref) {
  return TutorialController();
});
