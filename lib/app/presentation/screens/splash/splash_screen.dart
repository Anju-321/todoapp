import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/splash/splash_bloc.dart';
import '../../blocs/splash/splash_event.dart';
import '../../blocs/splash/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _animate = false;

  @override
  void initState() {
    super.initState();

    // Start animation
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _animate = true);
    });

    // Trigger splash logic
    context.read<SplashBloc>().add(SplashStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToLogin) {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is SplashNavigateToHome) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        body: Center(
          child: AnimatedScale(
            scale: _animate ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: _animate ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                'assets/images/applogo.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
