import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference machinesCollection =
      FirebaseFirestore.instance.collection('machines');

  // Real-time listener for machine changes
  Stream<List<Map<String, dynamic>>> listenToMachines() {
    return machinesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'location': doc['location'],
          'available': doc['available'],
        };
      }).toList();
    });
  }

  // Add a machine to Firestore with availability
  Future<void> addMachine(String name, String location, bool available) async {
    try {
      await machinesCollection.add({
        'name': name,
        'location': location,
        'available': available, // Save the availability status
      });
      print('Machine added to Firestore');
    } catch (e) {
      print('Error adding machine: $e');
    }
  }

  // Update machine availability
  Future<void> updateMachineAvailability(String id, bool isAvailable) async {
    try {
      await machinesCollection.doc(id).update({
        'available': isAvailable,
      });
      print('Machine availability updated');
    } catch (e) {
      print('Error updating machine availability: $e');
    }
  }
}
