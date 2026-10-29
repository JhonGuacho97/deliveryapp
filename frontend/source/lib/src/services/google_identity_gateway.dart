import 'package:google_sign_in/google_sign_in.dart';

class GoogleIdentity {
  const GoogleIdentity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.image,
    this.idToken,
  });
  final String id;
  final String email;
  final String fullName;
  final String image;
  final String? idToken;
}

abstract interface class GoogleIdentityGateway {
  static final GoogleIdentityGateway instance = NativeGoogleIdentityGateway();
  Future<GoogleIdentity?> signIn();
}

class NativeGoogleIdentityGateway implements GoogleIdentityGateway {
  NativeGoogleIdentityGateway({GoogleSignIn? signIn})
    : _signIn = signIn ?? GoogleSignIn.instance;
  final GoogleSignIn _signIn;
  Future<void>? _initialization;

  @override
  Future<GoogleIdentity?> signIn() async {
    const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    await (_initialization ??= _signIn.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    ));
    if (!_signIn.supportsAuthenticate()) return null;
    try {
      final account = await _signIn.authenticate();
      return GoogleIdentity(
        id: account.id,
        email: account.email,
        fullName: account.displayName ?? 'Usuario Google',
        image: account.photoUrl ?? '',
        idToken: account.authentication.idToken,
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}
