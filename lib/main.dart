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
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.teal),
      ),
      home: home_screen(),
    );
  }
}

class home_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hemodia'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Schedule'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DashboardScreen(),
            ScheduleScreen(),
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

  @override
  void initState() {
    super.initState();
    _listenToMachineChanges(); // Use a real-time listener
  }

  // Real-time listener for machine changes
  void _listenToMachineChanges() {
    _firestoreService.listenToMachines().listen((machines) {
      setState(() {
        availableMachines = machines.where((m) => m['available'] == true).toList();
        nonAvailableMachines = machines.where((m) => m['available'] == false).toList();
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        SizedBox(height: 10),
        _buildMachineList(availableMachines, true), // Display available machines

        SizedBox(height: 20), // Separation between available and non-available

        Text(
          'Non-Available Machines: ${nonAvailableMachines.length}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        SizedBox(height: 10),
        _buildMachineList(nonAvailableMachines, false), // Display non-available machines
      ],
    );
  }

  Widget _buildMachineList(List<Map<String, dynamic>> machines, bool isAvailable) {
    return machines.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: machines.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.local_hospital, color: isAvailable ? Colors.teal : Colors.grey),
                  title: Text('${machines[index]['name']} - ${machines[index]['location']}'),
                  trailing: Switch(
                    value: isAvailable,
                    onChanged: (value) => _toggleAvailability(machines[index]['id'], isAvailable),
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ),
              );
            },
          )
        : Center(child: Text('No machines found.'));
  }

  // Toggle availability of a machine
  void _toggleAvailability(String id, bool isCurrentlyAvailable) async {
    await _firestoreService.updateMachineAvailability(id, !isCurrentlyAvailable);
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
  final TextEditingController _patientNumberController = TextEditingController();
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

  void _scheduleMachine(String machineId, String patientName, String patientNumber) async {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _scheduledMachines.length,
        itemBuilder: (context, index) {
          final machine = _scheduledMachines[index];
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
                    machine['machineName'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Location: ${machine['location']}'),
                  SizedBox(height: 10),
                  Text('Patient Name: ${machine['patientName']}'),
                  SizedBox(height: 10),
                  Text('Patient Number: ${machine['patientNumber']}'),
                ],
              ),
            ),
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
                  onPressed: () {
                    // You should trigger scheduling logic here if needed
                  },
                  icon: Icon(Icons.schedule),
                  label: Text('Schedule'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
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

