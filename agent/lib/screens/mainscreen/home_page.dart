// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewHouses extends StatefulWidget {
  @override
  _NewHousesState createState() => _NewHousesState();
}

class _NewHousesState extends State<NewHouses> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = "Select the type";
  bool _schools = false;
  bool _malls = false;
  bool _shoppingCentre = false;
  bool _policeStation = false;
  bool _swimmingPool = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Houses'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: ["Select the type", "AirBNB", "Rental", "Sale"]
                  .map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _bedroomsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Number of Bedrooms'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 10),
            Text('Closed Amenities',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              runSpacing: 5,
              children: [
                _buildCheckbox('Schools', _schools,
                    (value) => setState(() => _schools = value)),
                _buildCheckbox(
                    'Malls', _malls, (value) => setState(() => _malls = value)),
                _buildCheckbox('Shopping Centre', _shoppingCentre,
                    (value) => setState(() => _shoppingCentre = value)),
                _buildCheckbox('Police Station', _policeStation,
                    (value) => setState(() => _policeStation = value)),
              ],
            ),
            SizedBox(height: 10),
            Text('Extra', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildCheckbox('Swimming Pool', _swimmingPool,
                (value) => setState(() => _swimmingPool = value)),
            SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
            value: value, onChanged: (bool? newValue) => onChanged(newValue!)),
        Text(title),
      ],
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
}













// // ignore_for_file: unnecessary_null_comparison

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class NewHouses extends StatefulWidget {
//   @override
//   _NewHousesState createState() => _NewHousesState();
// }

// class _NewHousesState extends State<NewHouses> {
//   List<File> _images = [];
//   final ImagePicker _picker = ImagePicker();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('New Houses'),
//       ),
//       body: Column(
//         children: <Widget>[
//           GestureDetector(
//             onTap: _selectImages,
//             child: Container(
//               margin: EdgeInsets.all(10),
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Center(
//                 child: Text('Upload photos'),
//               ),
//             ),
//           ),
//           _images.isEmpty
//               ? Container()
//               : Container(
//                   margin: EdgeInsets.all(10),
//                   height: 100,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _images.length,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         margin: EdgeInsets.all(5),
//                         width: 100,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                             image: Image.file(_images[index]).image,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//         ],
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
// }




// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class NewHouses extends StatefulWidget {
//   const NewHouses({super.key});

//   @override
//   State<NewHouses> createState() => _NewHousesState();
// }

// class _NewHousesState extends State<NewHouses> {
//   final ImagePicker imagePicker = ImagePicker();
//   List<XFile> imageFileList = [];

//   void selectImages() async {
//     final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
//     if (selectedImages!.isNotEmpty) {
//       imageFileList.addAll(selectedImages);
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add New Houses"),
//       ),
//       body: Center(
//         child: Column(children: <Widget>[
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.all(8.0),
//               child: GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3),
//                   itemCount: imageFileList.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return Image.file(File(imageFileList[index].path),
//                         fit: BoxFit.cover);
//                   }),
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           MaterialButton(
//               color: Colors.blue,
//               child: Text("Upload images"),
//               onPressed: () {
//                 selectImages();
//               })
//         ]),
//       ),
//     );
//   }
// }