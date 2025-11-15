// In lib/screens/admin_screen.dart (REPLACE THE WHOLE FILE)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_dicovery_hub/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:game_dicovery_hub/models/user_model.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  // --- NEW METHOD ---
  // This method opens the dialog to edit a user
  void _showEditUserDialog(
      BuildContext context, Map<String, dynamic> userDoc, String docId) {
    // We need a stateful dialog
    bool isPremium = userDoc['isPremium'] ?? false;
    bool isAdmin = userDoc['isAdmin'] ?? false;
    final String email = userDoc['email'] ?? 'No Email';

    showDialog(
      context: context,
      builder: (ctx) {
        // Use a StatefulWidget to manage the switch state
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit User: $email'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium Switch
                  SwitchListTile(
                    title: const Text('Premium Status'),
                    subtitle:
                        Text(isPremium ? 'Active' : 'Inactive'),
                    value: isPremium,
                    onChanged: (newValue) {
                      setDialogState(() {
                        isPremium = newValue;
                      });
                    },
                  ),
                  // Admin Switch
                  SwitchListTile(
                    title: const Text('Admin Status'),
                    subtitle: Text(isAdmin ? 'Active' : 'Inactive'),
                    value: isAdmin,
                    onChanged: (newValue) {
                      setDialogState(() {
                        isAdmin = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    // Save the changes to Firestore
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(docId)
                        .update({
                      'isPremium': isPremium,
                      'isAdmin': isAdmin,
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  // --- END OF NEW METHOD ---

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = Provider.of<UserModel?>(context); // For the welcome message

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel (Welcome ${user?.displayName ?? 'Admin'})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              // AuthWrapper will handle navigating back to login
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return Center(child: Text('Error loading users: ${snapshot.error}'));
          }

          final userDocs = snapshot.data!.docs;
          final totalUsers = userDocs.length;

          return Column(
            children: [
              // --- THE COUNTER ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  color: const Color(0xFF1E1E1E),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people,
                            size: 40, color: Colors.deepPurpleAccent),
                        const SizedBox(width: 20),
                        Text(
                          'Total Users: $totalUsers',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- THE LIST OF USERS ---
              Expanded(
                child: ListView.builder(
                  itemCount: userDocs.length,
                  itemBuilder: (context, index) {
                    final userDoc =
                        userDocs[index].data() as Map<String, dynamic>;
                    
                    // Get the document ID, which is the user's UID
                    final String docId = userDocs[index].id;

                    // Get user data, with fallbacks for safety
                    final email = userDoc['email'] ?? 'No Email';
                    final isPremium = userDoc['isPremium'] ?? false;
                    final isAdmin = userDoc['isAdmin'] ?? false;

                    // Don't show the current admin in the list
                    if (docId == user?.uid) {
                      return const SizedBox.shrink(); 
                    }

                    return ListTile(
                      leading: Icon(isAdmin
                          ? Icons.admin_panel_settings
                          : (isPremium ? Icons.star : Icons.person)),
                      title: Text(email),
                      subtitle: Text('UID: $docId'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isAdmin)
                            const Chip(
                                label: Text('Admin'),
                                backgroundColor: Colors.amber,
                                labelStyle: TextStyle(color: Colors.black))
                          else if (isPremium)
                            const Chip(
                                label: Text('Premium'),
                                backgroundColor: Colors.deepPurple),
                          
                          // --- NEW EDIT BUTTON ---
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              _showEditUserDialog(context, userDoc, docId);
                            },
                          ),
                          // --- END OF NEW BUTTON ---
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}