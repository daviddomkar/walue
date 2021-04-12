import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/add_record_dialog.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/logo.dart';
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
                          padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
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
                                  if (currency.data?.value != null)
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
                                ],
                              ),
                              Transform.translate(
                                offset: const Offset(8.0, -8.0),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    print('History length:');
                                    print(Beamer.of(context).beamHistory.length);
                                    print('Beam back location:');
                                    print(Beamer.of(context).beamBackLocation);
                                    print('Can beam back:');
                                    print(Beamer.of(context).canBeamBack);
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
                                      cells: <DataCell>[
                                        DataCell(Text(record.buyPrice.toString())),
                                        DataCell(Text(record.amount.toString())),
                                        DataCell(Text('TODO')),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () => Container(),
                          error: (e, s) => Container(),
                        )),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: GradientButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddRecordDialog(
                                  onAddRecord: (record) {
                                    viewModel.addBuyRecord(record);
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
