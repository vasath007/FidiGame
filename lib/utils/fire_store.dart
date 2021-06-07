import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:fidi_game/model/data_model.dart';

class FireStoreService{
  final CollectionReference myCollection=FirebaseFirestore.instance.collection('fidigame');
  Future<FidiData> creategamelist(String name,String Desc,
        String url,String Minicount,String Maxcount,String image,
        String category) async{
    final TransactionHandler createTransaction = (Transaction tx) async {
      final DocumentSnapshot ds = await tx.get(myCollection.doc());
      final FidiData fidiData = new FidiData(desc: Desc, image: image, maxcount: Maxcount,
                                      minicount: Minicount, name: name, url: url);
      DateTime time = new DateTime.now();
      final Map<String, dynamic> data = fidiData.toMap();
      data['likes'] = "0";
      data['category'] = category;
      data['time'] = time.toIso8601String();
      await tx.set(ds.reference, data);
      return data;
    };
    return FirebaseFirestore.instance.runTransaction(createTransaction).then((mapData) {
      return FidiData.fromMap(mapData);
    }).catchError((error) {
      print('error: $error');
      return null;
    });
  }
  Stream<QuerySnapshot> getgameList({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = myCollection.snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }
    if (limit != null) {
      snapshots = snapshots.take(limit);
    }
    return snapshots;
  }
}