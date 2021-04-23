import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class CryptoSelectSheet extends ConsumerWidget {
  const CryptoSelectSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final cryptoCurrencies = watch(cryptoCurrenciesStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, controller) {
        return Container(
          color: Colors.white,
          child: cryptoCurrencies.when(
            data: (data) {
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
                          leading: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(data[index].imageUrl),
                                  fit: BoxFit.contain),
                            ),
                          ),
                          title: Text(data[index].name),
                          subtitle: Text(data[index].symbol.toUpperCase()),
                          onTap: () {
                            context.beamToNamed('/currency/${data[index].id}');
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
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                strokeWidth: 2.0,
              ),
            ),
            error: (e, s) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  strokeWidth: 2.0,
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 64.0,
      color: Colors.white,
      child: Center(
        child: Text('Choose a crypto currency',
            style: Theme.of(context).textTheme.headline6),
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
