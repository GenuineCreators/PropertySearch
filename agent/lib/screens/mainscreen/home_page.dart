import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewHouses extends StatefulWidget {
  const NewHouses({super.key});

  @override
  State<NewHouses> createState() => _NewHousesState();
}

class _NewHousesState extends State<NewHouses> {
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Houses"),
      ),
      body: Center(
        child: Column(children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: imageFileList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Image.file(File(imageFileList[index].path),
                        fit: BoxFit.cover);
                  }),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          MaterialButton(
              color: Colors.blue,
              child: Text("Upload images"),
              onPressed: () {
                selectImages();
              })
        ]),
      ),
    );
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
