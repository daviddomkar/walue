import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../hooks/use_provider_cached.dart';
import '../models/crypto_currency.dart';
import '../providers.dart';
import 'w_text_form_field.dart';

class CryptoSelectSheet extends HookWidget {
  final List<String> ownedCurrencyIds;

  final void Function(CryptoCurrency) onCryptoCurrencySelected;

  const CryptoSelectSheet({required this.ownedCurrencyIds, required this.onCryptoCurrencySelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cryptoCurrencies = useProviderCached(cryptoCurrenciesStreamProvider);
    final searchText = useState('');

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, controller) {
        return Container(
          color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
          child: cryptoCurrencies.when(
            data: (data) {
              data = data
                  ?.where((currency) => ownedCurrencyIds.indexWhere((id) => currency.id == id) == -1)
                  .where(
                    (currency) => searchText.value == '' || currency.name.toLowerCase().startsWith(searchText.value) || currency.symbol.startsWith(searchText.value),
                  )
                  .toList();

              data?.sort((currency, other) => other.fiatPrice.compareTo(currency.fiatPrice));

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
                    delegate: CryptoSelectSheetHeaderDelegate(onSearch: (search) => searchText.value = search),
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
                                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          title: Text(
                            data[index].name,
                            style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                          ),
                          subtitle: Text(
                            data[index].symbol.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.light ? const Color(0x80222222) : const Color(0x80FFFFFF),
                            ),
                          ),
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
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).brightness == Brightness.light ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
                ),
                strokeWidth: 2.0,
              ),
            ),
            error: (e, s) {
              return Center(
                child: Text(
                  'An error occured while fetching crypto currencies, check your connection and try again!',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.red,
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

class CryptoCurrencySearchTextField extends StatelessWidget {
  final void Function(String searchText) onSearch;

  const CryptoCurrencySearchTextField({required this.onSearch, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WTextFormField(
      hintText: 'Search',
      onChanged: (value) => onSearch(value.toLowerCase()),
    );
  }
}

class CryptoSelectSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  final void Function(String searchText) onSearch;

  CryptoSelectSheetHeaderDelegate({required this.onSearch});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Choose a crypto currency', style: Theme.of(context).textTheme.headline6!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
            child: CryptoCurrencySearchTextField(onSearch: onSearch),
          ),
        ],
      ),
      /*
      child: Center(
        child: Text('Choose a crypto currency', style: Theme.of(context).textTheme.headline6),
      ),
      */
    );
  }

  @override
  double get maxExtent => 128.0;

  @override
  double get minExtent => 128.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
