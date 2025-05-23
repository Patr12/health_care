import 'package:flutter/material.dart';
import 'package:health/models/authModel.dart';
import 'package:health/providers/dioProvider.dart';
import '../main.dart';
import '../utils/config.dart';
import 'button.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Config.primaryColor,
            ),
            validator: (val) {
              return RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val!)
                  ? null : "Please enter a valid email";
            },
            onChanged: (val) {
              setState(() {
                email = val;
              });
            },
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
                hintText: 'Password',
                labelText: 'Password',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.lock_outline),
                prefixIconColor: Config.primaryColor,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obsecurePass = !obsecurePass;
                      });
                    },
                    icon: obsecurePass
                        ? const Icon(
                            Icons.visibility_off_outlined,
                            color: Colors.black38,
                          )
                        : const Icon(
                            Icons.visibility_outlined,
                            color: Config.primaryColor,
                          )
                )
            ),
            validator: (val) {
              if (val!.length < 6) {
                return "Password must be at least 6 characters";
              } else {
                return null;
              }
            },
            onChanged: (val) {
              setState(() {
                password = val;
              });
            },
          ),
          Config.spaceSmall,
          Consumer<AuthModel>(
            builder: (context, auth, child) {
              return Button(
                width: double.infinity,
                title: 'Sign In',
                onPressed: () async {
  print("Sign in button pressed");

  if (_formKey.currentState!.validate()) {
    print("Form validated successfully");

    try {
      final loginSuccess = await DioProvider()
          .getToken(_emailController.text, _passController.text);

      print("Login success response: $loginSuccess");

      if (loginSuccess == true) {
        auth.loginSuccess();

        // ✅ Navigate to home screen
        MyApp.navigatorKey.currentState!.pushNamed('home');
      } else {
        print("Login failed: Invalid credentials or token missing.");
        // Optionally show a snackbar or dialog here
      }
    } catch (e) {
      print("Login error: $e");
    }
  }
}, disable: false,

          );
            }
      )
        ]
      )
    );

  }}