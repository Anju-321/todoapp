import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/presentation/widgets/app_button.dart';
import 'package:todo_app/app/presentation/widgets/app_textfield.dart';
import 'package:todo_app/core/constants/colors.dart';
import 'package:todo_app/core/extensions/margin_extension.dart';
import 'package:todo_app/core/utils/screen_utils.dart';


import '../../blocs/auth/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool rememberMe = true;

   @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: primaryClr,
    body: BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        }

        if (state is AuthError) {
          showToast(context, state.message);
         
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _usernameController,
                hint: "Username",
                bgColor: whiteClr,
                isLightbackground: true,
                prefixIcon: const Icon(Icons.person),
              ),
              12.hBox,
              AppTextField(
                controller: _passwordController,
                hint: "Password",
                bgColor: whiteClr,
                isLightbackground: true,
                prefixIcon: const Icon(Icons.lock),
                obscureText: true,
              ),
              20.hBox,

              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const CircularProgressIndicator(color: whiteClr);
                  }

                  return AppButton(
                    text: "Login",
                    btnClr: greenClr,

                    onPressed: () {
                      context.read<AuthBloc>().add(
                        AuthLoginRequested(
                          username: _usernameController.text.trim(),
                          password: _passwordController.text.trim(),
                          rememberMe: rememberMe,
                        ),
                      );
                    },
                  );
                },
              ),

              20.hBox,

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    
                    child: Text("New User? Sign Up", style: TextStyle(color: whiteClr))),
                  const Spacer(),
                  Text("Remember Me", style: TextStyle(color: whiteClr)),
                  Checkbox(
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() => rememberMe = value ?? true);
                    },
                    fillColor: MaterialStateProperty.all(whiteClr),
                    checkColor: primaryClr,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}