// import 'package:elshaf3y_store/auth.dart';
// import 'package:elshaf3y_store/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';


// class AuthScreen extends StatefulWidget {
//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   String _status = '';
//   bool _isLoading = false;

//   // Handle login
//   void _login() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final email = _emailController.text;
//     final password = _passwordController.text;

//     final user = await _authService.login(email, password);
//     setState(() {
//       _isLoading = false;
//       _status = user != null ? 'Login Successful' : 'Login Failed';
//     });

//     if (user != null) {
//       // Navigate to MainScreen after successful login
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MainScreen()),
//       );
//     }
//   }

//   // Handle registration
//   void _register() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final email = _emailController.text;
//     final password = _passwordController.text;

//     final user = await _authService.register(email, password);
//     setState(() {
//       _isLoading = false;
//       _status = user != null ? 'Registration Successful' : 'Registration Failed';
//     });

//     if (user != null) {
//       // Navigate to MainScreen after successful registration
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MainScreen()),
//       );
//     }
//   }

//   // Navigate to Register Screen
//   void _goToRegisterScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => RegisterScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueGrey[50],
//       appBar: AppBar(
//         title: Text('Login'),
//         backgroundColor: Colors.blueAccent,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 50),
//               Icon(Icons.account_circle, size: 100, color: Colors.blueAccent),
//               SizedBox(height: 20),
//               Text(
//                 'Welcome Back',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               SizedBox(height: 20),
//               _buildTextField('Email', _emailController, false),
//               SizedBox(height: 16),
//               _buildTextField('Password', _passwordController, true),
//               SizedBox(height: 30),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : Column(
//                       children: [
//                         _buildButton('Login', _login),
//                       ],
//                     ),
//               SizedBox(height: 20),
//               Text(
//                 _status,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: _status.contains('Failed') ? Colors.red : Colors.green,
//                 ),
//               ),
//               SizedBox(height: 20),
//               GestureDetector(
//                 onTap: _goToRegisterScreen,
//                 child: Text(
//                   "Don't have an account? Register",
//                   style: TextStyle(
//                     color: Colors.blueAccent,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper function to build text fields
//   Widget _buildTextField(
//       String label, TextEditingController controller, bool obscureText) {
//     return TextField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.blueAccent),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blueAccent),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blueGrey),
//         ),
//         prefixIcon: Icon(
//           label == 'Email' ? Icons.email : Icons.lock,
//           color: Colors.blueAccent,
//         ),
//       ),
//     );
//   }

//   // Helper function to build buttons
//   Widget _buildButton(String text, Function onPressed) {
//     return ElevatedButton(
//       onPressed: () => onPressed(),
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
//         padding: MaterialStateProperty.all(
//             EdgeInsets.symmetric(vertical: 12, horizontal: 32)),
//         shape: MaterialStateProperty.all(RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8))),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }
// }

// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   String _status = '';
//   bool _isLoading = false;

//   // Handle registration
//   void _register() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final email = _emailController.text;
//     final password = _passwordController.text;

//     final user = await _authService.register(email, password);
//     setState(() {
//       _isLoading = false;
//       _status = user != null ? 'Registration Successful' : 'Registration Failed';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blueGrey[50],
//       appBar: AppBar(
//         title: Text('Register'),
//         backgroundColor: Colors.blueAccent,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 50),
//               Icon(Icons.account_circle, size: 100, color: Colors.blueAccent),
//               SizedBox(height: 20),
//               Text(
//                 'Create an Account',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               SizedBox(height: 20),
//               _buildTextField('Email', _emailController, false),
//               SizedBox(height: 16),
//               _buildTextField('Password', _passwordController, true),
//               SizedBox(height: 30),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : Column(
//                       children: [
//                         _buildButton('Register', _register),
//                       ],
//                     ),
//               SizedBox(height: 20),
//               Text(
//                 _status,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: _status.contains('Failed') ? Colors.red : Colors.green,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper function to build text fields
//   Widget _buildTextField(
//       String label, TextEditingController controller, bool obscureText) {
//     return TextField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.blueAccent),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blueAccent),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.blueGrey),
//         ),
//         prefixIcon: Icon(
//           label == 'Email' ? Icons.email : Icons.lock,
//           color: Colors.blueAccent,
//         ),
//       ),
//     );
//   }

//   // Helper function to build buttons
//   Widget _buildButton(String text, Function onPressed) {
//     return ElevatedButton(
//       onPressed: () => onPressed(),
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
//         padding: MaterialStateProperty.all(
//             EdgeInsets.symmetric(vertical: 12, horizontal: 32)),
//         shape: MaterialStateProperty.all(RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8))),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }
// }
import 'package:elshaf3y_store/auth.dart';
import 'package:elshaf3y_store/main.dart';
import 'package:elshaf3y_store/presentation/screens/fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isButtonEnabled = false;
  bool _isLoading = false;
  String _status = '';
