import 'package:flutter/material.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:omidvpn/ui/home/home_screen.dart';
import 'package:omidvpn/ui/server_list/server_list_screen.dart';
import 'package:omidvpn/ui/settings/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 1; // Set initial index to Home (middle tab)

  static final List<Widget> _widgetOptions = <Widget>[
    const ServerListScreen(),
    const HomePage(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: lang.serverListTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: lang.homeTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: lang.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
