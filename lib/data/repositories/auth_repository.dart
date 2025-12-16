// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/profile.dart';

// class AuthRepository {
//   final SupabaseClient client = Supabase.instance.client;

//   // LOGIN
//   Future<String?> signIn(String email, String password) async {
//     try {
//       await client.auth.signInWithPassword(email: email, password: password);
//       return null;
//     } on AuthException catch (e) {
//       return e.message;
//     }
//   }

//   // LOGOUT
//   Future<void> signOut() async {
//     await client.auth.signOut();
//   }

//   // FETCH PROFILE
//   Future<ProfileModel?> getProfile() async {
//     final user = client.auth.currentUser;
//     if (user == null) return null;

//     final data = await client
//         .from('profiles')
//         .select()
//         .eq('id', user.id)
//         .maybeSingle();

//     if (data == null) return null;

//     return ProfileModel.fromJson(data);
//   }

//   // AUTH STREAM
//   Stream<Session?> get authState =>
//       client.auth.onAuthStateChange.map((event) => event.session);
// }
