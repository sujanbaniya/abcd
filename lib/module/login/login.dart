import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:trendy_bike_mobile/common_utils/common_strings.dart';
import 'package:trendy_bike_mobile/common_utils/custom_mobile_field_login.dart';
import 'package:trendy_bike_mobile/common_utils/custom_sized_box.dart';
import 'package:trendy_bike_mobile/module/login/bloc/login_cubit.dart';
import 'package:trendy_bike_mobile/module/login/bloc/login_state.dart';
import 'package:trendy_bike_mobile/theme/style/custom_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../assets/assets.dart';
import '../../common_utils/custom_text_field_login.dart';
import '../../common_utils/system_utils.dart';
import '../../routes/route_constants.dart';
import 'bloc/password_toggle_cubit.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormBuilderState>();

  void notify() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1,
          channelKey: 'key1',
          title: 'Login Successful',
          body: ' Login Vayo',
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture:
              'https://images.idgesg.net/images/article/2019/01/android-q-notification-inbox-100785464-large.jpg?auto=webp&quality=85,70'),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemUtils().showSystemUiOverlay();
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, loginState) async {
        if (loginState is SuccessLoginState) {
          String? userType =
              await RepositoryProvider.of<FlutterSecureStorage>(context)
                  .read(key: 'userType');
          BotToast.showText(text: 'Login Success');
          if (userType == CommonStrings.userTypeAdmin) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.routeDashboardAdmin,
              (route) {
                return false;
              },
            );
            notify();
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.routeDashboard,
              (route) {
                return false;
              },
            );
            notify();
          }
        } else if (loginState is ErrorLoginState) {
          BotToast.showText(text: loginState.errorMessage!);
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: FormBuilder(
                key: formKey,
                child: ListView(
                  children: <Widget>[
                    sboxH20,
                    Image.asset(
                      Assets.donCuevaSplashLogo,
                      fit: BoxFit.contain,
                      width: 100.w,
                      height: 100.h,
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Sign In',
                        style: CustomStyle.blackTextSemiBold
                            .copyWith(fontSize: 26.sp),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: CustomMobileFieldLogin(
                        mobileNumberKey: const Key('usernameField'),
                        attribute: 'username',
                        label: 'Mobile No',
                        inputType: TextInputType.phone,
                        prefix: const Text('+977'),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: 'Mobile number is required',
                          ),
                          FormBuilderValidators.minLength(context, 10,
                              errorText:
                                  'Mobile number should be of 10 digits'),
                          FormBuilderValidators.maxLength(context, 10,
                              errorText:
                                  'Mobile number should be of 10 digits'),
                          FormBuilderValidators.numeric(context,
                              errorText: 'Invalid Mobile number'),
                        ]),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: BlocBuilder<PasswordToggleCubit, bool>(
                        builder: (context, showOrHide) {
                          return CustomTextFieldLogin(
                            attribute: 'password',
                            label: 'Password',
                            obscureText: !showOrHide,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                context
                                    .read<PasswordToggleCubit>()
                                    .emit(!showOrHide);
                              },
                              child: showOrHide
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                context,
                                errorText: 'Password is required',
                              ),
                              FormBuilderValidators.minLength(context, 6),
                            ]),
                          );
                        },
                      ),
                    ),
                    sboxH40,
                    Container(
                      height: 50.h,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: ElevatedButton(
                        child: const Text('Login'),
                        onPressed: () {
                          if (formKey.currentState != null) {
                            if (formKey.currentState!.saveAndValidate()) {
                              context.read<LoginCubit>().loginUser(
                                    formKey.currentState!.value['username'],
                                    formKey.currentState!.value['password'],
                                  );
                            }
                          }
                        },
                      ),
                    ),
                    sboxH20,
                    Row(
                      children: <Widget>[
                        const Text('Does not have account?'),
                        TextButton(
                          child: Text(
                            'Sign up',
                            style: CustomStyle.blackTextSemiBold
                                .copyWith(fontSize: 22.sp, color: Colors.orange),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RouteConstants.routeSignUp);
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
