import 'package:blocgallaryapp/error/firebase_auth_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

@immutable
abstract class MainBlocState {
  final bool isLoading;
  final AuthError? authError;

  const MainBlocState({
    required this.isLoading,
    this.authError,
  });
}

@immutable
class MainBlocStateLoggedIn extends MainBlocState {
  final User user;
  final Iterable<Reference> images;
  const MainBlocStateLoggedIn({
    required bool isLoading,
    required this.user,
    required this.images,
    AuthError? authError,
  }) : super(
          isLoading: isLoading,
          authError: authError,
        );

  @override
  bool operator ==(other) {
    final otherClass = other;
    if (otherClass is MainBlocStateLoggedIn) {
      return isLoading == otherClass.isLoading &&
          user.uid == otherClass.user.uid &&
          images.length == otherClass.images.length;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hash(
        user.uid,
        images,
      );

  @override
  String toString() => 'MainBlocStateLoggedIn, images.length = ${images.length}';
}

@immutable
class MainBlocStateLoggedOut extends MainBlocState {
  const MainBlocStateLoggedOut({
    required bool isLoading,
    AuthError? authError,
  }) : super(
          isLoading: isLoading,
          authError: authError,
        );

  @override
  String toString() =>
      'MainBlocStateLoggedOut, isLoading = $isLoading, authError = $authError';
}

@immutable
class MainBlocStateIsInRegistrationView extends MainBlocState {
  const MainBlocStateIsInRegistrationView({
    required bool isLoading,
    AuthError? authError,
  }) : super(
          isLoading: isLoading,
          authError: authError,
        );
}

extension GetUser on MainBlocState {
  User? get user {
    final cls = this;
    if (cls is MainBlocStateLoggedIn) {
      return cls.user;
    } else {
      return null;
    }
  }
}

extension GetImages on MainBlocState {
  Iterable<Reference>? get images {
    final cls = this;
    if (cls is MainBlocStateLoggedIn) {
      return cls.images;
    } else {
      return null;
    }
  }
}