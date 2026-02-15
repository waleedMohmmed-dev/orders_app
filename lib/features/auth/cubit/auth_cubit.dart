import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/constants/user_data.dart';
import '../repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo) : super(AuthInitial());
  final AuthRepo _authRepo;
  void registerUser(
      {required String email,
      required String userName,
      required String password}) async {
    emit(AuthLoading());
    final result = await _authRepo.registerUser(
        email: email, userName: userName, password: password);
    return result.fold(
      (l) {
        emit(AuthError(l));
      },
      (r) {
        emit(AuthSuccess("User Registered successfully"));
      },
    );
  }

  void loginUser({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await _authRepo.loginUser(email: email, password: password);
    return result.fold((l) {
      emit(AuthError(l));
    }, (userModel) {
      UserData.userModel = userModel;
      emit(AuthSuccess("User Login successfully"));
    });
  }
}
