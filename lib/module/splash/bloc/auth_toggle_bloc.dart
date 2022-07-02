import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../login/model/user_model.dart';

class AuthToggleBloc extends Bloc<SignUpArgumentsModel?, UserModelWithIsSignUp> {
  final StreamingSharedPreferences? sharedPreferences;
  AuthToggleBloc({required this.sharedPreferences}) : super(UserModelWithIsSignUp(userModel: null));

  @override
  Stream<UserModelWithIsSignUp> mapEventToState(SignUpArgumentsModel? event) async* {
    if (event != null) {
      try {
        var userModel;
        yield UserModelWithIsSignUp(
          userModel: userModel,
        );
      } catch (e) {
        yield UserModelWithIsSignUp(
          userModel: null,
        );
      }
    } else {
      yield UserModelWithIsSignUp(
        userModel: null,
      );
    }
  }
}

class UserModelWithIsSignUp {
  UserModel? userModel;
  bool isSignUp;
  UserModelWithIsSignUp({this.userModel, this.isSignUp = false});
}

class SignUpArgumentsModel {
  String? mobileNumber;
  String? email;
  String? fullName;

  SignUpArgumentsModel({
    this.mobileNumber,
    this.email,
    this.fullName,
  });
}