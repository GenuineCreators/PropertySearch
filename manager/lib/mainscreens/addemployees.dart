// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddEmployeesScreen extends StatefulWidget {
  const AddEmployeesScreen({super.key});

  @override
  State<AddEmployeesScreen> createState() => _AddEmployeesScreenState();
}

class _AddEmployeesScreenState extends State<AddEmployeesScreen> {
  Uint8List? _profileImage;
  Uint8List? _idImage;
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  bool _loading = false;

  Future<void> _selectProfileImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _profileImage = result.files.single.bytes;
      });
    }
  }

  Future<void> _selectIDImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _idImage = result.files.single.bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employees'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _selectProfileImage,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.memory(
                                _profileImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(child: Text('Add Profile Picture')),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _employeeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Employee Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _phoneNoController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _idNumberController,
                  decoration: const InputDecoration(
                    labelText: 'ID Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: _selectIDImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: _idImage != null
                        ? Image.memory(_idImage!, fit: BoxFit.cover)
                        : const Center(child: Text('Add ID Photo')),
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() {
                              _loading = true;
                            });
                            try {
                              // Retrieve managerId from "managers" table
                              final currentUserId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              final managerSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('managers')
                                  .where('managerID', isEqualTo: currentUserId)
                                  .get();

                              if (managerSnapshot.docs.isEmpty) {
                                throw Exception(
                                    'Manager not found for current user.');
                              }
                              final managerId = managerSnapshot.docs.first
                                  .data()['managerID'];

                              // Register the user
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              final userID = userCredential.user!.uid;

                              // Upload images to Firebase Storage
                              final storageRef = FirebaseStorage.instance.ref();
                              final profileImageRef =
                                  storageRef.child('profileImages/$userID.jpg');
                              final idImageRef =
                                  storageRef.child('idImages/$userID.jpg');
                              final profileImageTask =
                                  profileImageRef.putData(_profileImage!);
                              final idImageTask = idImageRef.putData(_idImage!);
                              final snapshot = await Future.wait(
                                  [profileImageTask, idImageTask]);
                              final profileImageUrl =
                                  await snapshot[0].ref.getDownloadURL();
                              final idImageUrl =
                                  await snapshot[1].ref.getDownloadURL();

                              // Hash the password
                              final bytes =
                                  utf8.encode(_passwordController.text);
                              final digest = sha256.convert(bytes);
                              final hashedPassword = digest.toString();

                              // Generate a unique employee ID
                              final uuid = Uuid();
                              final employeeId = uuid.v1();

                              // Store employee details in Firestore
                              final employeeData = {
                                'name': _employeeNameController.text,
                                'email': _emailController.text,
                                'phoneNo': _phoneNoController.text,
                                'idNumber': _idNumberController.text,
                                'profileImage': profileImageUrl,
                                'idImage': idImageUrl,
                                'userID': userID,
                                'employeeId': employeeId,
                                'managerId': managerId,
                              };
                              await FirebaseFirestore.instance
                                  .collection('employees')
                                  .doc(employeeId)
                                  .set(employeeData);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Employee added successfully'),
                                ),
                              );

                              // Reset the form
                              _employeeNameController.clear();
                              _emailController.clear();
                              _passwordController.clear();
                              _phoneNoController.clear();
                              _idNumberController.clear();
                              _profileImage = null;
                              _idImage = null;
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add employee: $e'),
                                ),
                              );
                            }
                            setState(() {
                              _loading = false;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('ADD EMPLOYEE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}














// // ignore_for_file: unused_local_variable

// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:crypto/crypto.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';

// class AddEmployeesScreen extends StatefulWidget {
//   const AddEmployeesScreen({super.key});
//   @override  
//   State<AddEmployeesScreen> createState() => _AddEmployeesScreenState();
// }

// class _AddEmployeesScreenState extends State<AddEmployeesScreen> {
//   Uint8List? _profileImage;
//   Uint8List? _idImage;
//   final TextEditingController _employeeNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneNoController = TextEditingController();
//   final TextEditingController _idNumberController = TextEditingController();
//   bool _loading = false;
//   Future<void> _selectProfileImage() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         _profileImage = result.files.single.bytes;
//       });
//     }
//   }

//   Future<void> _selectIDImage() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         _idImage = result.files.single.bytes;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Employees'),
//       ),
//       body: Scrollbar(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: _selectProfileImage,
//                   child: Container(
//                     height: 200,
//                     width: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     child: _profileImage != null
//                         ? ClipOval(
//                             child: Image.memory(
//                               _profileImage!,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : const Center(child: Text('Add profile pic')),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _employeeNameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Employee name',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _phoneNoController,
//                   decoration: const InputDecoration(
//                     labelText: 'PhoneNo',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _idNumberController,
//                   decoration: const InputDecoration(
//                     labelText: 'IdNumber',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 GestureDetector(
//                   onTap: _selectIDImage,
//                   child: Container(
//                     height: 200,
//                     width: 200,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: _idImage != null
//                         ? Image.memory(_idImage!, fit: BoxFit.cover)
//                         : const Center(child: Text('Add Id Photo')),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: _loading
//                       ? null
//                       : () async {
//                           setState(() {
//                             _loading = true;
//                           });
//                           try {
//                             // Register the user
//                             UserCredential userCredential = await FirebaseAuth
//                                 .instance
//                                 .createUserWithEmailAndPassword(
//                               email: _emailController.text,
//                               password: _passwordController.text,
//                             );
//                             final userID = userCredential.user!.uid;
//                             final storageRef = FirebaseStorage.instance.ref();
//                             final profileImageRef =
//                                 storageRef.child('profileImages/$userID.jpg');
//                             final idImageRef =
//                                 storageRef.child('idImages/$userID.jpg');
//                             final profileImageTask =
//                                 profileImageRef.putData(_profileImage!);
//                             final idImageTask = idImageRef.putData(_idImage!);
//                             final snapshot = await Future.wait(
//                                 [profileImageTask, idImageTask]);
//                             final profileImageUrl =
//                                 await snapshot[0].ref.getDownloadURL();
//                             final idImageUrl =
//                                 await snapshot[1].ref.getDownloadURL();
//                             final bytes = utf8.encode(_passwordController.text);
//                             final digest = sha256.convert(bytes);
//                             final hashedPassword = digest.toString();
//                             // Generate a unique employee ID
//                             final uuid = Uuid();
//                             final employeeId = uuid.v1();
//                             // Store employee details in Firestore
//                             final employeeData = {
//                               'name': _employeeNameController.text,
//                               'email': _emailController.text,
//                               'phoneNo': _phoneNoController.text,
//                               'idNumber': _idNumberController.text,
//                               'profileImage': profileImageUrl,
//                               'idImage': idImageUrl,
//                               'userID': userID,
//                               'employeeId': employeeId,
//                               'managerId':
//                                   FirebaseAuth.instance.currentUser!.uid,
//                             };
//                             await FirebaseFirestore.instance
//                                 .collection('employees')
//                                 .doc(employeeId)
//                                 .set(employeeData);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Employee added successfully'),
//                               ),
//                             );
//                             // Reset the form
//                             _employeeNameController.clear();
//                             _emailController.clear();
//                             _passwordController.clear();
//                             _phoneNoController.clear();
//                             _idNumberController.clear();
//                             _profileImage = null;
//                             _idImage = null;
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Failed to add employee: $e'),
//                               ),
//                             );
//                           }
//                           setState(() {
//                             _loading = false;
//                           });
//                         },
//                   child: _loading
//                       ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(),
//                         )
//                       : const Text('ADD EMPLOYEE'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ignore_for_file: unused_local_variable

// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:crypto/crypto.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AddEmployeesScreen extends StatefulWidget {
//   const AddEmployeesScreen({super.key});

//   @override
//   State<AddEmployeesScreen> createState() => _AddEmployeesScreenState();
// }

// class _AddEmployeesScreenState extends State<AddEmployeesScreen> {
//   Uint8List? _profileImage;
//   Uint8List? _idImage;
//   final TextEditingController _employeeNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneNoController = TextEditingController();
//   final TextEditingController _idNumberController = TextEditingController();
//   bool _loading = false;

//   Future<void> _selectProfileImage() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         _profileImage = result.files.single.bytes;
//       });
//     }
//   }

//   Future<void> _selectIDImage() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         _idImage = result.files.single.bytes;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Employees'),
//       ),
//       body: Scrollbar(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: _selectProfileImage,
//                   child: Container(
//                     height: 200,
//                     width: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     child: _profileImage != null
//                         ? ClipOval(
//                             child: Image.memory(
//                               _profileImage!,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : const Center(child: Text('Add profile pic')),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _employeeNameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Employee name',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _phoneNoController,
//                   decoration: const InputDecoration(
//                     labelText: 'PhoneNo',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _idNumberController,
//                   decoration: const InputDecoration(
//                     labelText: 'IdNumber',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 GestureDetector(
//                   onTap: _selectIDImage,
//                   child: Container(
//                     height: 200,
//                     width: 200,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: _idImage != null
//                         ? Image.memory(_idImage!, fit: BoxFit.cover)
//                         : const Center(child: Text('Add Id Photo')),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: _loading
//                       ? null
//                       : () async {
//                           setState(() {
//                             _loading = true;
//                           });
//                           try {
//                             // Register the user
//                             UserCredential userCredential = await FirebaseAuth
//                                 .instance
//                                 .createUserWithEmailAndPassword(
//                               email: _emailController.text,
//                               password: _passwordController.text,
//                             );

//                             final userID = userCredential.user!.uid;
//                             final storageRef = FirebaseStorage.instance.ref();
//                             final profileImageRef =
//                                 storageRef.child('profileImages/$userID.jpg');
//                             final idImageRef =
//                                 storageRef.child('idImages/$userID.jpg');
//                             final profileImageTask =
//                                 profileImageRef.putData(_profileImage!);
//                             final idImageTask = idImageRef.putData(_idImage!);
//                             final snapshot = await Future.wait(
//                                 [profileImageTask, idImageTask]);
//                             final profileImageUrl =
//                                 await snapshot[0].ref.getDownloadURL();
//                             final idImageUrl =
//                                 await snapshot[1].ref.getDownloadURL();
//                             final bytes = utf8.encode(_passwordController.text);
//                             final digest = sha256.convert(bytes);
//                             final hashedPassword = digest.toString();

//                             // Store employee details in Firestore
//                             final employeeData = {
//                               'name': _employeeNameController.text,
//                               'email': _emailController.text,
//                               'phoneNo': _phoneNoController.text,
//                               'idNumber': _idNumberController.text,
//                               'profileImage': profileImageUrl,
//                               'idImage': idImageUrl,
//                               'userID': userID,
//                             };

//                             await FirebaseFirestore.instance
//                                 .collection('employees')
//                                 .doc(userID)
//                                 .set(employeeData);

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Employee added successfully'),
//                               ),
//                             );

//                             // Reset the form
//                             _employeeNameController.clear();
//                             _emailController.clear();
//                             _passwordController.clear();
//                             _phoneNoController.clear();
//                             _idNumberController.clear();
//                             _profileImage = null;
//                             _idImage = null;
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Failed to add employee: $e'),
//                               ),
//                             );
//                           }
//                           setState(() {
//                             _loading = false;
//                           });
//                         },
//                   child: _loading
//                       ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(),
//                         )
//                       : const Text('ADD EMPLOYEE'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
