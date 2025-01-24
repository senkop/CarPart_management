// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon; // For regular icons
  final Widget? prefixSvgIcon; // For SVG or custom widgets
  final Widget? suffixIcon; // For suffix icon

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.prefixSvgIcon,
    this.suffixIcon,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          onChanged: (value) {
            setState(() {
              _errorText = widget.validator?.call(value);
            });
          },
          decoration: InputDecoration(
            prefixIcon: widget.prefixSvgIcon != null
                ? Padding(
                    padding: EdgeInsets.all(8.dg), // Adjust padding for SVG
                    child: widget.prefixSvgIcon,
                  )
                : widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, color: Colors.grey)
                    : null,
            suffixIcon: widget.suffixIcon,
            hintText: widget.labelText,
            labelStyle: const TextStyle(
              color: Color.fromRGBO(138, 136, 140, 1),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12), // Increased border radius
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12), // Increased border radius
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12), // Increased border radius
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.5),
                width: 1,
              ),
            ),
            errorText: _errorText,
            errorMaxLines: 1, // Limit error message lines
          ),
        ),
        if (_errorText != null)
          SizedBox(height: 20.h), // Fixed height for error message
      ],
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon; // Custom prefix icon
  final Widget? suffixIcon; // Custom suffix icon

  const PasswordField({
    super.key,
    this.controller,
    this.labelText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  String? _errorText;
  bool _isFocused = false; // Tracks focus state
  late FocusNode _focusNode; // FocusNode for detecting focus changes

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          focusNode: _focusNode, // Attach the FocusNode
          onChanged: (value) {
            setState(() {
              _errorText = widget.validator?.call(value);
            });
          },
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding:
                        EdgeInsets.all(8.0.dg), // Adjust padding for alignment
                    child: widget.prefixIcon,
                  )
                : const Icon(Iconsax.lock, color: Colors.grey),
            hintText: _isFocused ? null : widget.labelText, // Dynamic hint text
            labelStyle: const TextStyle(
              color: Color.fromRGBO(138, 136, 140, 1),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12), // Increased border radius
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12), // Increased border radius
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12), // Increased border radius
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.5),
                width: 1,
              ),
            ),
            errorText: _errorText,
            errorMaxLines: 1, // Limit error message lines
            suffixIcon: widget.suffixIcon ??
                IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
          ),
        ),
        if (_errorText != null)
          SizedBox(height: 20.h), // Fixed height for error message
      ],
    );
  }
}
