import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_bloc4/bloc/app_bloc.dart';
import 'package:learning_bloc4/bloc/app_event.dart';
import 'package:learning_bloc4/bloc/app_state.dart';
import 'package:learning_bloc4/dialogs/show_auth_error.dart';
import 'package:learning_bloc4/loading/loading_screen.dart';
import 'package:learning_bloc4/views/login_view.dart';
import 'package:learning_bloc4/views/photo_gallery_view.dart';
import 'package:learning_bloc4/views/register_view.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      create: (_) => AppBloc()..add(const AppEventInitialize()),
      child: MaterialApp(
        title: 'Photo Library',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<AppBloc, AppState>(
          builder: (context, appState) {
            if (appState is AppStateLoggedOut) {
              return const LoginView();
            } else if (appState is AppStateLoggedIn) {
              return const PhotoGalleryView();
            } else if (appState is AppStateIsInRegistrationView) {
              return const RegisterView();
            } else {
              // This should never happen
              return Container();
            }
          },
          listener: (context, appState) {
            if (appState.isLoading) {
              LoadingScreen.instance()
                  .show(context: context, text: 'Loading...');
            } else {
              LoadingScreen.instance().hide();
            }

            final authError = appState.authError;
            if (authError != null) {
              showAuthError(context: context, authError: authError);
            }
          },
        ),
      ),
    );
  }
}
