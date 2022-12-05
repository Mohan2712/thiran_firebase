import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thiranfirebasetask/model/data.dart';

class Repo {
  Future<void> createTicket(AllData data) async {
    final docTicket = FirebaseFirestore.instance.collection('ticket').doc();
    final json = data.toJson();
    await docTicket.set(json);
  }

  Stream<List<AllData>> getAllTicket() {
    final docTicket = FirebaseFirestore.instance
        .collection('ticket')
        .snapshots()
        .map((event) =>
            event.docs.map((e) => AllData.fromJson(e.data())).toList());
    return docTicket;
  }
}
