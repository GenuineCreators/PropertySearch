import 'package:agent/screens/extraScreens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('Agents')
          .doc(userId)
          .get();

      return docSnapshot.data();
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load profile details'));
          }

          final userData = snapshot.data!;
          final profileImage = userData['profileImage'];
          final userName = userData['userName'] ?? 'Unknown User';
          final rating = userData['rating'] ?? 'No rating';

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                //
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage) : null,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),

                const SizedBox(height: 20),
                Text(
                  userName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Rating: $rating',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                const Divider(thickness: 1, color: Colors.grey),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Personal Information'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('My Cars'),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => CarScreen()),
                    // );
                  },
                ),
                const Divider(thickness: 1, color: Colors.grey),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Saved Places',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home Location'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('Work Location'),
                  onTap: () {},
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add Place'),
                ),
                const Divider(thickness: 1, color: Colors.grey),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                const Divider(thickness: 1, color: Colors.grey),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log Out'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   Future<Map<String, dynamic>?> getUserDetails() async {
//     try {
//       final userId = FirebaseAuth.instance.currentUser?.uid;
//       if (userId == null) return null;

//       final docSnapshot = await FirebaseFirestore.instance
//           .collection('customers')
//           .doc(userId)
//           .get();

//       return docSnapshot.data();
//     } catch (e) {
//       print('Error fetching user details: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<Map<String, dynamic>?>(
//         future: getUserDetails(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError || snapshot.data == null) {
//             return const Center(child: Text('Failed to load profile details'));
//           }

//           final userData = snapshot.data!;
//           final profileImage =
//               userData['profileImage'] ?? 'https://via.placeholder.com/150';
//           final userName = userData['userName'] ?? 'Unknown User';
//           final rating = userData['rating'] ?? 'No rating';

//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 50),
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: NetworkImage(profileImage),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   userName,
//                   style: const TextStyle(
//                       fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Rating: $rating',
//                   style: const TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 30),
//                 const Divider(thickness: 1, color: Colors.grey),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
