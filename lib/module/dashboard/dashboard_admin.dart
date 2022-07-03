import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trendy_bike_mobile/common_utils/common_strings.dart';
import 'package:trendy_bike_mobile/common_utils/utils.dart';
import 'package:trendy_bike_mobile/module/products/view/products_add_edit_form.dart';
import 'package:trendy_bike_mobile/theme/color/custom_color.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:sized_context/sized_context.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common_utils/custom_cupertino_alert_dialog.dart';
import '../../common_utils/custom_sized_box.dart';
import '../../common_utils/custom_text_field.dart';
import '../../common_utils/responsive.dart';
import '../../common_utils/shared_preference_master.dart';
import '../../common_utils/system_utils.dart';
import '../../routes/route_constants.dart';
import '../../services/floor/cart_dao.dart';
import '../../theme/style/custom_style.dart';
import '../products/bloc/product_image_update_cubit.dart';
import '../products/bloc/products_cubit.dart';
import '../products/model/products_model.dart';
import 'bloc/product_search_cubit.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardAdmin> {
  FocusNode? searchFocus = FocusNode();
  final _searchKey = GlobalKey<FormBuilderState>();
  final optionsList = ['Update', 'Delete'];
  late String? userType = CommonStrings.userTypeAdmin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserType();
    context.read<ProductsCubit>().getAllProducts();
  }

  _getUserType() async {
    userType = await RepositoryProvider.of<FlutterSecureStorage>(context).read(key: 'userType');
  }

  @override
  Widget build(BuildContext context) {
    SystemUtils().showSystemUiOverlay();
    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, productsState) {
        if (productsState is ProductsSuccess) {
          if (productsState.isAdd) {
            BotToast.showText(text: 'Product Add Success!');
            Navigator.pop(productsState.context!);
          } else if (productsState.isUpdate) {
            BotToast.showText(text: 'Product Update Success!');
            Navigator.pop(productsState.context!);
          } else if (productsState.isDelete) {
            BotToast.showText(text: 'Product Delete Success!');
          }

          ///Clear the image bloc
          if (productsState.isAdd || productsState.isUpdate) {
            context.read<ProductImageUpdateCubit>().emit(null);
          }
        } else if (productsState is ProductsError) {
          BotToast.showText(text: productsState.errorMessage!);
        }
      },
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ProductsAddEditForm();
                  },
                ),
              );
            },
            elevation: 5,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            title: const Text('Dashboard Admin'),
            centerTitle: true,
            actions: [
              InkWell(
                child: Padding(
                  child: const Icon(Icons.power_settings_new_outlined),
                  padding: EdgeInsets.only(right: 10.w),
                ),
                onTap: () async {
                  String? token = await RepositoryProvider.of<FlutterSecureStorage>(context).read(key: 'accessToken');
                  if (token != null && token.isNotEmpty) {
                    await showDialog(
                      context: context,
                      builder: (dContext) {
                        return CustomCupertinoAlertDialog(
                          title: 'Alert!',
                          content: 'Are you sure you want to logout?',
                          positiveText: 'Proceed',
                          negativeText: 'Cancel',
                          onPositiveActionClick: () async {
                            await RepositoryProvider.of<FlutterSecureStorage>(context).deleteAll();
                            await RepositoryProvider.of<StreamingSharedPreferences>(context).clear();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              RouteConstants.routeLogin,
                              (route) {
                                return false;
                              },
                            );
                          },
                        );
                      },
                    );
                  }
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteConstants.routeLogin,
                    (route) {
                      return false;
                    },
                  );
                },
              )
            ],
          ),
          body: Container(
            padding: const EdgeInsets.all(20.0),
            width: context.widthPx,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: PreferenceBuilder<String>(
                      preference: RepositoryProvider.of<SharedPreferenceMaster>(context).userProfile,
                      builder: (context, userProfile) {
                        if (userProfile.isNotEmpty) {
                          final profileDetails = jsonDecode(userProfile) as Map<String, dynamic>;
                          return Text(
                            (profileDetails['name'] != null && profileDetails['name'].toString().isNotEmpty) ? 'Hi ${profileDetails['name']}!' : 'Hi Guest!',
                            style: CustomStyle.blackTextSemiBold.copyWith(fontSize: 18.sp),
                          );
                        }
                        return Text(
                          'Hi Guest!',
                          style: CustomStyle.blackTextSemiBold.copyWith(fontSize: 18.sp),
                        );
                      },
                    ),
                  ),
                  sboxH20,
                  _buildSearchBar(),
                  sboxH20,
                  BlocBuilder<ProductsCubit, ProductsState>(
                    builder: (context, productsState) {
                      if (productsState is ProductsSuccess) {
                        if (productsState.productsList != null) {
                          if (productsState.productsList!.isNotEmpty) {
                            return BlocBuilder<ProductSearchCubit, String>(
                              builder: (context, productSearch) {
                                List<ProductsModel>? filteredProductList = [];
                                if (productSearch.isNotEmpty) {
                                  for (var productData in productsState.productsList!) {
                                    if (productData.name!.toLowerCase().contains(productSearch) || productData.name!.contains(productSearch)) {
                                      filteredProductList.add(productData);
                                    }
                                  }
                                } else {
                                  filteredProductList.addAll(productsState.productsList!);
                                }
                                filteredProductList.sort((a, b) => a.name!.compareTo(b.name!));
                                return GridView.count(
                                  primary: false,
                                  padding: const EdgeInsets.all(1.5),
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.80,
                                  mainAxisSpacing: 1.0,
                                  crossAxisSpacing: 1.0,
                                  children: [
                                    ...List.generate(
                                      filteredProductList.length,
                                      (index) => _buildProductsCard(productsModel: filteredProductList[index]),
                                    )
                                  ],
                                  //new Cards()
                                  shrinkWrap: true,
                                );
                              },
                            );
                          } else {
                            return SizedBox(
                              height: context.heightPx / 2,
                              child: Center(
                                child: Utils().commonErrorWidget(
                                  'No Products Found',
                                  () => context.read<ProductsCubit>().getAllProducts(),
                                ),
                              ),
                            );
                          }
                        } else {
                          return SizedBox(
                            height: context.heightPx / 2,
                            child: Center(
                              child: Utils().commonErrorWidget(
                                'No Products Found',
                                () => context.read<ProductsCubit>().getAllProducts(),
                              ),
                            ),
                          );
                        }
                      } else if (productsState is ProductsError) {
                        return SizedBox(
                          height: context.heightPx / 2,
                          child: Center(
                            child: Utils().commonErrorWidget(
                              'No Products Found',
                              () => context.read<ProductsCubit>().getAllProducts(),
                            ),
                          ),
                        );
                      }
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: GridView.count(
                          primary: false,
                          padding: const EdgeInsets.all(1.5),
                          crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
                          childAspectRatio: 0.80,
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          children: [
                            ...List.generate(
                              10,
                              (index) => _buildDummyProductCard(),
                            )
                          ],
                          //new Cards()
                          shrinkWrap: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///Top Search Bar
  Widget _buildSearchBar() {
    return BlocBuilder<ProductSearchCubit, String>(
      builder: (context, productSearch) {
        return FormBuilder(
          key: _searchKey,
          child: CustomTextField(
            prefixIcon: const Icon(Icons.search),
            attribute: 'productSearch',
            focusNode: searchFocus,
            suffixIcon: productSearch.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchKey.currentState!.reset();
                      BlocProvider.of<ProductSearchCubit>(context).emit('');
                    },
                    child: const Icon(Icons.clear),
                  )
                : const SizedBox(),
            hint: 'Search Product',
            onChange: (val) {
              if (val != null) {
                if (val.toString().isEmpty) {
                  searchFocus!.unfocus();
                }
                BlocProvider.of<ProductSearchCubit>(context).emit(val);
              }
            },
          ),
        );
      },
    );
  }

  ///Products Card
  _buildProductsCard({required ProductsModel productsModel}) {
    return InkWell(
      onTap: () async {
        String? userType = await RepositoryProvider.of<FlutterSecureStorage>(context).read(key: 'userType');
        final cartData = await RepositoryProvider.of<CartDao>(context).findCartItemById(productsModel.id!);
        Navigator.of(context).pushNamed(RouteConstants.routeProductDetails, arguments: [productsModel, cartData, userType]);
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              child: CachedNetworkImage(
                imageUrl: productsModel.image != null ? productsModel.image! : '',
                memCacheWidth: MediaQuery.of(context).size.width ~/ 2.2,
                memCacheHeight: 130,
                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                    child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                )),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              height: 130.h,
              width: MediaQuery.of(context).size.width / 2.2,
            ),
            SizedBox(
              height: 8.h,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 8.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Wrap(
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Text(
                          '${productsModel.name}',
                          style: CustomStyle.blackTextRegular.copyWith(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Align(
                          child: Padding(
                            padding: EdgeInsets.only(right: 5.w),
                            child: PopupMenuButton(
                              initialValue: 2,
                              child: const Icon(
                                Icons.more_vert_sharp,
                                color: CustomColor.colorPrimary,
                              ),
                              itemBuilder: (ctx) {
                                return List.generate(
                                  optionsList.length,
                                  (index) {
                                    return PopupMenuItem(
                                      value: index,
                                      child: Text(optionsList[index]),
                                    );
                                  },
                                );
                              },
                              onSelected: (int index) {
                                if (index == 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ProductsAddEditForm(
                                          productsModel: productsModel,
                                        );
                                      },
                                    ),
                                  );
                                } else if (index == 1) {
                                  showDialog(
                                    context: context,
                                    builder: (dContext) {
                                      return CustomCupertinoAlertDialog(
                                        title: 'Alert!',
                                        content: 'Are you sure you want to delete?',
                                        positiveText: 'Yes',
                                        negativeText: 'Cancel',
                                        onPositiveActionClick: () async {
                                          Navigator.pop(dContext);
                                          context.read<ProductsCubit>().deleteProduct(productId: productsModel.id!, context: dContext);
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  BotToast.showText(text: CommonStrings.oopsSomethingWentWrong);
                                }
                              },
                            ),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "\$${productsModel.price! > 100 ? productsModel.price! - Utils().randomNumberPrice() : productsModel.price! - 50}",
                        style: CustomStyle.blackTextRegular.copyWith(fontSize: 16.sp),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Text(
                        "\$${productsModel.price}",
                        style: CustomStyle.blackTextRegular.copyWith(fontSize: 14.sp, color: Colors.grey, decoration: TextDecoration.lineThrough),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Text(
                        "${Utils().randomNumberPercentage()}% off",
                        style: CustomStyle.blackTextRegular.copyWith(fontSize: 13.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDummyProductCard() {
    return Container(
      color: Colors.white,
      child: const Card(
        elevation: 5.0,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(''),
        ),
      ),
    );
  }
}
