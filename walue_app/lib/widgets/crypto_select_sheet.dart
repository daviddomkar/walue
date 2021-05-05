import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../hooks/use_provider_cached.dart';
import '../models/crypto_currency.dart';
import '../providers.dart';

class CryptoSelectSheet extends HookWidget {
  final List<String> ownedCurrencyIds;

  final void Function(CryptoCurrency) onCryptoCurrencySelected;

  const CryptoSelectSheet({required this.ownedCurrencyIds, required this.onCryptoCurrencySelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cryptoCurrencies = useProviderCached(cryptoCurrenciesStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, controller) {
        return Container(
          color: Colors.white,
          child: cryptoCurrencies.when(
            data: (data) {
              data = data?.where((currency) => ownedCurrencyIds.indexWhere((id) => currency.id == id) == -1).toList();

              if (data == null) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    strokeWidth: 2.0,
                  ),
                );
              }

              return CustomScrollView(
                controller: controller,
                slivers: [
                  SliverPersistentHeader(
                    delegate: CryptoSelectSheetHeaderDelegate(),
                    pinned: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ListTile(
                          leading: CachedNetworkImage(
                            width: 40.0,
                            height: 40.0,
                            imageUrl: data![index].imageUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          title: Text(data[index].name),
                          subtitle: Text(data[index].symbol.toUpperCase()),
                          onTap: () {
                            onCryptoCurrencySelected(data![index]);
                          },
                        );
                      },
                      childCount: data.length,
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                strokeWidth: 2.0,
              ),
            ),
            error: (e, s) {
              return Center(
                child: Text(
                  'An error occured while fetching crypto currencies, check your connection and try again!',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: const Color(0xFFD90D00),
                      ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CryptoSelectSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 64.0,
      color: Colors.white,
      child: Center(
        child: Text('Choose a crypto currency', style: Theme.of(context).textTheme.headline6),
      ),
    );
  }

  @override
  double get maxExtent => 64.0;

  @override
  double get minExtent => 64.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
