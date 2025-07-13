import 'package:project_app1/screens/onboarding.dart';

//UTILS
import '../utils/impact.dart';

//PLUG IN
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  //Text controller to check the email and the password
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Backgroud colors
      backgroundColor: const Color.fromARGB(255, 250, 239, 221),

      // SafeArea widget to avoid system UI overlaps
      body: SafeArea(
        // To define the edges
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 50,
            bottom: 30,
          ),

          child: Column(
            // Align the logo to the top
            mainAxisAlignment: MainAxisAlignment.start,

            // Import the logo image from /immagini (by adding the folder path in pubscpec.yaml)
            children: [
              Image.asset('immagini/logo_StrongRoots.png', scale: 2),

              const SizedBox(
                height: 60,
              ), // Space between the log and the text field
              // Text box parameters for the email
              TextField(
                obscureText: false,
                controller: userController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Email',
                  hintText: 'Enter email',
                ),
              ),

              const SizedBox(height: 20),

              // Text box parameters for the password
              TextField(
                obscureText: true, // To obscure the password
                controller:
                    passwordController, // The controller manages the content of the TextField
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    // Adds an outlined border around the TextField with rounded corners
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'Password',
                  hintText: 'Enter password',
                ),
              ),

              const SizedBox(height: 20),

              //LOGIN BUTTON AND VERIFICATION
              // Align widget centers its child (the button) horizontally and vertically
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 36, 84, 44),
                    ),
                    // When the button is pressed, check if the username and password are correct
                    onPressed: () async {
                      final result = await Impact.getTokens(
                        userController.text,
                        passwordController.text,
                      );

                      //🟠    hGYSAA5QpP
                      //🟠    12345678!

                      // We need to put an async because inside this function there are asynchronous operations that take time to complete.
                      if (result == 200) {
                        // Save the user and password in SP
                        final sp = await SharedPreferences.getInstance();
                        await sp.setString('username', userController.text);
                        await sp.setString('password', passwordController.text);

                        // To navigate to the homepage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Onboarding()),
                        );
                      } else {
                        // If the credentials are incorrect, show a temporary SnackBar with an error message
                        ScaffoldMessenger.of(context)
                          // Remove any current SnackrBar before showing a new one
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              // Red background for error
                              backgroundColor: Colors.red,
                              // Makes the SnackBar float over the UI
                              behavior: SnackBarBehavior.floating,
                              // Margin around the SnackBar
                              margin: EdgeInsets.only(
                                left: 24.0,
                                right: 24.0,
                                top: 1,
                                bottom: 220,
                              ),
                              duration: Duration(
                                seconds: 2,
                              ), // Duration it stays on screen
                              content: Text(
                                "Email or Password incorrect",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                      }
                    },

                    //LOGIN BUTTON TEXT
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Color.fromARGB(255, 250, 239, 221),
                      ),
                    ),
                  ),
                ),
              ),

              //TERMS & CONDITIONS
              // Spacer() creates an empty space that takes up all available space
              const Spacer(),

              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Accessing your account implies acceptance of \nStrongRoots Terms & Conditions and\n Privacy Policy.",
                  textAlign:
                      TextAlign.center, // To align the text in the center axis
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
