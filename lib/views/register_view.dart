import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:learning_bloc4/bloc/app_bloc.dart';
import 'package:learning_bloc4/bloc/app_event.dart';
import 'package:learning_bloc4/extensions/if_debugging.dart';

class RegisterView extends HookWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController =
        useTextEditingController(text: 'oradam86@gmail.com'.ifDebugging);
    final passwordController =
        useTextEditingController(text: 'oradam86'.ifDebugging);

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Register')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(hintText: 'Enter you email here...'),
              keyboardType: TextInputType.emailAddress,
              keyboardAppearance: Brightness.dark,
            ),
            TextField(
              controller: passwordController,
              decoration:
                  const InputDecoration(hintText: 'Enter you password here...'),
              keyboardAppearance: Brightness.dark,
              obscureText: true,
              obscuringCharacter: '⚫',
            ),
            TextButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;

                context.read<AppBloc>().add(
                      AppEventRegister(
                        email: email,
                        password: password,
                      ),
                    );
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                context.read<AppBloc>().add(const AppEventGoToLogin());
              },
              child: const Text('Already registered? Log in here!'),
            ),
          ],
        ),
      ),
    );
  }
}
