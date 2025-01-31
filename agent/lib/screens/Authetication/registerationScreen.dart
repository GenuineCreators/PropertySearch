import 'dart:io';
import 'package:agent/screens/mainscreens/mainScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'loginScreen.dart';

class Registerationscreen extends StatefulWidget {
  const Registerationscreen({super.key});

  @override
  State<Registerationscreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<Registerationscreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  File? _idImage;

  Future<void> _pickImage(ImageSource source, bool isProfileImage) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isProfileImage) {
          _profileImage = File(pickedFile.path);
        } else {
          _idImage = File(pickedFile.path);
        }
      });
    }
    Navigator.pop(context);
  }

  void _showImagePickerOptions(bool isProfileImage) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => _pickImage(ImageSource.camera, isProfileImage),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => _pickImage(ImageSource.gallery, isProfileImage),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _registerUser() async {
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();

    if (!_isValidEmail(email) || !_isValidPhone(phone)) {
      Fluttertoast.showToast(
          msg: "Input valid email or Phone No",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();

        await _firestore.collection('Agents').doc(user.uid).set({
          'username': _userNameController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': email,
          'phone': phone,
          'idNumber': _idNumberController.text.trim(),
          'profileImage': _profileImage != null ? _profileImage!.path : '',
          'idImage': _idImage != null ? _idImage!.path : '',
        });

        Fluttertoast.showToast(
            msg: "Registered Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

        // Dismiss progress indicator before navigating
        Navigator.of(context).pop();

        // Navigate to NewCompanyScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM);
    } finally {
      Navigator.of(context)
          .pop(); // Remove CircularProgressIndicator if error occurs
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      _profileImage != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(_profileImage!),
                            )
                          : const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                  'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg'),
                            ),
                      Positioned(
                        bottom: -0,
                        left: 140,
                        child: IconButton(
                          onPressed: () {
                            _showImagePickerOptions(true);
                          },
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => _showImagePickerOptions(true),
                    child: const Text('Add Profile Picture'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Second Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone No',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _idNumberController,
                  decoration: const InputDecoration(
                    labelText: 'ID Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () => _showImagePickerOptions(false),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                      ),
                      child: _idImage != null
                          ? Image.file(
                              _idImage!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                'Upload a Photo of Your ID',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Already have an account? Login here',
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import 'loginScreen.dart';

// class Registerationscreen extends StatefulWidget {
//   const Registerationscreen({Key? key}) : super(key: key);

//   @override
//   State<Registerationscreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<Registerationscreen> {
//   TextEditingController _userNameController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _phoneController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();
//   TextEditingController _idNumberController = TextEditingController();

//   // ignore: unused_fieldap, unused_field
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final ImagePicker _picker = ImagePicker();

//   File? _profileImage;
//   File? _idImage;

//   Future<void> _pickImage(ImageSource source, bool isProfileImage) async {
//     final pickedFile = await _picker.pickImage(source: source);

//     if (pickedFile != null) {
//       setState(() {
//         if (isProfileImage) {
//           _profileImage = File(pickedFile.path);
//         } else {
//           _idImage = File(pickedFile.path);
//         }
//       });
//     }
//     Navigator.pop(context);
//   }

//   void _showImagePickerOptions(bool isProfileImage) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () => _pickImage(ImageSource.camera, isProfileImage),
//               ),
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Gallery'),
//                 onTap: () => _pickImage(ImageSource.gallery, isProfileImage),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 30),
//                 Center(
//                   child: Text(
//                     'Create an Account',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: Stack(
//                     children: [
//                       _profileImage != null
//                           ? CircleAvatar(
//                               radius: 50,
//                               backgroundImage: FileImage(_profileImage!),
//                             )
//                           : CircleAvatar(
//                               radius: 50,
//                               backgroundImage: const NetworkImage(
//                                   'https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg'),
//                             ),
//                       Positioned(
//                         bottom: -0,
//                         left: 140,
//                         child: IconButton(
//                           onPressed: () {
//                             _showImagePickerOptions(true);
//                           },
//                           icon: const Icon(Icons.add_a_photo),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Center(
//                   child: TextButton(
//                     onPressed: () => _showImagePickerOptions(true),
//                     child: const Text('Add Profile Picture'),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _userNameController,
//                   decoration: InputDecoration(
//                     labelText: 'User Name',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _userNameController,
//                   decoration: InputDecoration(
//                     labelText: 'First Name',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _userNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Second Name',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _phoneController,
//                   decoration: InputDecoration(
//                     labelText: 'Phone No',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.phone,
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                   ),
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _idNumberController,
//                   decoration: InputDecoration(
//                     labelText: 'ID Number',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                   child: GestureDetector(
//                     onTap: () => _showImagePickerOptions(false),
//                     child: Container(
//                       height: 150,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.grey.shade200,
//                       ),
//                       child: _idImage != null
//                           ? Image.file(
//                               _idImage!,
//                               fit: BoxFit.cover,
//                             )
//                           : Center(
//                               child: Text(
//                                 'Upload a Photo of Your ID',
//                                 style: TextStyle(color: Colors.grey[600]),
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: 350,
//                   child: ElevatedButton(
//                     onPressed: () {}, // signUpWithEmail,
//                     child: Text(
//                       'Sign Up',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20.0),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LoginScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text('Sign In'),
//                     ),
//                     const SizedBox(width: 20),
//                     TextButton(
//                       onPressed: () {
//                         // Add logic for forgot password
//                       },
//                       child: const Text('Forgot Password?'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
