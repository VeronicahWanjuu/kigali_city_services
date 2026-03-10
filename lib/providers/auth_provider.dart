import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';


// I use this enum to track every possible state of the auth flow.
// main.dart reads this to decide which screen to show.
enum AuthState {
  initial,              // app just opened, checking if there's a saved session
  loading,              // sign up or sign in network call is running
  authenticated,        // logged in and email is verified
  verificationRequired, // logged in but email not yet verified
  unauthenticated,      // not logged in
  error,                // something went wrong
}


// I named this AppAuthProvider to avoid clashing with firebase_auth's own AuthProvider.
class AppAuthProvider extends ChangeNotifier {
  final AuthService _svc;
  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _error;


  AuthState get state => _state;
  UserModel? get currentUser => _user;
  String? get errorMessage => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;


  // I start listening to Firebase auth changes as soon as this provider is created
  AppAuthProvider(this._svc) {
    _svc.authStateChanges.listen(_onAuthChanged);
  }


  void _onAuthChanged(User? user) async {
    if (user == null) {
      _state = AuthState.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }
    if (!user.emailVerified) {
      _state = AuthState.verificationRequired;
      notifyListeners();
      return;
    }
    await _loadUser(user.uid);
  }


  Future<void> _loadUser(String uid) async {
    try {
      _user = await _svc.getUserDocument(uid);
      _state = AuthState.authenticated;
    } catch (_) {
      _state = AuthState.error;
      _error = 'Failed to load profile. Please restart.';
    }
    notifyListeners();
  }


  Future<void> signUp(String email, String password, String name) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    try {
      await _svc.signUp(email, password, name);
      _state = AuthState.verificationRequired;
    } catch (e) {
      _state = AuthState.error;
      _error = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }


  Future<void> signIn(String email, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    try {
      await _svc.signIn(email, password);
      // _onAuthChanged fires automatically after a successful sign in
    } catch (e) {
      _state = AuthState.error;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }


  Future<void> signOut() async {
    await _svc.signOut();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }


  // I call this every 3 seconds from the email verification screen
  // to detect when the user clicks the link in their inbox.
  Future<void> refreshAuthState() async {
    await _svc.reloadUser();
    final u = _svc.currentUser;
    if (u != null && u.emailVerified) await _loadUser(u.uid);
  }


  // I made this public so email_verification_screen can call it directly
  Future<void> sendVerificationEmail() => _svc.sendVerificationEmail();


  Future<void> updateNotificationPreference(bool val) async {
    if (_user == null) return;
    try {
      await _svc.updateNotificationPreference(_user!.uid, val);
      _user = _user!.copyWith(notificationsEnabled: val);
      notifyListeners();
    } catch (_) {
      _error = 'Failed to save preference.';
      notifyListeners();
    }
  }
}
