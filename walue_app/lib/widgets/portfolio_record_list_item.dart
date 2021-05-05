import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import '../models/crypto_currency.dart';
import '../models/currency.dart';
import '../models/portfolio_record.dart';

class PortfolioRecordListItem extends StatelessWidget {
  final PortfolioRecord record;
  final CryptoCurrency currency;
  final Currency fiatCurrency;

  const PortfolioRecordListItem({
    Key? key,
    required this.record,
    required this.currency,
    required this.fiatCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.beamToNamed('/currency/${record.id}', popToNamed: '/', data: {
          'currencyImageUrl': currency.imageUrl,
          'currencyName': currency.name,
          'totalFiatAmount': record.computeTotalFiatAmount(currency.fiatPrice, fiatCurrency.symbol),
          'totalAmount': record.computeTotalAmount(),
          'increasePercentage': record.computeIncreasePercentage(currency.fiatPrice),
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 64.0,
        child: Row(
          children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(currency.imageUrl), fit: BoxFit.contain),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LimitedBox(
                          maxWidth: 80.0,
                          child: Text(
                            currency.name,
                            style: Theme.of(context).textTheme.bodyText1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        LimitedBox(
                          maxWidth: 80.0,
                          child: Text(
                            record.computeTotalFiatAmount(
                              currency.fiatPrice,
                              fiatCurrency.symbol,
                            )!,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currency.symbol.toUpperCase(),
                        ),
                        Text(
                          record.computeTotalAmount()!,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 90.0,
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

                    var color = const Color(0xFF222222);

                    if (profitText.startsWith('+')) {
                      color = const Color(0xFF54D790);
                    } else if (profitText.startsWith('-')) {
                      color = const Color(0xFFD90D00);
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
