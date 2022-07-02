import 'package:equatable/equatable.dart';

import '../model/user_model.dart';

abstract class LoginState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class InitialLoginState extends LoginState {}

class LoadingLoginState extends LoginState {}

class SuccessLoginState extends LoginState {
  final UserModel? userModel;

  SuccessLoginState({this.userModel});

  @override
  // TODO: implement props
  List<Object?> get props => [userModel];
}

class ErrorLoginState extends LoginState {
  final String? errorMessage;

  ErrorLoginState({this.errorMessage});

  @override
  // TODO: implement props
  List<Object?> get props => [errorMessage];
}
