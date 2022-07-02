import 'package:trendy_bike_mobile/common_utils/common_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../assets/assets.dart';
import '../../common_utils/custom_sized_box.dart';

import '../../routes/route_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/color/custom_color.dart';
import '../../theme/style/custom_style.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(context);
  }

  _checkLoginStatus(BuildContext context) async {
    String? token = await RepositoryProvider.of<FlutterSecureStorage>(context)
        .read(key: 'accessToken');
    if (token != null && token.isNotEmpty) {
      final isTokenExpired = Jwt.isExpired(token);
      if (isTokenExpired) {
        Future.delayed(
          const Duration(seconds: 10),
          () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.routeLogin,
              (route) {
                return false;
              },
            );
          },
        );
      } else {
        String? userType =
            await RepositoryProvider.of<FlutterSecureStorage>(context)
                .read(key: 'userType');
        if (userType == CommonStrings.userTypeAdmin) {
          Future.delayed(const Duration(seconds: 10), () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.routeDashboardAdmin,
              (route) {
                return false;
              },
            );
          });
        } else {
          Future.delayed(const Duration(seconds: 10), () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.routeDashboard,
              (route) {
                return false;
              },
            );
          });
        }
      }
    } else {
      Future.delayed(const Duration(seconds: 10), () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.routeLogin,
          (route) {
            return false;
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.donCuevaSplashLogo,
                  fit: BoxFit.contain,
                  width: 100.w,
                  height: 100.h,
                ),
                Text(
                  'Bike Servicing ',
                  style: CustomStyle.blackTextSemiBold.copyWith(
                    fontSize: 26.sp,
                    color: CustomColor.colorPrimary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'By',
                  style: CustomStyle.blackTextMedium.copyWith(fontSize: 14.sp),
                ),
                sboxH5,
                Text(
                  'Sujan Baniya',
                  style: CustomStyle.blackTextSemiBold.copyWith(
                      fontSize: 14.sp, color: CustomColor.colorPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
