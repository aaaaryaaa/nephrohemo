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
            schedule_screen(),
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

// class _DashboardViewState extends State<DashboardView> {
//   FirestoreService _firestoreService = FirestoreService();
//   List<Map<String, dynamic>> availableMachines = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchMachines();
//   }

//   // Fetch machines from Firestore and update state
//   void _fetchMachines() async {
//     List<Map<String, dynamic>> machines = await _firestoreService.fetchMachines();
//     setState(() {
//       availableMachines = machines;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15.0),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               'Total Machines: ${availableMachines.length}',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Free Machines: ${availableMachines.length}', // Adjust based on logic
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.green,
//               ),
//             ),
//             SizedBox(height: 10),
//             Divider(),
//             availableMachines.isNotEmpty
//                 ? ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: availableMachines.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: EdgeInsets.symmetric(vertical: 4.0),
//                         child: Row(
//                           children: [
//                             Icon(Icons.local_hospital, color: Colors.teal),
//                             SizedBox(width: 8),
//                             Text('${availableMachines[index]['name']} - ${availableMachines[index]['location']}'),
//                           ],
//                         ),
//                       );
//                     },
//                   )
//                 : Center(child: CircularProgressIndicator()), // Show loader while fetching
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DashboardViewState extends State<DashboardView> {
//   FirestoreService _firestoreService = FirestoreService();
//   List<Map<String, dynamic>> availableMachines = [];
//   List<Map<String, dynamic>> nonAvailableMachines = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchMachines();
//   }

//   // Fetch machines from Firestore and separate available/non-available
//   void _fetchMachines() async {
//     List<Map<String, dynamic>> machines = await _firestoreService.fetchMachines();
//     setState(() {
//       availableMachines = machines.where((m) => m['available'] == true).toList();
//       nonAvailableMachines = machines.where((m) => m['available'] == false).toList();
//     });
//   }

//   // Toggle availability of a machine
//   void _toggleAvailability(String id, bool isCurrentlyAvailable) async {
//     await _firestoreService.updateMachineAvailability(id, !isCurrentlyAvailable);
//     _fetchMachines(); // Refresh the list after updating
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Available Machines: ${availableMachines.length}',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//         ),
//         SizedBox(height: 10),
//         _buildMachineList(availableMachines, true), // Display available machines

//         SizedBox(height: 20), // Separation between available and non-available

//         Text(
//           'Non-Available Machines: ${nonAvailableMachines.length}',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
//         ),
//         SizedBox(height: 10),
//         _buildMachineList(nonAvailableMachines, false), // Display non-available machines
//       ],
//     );
//   }

//   Widget _buildMachineList(List<Map<String, dynamic>> machines, bool isAvailable) {
//     return machines.isNotEmpty
//         ? ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: machines.length,
//             itemBuilder: (context, index) {
//               return Card(
//                 elevation: 3,
//                 margin: EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   leading: Icon(Icons.local_hospital, color: isAvailable ? Colors.teal : Colors.grey),
//                   title: Text('${machines[index]['name']} - ${machines[index]['location']}'),
//                   trailing: Switch(
//                     value: isAvailable,
//                     onChanged: (value) => _toggleAvailability(machines[index]['id'], isAvailable),
//                     activeColor: Colors.green,
//                     inactiveThumbColor: Colors.red,
//                   ),
//                 ),
//               );
//             },
//           )
//         : Center(child: Text('No machines found.'));
//   }
// }
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



class schedule_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Schedule or Cancel a Machine',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: <Widget>[
                schedule_card(
                  machine_name: 'Machine 1',
                  location: 'Room 101',
                ),
                schedule_card(
                  machine_name: 'Machine 2',
                  location: 'Room 102',
                ),
                schedule_card(
                  machine_name: 'Machine 3',
                  location: 'Room 103',
                ),
                schedule_card(
                  machine_name: 'Machine 4',
                  location: 'Room 104',
                ),
                schedule_card(
                  machine_name: 'Machine 5',
                  location: 'Room 105',
                ),
                schedule_card(
                  machine_name: 'Machine 6',
                  location: 'Room 106',
                ),
                schedule_card(
                  machine_name: 'Machine 7',
                  location: 'Room 107',
                ),
                schedule_card(
                  machine_name: 'Machine 8',
                  location: 'Room 108',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class schedule_card extends StatelessWidget {
  final String machine_name;
  final String location;

  schedule_card({
    required this.machine_name,
    required this.location,
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
              machine_name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            Text('Location: $location'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.schedule),
                  label: Text('Schedule'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
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
