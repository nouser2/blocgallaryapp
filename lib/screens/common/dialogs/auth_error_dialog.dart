import 'package:blocgallaryapp/error/firebase_auth_error.dart';
import 'package:blocgallaryapp/screens/common/dialogs/gereric_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showAuthError({
  required AuthError authError,
  required BuildContext context,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionsBuilder: () => {
      'OK': true,
    },
  );
}
