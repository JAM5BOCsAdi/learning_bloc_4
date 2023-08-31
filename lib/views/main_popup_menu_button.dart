import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_bloc4/bloc/app_bloc.dart';
import 'package:learning_bloc4/bloc/app_event.dart';
import 'package:learning_bloc4/dialogs/delete_account_dialog.dart';
import 'package:learning_bloc4/dialogs/logout_dialog.dart';

enum MenuAction { logout, deleteAccount }

class MainPopupMenuButton extends StatelessWidget {
  const MainPopupMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuAction>(
      onSelected: (value) async {
        switch (value) {
          case MenuAction.logout:
            final shouldLogOut = await showLogOutDialog(context);
            if (shouldLogOut) {
              if (context.mounted) {
                context.read<AppBloc>().add(const AppEventLogOut());
              }
            }
            break;
          case MenuAction.deleteAccount:
            // ignore: use_build_context_synchronously
            final shouldDeleteAccount = await showDeleteAccountDialog(context);
            if (shouldDeleteAccount) {
              if (context.mounted) {
                context.read<AppBloc>().add(const AppEventDeleteAccount());
              }
            }
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<MenuAction>(
            value: MenuAction.logout,
            child: Text('Log out'),
          ),
          const PopupMenuItem<MenuAction>(
            value: MenuAction.deleteAccount,
            child: Text('Delete account'),
          ),
        ];
      },
    );
  }
}
