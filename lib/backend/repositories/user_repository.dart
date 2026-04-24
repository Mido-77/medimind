import '../database/local_database.dart';
import '../models/user.dart';

class UserRepository {
  final LocalDatabase _db = LocalDatabase.instance;

  Future<User> getUser() async {
    final json = await _db.getUser();
    if (json == null) return User.defaultUser;
    return User.fromJson(json);
  }

  Future<void> saveUser(User user) async {
    await _db.saveUser(user.toJson());
  }

  Future<void> updateStats({int? takenDelta, int? missedDelta}) async {
    final user = await getUser();
    final updated = user.copyWith(
      totalTaken: user.totalTaken + (takenDelta ?? 0),
      totalMissed: user.totalMissed + (missedDelta ?? 0),
    );
    await saveUser(updated);
  }

  Future<bool> login(String email, String password) async {
    // Simulated authentication — in a real app, call an API
    if (email.isEmpty || password.length < 4) return false;
    await _db.setLoggedIn(true);
    final existing = await _db.getUser();
    if (existing == null) {
      await saveUser(User.defaultUser.copyWith(email: email));
    }
    return true;
  }

  Future<bool> signup(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.length < 4) return false;
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    await saveUser(user);
    await _db.setLoggedIn(true);
    return true;
  }

  Future<void> logout() async {
    await _db.setLoggedIn(false);
  }

  Future<bool> isLoggedIn() => _db.isLoggedIn();

  Future<void> changePassword(String current, String newPass) async {
    // In a real app, verify against stored hash
    if (newPass.length < 4) throw Exception('Password too short');
  }
}
