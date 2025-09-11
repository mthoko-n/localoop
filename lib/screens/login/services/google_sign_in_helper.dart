import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: dotenv.env['GOOGLE_CLIENT_ID'], // loaded from .env
  scopes: ['email', 'profile'],
);

Future<String?> signInWithGoogle() async {
  try {
    final account = await googleSignIn.signIn();
    if (account == null) return null; // user canceled

    final auth = await account.authentication;
    final idToken = auth.idToken;

    return idToken; // send this to your backend
  } catch (e) {
    print('Google sign-in error: $e');
    return null;
  }
}
