import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnings1/blocs/signup_bloc/signup_bloc.dart';
import 'package:learnings1/blocs/signup_bloc/signup_event.dart';
import 'package:learnings1/blocs/signup_bloc/signup_state.dart';
import 'package:learnings1/screens/login_blocscreen.dart';
// import '../screens/chat_screen.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar to match the design from LoginPage
      body: Stack(
        children: [
          // Custom background
          // ExactBackground(), // Ensure this widget is properly defined
          // Main content with BlocConsumer
          BlocConsumer<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignupSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Great, let's login to start using Superchat!", style: TextStyle(color: Colors.black)), backgroundColor: Colors.greenAccent),
                );
              } else if (state is SignupFailure) {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (_) => ChatScreen()),
                // );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
                // 6/1/25
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 80),
                      const Center(
                        child: Text(
                          "Superchat LLC",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Hey there!\nLet's sign you up for\nSuperchat",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildInputField(
                        label: 'Email',
                        hint: 'Please enter your Mail ID',
                        controller: emailController,
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        label: 'Password',
                        hint: 'Please enter your password',
                        controller: passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      //   child: Row(
                      //     children: [
                      //       Checkbox(
                      //         value: true,
                      //         onChanged: (value) {},
                      //         checkColor: Colors.black,
                      //         fillColor: MaterialStateProperty.all(Colors.white),
                      //       ),
                      //       const Text(
                      //         "Remember Password",
                      //         style: TextStyle(color: Colors.grey),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      // Login Button
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 60.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: state is SignupLoading
                                ? null
                                : () {
                                    // Trigger the login event
                                    BlocProvider.of<SignupBloc>(context).add(
                                      SignupSubmitted(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      ),
                                    );
                                  },
                            child: state is SignupLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    'Signup',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 20),
                      // // OR Divider
                      // const Center(
                      //   child: Text(
                      //     "───────── or continue with ──────────",
                      //     style: TextStyle(color: Colors.grey),
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      // // Social Login Buttons
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     // Google Button
                      //     Expanded(
                      //       child: ElevatedButton(
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.pink[900],
                      //           minimumSize:
                      //               Size.fromHeight(60), // Added height

                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //         ),
                      //         onPressed: () {
                      //           // Handle Google login
                      //         },
                      //         child: const Text(
                      //           'Google',
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 16),
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 10),
                      //     // Apple Button
                      //     Expanded(
                      //       child: ElevatedButton(
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.pink[900],
                      //           minimumSize:
                      //               Size.fromHeight(60), // Added height
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //         ),
                      //         onPressed: () {
                      //           // Handle Apple login
                      //         },
                      //         child: const Text(
                      //           'Apple',
                      //           style: TextStyle(
                      //               color: Colors.white, fontSize: 16),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 30),
                      // Sign Up Redirect
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                              "Already an existing user?",
                              style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(width: 5),
                              Text(
                              "Proceed to Login",
                              style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                              ),
                            ],
                            ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build input fields
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black87),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none, // Remove default border
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }
}
