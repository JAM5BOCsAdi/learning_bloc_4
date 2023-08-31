import 'package:flutter/widgets.dart' show BuildContext;
import 'package:learning_bloc4/auth/auth_error.dart';
import 'package:learning_bloc4/dialogs/generic_dialog.dart';

Future<void> showAuthError({
  required BuildContext context,
  required AuthError authError,
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
