import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers.dart';

class ThemeModeDialog extends HookWidget {
  const ThemeModeDialog({Key? key}) : super(key: key);

  static String getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = useProvider(themeProvider.notifier);

    final themeMode = useState<ThemeMode?>(null);

    useEffect(() {
      themeMode.value = themeNotifier.mode;
    }, []);

    final themeModes = ThemeMode.values.where((mode) => mode != themeMode.value);

    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
      child: SingleChildScrollView(
        child: Column(
          children: themeModes.map((mode) {
            return InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                themeNotifier.mode = mode;
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getThemeModeName(mode),
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
