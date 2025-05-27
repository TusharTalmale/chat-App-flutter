import 'dart:io';

import 'package:chat_app/Widgets/custom_form_input.dart';
import 'package:chat_app/const.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/Auth_service.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService ;
  late DatabaseService _databaseService ;
  late AlertService _alertService ;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  late AuthService _authService;
  bool isLoading  = false ; 


String? email , password ,name ;
  File? selectedImage;
  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      resizeToAvoidBottomInset: false,
 body: _buildUI());
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(children: [
          _headerText(),
        if(!isLoading )_registerForm(),
        if(!isLoading )_loginAccountLink(),
         if(isLoading ) const Expanded(child: Center(
          child: CircularProgressIndicator(),
          

          ),
          
         ),

        ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0.0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main title with gradient
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [Colors.blueAccent, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: const Text(
                "Let's, get going",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color:
                      Colors.white, // This color will be replaced by gradient
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle with animated underline
            Stack(
              children: [
                const Text(
                  'Register an account using the form below ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
                Positioned(
                  bottom: -4,
                  left: 0,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return SizedBox(
                        width: 200 * value,
                        child: Divider(
                          thickness: 2,
                          color: Colors.blueAccent.withOpacity(0.7),
                          height: 1,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Decorative elements
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 16,
                  height: 2,
                  color: Colors.blueAccent.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pFpSelectionField(),
            CustomFormInput(
              hintText: "Your Name ",
              height: MediaQuery.sizeOf(context).height  * 0.1 , 
              validationRegEx: NAME_VALIDATION_REGEX, 
            onSaved: (value){
                setState(() {
                  name = value;
                });
            },),
             CustomFormInput(
              hintText: "Your non registed Email ",
              height: MediaQuery.sizeOf(context).height  * 0.1 , 
              validationRegEx: EMAIL_VALIDATION_REGEX, 
            onSaved: (value){
                setState(() {
                  email = value;
                });
            },),
            CustomFormInput(
              hintText: "Your non registed Password ",
              height: MediaQuery.sizeOf(context).height  * 0.1 , 
              validationRegEx: PASSWORD_VALIDATION_REGEX, 
            onSaved: (value){
                setState(() {
                  password = value;
                });
            },),

            _registerButton(),
          ],
        ),
      ),
    );
  }
Widget _pFpSelectionField() {
  return GestureDetector(
    onTap: () async {
      File? file = await _mediaService.getImageFromGallary();
      if (file != null) {
        setState(() {
          selectedImage = file;
        });
      }
    },
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.15,
              backgroundColor: Colors.white,
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
            ),
          ),
        );
      },
    ),
  );
}

// Widget _registerButton() {
//   return Center(
//     child: SizedBox(
//       width: MediaQuery.of(context).size.width * 0.5,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           gradient: const LinearGradient(
//             colors: [Colors.blueAccent, Colors.purpleAccent],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//         ),
//         child: FilledButton(
//           onPressed: () async{
//             setState(() {
//               isLoading = true;
//             });
//            try {
//              if((_registerFormKey.currentState?.validate()?? false) && selectedImage != null ){
//                 _registerFormKey.currentState?.save();
//                 bool result = await _authService.signup(email!, password!);
//                 if(result){
//                   String? pfpURL = await _storageService.uploadUserPfp(file: selectedImage!, uid: _authService.user!.uid);
//                   if(pfpURL != null ){
//                   await _databaseService.createUserProfile(user_profile :UserProfile(
//                     uid: _authService.user!.uid,
//                     name: name,
//                     pfpURL: pfpURL
//                     ),
//                                         _alertService.showTost(text: "User Registered Successfully",icon: Icons.check),

//                    );

//                   }
//                 }
               
//              }
//            } catch (e) {
//               // Show error message to user
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Registration failed: ${e.toString()}')),
//               );
//            }
//              setState(() {
//               isLoading = false;
//             });
//           },
//           style: FilledButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//             elevation: 0,
//           ).copyWith(
//             overlayColor: MaterialStateProperty.all(
//               Colors.white.withOpacity(0.1),
//             ),
//           ),
//           child: const Text(
//             'Register',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }

Widget _registerButton() {
  return Center(
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: FilledButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            try {
              if ((_registerFormKey.currentState?.validate() ?? false) && selectedImage != null) {
                _registerFormKey.currentState?.save();
                bool result = await _authService.signup(email!, password!);
                if (result) {
                  String? pfpURL = await _storageService.uploadUserPfp(
                    file: selectedImage!,
                    uid: _authService.user!.uid,
                  );
                  if (pfpURL != null) {
                    await _databaseService.createUserProfile(
                      user_profile: UserProfile(
                        uid: _authService.user!.uid,
                        name: name!,
                        pfpURL: pfpURL,
                      ),
                    );
                    _alertService.showTost(
                      text: "User Registered Successfully",
                      icon: Icons.check,
                    );
                    _navigationService.goBack();
                    _navigationService.pushReplacementNamed('/home');
                  }
                }
              } else {
                _alertService.showTost(
                  text: "Please fill all fields and select a profile image",
                  icon: Icons.error,
                );
              }
            } catch (e) {
              _alertService.showTost(
                text: "Registration failed: ${e.toString()}",
                icon: Icons.error,
              );
            } finally {
              setState(() {
                isLoading = false;
              });
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ).copyWith(
            overlayColor: MaterialStateProperty.all(
              Colors.white.withOpacity(0.1),
            ),
          ),
          child: const Text(
            'Register',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ),
  );
}
Widget _loginAccountLink(){
  return  Expanded(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
          const Text("Already have an account ? "),
          GestureDetector(
            onTap: (){
              _navigationService.goBack();
            },
            child: const Text(
            "Login",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          )
  ],),);
}
}