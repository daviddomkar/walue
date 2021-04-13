import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/logo.dart';
import '../../widgets/buy_record_dialog.dart';
import 'currency_view_model.dart';

final currencyViewModelProvider = ChangeNotifierProvider.autoDispose.family<CurrencyViewModel, String>((ref, id) {
  final userRepository = ref.watch(userRepositoryProvider);

  final currency = ref.watch(cryptoCurrencyStreamProvider(id));
  final buyRecords = ref.watch(buyRecordsStreamProvider(id));

  return CurrencyViewModel(
    userRepository: userRepository,
    currency: currency,
    buyRecords: buyRecords,
  );
});

class CurrencyScreen extends ConsumerWidget {
  final String id;

  const CurrencyScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final viewModel = watch(currencyViewModelProvider(id));

    final currency = viewModel.currency;
    final buyRecords = viewModel.buyRecords;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    Transform(
                      transform: Matrix4.rotationZ(0.4)..translate(-150.0, -96.0),
                      alignment: Alignment.center,
                      child: Container(
                        width: 400.0,
                        height: 400.0,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(40.0),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Logo(
                                    small: true,
                                  ),
                                  if (currency.data?.value != null) ...[
                                    Transform.translate(
                                      offset: const Offset(0.0, -10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 24.0,
                                            height: 24.0,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(image: NetworkImage(currency.data!.value!.imageUrl), fit: BoxFit.contain),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4.0),
                                            child: Text(
                                              currency.data!.value!.name,
                                              style: Theme.of(context).textTheme.headline5!.copyWith(color: const Color(0xCCFFFFFF)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        '3,241.45 USD',
                                        style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      '0,067 BTC',
                                      style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.white),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0, bottom: 96.0),
                                      child: Text(
                                        '+10,24%',
                                        style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Transform.translate(
                                offset: const Offset(8.0, -8.0),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    context.beamBack();
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.arrowLeft,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: buyRecords.when(
                            data: (data) {
                              return DataTable(
                                showCheckboxColumn: false,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Buy price',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Amount',
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Profit',
                                    ),
                                  ),
                                ],
                                rows: data
                                    .map(
                                      (record) => DataRow(
                                        onSelectChanged: (_) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => BuyRecordDialog(
                                              initialRecord: record,
                                              onEditRecord: (id, buyPrice, amount) {
                                                viewModel.editBuyRecord(id, buyPrice, amount);
                                                Navigator.of(context, rootNavigator: true).pop(context);
                                              },
                                              onDeleteRecord: (id) {
                                                viewModel.deleteBuyRecord(id);
                                                Navigator.of(context, rootNavigator: true).pop(context);
                                              },
                                            ),
                                          );
                                        },
                                        cells: <DataCell>[
                                          DataCell(Text(record.buyPrice.toString())),
                                          DataCell(Text(record.amount.toString())),
                                          DataCell(
                                            Text(
                                              ((currency.data!.value!.fiatPrice * record.amount) - (record.buyPrice * record.amount)).toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                            loading: () => Center(
                              child: Text('loading'),
                            ),
                            error: (e, s) => Center(
                              child: Text('loading'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: GradientButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => BuyRecordDialog(
                                  onAddRecord: (buyPrice, amount) {
                                    viewModel.addBuyRecord(buyPrice, amount);
                                    Navigator.of(context, rootNavigator: true).pop(context);
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Add new buy record',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
