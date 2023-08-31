import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_bloc4/auth/auth_error.dart';
import 'package:learning_bloc4/bloc/app_event.dart';
import 'package:learning_bloc4/bloc/app_state.dart';
import 'package:learning_bloc4/utils/upload_image.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppStateLoggedOut(isLoading: false)) {
    on<AppEventLogIn>(
      (event, emit) async {
        // Loading while you are not logged in.
        emit(const AppStateLoggedOut(isLoading: true));
        try {
          final email = event.email;
          final password = event.password;
          final userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          final user = userCredential.user!;
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(
              user: user,
              images: images,
              isLoading: false,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(AppStateLoggedOut(
              isLoading: false, authError: AuthError.from(e)));
        }
      },
    );

    on<AppEventGoToLogin>(
      (event, emit) {
        emit(const AppStateLoggedOut(isLoading: false));
      },
    );

    on<AppEventRegister>(
      (event, emit) async {
        // Start loading
        emit(const AppStateIsInRegistrationView(isLoading: true));

        final email = event.email;
        final password = event.password;
        try {
          // Create the user
          final credentials = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          emit(
            AppStateLoggedIn(
              user: credentials.user!,
              images: const [],
              isLoading: false,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateIsInRegistrationView(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );

    on<AppEventInitialize>(
      (event, emit) async {
        // Get the current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: false));
        } else {
          // Go grab the user's uploaded images
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(
              user: user,
              images: images,
              isLoading: false,
            ),
          );
        }
      },
    );

    // Log Out event
    on<AppEventLogOut>(
      (event, emit) async {
        // Start loading
        emit(const AppStateLoggedOut(isLoading: true));
        // Log the user out
        await FirebaseAuth.instance.signOut();
        // Log the user out in the UI as well
        emit(const AppStateLoggedOut(isLoading: false));
      },
    );

    //Handle account deletion
    on<AppEventDeleteAccount>(
      (event, emit) async {
        // 1 way to get the current user:
        final user = FirebaseAuth.instance.currentUser;
        // Log the user out, if we don't have a current user
        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: false));
          return;
        }
        // Start the loading process
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        // Delete the user folder
        try {
          // Delete user folder
          final folderContents =
              await FirebaseStorage.instance.ref(user.uid).listAll();

          for (final item in folderContents.items) {
            await item.delete().catchError((_) {});
          }
          // Delete the folder itself
          await FirebaseStorage.instance
              .ref(user.uid)
              .delete()
              .catchError((_) {});
          // Delete the user
          await user.delete();
          // Log the user out
          await FirebaseAuth.instance.signOut();
          // Log the user out in the UI as well
          emit(const AppStateLoggedOut(isLoading: false));
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              images: state.images ?? [],
              authError: AuthError.from(e),
            ),
          );
        } on FirebaseException {
          // We might not be able to delete the folder
          // Log the user out
          emit(const AppStateLoggedOut(isLoading: false));
          // Maybe handle error(s)?
        }
      },
    );

    //Handle uploading images
    on<AppEventUploadImage>(
      (event, emit) async {
        // Another way of getting the current user: [Upper is the first 1]
        final user = state.user;
        // Log user out if we don't have an actual user in app state
        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: false));
          return;
        }
        // Start the loading process
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );

        final file = File(event.filePathToUpload);
        await uploadImage(file: file, userId: user.uid);

        // After upload is complete, grab the latest file references
        final images = await _getImages(user.uid);

        // Emit the new images and turn off loading
        emit(
          AppStateLoggedIn(
            isLoading: false,
            user: user,
            images: images,
          ),
        );
      },
    );
  }

  Future<Iterable<Reference>> _getImages(String userId) =>
      FirebaseStorage.instance
          .ref(userId)
          .list()
          .then((listResult) => listResult.items);
}
