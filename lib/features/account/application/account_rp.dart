import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/features/account/domain/repository/account_repository.dart';
import 'package:logistix/features/account/infrastructure/repository/account_repository_impl.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';

final accountRepoProvider = Provider.autoDispose<AccountRepository>(
  (ref) => AccountRepositoryImpl(client: DioClient.instance),
);

final class AccountState {
  const AccountState({required this.data});
  final UserData data;
}

class AccountNotifier extends AutoDisposeNotifier<AccountState> {
  @override
  AccountState build() {
    assert(AuthLocalStore.instance.getUser() != null, 'User must be logged in');
    return AccountState(data: AuthLocalStore.instance.getUser()!.data);
  }

  Future<String?> _getToken() {
    //TODO: Remove this
    // if (kDebugMode && Platform.isIOS) return Future.value(uuid.v1());
    return FirebaseMessaging.instance.getToken();
  }

  Future uploadFCM() async {
    final token = await _getToken();
    await ref.watch(accountRepoProvider).updateFCM(token!);
  }

  Future clearFCM() async {
    final token = await _getToken();
    await ref.watch(accountRepoProvider).removeFCM(token!);
    await FirebaseMessaging.instance.deleteToken();
  }
}

final accountProvider = NotifierProvider.autoDispose(AccountNotifier.new);
