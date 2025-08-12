import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;
  final String? adminEmail;

  AuthState({
    this.isLoggedIn = false,
    this.adminEmail,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? adminEmail,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      adminEmail: adminEmail ?? this.adminEmail,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void login(String email) {
    state = state.copyWith(
      isLoggedIn: true,
      adminEmail: email,
    );
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});