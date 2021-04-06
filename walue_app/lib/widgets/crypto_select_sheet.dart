import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walue_app/providers.dart';

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
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
          ),
          child: cryptoCurrencies.when(
            data: (data) {
              if (data != null) {
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
                          return Text(data[index].name);
                        },
                        childCount: data.length,
                      ),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    strokeWidth: 2.0,
                  ),
                );
              }
            },
            loading: () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                strokeWidth: 2.0,
              ),
            ),
            error: (e, s) {
              print(e);
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(height: 64.0, child: Text('Lulw'));
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
