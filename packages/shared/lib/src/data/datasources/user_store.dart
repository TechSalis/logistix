import 'package:bootstrap/interfaces/store/store.dart';
import 'package:shared/shared.dart';

/// Local storage for user data
abstract class UserStore {
  /// Synchronous access to the currently cached user
  User? get user;

  /// Save user to local storage and update cache
  Future<void> saveUser(User user);

  /// Get user from local storage and populate cache
  Future<User?> getUser();

  /// Clear user from local storage and cache
  Future<void> clearUser();
}

class UserStoreImpl implements UserStore {
  UserStoreImpl(this._store);
  final ObjectStore<UserDto> _store;
  User? _cachedUser;

  @override
  User? get user => _cachedUser;

  @override
  Future<void> saveUser(User user) async {
    _cachedUser = user;
    await _store.set(UserDto.fromEntity(user));
  }

  @override
  Future<User?> getUser() async {
    final dto = await _store.get();
    return _cachedUser = dto?.toEntity();
  }

  @override
  Future<void> clearUser() async {
    _cachedUser = null;
    await _store.delete();
  }
}
