import 'package:bot_toast/bot_toast.dart';
import 'package:trendy_bike_mobile/common_utils/common_strings.dart';
import 'package:trendy_bike_mobile/module/signup/bloc/signup_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../assets/assets.dart';
import '../../common_utils/custom_mobile_field_login.dart';
import '../../common_utils/custom_sized_box.dart';
import '../../common_utils/custom_text_field_login.dart';
import '../../routes/route_constants.dart';
import '../../theme/style/custom_style.dart';
import '../login/bloc/password_toggle_cubit.dart';

class Signup extends StatelessWidget {
  Signup({Key? key}) : super(key: key);

  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupCubit, SignupState>(
      listener: (context, signupState) {
        if (signupState is SignupError) {
          BotToast.showText(text: signupState.errorMessage!);
        } else if (signupState is SignupSuccess) {
          BotToast.showText(text: CommonStrings.userRegisteredAndLogged);
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.routeDashboard,
            (route) {
              return false;
            },
          );
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
                        'Sign Up',
                        style: CustomStyle.blackTextSemiBold.copyWith(fontSize: 26.sp),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: CustomTextFieldLogin(
                        attribute: 'fullName',
                        label: 'Full Name',
                        inputType: TextInputType.text,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: 'Full Name is required',
                          ),
                          FormBuilderValidators.minLength(context, 6),
                        ]),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: CustomTextFieldLogin(
                        attribute: 'email',
                        label: 'Email ID',
                        inputType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: 'Email ID is required',
                          ),
                          FormBuilderValidators.email(context),
                        ]),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: CustomMobileFieldLogin(
                        attribute: 'mobileNumber',
                        label: 'Mobile No',
                        inputType: TextInputType.phone,
                        prefix: const Text('+977'),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            context,
                            errorText: 'Mobile number is required',
                          ),
                          FormBuilderValidators.minLength(context, 10, errorText: 'Mobile number should be of 10 digits'),
                          FormBuilderValidators.maxLength(context, 10, errorText: 'Mobile number should be of 10 digits'),
                          FormBuilderValidators.numeric(context, errorText: 'Invalid Mobile number'),
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
                                context.read<PasswordToggleCubit>().emit(!showOrHide);
                              },
                              child: showOrHide ? const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
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
                        child: const Text('Sign Up'),
                        onPressed: () {
                          if (formKey.currentState != null) {
                            if (formKey.currentState!.saveAndValidate()) {
                              context.read<SignupCubit>().userSignUp(
                                    formData: formKey.currentState!.value,
                                    context: context,
                                  );
                            }
                          }
                        },
                      ),
                    ),
                    sboxH20,
                    Row(
                      children: <Widget>[
                        const Text('Already have account?'),
                        TextButton(
                          child: Text(
                            'Sign In',
                            style: CustomStyle.blackTextSemiBold.copyWith(
                              fontSize: 22.sp,
                              color: Colors.orange,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
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
