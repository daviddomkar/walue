import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

class GuideViewModel extends ChangeNotifier {
  final Reader read;

  bool _loading;

  GuideViewModel(this.read) : _loading = false;

  void completeGuide() {
    _loading = true;
    notifyListeners();

    read(userRepositoryProvider).completeGuide();
  }

  bool get loading => _loading;

  bool get hasCompletedGuide => read(userStreamProvider).data?.value?.hasCompletedGuide ?? false;
}
