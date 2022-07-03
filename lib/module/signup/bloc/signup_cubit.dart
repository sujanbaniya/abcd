import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:trendy_bike_mobile/common_utils/app_loader_widget.dart';
import 'package:trendy_bike_mobile/services/dio/dio_api_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../../../common_utils/api_utils.dart';
import '../../../common_utils/common_strings.dart';
import '../../login/model/user_model.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({
    required this.dioApiService,
    required this.sharedPreferences,
    this.flutterSecureStorage,
  }) : super(SignupInitial());
  final DioApiService dioApiService;
  final FlutterSecureStorage? flutterSecureStorage;
  final StreamingSharedPreferences? sharedPreferences;

  userSignUp({required Map<String, dynamic>? formData, required BuildContext? context}) async {
    showAppLoader();
    UserModel? userModel;
    UserModel? userCheckEmail;
    UserModel? userCheckMobileNumber;
    try {
      try {
        final response = await dioApiService.checkUserPresenceWithEmail(email: formData!['email']);
        if (response.statusCode! >= 400) {
          throw ApiUtils.handleHttpException(response);
        }
        final messageAndData = ApiUtils.getMessageAndSingleDataFromResponse(response);
        userCheckEmail = UserModel.fromJson(messageAndData.data[0]);
      } catch (e) {}
      if (userCheckEmail != null) {
        throw 'Email already exists.';
      }
      try {
        final response = await dioApiService.checkUserPresenceWithMobileNumber(mobileNumber: '+977' + formData!['mobileNumber']);
        if (response.statusCode! >= 400) {
          throw ApiUtils.handleHttpException(response);
        }
        final messageAndData = ApiUtils.getMessageAndSingleDataFromResponse(response);
        userCheckMobileNumber = UserModel.fromJson(messageAndData.data[0]);
      } catch (e) {}
      if (userCheckMobileNumber != null) {
        throw 'Mobile number already exists.';
      }
      if (userCheckEmail == null && userCheckMobileNumber == null) {
        userModel = UserModel.fromFormMap(formData!);
        userModel.mobileNumber = '+977' + formData['mobileNumber'];
        userModel.userType = CommonStrings.userType;
        final response = await dioApiService.createUser(userModel: userModel);
        if (response.statusCode! >= 400) {
          throw ApiUtils.handleHttpException(response);
        }
        final responseHeader = response.headers['authorization']!;
        if (response.statusCode == 200) {
          final messageAndData = ApiUtils.getMessageTokensAndSingleDataFromResponse(response);
          final userResponse = UserModel.fromJson(messageAndData.data[0]);
          await flutterSecureStorage!.write(key: 'accessToken', value: responseHeader[0].split('Bearer ')[1]);
          await flutterSecureStorage!.write(key: 'userType', value: userResponse.userType);
          await sharedPreferences!.setBool(CommonStrings.sharedPrefIsLoggedIn, true);
          await sharedPreferences!.setString(
            CommonStrings.sharedPrefUserProfile,
            jsonEncode({
              'userId': userResponse.userId,
              'name': userResponse.fullName,
              'mobileNumber': userResponse.mobileNumber,
              'email': userResponse.email,
            }),
          );
          emit(SignupSuccess(context: context, userModel: userModel));
        }
      }
    } on DioError catch (e) {
      String errorMessage = CommonStrings.oopsSomethingWentWrong;
      if (e.response != null && e.response!.data != null) {
        errorMessage = e.response!.data['message'];
      } else if (DioErrorType.receiveTimeout == e.type || DioErrorType.connectTimeout == e.type) {
        errorMessage = CommonStrings.errorConnectingServer;
      } else if (DioErrorType.other == e.type) {
        if (e.message.contains('SocketException')) {
          errorMessage = CommonStrings.errorConnectingServer;
        }
      }
      emit(SignupError(errorMessage: errorMessage));
    } catch (e) {
      if (userModel != null) {
        await dioApiService.deleteUserById(uId: userModel.userId!);
      }
      emit(SignupError(errorMessage: CommonStrings.oopsSomethingWentWrong));
    }
    closeAppLoader();
  }
}
