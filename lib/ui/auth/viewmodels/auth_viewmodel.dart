// import 'package:adminshahrayar_stores/data/models/profile.dart';
// import 'package:adminshahrayar_stores/data/repositories/auth_repository.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';


// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   return AuthRepository();
// });

// final authViewModelProvider =
//     StateNotifierProvider<AuthViewModel, AsyncValue<ProfileModel?>>((ref) {
//   return AuthViewModel(ref);
// });

// class AuthViewModel extends StateNotifier<AsyncValue<ProfileModel?>> {
//   final Ref ref;

//   AuthViewModel(this.ref) : super(const AsyncValue.data(null)) {
//     _listenAuthState();
//   }

//   void _listenAuthState() {
//     ref.read(authRepositoryProvider).authState.listen((session) async {
//       if (session == null) {
//         state = const AsyncValue.data(null);
//       } else {
//         await fetchProfile();
//       }
//     });
//   }

//   Future<void> fetchProfile() async {
//     state = const AsyncValue.loading();
//     final profile = await ref.read(authRepositoryProvider).getProfile();
//     state = AsyncValue.data(profile);
//   }

//   Future<String?> signIn(String email, String password) async {
//     final result =
//         await ref.read(authRepositoryProvider).signIn(email, password);

//     if (result == null) {
//       await fetchProfile();
//     }

//     return result;
//   }

//   Future<void> signOut() async {
//     await ref.read(authRepositoryProvider).signOut();
//     state = const AsyncValue.data(null);
//   }
// }
