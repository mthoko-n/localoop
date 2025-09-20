import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  // Use the Android Client ID from .env for Flutter app
  clientId: dotenv.env['GOOGLE_ANDROID_CLIENT_ID'], 
  scopes: ['email', 'profile'],
  // Optional: Add server client ID for backend verification
  serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
);

Future<String?> signInWithGoogle() async {
  try {
    // Debug: Print the client ID being used (first 20 chars for security)
    final clientId = dotenv.env['GOOGLE_ANDROID_CLIENT_ID'];
    print('Using Android Client ID: ${clientId?.substring(0, 20)}...');
    
    // Clear any cached sign-in state first
    await googleSignIn.signOut();
    
    print('Starting Google sign-in...');
    final account = await googleSignIn.signIn();
    
    if (account == null) {
      print('User canceled Google sign-in');
      return null; // user canceled
    }

    print('Got Google account: ${account.email}');
    final auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken == null) {
      print('Failed to get ID token from Google');
      return null;
    }

    print('Successfully got Google ID token');
    return idToken; // send this to your backend
  } catch (e) {
    print('Google sign-in error: $e');
    
    // More specific error handling
    if (e.toString().contains('PlatformException')) {
      print('PlatformException details: $e');
      if (e.toString().contains('10:')) {
        print('Error 10 = DEVELOPER_ERROR: Check OAuth client configuration');
        print('Make sure SHA-1 fingerprint and client ID match Google Console');
      }
    }
    return null;
  }
}