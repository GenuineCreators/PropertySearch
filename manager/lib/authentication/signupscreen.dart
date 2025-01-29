import 'dart:typed_data';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manager/mainscreens/homepage.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() {
  runApp(const MaterialApp(home: SignupScreen()));
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  Uint8List? businessPhotoBytes;
  Uint8List? ownerPhotoBytes;
  Uint8List? idPhotoBytes;
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessEmailController = TextEditingController();
  final TextEditingController businessPhoneController = TextEditingController();
  final TextEditingController physicalAddressController =
      TextEditingController();
  final TextEditingController bankAccountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerEmailController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController ownerIDController = TextEditingController();
  Future<void> pickBusinessPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        businessPhotoBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> pickOwnerPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        ownerPhotoBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> pickIDPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        idPhotoBytes = result.files.single.bytes;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> handleSignUp() async {
    if (businessPhotoBytes == null ||
        ownerPhotoBytes == null ||
        idPhotoBytes == null ||
        businessNameController.text.isEmpty ||
        businessEmailController.text.isEmpty ||
        businessPhoneController.text.isEmpty ||
        physicalAddressController.text.isEmpty ||
        bankAccountController.text.isEmpty ||
        passwordController.text.isEmpty ||
        ownerNameController.text.isEmpty ||
        ownerEmailController.text.isEmpty ||
        ownerPhoneController.text.isEmpty ||
        ownerIDController.text.isEmpty) {
      _showErrorDialog(
          'Please fill out all fields and upload all required photos.');
      return;
    } else if (!EmailValidator.validate(businessEmailController.text)) {
      _showErrorDialog('Please enter a valid business email.');
      return;
    } else if (!EmailValidator.validate(ownerEmailController.text)) {
      _showErrorDialog('Please enter a valid owner email.');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final businessPhotoUrl = await uploadImageToStorage(businessPhotoBytes!);
      final ownerPhotoUrl = await uploadImageToStorage(ownerPhotoBytes!);
      final idPhotoUrl = await uploadImageToStorage(idPhotoBytes!);
      // Authenticate the user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: businessEmailController.text,
        password: passwordController.text,
      );
      // Get the current user's UID
      String managerID = userCredential.user!.uid;
      // Store user details in Firestore
      await FirebaseFirestore.instance
          .collection('managers')
          .doc(managerID)
          .set({
        'managerID': managerID,
        'businessName': businessNameController.text,
        'businessEmail': businessEmailController.text,
        'businessPhone': businessPhoneController.text,
        'physicalAddress': physicalAddressController.text,
        'bankAccountDetails': bankAccountController.text,
        'ownerFullName': ownerNameController.text,
        'ownerEmail': ownerEmailController.text,
        'ownerPhone': ownerPhoneController.text,
        'ownerIDNumber': ownerIDController.text,
        'ownerPhotoUrl': ownerPhotoUrl,
        'idPhotoUrl': idPhotoUrl,
        'businessPhotoUrl': businessPhotoUrl,
      });
      // Successfully signed up, redirect to HomePage
      setState(() {
        _isLoading = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false, // This removes the previous routes
      );
    } catch (e) {
      // Handling authentication exceptions and other errors
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Sign up failed: ${e.toString()}');
    }
  }

  bool _isLoading = false;
  Future<String> uploadImageToStorage(Uint8List image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final uploadTask =
        storageRef.child('manager_images/${Uuid().v4()}').putData(image);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Signup'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: pickBusinessPhoto,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: businessPhotoBytes == null
                    ? const Center(child: Text('Upload Business Photo'))
                    : Image.memory(businessPhotoBytes!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: businessNameController,
              decoration: InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: businessEmailController,
              decoration: InputDecoration(
                labelText: 'Business Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: businessPhoneController,
              decoration: InputDecoration(
                labelText: 'Business Phone No',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: physicalAddressController,
              decoration: InputDecoration(
                labelText: 'Physical Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: bankAccountController,
              decoration: InputDecoration(
                labelText: 'Bank Account Details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              "Owner Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Column(
              children: [
                GestureDetector(
                  onTap: pickOwnerPhoto,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ownerPhotoBytes == null
                        ? const Center(child: Text('Profile Photo'))
                        : ClipOval(
                            child: Image.memory(
                              ownerPhotoBytes!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: ownerNameController,
              decoration: InputDecoration(
                labelText: 'Owner Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: ownerEmailController,
              decoration: InputDecoration(
                labelText: 'Owner Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: ownerPhoneController,
              decoration: InputDecoration(
                labelText: 'Owner Phone No',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: ownerIDController,
              decoration: InputDecoration(
                labelText: 'Owner ID Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: pickIDPhoto,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: idPhotoBytes == null
                    ? const Center(child: Text('Upload ID Photo'))
                    : Image.memory(idPhotoBytes!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:typed_data';

// import 'package:email_validator/email_validator.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:managers/mainscreens/homepage.dart';
// import 'package:uuid/uuid.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// void main() {
//   runApp(const MaterialApp(home: SignupScreen()));
// }

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   Uint8List? businessPhotoBytes;
//   Uint8List? ownerPhotoBytes;
//   Uint8List? idPhotoBytes;
//   final TextEditingController businessNameController = TextEditingController();
//   final TextEditingController businessEmailController = TextEditingController();
//   final TextEditingController businessPhoneController = TextEditingController();
//   final TextEditingController physicalAddressController =
//       TextEditingController();
//   final TextEditingController bankAccountController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController ownerNameController = TextEditingController();
//   final TextEditingController ownerEmailController = TextEditingController();
//   final TextEditingController ownerPhoneController = TextEditingController();
//   final TextEditingController ownerIDController = TextEditingController();
//   Future<void> pickBusinessPhoto() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         businessPhotoBytes = result.files.single.bytes;
//       });
//     }
//   }

//   Future<void> pickOwnerPhoto() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         ownerPhotoBytes = result.files.single.bytes;
//       });
//     }
//   }

//   Future<void> pickIDPhoto() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         idPhotoBytes = result.files.single.bytes;
//       });
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> handleSignUp() async {
//     if (businessPhotoBytes == null ||
//         ownerPhotoBytes == null ||
//         idPhotoBytes == null ||
//         businessNameController.text.isEmpty ||
//         businessEmailController.text.isEmpty ||
//         businessPhoneController.text.isEmpty ||
//         physicalAddressController.text.isEmpty ||
//         bankAccountController.text.isEmpty ||
//         passwordController.text.isEmpty ||
//         ownerNameController.text.isEmpty ||
//         ownerEmailController.text.isEmpty ||
//         ownerPhoneController.text.isEmpty ||
//         ownerIDController.text.isEmpty) {
//       _showErrorDialog(
//           'Please fill out all fields and upload all required photos.');
//       return;
//     } else if (!EmailValidator.validate(businessEmailController.text)) {
//       _showErrorDialog('Please enter a valid business email.');
//       return;
//     } else if (!EmailValidator.validate(ownerEmailController.text)) {
//       _showErrorDialog('Please enter a valid owner email.');
//       return;
//     }
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final businessPhotoUrl = await uploadImageToStorage(businessPhotoBytes!);
//       final ownerPhotoUrl = await uploadImageToStorage(ownerPhotoBytes!);
//       final idPhotoUrl = await uploadImageToStorage(idPhotoBytes!);
//       // Authenticate the user
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: businessEmailController.text,
//         password: passwordController.text,
//       );
//       // Generate a unique manager ID
//       String managerID = Uuid().v4();
//       // Store user details in Firestore
//       await FirebaseFirestore.instance
//           .collection('managers')
//           .doc(managerID)
//           .set({
//         'managerID': managerID,
//         'businessName': businessNameController.text,
//         'businessEmail': businessEmailController.text,
//         'businessPhone': businessPhoneController.text,
//         'physicalAddress': physicalAddressController.text,
//         'bankAccountDetails': bankAccountController.text,
//         'ownerFullName': ownerNameController.text,
//         'ownerEmail': ownerEmailController.text,
//         'ownerPhone': ownerPhoneController.text,
//         'ownerIDNumber': ownerIDController.text,
//         'ownerPhotoUrl': ownerPhotoUrl,
//         'idPhotoUrl': idPhotoUrl,
//         'businessPhotoUrl': businessPhotoUrl,
//       });
//       // Successfully signed up, redirect to HomePage
//       setState(() {
//         _isLoading = false;
//       });
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const HomePage()),
//         (Route<dynamic> route) => false, // This removes the previous routes
//       );
//     } catch (e) {
//       // Handling authentication exceptions and other errors
//       setState(() {
//         _isLoading = false;
//       });
//       _showErrorDialog('Sign up failed: ${e.toString()}');
//     }
//   }

//   bool _isLoading = false;
//   Future<String> uploadImageToStorage(Uint8List image) async {
//     final storageRef = FirebaseStorage.instance.ref();
//     final uploadTask =
//         storageRef.child('manager_images/${Uuid().v4()}').putData(image);
//     final snapshot = await uploadTask.whenComplete(() => null);
//     return await snapshot.ref.getDownloadURL();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Business Signup'),
//         backgroundColor: Colors.blue,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 16.0),
//             GestureDetector(
//               onTap: pickBusinessPhoto,
//               child: Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: businessPhotoBytes == null
//                     ? const Center(child: Text('Upload Business Photo'))
//                     : Image.memory(businessPhotoBytes!, fit: BoxFit.cover),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: businessNameController,
//               decoration: InputDecoration(
//                 labelText: 'Business Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: businessEmailController,
//               decoration: InputDecoration(
//                 labelText: 'Business Email',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: businessPhoneController,
//               decoration: InputDecoration(
//                 labelText: 'Business Phone No',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: physicalAddressController,
//               decoration: InputDecoration(
//                 labelText: 'Physical Address',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: bankAccountController,
//               decoration: InputDecoration(
//                 labelText: 'Bank Account Details',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Text(
//               "Owner Details",
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Column(
//               children: [
//                 GestureDetector(
//                   onTap: pickOwnerPhoto,
//                   child: Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     child: ownerPhotoBytes == null
//                         ? const Center(child: Text('Profile Photo'))
//                         : ClipOval(
//                             child: Image.memory(
//                               ownerPhotoBytes!,
//                               fit: BoxFit.cover,
//                               width: 120,
//                               height: 120,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 8.0),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: ownerNameController,
//               decoration: InputDecoration(
//                 labelText: 'Owner Full Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: ownerEmailController,
//               decoration: InputDecoration(
//                 labelText: 'Owner Email',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: ownerPhoneController,
//               decoration: InputDecoration(
//                 labelText: 'Owner Phone No',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: ownerIDController,
//               decoration: InputDecoration(
//                 labelText: 'Owner ID Number',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             GestureDetector(
//               onTap: pickIDPhoto,
//               child: Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: idPhotoBytes == null
//                     ? const Center(child: Text('Upload ID Photo'))
//                     : Image.memory(idPhotoBytes!, fit: BoxFit.cover),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _isLoading ? null : handleSignUp,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//               child: _isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Sign Up'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
