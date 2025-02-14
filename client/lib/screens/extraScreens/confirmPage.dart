import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class ConfirmPage extends StatefulWidget {
  final String houseID;

  const ConfirmPage({super.key, required this.houseID});

  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>> _houseData;
  DateTime _selectedDate =
      DateTime.now().add(Duration(days: 1)); // Default: Next day
  TimeOfDay _selectedTime = TimeOfDay(hour: 16, minute: 0); // Default: 4:00 PM
  double _serviceFee = 0.0; // To store the service fee
  double _totalFee = 0.0; // To store the total fee

  @override
  void initState() {
    super.initState();
    _houseData = _fetchHouseData().then((data) {
      // Fetch service fee after house data is fetched
      _fetchServiceFee().then((_) {
        // Calculate total fee after both house data and service fee are fetched
        _calculateTotalFee(data);
      });
      return data;
    });
  }

  Future<Map<String, dynamic>> _fetchHouseData() async {
    final doc = await _firestore.collection('houses').doc(widget.houseID).get();
    if (!doc.exists) {
      throw Exception('House not found');
    }
    return doc.data()!;
  }

  Future<void> _fetchServiceFee() async {
    final doc = await _firestore.collection('servicefee').doc('Kenya').get();
    if (doc.exists) {
      setState(() {
        // Ensure the fee is treated as a double
        _serviceFee = doc['fee'] is String
            ? double.parse(doc['fee'])
            : doc['fee'].toDouble();
      });
    }
  }

  void _calculateTotalFee(Map<String, dynamic> houseData) {
    // Ensure the agent fee is treated as a double
    final agentFee = houseData['agentfee'] is String
        ? double.parse(houseData['agentfee'])
        : houseData['agentfee'].toDouble();
    setState(() {
      _totalFee = agentFee + _serviceFee;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _houseData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data found.'));
          }

          final houseData = snapshot.data!;
          final imageUrls = houseData['imageUrls'] as List<dynamic>;
          final name = houseData['name'] as String;
          final price = houseData['price'] as double;
          final agentFee =
              houseData['agentfee']; // This could be a String or double

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Row with imageUrls and name, price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the first image from imageUrls
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(imageUrls[0]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Column with name and price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(), // Divider below the row

                // Clickable containers for date and time
                Column(
                  children: [
                    // Date of Visit
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date of Visit: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Time of Visit
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time of Visit: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(), // Divider below the containers

                // Agent Fee, Service Fee, and Total Fees
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Agent Fee Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Agent Fee',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '\$${agentFee is String ? double.parse(agentFee).toStringAsFixed(2) : agentFee.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Service Fee Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Service Fee',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '\$${_serviceFee.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Total Fees Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Fees',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '\$${_totalFee.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(), // Divider below the fees section

                // Pay with section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay with:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // M-PESA Clickable Container
                    InkWell(
                      onTap: () {
                        // Handle M-PESA payment
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.phone_android,
                                color: Colors.green), // M-PESA icon
                            SizedBox(width: 8),
                            Text(
                              'M-PESA',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Credit or Debit Card Clickable Container
                    InkWell(
                      onTap: () {
                        // Handle Credit/Debit Card payment
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.credit_card,
                                color: Colors.blue), // Credit Card icon
                            SizedBox(width: 8),
                            Text(
                              'Credit or Debit Card',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(),

                SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirm & Pay',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                ), // Divider below the Pay with section
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
// import 'package:intl/intl.dart'; // For date and time formatting

// class ConfirmPage extends StatefulWidget {
//   final String houseID;

//   const ConfirmPage({super.key, required this.houseID});

//   @override
//   _ConfirmPageState createState() => _ConfirmPageState();
// }

// class _ConfirmPageState extends State<ConfirmPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late Future<Map<String, dynamic>> _houseData;
//   DateTime _selectedDate =
//       DateTime.now().add(Duration(days: 1)); // Default: Next day
//   TimeOfDay _selectedTime = TimeOfDay(hour: 16, minute: 0); // Default: 4:00 PM
//   double _serviceFee = 0.0; // To store the service fee
//   double _totalFee = 0.0; // To store the total fee

//   @override
//   void initState() {
//     super.initState();
//     _houseData = _fetchHouseData();
//     _fetchServiceFee(); // Fetch the service fee when the page loads
//   }

//   Future<Map<String, dynamic>> _fetchHouseData() async {
//     final doc = await _firestore.collection('houses').doc(widget.houseID).get();
//     if (!doc.exists) {
//       throw Exception('House not found');
//     }
//     return doc.data()!;
//   }

//   Future<void> _fetchServiceFee() async {
//     final doc = await _firestore.collection('servicefee').doc('Kenya').get();
//     if (doc.exists) {
//       setState(() {
//         // Ensure the fee is treated as a double
//         _serviceFee = doc['fee'] is String
//             ? double.parse(doc['fee'])
//             : doc['fee'].toDouble();
//         _calculateTotalFee(); // Calculate total fee after fetching service fee
//       });
//     }
//   }

//   void _calculateTotalFee() {
//     final houseData = _houseData as Map<String, dynamic>;
//     // Ensure the agent fee is treated as a double
//     final agentFee = houseData['agentfee'] is String
//         ? double.parse(houseData['agentfee'])
//         : houseData['agentfee'].toDouble();
//     setState(() {
//       _totalFee = agentFee + _serviceFee;
//     });
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Confirm Details'),
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _houseData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData) {
//             return Center(child: Text('No data found.'));
//           }

//           final houseData = snapshot.data!;
//           final imageUrls = houseData['imageUrls'] as List<dynamic>;
//           final name = houseData['name'] as String;
//           final price = houseData['price'] as double;
//           final agentFee =
//               houseData['agentfee']; // This could be a String or double

//           return SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Row with imageUrls and name, price
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Display the first image from imageUrls
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         image: DecorationImage(
//                           image: NetworkImage(imageUrls[0]),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     // Column with name and price
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             name,
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             '\$${price.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 Divider(), // Divider below the row

//                 // Clickable containers for date and time
//                 Column(
//                   children: [
//                     // Date of Visit
//                     InkWell(
//                       onTap: () => _selectDate(context),
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Date of Visit: ',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               DateFormat('MMM dd, yyyy').format(_selectedDate),
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     // Time of Visit
//                     InkWell(
//                       onTap: () => _selectTime(context),
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Time of Visit: ',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               _selectedTime.format(context),
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 Divider(), // Divider below the containers

//                 // Agent Fee, Service Fee, and Total Fees
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Price details',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     // Agent Fee Row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Agent Fee',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         Text(
//                           '\$${agentFee is String ? double.parse(agentFee).toStringAsFixed(2) : agentFee.toStringAsFixed(2)}',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     // Service Fee Row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Service Fee',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         Text(
//                           '\$${_serviceFee.toStringAsFixed(2)}',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     // Total Fees Row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Total Fees',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         Text(
//                           '\$${_totalFee.toStringAsFixed(2)}',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 Divider(), // Divider below the fees section

//                 // Pay with section
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Pay with:',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     // M-PESA Clickable Container
//                     InkWell(
//                       onTap: () {
//                         // Handle M-PESA payment
//                       },
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.phone_android,
//                                 color: Colors.green), // M-PESA icon
//                             SizedBox(width: 8),
//                             Text(
//                               'M-PESA',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     // Credit or Debit Card Clickable Container
//                     InkWell(
//                       onTap: () {
//                         // Handle Credit/Debit Card payment
//                       },
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.credit_card,
//                                 color: Colors.blue), // Credit Card icon
//                             SizedBox(width: 8),
//                             Text(
//                               'Credit or Debit Card',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 Divider(),

//                 SizedBox(
//                   width: 350,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Confirm & Pay',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20.0),
//                     ),
//                   ),
//                 ), // Divider below the Pay with section
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
