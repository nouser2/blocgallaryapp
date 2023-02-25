import 'dart:io';

import 'package:blocgallaryapp/bloc/main_bloc_event.dart';
import 'package:blocgallaryapp/bloc/main_bloc_state.dart';
import 'package:blocgallaryapp/bloc/utils/uploading_image.dart';
import 'package:blocgallaryapp/error/firebase_auth_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainBloc extends Bloc<MainBlocEvent, MainBlocState> {
  MainBloc()
      : super(
          const MainBlocStateLoggedOut(
            isLoading: false,
          ),
        ) {
    on<MainBlocEventGoToRegistration>((event, emit) {
      emit(
        const MainBlocStateIsInRegistrationView(
          isLoading: false,
        ),
      );
    });

    on<MainBlocEventLogIn>(
      (event, emit) async {
        emit(
          const MainBlocStateLoggedOut(
            isLoading: true,
          ),
        );
        // log the user in
        try {
          final email = event.email;
          final password = event.password;
          final userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          // get images for user
          final user = userCredential.user!;
          final images = await _getImages(user.uid);
          emit(
            MainBlocStateLoggedIn(
              isLoading: false,
              user: user,
              images: images,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            MainBlocStateLoggedOut(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );

    on<MainBlocEventGoToLogin>(
      (event, emit) {
        emit(
          const MainBlocStateLoggedOut(
            isLoading: false,
          ),
        );
      },
    );

    on<MainBlocEventRegister>(
      (event, emit) async {
        // start loading
        emit(
          const MainBlocStateIsInRegistrationView(
            isLoading: true,
          ),
        );
        final email = event.email;
        final password = event.password;
        try {
          // create the user
          final credentials =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          emit(
            MainBlocStateLoggedIn(
              isLoading: false,
              user: credentials.user!,
              images: const [],
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            MainBlocStateIsInRegistrationView(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );

    on<MainBlocEventInitialize>(
      (event, emit) async {
        // get the current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            const MainBlocStateLoggedOut(
              isLoading: false,
            ),
          );
        } else {
          // go grab the user's uploaded images
          final images = await _getImages(user.uid);
          emit(
            MainBlocStateLoggedIn(
              isLoading: false,
              user: user,
              images: images,
            ),
          );
        }
      },
    );
    // log out event

    on<MainBlocEventLogOut>(
      (event, emit) async {
        // start loading
        emit(
          const MainBlocStateLoggedOut(
            isLoading: true,
          ),
        );
        // log the user out
        await FirebaseAuth.instance.signOut();
        // log the user out in the UI as well
        emit(
          const MainBlocStateLoggedOut(
            isLoading: false,
          ),
        );
      },
    );
    // handle account deletion

    on<MainBlocEventDeleteAccount>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        // log the user out if we don't have a current user
        if (user == null) {
          emit(
            const MainBlocStateLoggedOut(
              isLoading: false,
            ),
          );
          return;
        }
        // start loading
        emit(
          MainBlocStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        // delete the user folder
        try {
          // delete user folder
          final folderContents =
              await FirebaseStorage.instance.ref(user.uid).listAll();
          for (final item in folderContents.items) {
            await item.delete().catchError((_) {}); // maybe handle the error?
          }
          // delete the folder itself
          await FirebaseStorage.instance
              .ref(user.uid)
              .delete()
              .catchError((_) {});

          // delete the user
          await user.delete();
          // log the user out
          await FirebaseAuth.instance.signOut();
          // log the user out in the UI as well
          emit(
            const MainBlocStateLoggedOut(
              isLoading: false,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            MainBlocStateLoggedIn(
              isLoading: false,
              user: user,
              images: state.images ?? [],
              authError: AuthError.from(e),
            ),
          );
        } on FirebaseException {
          // we might not be able to delete the folder
          // log the user out
          emit(
            const MainBlocStateLoggedOut(
              isLoading: false,
            ),
          );
        }
      },
    );

    // handle uploading images

    on<MainBlocEventUploadImage>(
      (event, emit) async {
        final user = state.user;
        // log user out if we don't have an actual user in MainBloc state
        if (user == null) {
          emit(
            const MainBlocStateLoggedOut(
              isLoading: false,
            ),
          );
          return;
        }
        // start the loading process
        emit(
          MainBlocStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        // upload the file
        final file = File(event.filePathToUpload);
        await uploadImage(
          file: file,
          userId: user.uid,
        );
        // after upload is complete, grab the latest file references
        final images = await _getImages(user.uid);
        // emit the new images and turn off loading
        emit(
          MainBlocStateLoggedIn(
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
