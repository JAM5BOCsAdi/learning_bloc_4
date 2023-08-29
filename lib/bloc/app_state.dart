import 'package:flutter/foundation.dart' show immutable;
import 'package:learning_bloc4/auth/auth_error.dart';

@immutable
abstract class AppState {
  final bool isLoading;
  final AuthError? authError;

  const AppState({
    required this.isLoading,
    required this.authError,
  });
}

@immutable
class AppStateLoggedIn extends AppState {
  const AppStateLoggedIn({
    required bool isLoading,
    required AuthError? authError,
  }) : super(
          isLoading: isLoading,
          authError: authError,
        );
}
