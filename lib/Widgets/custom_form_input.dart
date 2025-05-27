import 'package:flutter/material.dart';

class CustomFormInput extends StatefulWidget {
  final String? hintText;
  final double? height;
  final RegExp validationRegEx;
  final bool obscureText;
  final void Function(String?) onSaved;

  const CustomFormInput({super.key, 
  this.hintText,
   this.height,
   required this.validationRegEx,
   this.obscureText = false,
   required this.onSaved,

  });

  @override
  State<CustomFormInput> createState() => _CustomFormInputState();
}

class _CustomFormInputState extends State<CustomFormInput> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 52,
      child: TextFormField(
        onSaved: widget.onSaved,
        obscureText: widget.obscureText ,
        validator:(value){
          if(value != null && widget.validationRegEx.hasMatch(value)){
            return null;
          }
          return 'Enter a valid ${widget.hintText?.toLowerCase()}';  
       } ,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}