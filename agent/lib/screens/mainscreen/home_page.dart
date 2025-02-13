// // ignore_for_file: unnecessary_null_comparison

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart'; // Use the geocoding package

// class NewHouses extends StatefulWidget {
//   const NewHouses({super.key});

//   @override
//   _NewHousesState createState() => _NewHousesState();
// }

// class _NewHousesState extends State<NewHouses> {
//   final List<File> _images = [];
//   final ImagePicker _picker = ImagePicker();
//   String? _selectedType;
//   final List<String> _types = ['AirBNB', 'Rental', 'Sale'];
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _bedroomsController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _bathroomController = TextEditingController();
//   final TextEditingController _searchLocationController =
//       TextEditingController();

//   final Map<String, bool> _amenities = {
//     'Schools': false,
//     'Malls': false,
//     'Shopping Centre': false,
//     'Police Station': false,
//   };
//   bool _hasSwimmingPool = false;
//   bool _hasGym = false;
//   bool _hasParking = false;
//   bool _hasBalcony = false;
//   bool _hasSecurity = false;
//   bool _isPetFriendly = false;
//   bool _isUploading = false;

//   // Firebase Auth instance
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Google Maps Controller
//   late GoogleMapController _mapController;

//   // Marker for the selected location
//   Marker? _locationMarker;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('New Houses'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             // Search Location Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _searchLocationController,
//                     decoration: InputDecoration(
//                       labelText: 'Search Location',
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) {
//                       _onSearchChanged(value);
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // Location Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _locationController,
//                 decoration: InputDecoration(
//                   labelText: 'Location',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),

//             // Type Dropdown
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: DropdownButtonFormField<String>(
//                 value: _selectedType,
//                 decoration: InputDecoration(
//                   labelText: 'Select the type',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _types.map((String type) {
//                   return DropdownMenuItem<String>(
//                     value: type,
//                     child: Text(type),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedType = newValue;
//                   });
//                 },
//               ),
//             ),

//             // Number of Bedrooms Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _bedroomsController,
//                 decoration: InputDecoration(
//                   labelText: 'Number of bedrooms',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),

//             // Number of Bathrooms Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _bathroomController,
//                 decoration: InputDecoration(
//                   labelText: 'Number of bathrooms',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),

//             // Price Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _priceController,
//                 decoration: InputDecoration(
//                   labelText: 'Price',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),

//             // Description Text Form Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ),

//             // Closed Amenities Section
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Closed Amenities',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   GridView.count(
//                     crossAxisCount: 2,
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     children: _amenities.keys.map((String key) {
//                       return CheckboxListTile(
//                         title: Text(key),
//                         value: _amenities[key],
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _amenities[key] = value!;
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),

//             // Extra Section
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Extra',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   // Arrange checkboxes in rows of 2
//                   GridView.count(
//                     crossAxisCount: 2,
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     children: [
//                       CheckboxListTile(
//                         title: Text('Swimming Pool'),
//                         value: _hasSwimmingPool,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasSwimmingPool = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Gym'),
//                         value: _hasGym,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasGym = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Parking'),
//                         value: _hasParking,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasParking = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Balcony'),
//                         value: _hasBalcony,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasBalcony = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Security'),
//                         value: _hasSecurity,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasSecurity = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Pet Friendly'),
//                         value: _isPetFriendly,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _isPetFriendly = value!;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Upload Photos Section
//             GestureDetector(
//               onTap: _selectImages,
//               child: Container(
//                 margin: EdgeInsets.all(10),
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Text('Upload photos'),
//                 ),
//               ),
//             ),

//             // Display Selected Images
//             _images.isEmpty
//                 ? Container()
//                 : Container(
//                     margin: EdgeInsets.all(10),
//                     height: 100,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _images.length,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           margin: EdgeInsets.all(5),
//                           width: 100,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image: Image.file(_images[index]).image,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//             // Google Maps Section
//             Container(
//               height: 300,
//               margin: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: GoogleMap(
//                 onMapCreated: (controller) {
//                   setState(() {
//                     _mapController = controller;
//                   });
//                 },
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(0, 0), // Default position
//                   zoom: 10,
//                 ),
//                 markers: _locationMarker != null ? {_locationMarker!} : {},
//               ),
//             ),

//             // Upload House Button
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: _isUploading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _uploadHouse,
//                       child: Text('Upload House'),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _selectImages() async {
//     final pickedFiles = await _picker.pickMultiImage();
//     setState(() {
//       if (pickedFiles != null) {
//         _images.addAll(pickedFiles.map((file) => File(file.path)));
//       }
//     });
//   }

//   void _uploadHouse() async {
//     // Validate that all text fields are filled out
//     if (_locationController.text.isEmpty ||
//         _selectedType == null ||
//         _bedroomsController.text.isEmpty ||
//         _bathroomController.text.isEmpty ||
//         _priceController.text.isEmpty ||
//         _descriptionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill out all fields')),
//       );
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       // Get the current user
//       final User? user = _auth.currentUser;
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('User not logged in')),
//         );
//         return;
//       }

//       // Generate a unique houseID
//       final houseID = Uuid().v4();

//       // Upload images to Firebase Storage and get their URLs
//       final List<String> imageUrls = [];
//       for (final image in _images) {
//         final ref = FirebaseStorage.instance
//             .ref()
//             .child('house_images/$houseID/${Uuid().v4()}');
//         await ref.putFile(image);
//         final url = await ref.getDownloadURL();
//         imageUrls.add(url);
//       }

//       // Prepare data for Firestore
//       final houseData = {
//         'houseID': houseID,
//         'agentID': user.uid,
//         'searchLocation':
//             _searchLocationController.text, // Use the current user's UID
//         'location': _locationController.text,
//         'type': _selectedType,
//         'bedrooms': int.parse(_bedroomsController.text),
//         'bathrooms': int.parse(_bathroomController.text),
//         'price': double.parse(_priceController.text),
//         'description': _descriptionController.text,
//         'amenities': _amenities,
//         'hasSwimmingPool': _hasSwimmingPool,
//         'hasGym': _hasGym,
//         'hasParking': _hasParking,
//         'hasBalcony': _hasBalcony,
//         'hasSecurity': _hasSecurity,
//         'isPetFriendly': _isPetFriendly,
//         'imageUrls': imageUrls,
//         'createdAt': DateTime.now(),
//       };

//       // Upload data to Firestore
//       await FirebaseFirestore.instance
//           .collection('houses')
//           .doc(houseID)
//           .set(houseData);

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload Successful')),
//       );

//       // Refresh the page
//       setState(() {
//         _isUploading = false;
//         _locationController.clear();
//         _selectedType = null;
//         _bedroomsController.clear();
//         _bathroomController.clear();
//         _priceController.clear();
//         _descriptionController.clear();
//         _images.clear();
//         _amenities.forEach((key, value) => _amenities[key] = false);
//         _hasSwimmingPool = false;
//         _hasGym = false;
//         _hasParking = false;
//         _hasBalcony = false;
//         _hasSecurity = false;
//         _isPetFriendly = false;
//       });
//     } catch (e) {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not upload: $e')),
//       );
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }

//   void _onSearchChanged(String value) async {
//     if (value.isNotEmpty) {
//       // Use the geocoding package to search for the location
//       try {
//         List<Location> locations = await locationFromAddress(value);
//         if (locations.isNotEmpty) {
//           final location = locations.first;
//           setState(() {
//             _locationMarker = Marker(
//               markerId: MarkerId('selectedLocation'),
//               position: LatLng(location.latitude, location.longitude),
//             );
//           });

//           // Move the camera to the selected location
//           _mapController.animateCamera(
//             CameraUpdate.newLatLngZoom(
//                 LatLng(location.latitude, location.longitude), 15),
//           );
//         }
//       } catch (e) {
//         print('Geocoding error: $e');
//       }
//     }
//   }
// }

// // ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_webservice/places.dart';

class NewHouses extends StatefulWidget {
  const NewHouses({super.key});

  @override
  _NewHousesState createState() => _NewHousesState();
}

class _NewHousesState extends State<NewHouses> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  String? _selectedType;
  final List<String> _types = ['AirBNB', 'Rental', 'Sale'];
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bathroomController = TextEditingController();
  final TextEditingController _searchLocationController =
      TextEditingController();

  final Map<String, bool> _amenities = {
    'Schools': false,
    'Malls': false,
    'Shopping Centre': false,
    'Police Station': false,
  };
  bool _hasSwimmingPool = false;
  bool _hasGym = false;
  bool _hasParking = false;
  bool _hasBalcony = false;
  bool _hasSecurity = false;
  bool _isPetFriendly = false;
  bool _isUploading = false;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Places API
  final GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey:
          'AIzaSyD6QxmfNe3QuZPf-tKIr6_p469DPixINrU'); // Replace with your API key
  List<Prediction> _placePredictions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Houses'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Search Location Text Field
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchLocationController,
                    decoration: InputDecoration(
                      labelText: 'Search Location',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _onSearchChanged(value);
                    },
                  ),
                  if (_placePredictions.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _placePredictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_placePredictions[index].description!),
                            onTap: () {
                              _onPlaceSelected(_placePredictions[index]);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Location Text Field
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Type Dropdown
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Select the type',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
              ),
            ),

            // Number of Bedrooms Text Field
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _bedroomsController,
                decoration: InputDecoration(
                  labelText: 'Number of bedrooms',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),

            // Number of Bathrooms Text Field
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _bathroomController,
                decoration: InputDecoration(
                  labelText: 'Number of bathrooms',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),

            // Price Text Field
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),

            // Description Text Form Field
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),

            // Closed Amenities Section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Closed Amenities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: _amenities.keys.map((String key) {
                      return CheckboxListTile(
                        title: Text(key),
                        value: _amenities[key],
                        onChanged: (bool? value) {
                          setState(() {
                            _amenities[key] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Extra Section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extra',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // Arrange checkboxes in rows of 2
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      CheckboxListTile(
                        title: Text('Swimming Pool'),
                        value: _hasSwimmingPool,
                        onChanged: (bool? value) {
                          setState(() {
                            _hasSwimmingPool = value!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Gym'),
                        value: _hasGym,
                        onChanged: (bool? value) {
                          setState(() {
                            _hasGym = value!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Parking'),
                        value: _hasParking,
                        onChanged: (bool? value) {
                          setState(() {
                            _hasParking = value!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Balcony'),
                        value: _hasBalcony,
                        onChanged: (bool? value) {
                          setState(() {
                            _hasBalcony = value!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Security'),
                        value: _hasSecurity,
                        onChanged: (bool? value) {
                          setState(() {
                            _hasSecurity = value!;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Pet Friendly'),
                        value: _isPetFriendly,
                        onChanged: (bool? value) {
                          setState(() {
                            _isPetFriendly = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Upload Photos Section
            GestureDetector(
              onTap: _selectImages,
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('Upload photos'),
                ),
              ),
            ),

            // Display Selected Images
            _images.isEmpty
                ? Container()
                : Container(
                    margin: EdgeInsets.all(10),
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(5),
                          width: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: Image.file(_images[index]).image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            // Upload House Button
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadHouse,
                      child: Text('Upload House'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      if (pickedFiles != null) {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      }
    });
  }

  void _uploadHouse() async {
    // Validate that all text fields are filled out
    if (_locationController.text.isEmpty ||
        _selectedType == null ||
        _bedroomsController.text.isEmpty ||
        _bathroomController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get the current user
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Generate a unique houseID
      final houseID = Uuid().v4();

      // Upload images to Firebase Storage and get their URLs
      final List<String> imageUrls = [];
      for (final image in _images) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('house_images/$houseID/${Uuid().v4()}');
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // Prepare data for Firestore
      final houseData = {
        'houseID': houseID,
        'agentID': user.uid,
        'searchLocation':
            _searchLocationController.text, // Use the current user's UID
        'location': _locationController.text,
        'type': _selectedType,
        'bedrooms': int.parse(_bedroomsController.text),
        'bathrooms': int.parse(_bathroomController.text),
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'amenities': _amenities,
        'hasSwimmingPool': _hasSwimmingPool,
        'hasGym': _hasGym,
        'hasParking': _hasParking,
        'hasBalcony': _hasBalcony,
        'hasSecurity': _hasSecurity,
        'isPetFriendly': _isPetFriendly,
        'imageUrls': imageUrls,
        'createdAt': DateTime.now(),
      };

      // Upload data to Firestore
      await FirebaseFirestore.instance
          .collection('houses')
          .doc(houseID)
          .set(houseData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload Successful')),
      );

      // Refresh the page
      setState(() {
        _isUploading = false;
        _locationController.clear();
        _selectedType = null;
        _bedroomsController.clear();
        _bathroomController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _images.clear();
        _amenities.forEach((key, value) => _amenities[key] = false);
        _hasSwimmingPool = false;
        _hasGym = false;
        _hasParking = false;
        _hasBalcony = false;
        _hasSecurity = false;
        _isPetFriendly = false;
      });
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not upload: $e')),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      PlacesAutocompleteResponse response = await _places.autocomplete(value);
      setState(() {
        _placePredictions = response.predictions;
      });
    } else {
      setState(() {
        _placePredictions.clear();
      });
    }
  }

  void _onPlaceSelected(Prediction prediction) async {
    PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(prediction.placeId!);
    setState(() {
      _searchLocationController.text = prediction.description!;
      _locationController.text = detail.result.formattedAddress!;
      _placePredictions.clear();
    });
  }
}



























// // ignore_for_file: unnecessary_null_comparison

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NewHouses extends StatefulWidget {
//   const NewHouses({super.key});

//   @override
//   _NewHousesState createState() => _NewHousesState();
// }

// class _NewHousesState extends State<NewHouses> {
//   final List<File> _images = [];
//   final ImagePicker _picker = ImagePicker();
//   String? _selectedType;
//   final List<String> _types = ['AirBNB', 'Rental', 'Sale'];
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _bedroomsController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _bathroomController = TextEditingController();

//   final Map<String, bool> _amenities = {
//     'Schools': false,
//     'Malls': false,
//     'Shopping Centre': false,
//     'Police Station': false,
//   };
//   bool _hasSwimmingPool = false;
//   bool _hasGym = false;
//   bool _hasParking = false;
//   bool _hasBalcony = false;
//   bool _hasSecurity = false;
//   bool _isPetFriendly = false;
//   bool _isUploading = false;

//   // Firebase Auth instance
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('New Houses'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             // Location Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _locationController,
//                 decoration: InputDecoration(
//                   labelText: 'Location',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),

//             // Type Dropdown
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: DropdownButtonFormField<String>(
//                 value: _selectedType,
//                 decoration: InputDecoration(
//                   labelText: 'Select the type',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: _types.map((String type) {
//                   return DropdownMenuItem<String>(
//                     value: type,
//                     child: Text(type),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedType = newValue;
//                   });
//                 },
//               ),
//             ),

//             // Number of Bedrooms Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _bedroomsController,
//                 decoration: InputDecoration(
//                   labelText: 'Number of bedrooms',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),

//             // Number of Bathrooms Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _bathroomController,
//                 decoration: InputDecoration(
//                   labelText: 'Number of bathrooms',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),

//             // Price Text Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: _priceController,
//                 decoration: InputDecoration(
//                   labelText: 'Price',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),

//             // Description Text Form Field
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ),

//             // Closed Amenities Section
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Closed Amenities',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   GridView.count(
//                     crossAxisCount: 2,
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     children: _amenities.keys.map((String key) {
//                       return CheckboxListTile(
//                         title: Text(key),
//                         value: _amenities[key],
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _amenities[key] = value!;
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ],
//               ),
//             ),

//             // Extra Section
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Extra',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   // Arrange checkboxes in rows of 2
//                   GridView.count(
//                     crossAxisCount: 2,
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     children: [
//                       CheckboxListTile(
//                         title: Text('Swimming Pool'),
//                         value: _hasSwimmingPool,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasSwimmingPool = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Gym'),
//                         value: _hasGym,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasGym = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Parking'),
//                         value: _hasParking,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasParking = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Balcony'),
//                         value: _hasBalcony,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasBalcony = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Security'),
//                         value: _hasSecurity,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _hasSecurity = value!;
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Pet Friendly'),
//                         value: _isPetFriendly,
//                         onChanged: (bool? value) {
//                           setState(() {
//                             _isPetFriendly = value!;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Upload Photos Section
//             GestureDetector(
//               onTap: _selectImages,
//               child: Container(
//                 margin: EdgeInsets.all(10),
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Text('Upload photos'),
//                 ),
//               ),
//             ),

//             // Display Selected Images
//             _images.isEmpty
//                 ? Container()
//                 : Container(
//                     margin: EdgeInsets.all(10),
//                     height: 100,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _images.length,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           margin: EdgeInsets.all(5),
//                           width: 100,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image: Image.file(_images[index]).image,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//             // Upload House Button
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: _isUploading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _uploadHouse,
//                       child: Text('Upload House'),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _selectImages() async {
//     final pickedFiles = await _picker.pickMultiImage();
//     setState(() {
//       if (pickedFiles != null) {
//         _images.addAll(pickedFiles.map((file) => File(file.path)));
//       }
//     });
//   }

//   void _uploadHouse() async {
//     // Validate that all text fields are filled out
//     if (_locationController.text.isEmpty ||
//         _selectedType == null ||
//         _bedroomsController.text.isEmpty ||
//         _bathroomController.text.isEmpty ||
//         _priceController.text.isEmpty ||
//         _descriptionController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill out all fields')),
//       );
//       return;
//     }

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       // Get the current user
//       final User? user = _auth.currentUser;
//       if (user == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('User not logged in')),
//         );
//         return;
//       }

//       // Generate a unique houseID
//       final houseID = Uuid().v4();

//       // Upload images to Firebase Storage and get their URLs
//       final List<String> imageUrls = [];
//       for (final image in _images) {
//         final ref = FirebaseStorage.instance
//             .ref()
//             .child('house_images/$houseID/${Uuid().v4()}');
//         await ref.putFile(image);
//         final url = await ref.getDownloadURL();
//         imageUrls.add(url);
//       }

//       // Prepare data for Firestore
//       final houseData = {
//         'houseID': houseID,
//         'agentID': user.uid, // Use the current user's UID
//         'location': _locationController.text,
//         'type': _selectedType,
//         'bedrooms': int.parse(_bedroomsController.text),
//         'bathrooms': int.parse(_bathroomController.text),
//         'price': double.parse(_priceController.text),
//         'description': _descriptionController.text,
//         'amenities': _amenities,
//         'hasSwimmingPool': _hasSwimmingPool,
//         'hasGym': _hasGym,
//         'hasParking': _hasParking,
//         'hasBalcony': _hasBalcony,
//         'hasSecurity': _hasSecurity,
//         'isPetFriendly': _isPetFriendly,
//         'imageUrls': imageUrls,
//         'createdAt': DateTime.now(),
//       };

//       // Upload data to Firestore
//       await FirebaseFirestore.instance
//           .collection('houses')
//           .doc(houseID)
//           .set(houseData);

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload Successful')),
//       );

//       // Refresh the page
//       setState(() {
//         _isUploading = false;
//         _locationController.clear();
//         _selectedType = null;
//         _bedroomsController.clear();
//         _bathroomController.clear();
//         _priceController.clear();
//         _descriptionController.clear();
//         _images.clear();
//         _amenities.forEach((key, value) => _amenities[key] = false);
//         _hasSwimmingPool = false;
//         _hasGym = false;
//         _hasParking = false;
//         _hasBalcony = false;
//         _hasSecurity = false;
//         _isPetFriendly = false;
//       });
//     } catch (e) {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not upload: $e')),
//       );
//       setState(() {
//         _isUploading = false;
//       });
//     }
//   }
// }