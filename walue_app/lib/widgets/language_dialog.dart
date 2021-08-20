import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          children: context.supportedLocales.map((locale) {
            return InkWell(
              onTap: () {
                context.setLocale(locale);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    locale.languageCode.tr(),
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
