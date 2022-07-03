part of 'signup_cubit.dart';

abstract class SignupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignupInitial extends SignupState {}

class SignupSuccess extends SignupState {
  SignupSuccess({this.userModel, this.context});

  final UserModel? userModel;
  final BuildContext? context;

  @override
  List<Object?> get props => [
        userModel,
        context,
      ];
}

class SignupError extends SignupState {
  SignupError({this.errorMessage});

  final String? errorMessage;

  @override
  // TODO: implement props
  List<Object?> get props => [errorMessage];
}
