import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:trendy_bike_mobile/common_utils/app_loader_widget.dart';
import 'package:trendy_bike_mobile/module/login/bloc/login_state.dart';
import 'package:trendy_bike_mobile/services/dio/dio_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../../common_utils/api_utils.dart';
import '../../../common_utils/common_strings.dart';
import '../../../common_utils/utils.dart';
import '../model/user_model.dart';

class LoginCubit extends Cubit<LoginState> {
  final StreamingSharedPreferences? sharedPreferences;
  final FlutterSecureStorage? flutterSecureStorage;
  final DioApiService? dioApiService;

  LoginCubit({
    required this.sharedPreferences,
    required this.flutterSecureStorage,
    required this.dioApiService,
  }) : super(InitialLoginState());

  loginUser(String? username, String? password) async {
    showAppLoader();
    try {
      String? uName = '';
      if (username != null) {
        if (Utils().isEmail(username)) {
          uName = username;
        } else {
          uName = '+977$username';
        }
      }

      final response = await dioApiService!.login(username: uName, password: password!);
      if (response.statusCode! >= 400) {
        throw ApiUtils.handleHttpException(response);
      }
      final messageAndData = ApiUtils.getMessageTokensAndSingleDataFromResponse(response);
      final loginResponse = UserModel.fromJson(messageAndData.data[0]);
      await flutterSecureStorage!.write(key: 'accessToken', value: messageAndData.accessToken);
      await flutterSecureStorage!.write(key: 'userType', value: loginResponse.userType);
      await sharedPreferences!.setString(
        CommonStrings.sharedPrefUserProfile,
        jsonEncode({
          'userId': loginResponse.userId,
          'name': loginResponse.fullName,
          'mobileNumber': loginResponse.mobileNumber,
          'email': loginResponse.email,
        }),
      );
      emit(SuccessLoginState(userModel: loginResponse));
    } on DioError catch (e) {
      String errorMessage = CommonStrings.oopsSomethingWentWrong;
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data.toString().isNotEmpty) {
          errorMessage = e.response!.data['message'];
        }
      } else if (DioErrorType.receiveTimeout == e.type || DioErrorType.connectTimeout == e.type) {
        errorMessage = CommonStrings.errorConnectingServer;
      } else if (DioErrorType.other == e.type) {
        if (e.message.contains('SocketException')) {
          errorMessage = CommonStrings.errorConnectingServer;
        }
      }
      emit(ErrorLoginState(errorMessage: errorMessage));
    } catch (e) {
      emit(ErrorLoginState(errorMessage: CommonStrings.oopsSomethingWentWrong));
    }
    closeAppLoader();
  }
}
