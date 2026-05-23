class AuthService {
  static bool login({required String username, required String password}) {
    /// ADMIN
    if (username == 'brc' && password == 'brc') {
      return true;
    }

    /// INSPECTOR
    if (username == 'inspector' && password == 'inspect123') {
      return true;
    }

    return false;
  }
}
