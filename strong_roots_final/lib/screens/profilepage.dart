import 'package:flutter/material.dart';

//SCREENS
import 'loginpage.dart';
import 'onboarding.dart';

//PROVIDER
import '../providers/profile_provider.dart';

//PLUG IN
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder:
          (context, profile, child) => Scaffold(
            backgroundColor: Color.fromARGB(255, 249, 244, 252),
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 249, 244, 252),
              title: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 80),
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Onboarding()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // To manage the profile image
                    Center(
                      child: Image.asset(
                        profile.gender == 'F'
                            ? 'immagini/avatar_F.png'
                            : profile.gender == 'M'
                            ? 'immagini/avatar_M.png'
                            : 'immagini/avatar_null.png',
                        width: 200,
                        height: 200,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Grey line between image and profile information
                    Divider(color: Colors.grey, thickness: 1),

                    const SizedBox(height: 10),

                    Center(
                      child: Text(
                        'Personal Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    _buildInfoRow('Name', profile.name),
                    const SizedBox(height: 20),

                    _buildInfoRow('Surname', profile.surname),
                    const SizedBox(height: 20),

                    _buildInfoRow('Age', profile.age),
                    const SizedBox(height: 20),

                    _buildInfoRow('Gender', profile.gender),
                    const SizedBox(height: 20),

                    if (profile.gender == 'F')
                      _buildInfoRow(
                        'Pregnant',
                        profile.isPregnant ? 'Yes' : 'No',
                      ),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 249, 244, 252),
              child: const Icon(Icons.logout, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Confirm logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('username');
                  await prefs.remove('password');
                  await prefs.remove('access');
                  await prefs.remove('refresh');

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
    );
  }

  // Helper method to build a row with label and value
  Widget _buildInfoRow(String label, String? value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 20),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value != null && value.isNotEmpty ? value : ' no information',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
