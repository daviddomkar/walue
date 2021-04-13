import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/buy_record.dart';
import '../providers.dart';

final buyRecordsStreamProvider = StreamProvider.autoDispose.family<List<BuyRecord>, String>((ref, id) {
  final _firestore = FirebaseFirestore.instance;

  final user = ref.watch(userStreamProvider);

  return _firestore.collection('users').doc(user.data?.value?.id).collection('portfolio').doc(id).collection('buy_records').orderBy('timestamp').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return BuyRecord(
        id: doc.id,
        buyPrice: data['buy_price'] as double,
        amount: data['amount'] as double,
      );
    }).toList();
  });
});
