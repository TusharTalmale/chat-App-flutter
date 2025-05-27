import 'package:chat_app/Widgets/custom_form_input.dart';
import 'package:chat_app/const.dart';
import 'package:chat_app/services/Auth_service.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt = GetIt.instance;

  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService=_getIt.get<AlertService>();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }
  
Widget _buildUI() {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical : 20.0,
      ),
      child: Column(
        children: [
          _headerText(),
           SizedBox(height: 40),
           _loginFom(),
           _createAnAccountLink(),
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
              'Hi, Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white, // This color will be replaced by gradient
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle with animated underline
          Stack(
            children: [
              const Text(
                'Hello Again, you have been missed!',
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

Widget _loginFom(){
  return Container(
    height: MediaQuery.sizeOf(context).height*0.40,
    margin: EdgeInsets.symmetric(
      vertical: MediaQuery.sizeOf(context).height*0.05,
    ),
    child: Form(
      key: _loginFormKey,
      child: Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [CustomFormInput(
        height: MediaQuery.sizeOf(context).height*0.1,
        hintText: 'Enter the Email',
        validationRegEx: EMAIL_VALIDATION_REGEX,
        onSaved: (value) {
          setState(() {
            email = value;
          });
        },
      ),
      CustomFormInput(
        height: MediaQuery.sizeOf(context).height*0.1,
        hintText: 'Enter the Password',
        validationRegEx: PASSWORD_VALIDATION_REGEX,
        obscureText: true,
         onSaved: (value) {
          setState(() {
            password = value;
          });
        },
      ),
      
      _loginButton(),

      ],
    )) ,
  );

}


Widget _loginButton(){
  return SizedBox(
    width: MediaQuery.sizeOf(context).width/2,
    child: MaterialButton(onPressed: () async{
      if(_loginFormKey.currentState?.validate()?? false){
        _loginFormKey.currentState?.save();
        bool result = await _authService.login(email!, password!);
        print(result);
        if(result){
_navigationService.pushReplacementNamed('/home');
        }
        else{
          _alertService.showTost(
            text: 'Failed to login, Please try again!',
            icon: Icons.error_outline_outlined,
          );
        }
      }
    },
    color: Theme.of(context).colorScheme.primary,
    child: const Text(
      "Login",
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    ),
  );
}
Widget _createAnAccountLink(){
  return  Expanded(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
          const Text("Dont have an account ? "),
          GestureDetector(
            onTap: (){
              _navigationService.pushNamed("/register");
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          )
  ],),);
}

}
