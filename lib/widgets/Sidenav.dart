import 'package:flutter/material.dart';

class SideNav extends StatelessWidget {
  final Function(String) onNavItemTap;

  SideNav({required this.onNavItemTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 100, // Adjust the height of the header
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Row(
                children: [
                  Icon(Icons.menu, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Tasks'),
            onTap: () {
              onNavItemTap('Tasks');
              Navigator.pushNamed(context, '/tasks'); // Navigate to tasks page
            },
          ),
          ListTile(
            leading: Icon(Icons.build),
            title: Text('Equipment'),
            onTap: () {
              onNavItemTap('Equipment');
              Navigator.pushNamed(
                  context, '/equipments'); // Navigate to equipments page
            },
          ),
          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('Completed Tasks'),
            onTap: () {
              onNavItemTap('Equipment');
              Navigator.pushNamed(
                  context, '/taskscompleted'); // Navigate to equipments page
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sign Out'),
            onTap: () {
              onNavItemTap('Sign Out');
              // Add logic to sign out if needed
            },
          ),
        ],
      ),
    );
  }
}
