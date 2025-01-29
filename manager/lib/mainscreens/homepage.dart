import 'package:flutter/material.dart';
import 'package:manager/mainscreens/addemployees.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Row(
        children: [
          NavigationBar(_selectedIndex, (index) {
            setState(() {
              _selectedIndex = index;
            });
          }),
          const VerticalDivider(width: 1),
          Expanded(
            child: _selectedIndex == 0
                ? DashboardScreen()
                : _selectedIndex == 1
                    ? ViewOrdersScreen()
                    : _selectedIndex == 2
                        ? AddEmployeesScreen()
                        : _selectedIndex == 3
                            ? PromotionScreen()
                            : FeedbackScreen(),
          ),
        ],
      ),
    );
  }
}

class NavigationBar extends StatelessWidget {
  final int _selectedIndex;
  final Function(int) _onTap;
  const NavigationBar(this._selectedIndex, this._onTap, {super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(
              index == 0
                  ? Icons.dashboard
                  : index == 1
                      ? Icons.view_list
                      : index == 2
                          ? Icons.person_add
                          : index == 3
                              ? Icons.local_offer
                              : Icons.feedback,
            ),
            title: Text(
              index == 0
                  ? 'Dashboard'
                  : index == 1
                      ? 'View Orders'
                      : index == 2
                          ? 'Add employees'
                          : index == 3
                              ? 'Promotion'
                              : 'Feedback',
            ),
            onTap: () {
              _onTap(index);
            },
            selected: _selectedIndex == index,
          );
        },
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Dashboard Screen'),
    );
  }
}

class ViewOrdersScreen extends StatelessWidget {
  const ViewOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('View Orders Screen'),
    );
  }
}

class PromotionScreen extends StatelessWidget {
  const PromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Promotion Screen'),
    );
  }
}

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Feedback Screen'),
    );
  }
}
