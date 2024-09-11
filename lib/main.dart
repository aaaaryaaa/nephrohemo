import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nephrohemo/firebase_options.dart';
import 'firestore_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase Initialized');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Dialysis ',
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
          textTheme: ButtonTextTheme.primary,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.teal),
      ),
      home: home_screen(),
    );
  }
}

class home_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Updated length
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hemodia'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Schedule'),
              Tab(text: 'Patients'), // New Tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DashboardScreen(),
            ScheduleScreen(),
            PatientList(), // New Widget
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isViewingMachines = true;

  // Function to toggle between viewing machines and adding machines
  void _toggleView() {
    setState(() {
      isViewingMachines = !isViewingMachines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Machine Availability',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: isViewingMachines
                  ? DashboardView() // Widget for viewing machines
                  : AddMachine(), // Widget for adding machines
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleView,
              child: Text(isViewingMachines ? 'Add Machine' : 'View Machines'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> availableMachines = [];
  List<Map<String, dynamic>> nonAvailableMachines = [];
  List<String> scheduledMachineIds = [];

  @override
  void initState() {
    super.initState();
    _listenToMachineChanges();
    _listenToScheduledMachines(); // Add this line
  }

  void _listenToMachineChanges() {
    _firestoreService.listenToMachines().listen((machines) {
      setState(() {
        availableMachines =
            machines.where((m) => m['available'] == true).toList();
        nonAvailableMachines =
            machines.where((m) => m['available'] == false).toList();
      });
    });
  }

  void _listenToScheduledMachines() {
    _firestoreService
        .listenToScheduledMachines()
        .listen((List<dynamic> machines) {
      setState(() {
        // Ensure you are extracting the 'machineId' field correctly.
        scheduledMachineIds =
            machines.map((dynamic m) => m['machineId'] as String).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Machines: ${availableMachines.length}',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        SizedBox(height: 10),
        _buildMachineList(
            availableMachines, true), // Display available machines

        SizedBox(height: 20),

        Text(
          'Non-Available Machines: ${nonAvailableMachines.length}',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        SizedBox(height: 10),
        _buildMachineList(
            nonAvailableMachines, false), // Display non-available machines
      ],
    );
  }

  void _confirmDelete(String machineId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this machine?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _deleteMachine(machineId); // Proceed with deletion
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _deleteMachine(String id) async {
    await _firestoreService.deleteMachine(id);
  }

  Widget _buildMachineList(
      List<Map<String, dynamic>> machines, bool isAvailable) {
    return machines.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: machines.length,
            itemBuilder: (context, index) {
              bool isScheduled =
                  scheduledMachineIds.contains(machines[index]['id']);
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.local_hospital,
                    color: isAvailable ? Colors.teal : Colors.grey,
                  ),
                  title: Text(
                      '${machines[index]['name']} - ${machines[index]['location']}'),
                  trailing: isScheduled
                      ? Text('Scheduled', style: TextStyle(color: Colors.red))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmDelete(machines[index]['id']),
                            ),
                            Switch(
                              value: isAvailable,
                              onChanged: (value) => _toggleAvailability(
                                  machines[index]['id'], isAvailable),
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                            ),
                          ],
                        ),
                ),
              );
            },
          )
        : Center(child: Text('No machines found.'));
  }

  void _toggleAvailability(String id, bool isCurrentlyAvailable) async {
    if (scheduledMachineIds.contains(id)) {
      return; // Do not allow toggling if the machine is scheduled
    }
    await _firestoreService.updateMachineAvailability(
        id, !isCurrentlyAvailable);
  }
}

class AddMachine extends StatefulWidget {
  @override
  _AddMachineState createState() => _AddMachineState();
}

class _AddMachineState extends State<AddMachine> {
  FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isAvailable = true; // Default value for availability

  // Add machine using FirestoreService
  void _addMachine() async {
    String name = _nameController.text;
    String location = _locationController.text;
    if (name.isNotEmpty && location.isNotEmpty) {
      await _firestoreService.addMachine(name, location, _isAvailable);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Machine Added Successfully!'),
      ));
      _nameController.clear();
      _locationController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Add New Machine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Machine Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available', style: TextStyle(fontSize: 16)),
                Switch(
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMachine,
              child: Text('Add Machine'),
            ),
          ],
        ),
      ),
    );
  }
}

//SCHEDULING

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isScheduling = true;

  // Function to toggle between scheduling and viewing scheduled machines
  void _toggleView() {
    setState(() {
      _isScheduling = !_isScheduling;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Schedule Machines'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Schedule Machine'),
              Tab(text: 'Scheduled Machines'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ScheduleMachineView(),
            ScheduledMachinesView(),
          ],
        ),
      ),
    );
  }
}

class ScheduleMachineView extends StatefulWidget {
  @override
  _ScheduleMachineViewState createState() => _ScheduleMachineViewState();
}

