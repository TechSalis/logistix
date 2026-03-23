import 'package:bootstrap/definitions/app_error.dart';
import 'package:flutter/material.dart';
import 'package:logistix/startup/presentation/bloc/app_bloc.dart';
import 'package:logistix/startup/presentation/bloc/app_event.dart';
import 'package:shared/shared.dart';

/// The entry point page that handles initialization and initial routing.
///
/// This page uses [SyncPage] to show the loading state and listens to
/// the [AppBloc] for routing instructions (authenticated, unauthenticated, etc.).
class EntrySplashPage extends StatelessWidget {
  const EntrySplashPage({
    required this.logoutUseCase,
    required this.appBloc,
    super.key,
  });

  final AppBloc appBloc;
  final LogoutUseCase logoutUseCase;

  @override
  Widget build(BuildContext context) {
    return SyncPage(
      onInitialize: () async {
        appBloc.add(const AppEvent.initialize());

        // Wait for initialization (either success or error)
        final state = await appBloc.stream.firstWhere((s) => !s.isInitializing);

        // If it's an error state, throw so SyncPage can handle it
        state.whenOrNull(error: (message) => throw UserError(message: message));
      },
      onError: (context, e, retry) {
        SyncPage.showErrorDialog(
          context,
          error: e,
          onRetry: retry,
          logoutUseCase: logoutUseCase,
        );
      },
    );
  }
}
