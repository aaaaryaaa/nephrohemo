import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference machinesCollection =
      FirebaseFirestore.instance.collection('machines');
  final CollectionReference scheduleCollection =
      FirebaseFirestore.instance.collection('schedule');
  final CollectionReference patientsCollection = FirebaseFirestore.instance
      .collection('patients'); // New collection for patients

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

  // Real-time listener for available machines
  Stream<List<Map<String, dynamic>>> listenToAvailableMachines() {
    return machinesCollection
        .where('available', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
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

// Real-time listener for scheduled machines
  Stream<List<Map<String, dynamic>>> listenToScheduledMachines() {
    return scheduleCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'machineId': doc['machineId'],
          'machineName': doc['machineName'],
          'location': doc['location'],
          'patientName': doc['patientName'],
          'patientNumber': doc['patientNumber'],
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

  // Delete a machine from Firestore
  Future<void> deleteMachine(String id) async {
    try {
      await machinesCollection.doc(id).delete();
      print('Machine deleted from Firestore');
    } catch (e) {
      print('Error deleting machine: $e');
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

  // Add machine to schedule
  Future<void> scheduleMachine(String machineId, String machineName,
      String location, String patientName, String patientNumber) async {
    try {
      await scheduleCollection.add({
        'machineId': machineId,
        'machineName': machineName,
        'location': location,
        'patientName': patientName,
        'patientNumber': patientNumber,
        'scheduledAt': FieldValue.serverTimestamp(),
      });
      // Mark machine as not available
      await machinesCollection.doc(machineId).update({
        'available': false,
      });
    } catch (e) {
      print('Error scheduling machine: $e');
    }
  }

  // Remove machine from schedule and mark as available
  Future<void> cancelSchedule(String scheduleId, String machineId) async {
    try {
      await scheduleCollection.doc(scheduleId).delete();
      // Mark machine as available again
      await machinesCollection.doc(machineId).update({
        'available': true,
      });
    } catch (e) {
      print('Error canceling schedule: $e');
    }
  }

  // Real-time listener for patient changes
  Stream<List<Map<String, dynamic>>> listenToPatients() {
    return patientsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'age': doc['age'],
          'contact': doc['contact'],
          'number': doc['number'],
        };
      }).toList();
    });
  }

  // Add a new patient to Firestore
  Future<void> addPatient(
      String name, int age, String contact, String number) async {
    try {
      await patientsCollection.add({
        'name': name,
        'age': age,
        'contact': contact,
        'number': number,
      });
      print('Patient added to Firestore');
    } catch (e) {
      print('Error adding patient: $e');
    }
  }

  // Update patient details
  Future<void> updatePatient(
      String id, String name, int age, String contact, String number) async {
    try {
      await patientsCollection.doc(id).update({
        'name': name,
        'age': age,
        'contact': contact,
        'number': number,
      });
      print('Patient updated in Firestore');
    } catch (e) {
      print('Error updating patient: $e');
    }
  }

  // Delete a patient from Firestore
  Future<void> deletePatient(String id) async {
    try {
      await patientsCollection.doc(id).delete();
      print('Patient deleted from Firestore');
    } catch (e) {
      print('Error deleting patient: $e');
    }
  }
}
