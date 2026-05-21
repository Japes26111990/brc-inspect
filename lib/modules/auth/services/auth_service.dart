class AuthService {
  static bool login({required String username, required String password}) {
    /// ADMIN
    if (username == 'admin' && password == 'brc123') {
      return true;
    }

    /// INSPECTOR
    if (username == 'inspector' && password == 'inspect123') {
      return true;
    }

    return false;
  }
}
