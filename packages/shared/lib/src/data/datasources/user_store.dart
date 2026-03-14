import 'package:bootstrap/interfaces/store/primitive_store.dart';
import 'package:shared/shared.dart';

/// Local storage for user data
abstract class UserStore {
  /// Save user to local storage
  Future<void> saveUser(User user);

  /// Get user from local storage
  Future<User?> getUser();

  /// Clear user from local storage
  Future<void> clearUser();
}

class UserStoreImpl implements UserStore {
  UserStoreImpl(this._store);
  final ObjectStore<UserDto> _store;

  @override
  Future<void> saveUser(User user) => _store.set(UserDto.fromEntity(user));

  @override
  Future<User?> getUser() => _store.get().then((user) => user?.toEntity());

  @override
  Future<void> clearUser() => _store.delete();
}
