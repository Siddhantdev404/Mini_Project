// In lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:game_dicovery_hub/services/auth_service.dart';
import 'package:game_dicovery_hub/models/user_model.dart';
import 'package:game_dicovery_hub/screens/backlog_screen.dart';
import 'package:game_dicovery_hub/screens/discover_screen.dart';
import 'package:game_dicovery_hub/screens/profile_screen.dart';
import 'package:game_dicovery_hub/screens/search_screen.dart';
import 'package:game_dicovery_hub/screens/upgrade_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // The 5 tabs
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // This allows DiscoverScreen to change the tab
    _widgetOptions = <Widget>[
      DiscoverScreen(
        onUpgradePressed: () {
          _onItemTapped(2); // Go to Upgrade tab (index 2)
        },
      ),
      const SearchScreen(),
      const UpgradeScreen(),
      const BacklogScreen(),
      ProfileScreen(),
    ];
  }

  // --- CORRECTED ITEM TAPPED LOGIC ---
  void _onItemTapped(int index) {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user == null) return; // Should not happen

    // 1. GUEST UPGRADE CHECK (Index 2): ALWAYS redirects to Auth.
    if (user.isGuest && index == 2) {
      _showGuestDialog(context);
      return; // Don't switch the tab
    }

    // 2. SEARCH CHECK (Index 1): Block ALL NON-PREMIUM users. Guests must sign up.
    if (!user.isPremium && !user.isAdmin && index == 1) {
      if (user.isGuest) {
        // Guests cannot use search, must sign in/up
        _showGuestDialog(context); 
      } else {
        // Normal signed-in user, ask for premium
        _showLimitDialog(context, "Search"); 
      }
      return;
    }
    
    // 3. BACKLOG CHECK (Index 3): Allow guests/normal users to view their limited backlog.
    // We only block users if they are NOT premium/admin AND the FirestoreService throws a limit error when saving.
    // Since the actual save limit is handled by the FirestoreService, this navigation allows viewing.
    // The previous logic was correct in allowing viewing for guests/normal users.
    
    setState(() {
      _selectedIndex = index;
    });
  }
  // --- END CORRECTED ITEM TAPPED LOGIC ---

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined,
              // Guests, Premium, and Admins all see the normal color
              color: (user.isPremium || user.isAdmin) ? Colors.grey : (user.isGuest ? Colors.grey[700] : Colors.grey),
            ),
            activeIcon: Icon(Icons.search,
              color: (user.isPremium || user.isAdmin) ? null : (user.isGuest ? Colors.grey[700] : Colors.grey),
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star_rounded,
              size: 30,
              color: user.isPremium
                  ? Colors.amber
                  : (user.isGuest ? Colors.grey[700] : Colors.grey),
            ),
            label: 'Upgrade',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border,
              // Guests, Premium, and Admins all see the normal color
              color: (user.isPremium || user.isAdmin || user.isGuest) ? Colors.grey : Colors.grey[700],
            ),
            activeIcon: Icon(Icons.bookmark,
              color: (user.isPremium || user.isAdmin || user.isGuest) ? null : Colors.grey[700],
            ),
            label: 'Backlog',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // --- GUEST DIALOG METHOD ---
  void _showGuestDialog(BuildContext context) {
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Up Required'),
        content: const Text(
            'This feature requires a signed-in account. Please sign up or log in.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Sign Up / Log In'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await authService.signOut(); 
            },
          ),
        ],
      ),
    );
  }

  // --- EXISTING LIMIT DIALOG METHOD ---
  void _showLimitDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Feature Locked'),
        content: Text(
            'The $feature feature is for Premium members only. Please upgrade to unlock all features!'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Upgrade'),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _selectedIndex = 2; // Go to Upgrade tab
              });
            },
          ),
        ],
      ),
    );
  }
}