final String? robotoFont = GoogleFonts.roboto().fontFamily;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
  }

  void _validateFields() {
    final email = emailController.text;
    final password = passwordController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    setState(() {
      isButtonEnabled =
          email.isNotEmpty && password.isNotEmpty && emailRegex.hasMatch(email);
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    final email = emailController.text;
    final password = passwordController.text;

    final user = await _authService.login(email, password);
    setState(() {
      _isLoading = false;
      _status = user != null ? 'Login Successful' : 'Login Failed';
    });

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  Future<bool> _onWillPop() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Quit
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return result ?? false; // Default to false if dialog is dismissed
  }
@override
Widget build(BuildContext context) {
  final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
  final isKeyboardOpen = bottomPadding > 0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 50.0.h,
                    horizontal: 20.0.w,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                            Visibility(
                        visible: !isKeyboardOpen,
                      child:   Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 43.w),
                            child: Wrap(
                              direction: Axis.vertical,
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/logo.png',
                                  width: 80.w,
                                  height: 80.h,
                                ),
                                SizedBox(height: 10.0.h),
                                Text(
                                  'Nice to see you',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: robotoFont,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                SizedBox(height: 8.0.h),
                                Text(
                                  'Log in to continue',
                                  style: TextStyle(
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: robotoFont,
                                    color: const Color(0xFF666666),
                              ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isKeyboardOpen)
                        Row(
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              width: 55.w,
                              height: 55.h,
                            ),
                            SizedBox(width: 15.0.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nice to see you',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: robotoFont,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                Text(
                                  'Log in to continue',
                                  style: TextStyle(
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: robotoFont,
                                    color: const Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      SizedBox(height: 20.0.h),
                           

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                color: const Color(0xFF191C1F),
                                fontSize: 14.0.sp,
                                fontFamily: robotoFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5.0.h),
                            CustomTextField(
                              controller: emailController,
                              labelText: 'Enter email address',
                              prefixSvgIcon: SvgPicture.asset(
                                'assets/sms.svg',
                                width: 22.w,
                                height: 22.h,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                color: const Color(0xFF191C1F),
                                fontSize: 14.0.sp,
                                fontFamily: robotoFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5.0.h),
                            PasswordField(
                              controller: passwordController,
                              labelText: 'Enter your password',
                              prefixIcon: SvgPicture.asset(
                                'assets/lock.svg',
                                width: 22.w,
                                height: 22.h,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                child: Column(
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isButtonEnabled ? _login : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isButtonEnabled
                                    ? const Color.fromRGBO(25, 28, 31, 1)
                                    : const Color.fromRGBO(123, 123, 123, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontFamily: robotoFont,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 8.0.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No account yet? ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF7B7B7B),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: robotoFont,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            ' Signup',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: robotoFont,
                              color: const Color(0xFF191C1F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isButtonEnabled = false;
  bool _isLoading = false;
  String _status = '';
  final String? robotoFont = GoogleFonts.roboto().fontFamily;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
  }

  void _validateFields() {
    final email = emailController.text;
    final password = passwordController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    setState(() {
      isButtonEnabled =
          email.isNotEmpty && password.isNotEmpty && emailRegex.hasMatch(email);
    });
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });
    final email = emailController.text;
    final password = passwordController.text;

    final user = await _authService.register(email, password);
    setState(() {
      _isLoading = false;
      _status = user != null ? 'Registration Successful' : 'Registration Failed';
    });

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  Future<bool> _onWillPop() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Quit
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return result ?? false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomPadding > 0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 50.0.h,
                    horizontal: 20.0.w,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Visibility(
                          visible: !isKeyboardOpen,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 43.w),
                              child: Wrap(
                                direction: Axis.vertical,
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/logo.png',
                                    width: 80.w,
                                    height: 80.h,
                                  ),
                                  SizedBox(height: 10.0.h),
                                  Text(
                                    'Welcome',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: robotoFont,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                  SizedBox(height: 8.0.h),
                                  Text(
                                    'Create an account to continue',
                                    style: TextStyle(
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: robotoFont,
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isKeyboardOpen)
                          Row(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                width: 55.w,
                                height: 55.h,
                              ),
                              SizedBox(width: 15.0.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create an account to continue',
                                    style: TextStyle(
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: robotoFont,
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                color: const Color(0xFF191C1F),
                                fontSize: 14.0.sp,
                                fontFamily: robotoFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5.0.h),
                            CustomTextField(
                              controller: emailController,
                              labelText: 'Enter email address',
                              prefixSvgIcon: SvgPicture.asset(
                                'assets/sms.svg',
                                width: 22.w,
                                height: 22.h,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                color: const Color(0xFF191C1F),
                                fontSize: 14.0.sp,
                                fontFamily: robotoFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5.0.h),
                            PasswordField(
                              controller: passwordController,
                              labelText: 'Enter your password',
                              prefixIcon: SvgPicture.asset(
                                'assets/lock.svg',
                                width: 22.w,
                                height: 22.h,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                child: Column(
                  children: [
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isButtonEnabled ? _register : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isButtonEnabled
                                    ? const Color.fromRGBO(25, 28, 31, 1)
                                    : const Color.fromRGBO(123, 123, 123, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontFamily: robotoFont,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 8.0.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF7B7B7B),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: robotoFont,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            ' Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: robotoFont,
                              color: const Color(0xFF191C1F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}