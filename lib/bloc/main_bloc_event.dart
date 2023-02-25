import 'package:flutter/material.dart';

@immutable
abstract class MainBlocEvent {
  const MainBlocEvent();
}

@immutable
class MainBlocEventInitialize implements MainBlocEvent {
  const MainBlocEventInitialize();
}

@immutable
class MainBlocEventUploadImage implements MainBlocEvent {
  final String filePathToUpload;

  const MainBlocEventUploadImage({
    required this.filePathToUpload,
  });
}

@immutable
class MainBlocEventDeleteAccount implements MainBlocEvent {
  const MainBlocEventDeleteAccount();
}

@immutable
class MainBlocEventLogOut implements MainBlocEvent {
  const MainBlocEventLogOut();
}

@immutable
class MainBlocEventLogIn implements MainBlocEvent {
  final String email;
  final String password;

  const MainBlocEventLogIn({
    required this.email,
    required this.password,
  });
}

@immutable
class MainBlocEventGoToRegistration implements MainBlocEvent {
  const MainBlocEventGoToRegistration();
}

@immutable
class MainBlocEventGoToLogin implements MainBlocEvent {
  const MainBlocEventGoToLogin();
}

@immutable
class MainBlocEventRegister implements MainBlocEvent {
  final String email;
  final String password;

  const MainBlocEventRegister({
    required this.email,
    required this.password,
  });
}
