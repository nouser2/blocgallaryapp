import 'package:blocgallaryapp/bloc/main_bloc.dart';
import 'package:blocgallaryapp/bloc/main_bloc_event.dart';
import 'package:blocgallaryapp/bloc/main_bloc_state.dart';
import 'package:blocgallaryapp/screens/common/dialogs/auth_error_dialog.dart';
import 'package:blocgallaryapp/screens/common/loading/loading_screen_controller.dart';
import 'package:blocgallaryapp/screens/login_screen.dart';
import 'package:blocgallaryapp/screens/photo_gallery_screen.dart';
import 'package:blocgallaryapp/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppHome extends StatelessWidget {
  const AppHome({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainBloc>(
      create: (_) => MainBloc()
        ..add(
          const MainBlocEventInitialize(),
        ),
      child: MaterialApp(
        title: 'Photo Library',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<MainBloc, MainBlocState>(
          listener: (context, state) {
            if (state.isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: 'Loading...',
              );
            } else {
              LoadingScreen.instance().hide();
            }

            final authError = state.authError;
            if (authError != null) {
              showAuthError(
                authError: authError,
                context: context,
              );
            }
          },
          builder: (context, state) {
            if (state is MainBlocStateLoggedOut) {
              return const LoginScreen();
            } else if (state is MainBlocStateLoggedIn) {
              return const PhotoGalleryScreen();
            } else if (state is MainBlocStateIsInRegistrationView) {
              return const RegisterView();
            } else {
              // this should never hMainBlocen
              return Container();
            }
          },
        ),
      ),
    );
  }
}