class _ScheduleMachineViewState extends State<ScheduleMachineView> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientNumberController =
      TextEditingController();
  String? _selectedMachineId;
  List<Map<String, dynamic>> _machines = [];

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  void _fetchMachines() async {
    _firestoreService.listenToMachines().listen((machines) {
      setState(() {
        _machines = machines.where((m) => m['available'] == true).toList();
      });
    });
  }

  void _scheduleMachine(
      String machineId, String patientName, String patientNumber) async {
    final machine = _machines.firstWhere((m) => m['id'] == machineId);
    await _firestoreService.scheduleMachine(
      machineId,
      machine['name'],
      machine['location'],
      patientName,
      patientNumber,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Machine Scheduled Successfully!'),
    ));
    setState(() {
      _selectedMachineId = null;
      _patientNameController.clear();
      _patientNumberController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Schedule a Machine',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: _selectedMachineId,
            hint: Text('Select Machine'),
            items: _machines.map((machine) {
              return DropdownMenuItem<String>(
                value: machine['id'],
                child: Text('${machine['name']} - ${machine['location']}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMachineId = value;
              });
            },
          ),
          SizedBox(height: 20),
          TextField(
            controller: _patientNameController,
            decoration: InputDecoration(labelText: 'Patient Name'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _patientNumberController,
            decoration: InputDecoration(labelText: 'Patient Number'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedMachineId != null &&
                    _patientNameController.text.isNotEmpty &&
                    _patientNumberController.text.isNotEmpty
                ? () => _scheduleMachine(
                      _selectedMachineId!,
                      _patientNameController.text,
                      _patientNumberController.text,
                    )
                : null,
            child: Text('Schedule Machine'),
          ),
        ],
      ),
    );
  }
}

class ScheduledMachinesView extends StatefulWidget {
  @override
  _ScheduledMachinesViewState createState() => _ScheduledMachinesViewState();
}

class _ScheduledMachinesViewState extends State<ScheduledMachinesView> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _scheduledMachines = [];

  @override
  void initState() {
    super.initState();
    _listenToScheduledMachines();
  }

  void _listenToScheduledMachines() {
    _firestoreService.listenToScheduledMachines().listen((machines) {
      setState(() {
        _scheduledMachines = machines;
      });
    });
  }

  void _cancelSchedule(String scheduleId, String machineId) async {
    await _firestoreService.cancelSchedule(scheduleId, machineId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Machine schedule canceled and marked as available.'),
    ));
    setState(() {
      _scheduledMachines.removeWhere((machine) => machine['id'] == scheduleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _scheduledMachines.length,
        itemBuilder: (context, index) {
          final machine = _scheduledMachines[index];
          return schedule_card(
            machineId: machine['machineId'],
            machineName: machine['machineName'],
            location: machine['location'],
            patientName: machine['patientName'],
            patientNumber: machine['patientNumber'],
            onCancel: () =>
                _cancelSchedule(machine['id'], machine['machineId']),
          );
        },
      ),
    );
  }
}

class schedule_card extends StatelessWidget {
  final String machineId;
  final String machineName;
  final String location;
  final String? patientName;
  final String? patientNumber;
  final VoidCallback onCancel;

  schedule_card({
    required this.machineId,
    required this.machineName,
    required this.location,
    this.patientName,
    this.patientNumber,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              machineName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.teal,
                  ),
            ),
            SizedBox(height: 10),
            Text('Location: $location'),
            SizedBox(height: 10),
            if (patientName != null && patientNumber != null) ...[
              Text('Patient: $patientName'),
              Text('Contact: $patientNumber'),
            ],
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: onCancel,
                  icon: Icon(Icons.cancel),
                  label: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// PATIENT WIDGET
class PatientList extends StatefulWidget {
  @override
  _PatientListState createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _patients = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  String? _editingPatientId;

  @override
  void initState() {
    super.initState();
    _listenToPatients();
  }

  void _listenToPatients() {
    _firestoreService.listenToPatients().listen((patients) {
      setState(() {
        _patients = patients;
      });
    });
  }

  void _addOrUpdatePatient() async {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;
    final contact = _contactController.text;
    final number = _numberController.text;
    if (name.isNotEmpty && age > 0 && contact.isNotEmpty && number.isNotEmpty) {
      if (_editingPatientId != null) {
        await _firestoreService.updatePatient(
            _editingPatientId!, name, age, contact, number);
        setState(() {
          _editingPatientId = null;
        });
      } else {
        await _firestoreService.addPatient(name, age, contact, number);
      }
      _nameController.clear();
      _ageController.clear();
      _contactController.clear();
      _numberController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            _editingPatientId == null ? 'Patient Added' : 'Patient Updated'),
      ));
    }
  }

  void _editPatient(
      String id, String name, int age, String contact, String number) {
    setState(() {
      _editingPatientId = id;
      _nameController.text = name;
      _ageController.text = age.toString();
      _contactController.text = contact;
      _numberController.text = number;
    });
  }

  void _deletePatient(String id) async {
    await _firestoreService.deletePatient(id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Patient List',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Patient Name'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Age'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _contactController,
            decoration: InputDecoration(labelText: 'Contact'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _numberController,
            decoration: InputDecoration(labelText: 'Patient Number'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addOrUpdatePatient,
            child: Text(
                _editingPatientId == null ? 'Add Patient' : 'Update Patient'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(patient['name']),
                    subtitle: Text(
                      'Age: ${patient['age']}\nContact: ${patient['contact']}\nNumber: ${patient['number']}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editPatient(
                              patient['id'],
                              patient['name'],
                              patient['age'],
                              patient['contact'],
                              patient['number']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePatient(patient['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
