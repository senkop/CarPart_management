import 'package:elshaf3y_store/auth.dart';
import 'package:elshaf3y_store/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';


class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _status = '';
  bool _isLoading = false;

  // Handle login
  void _login() async {
    setState(() {
      _isLoading = true;
    });
    final email = _emailController.text;
    final password = _passwordController.text;

    final user = await _authService.login(email, password);
    setState(() {
      _isLoading = false;
      _status = user != null ? 'Login Successful' : 'Login Failed';
    });

    if (user != null) {
      // Navigate to MainScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  // Handle registration
  void _register() async {
    setState(() {
      _isLoading = true;
    });
    final email = _emailController.text;
    final password = _passwordController.text;

    final user = await _authService.register(email, password);
    setState(() {
      _isLoading = false;
      _status = user != null ? 'Registration Successful' : 'Registration Failed';
    });

    if (user != null) {
      // Navigate to MainScreen after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  // Navigate to Register Screen
  void _goToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Icon(Icons.account_circle, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Email', _emailController, false),
              SizedBox(height: 16),
              _buildTextField('Password', _passwordController, true),
              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        _buildButton('Login', _login),
                      ],
                    ),
              SizedBox(height: 20),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color: _status.contains('Failed') ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _goToRegisterScreen,
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(
      String label, TextEditingController controller, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        prefixIcon: Icon(
          label == 'Email' ? Icons.email : Icons.lock,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Helper function to build buttons
  Widget _buildButton(String text, Function onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 12, horizontal: 32)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8))),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _status = '';
  bool _isLoading = false;

  // Handle registration
  void _register() async {
    setState(() {
      _isLoading = true;
    });
    final email = _emailController.text;
    final password = _passwordController.text;

    final user = await _authService.register(email, password);
    setState(() {
      _isLoading = false;
      _status = user != null ? 'Registration Successful' : 'Registration Failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Icon(Icons.account_circle, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Email', _emailController, false),
              SizedBox(height: 16),
              _buildTextField('Password', _passwordController, true),
              SizedBox(height: 30),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        _buildButton('Register', _register),
                      ],
                    ),
              SizedBox(height: 20),
              Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color: _status.contains('Failed') ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(
      String label, TextEditingController controller, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        prefixIcon: Icon(
          label == 'Email' ? Icons.email : Icons.lock,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Helper function to build buttons
  Widget _buildButton(String text, Function onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
        padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: 12, horizontal: 32)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8))),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
