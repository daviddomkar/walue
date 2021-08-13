import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import '../models/crypto_currency.dart';
import '../models/currency.dart';
import '../models/portfolio_record.dart';

class PortfolioRecordListItem extends StatelessWidget {
  final PortfolioRecord record;
  final CryptoCurrency currency;
  final Currency fiatCurrency;

  final group = AutoSizeGroup();

  PortfolioRecordListItem({
    Key? key,
    required this.record,
    required this.currency,
    required this.fiatCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return InkWell(
      onTap: () {
        context.beamToNamed('/currency/${record.id}', popToNamed: '/', data: {
          'currencyImageUrl': currency.imageUrl,
          'currencyName': currency.name,
          'totalFiatAmount': record.computeTotalFiatAmount(currency.fiatPrice, fiatCurrency.symbol, isLandscape ? 1000000000000000000 : 1000000000000),
          'totalAmount': record.computeTotalAmount(currency.symbol, isLandscape ? 1000000000000000 : 1000000000),
          'increasePercentage': record.computeIncreasePercentage(currency.fiatPrice),
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 72.0,
        child: Row(
          children: [
            CachedNetworkImage(
              width: 32.0,
              height: 32.0,
              imageUrl: currency.imageUrl,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      currency.name,
                      group: group,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      minFontSize: 8.0,
                    ),
                    AutoSizeText(
                      record.computeTotalFiatAmount(
                        currency.fiatPrice,
                        fiatCurrency.symbol,
                        isLandscape ? 1000000000000000000 : 1000000000000,
                      )!,
                      group: group,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                          ),
                      maxLines: 1,
                      minFontSize: 8.0,
                    ),
                    AutoSizeText(
                      '${currency.symbol.toUpperCase()} ${record.computeTotalAmount(null, isLandscape ? 1000000000000000 : 1000000000)!}',
                      group: group,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light ? const Color(0x80222222) : const Color(0x80FFFFFF),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      minFontSize: 8.0,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 80.0,
              child: AutoSizeText(
                record.computeIncreasePercentage(
                  currency.fiatPrice,
                )!,
                maxLines: 1,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  color: (() {
                    final profitText = record.computeIncreasePercentage(
                      currency.fiatPrice,
                    )!;

                    var color = Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white;

                    if (profitText.startsWith('+')) {
                      color = const Color(0xFF00D964);
                    } else if (profitText.startsWith('-')) {
                      color = Colors.red;
                    }

                    return color;
                  })(),
                ),
                textAlign: TextAlign.right,
              ),
            )
          ],
        ),
      ),
    );
  }
}
