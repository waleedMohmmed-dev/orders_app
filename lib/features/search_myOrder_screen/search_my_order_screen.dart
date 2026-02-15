import 'package:animated_snack_bar/animated_snack_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:practical_google_maps_example/core/routing/app_routes.dart';
import 'package:practical_google_maps_example/core/styling/app_assets.dart';
import 'package:practical_google_maps_example/core/styling/app_colors.dart';
import 'package:practical_google_maps_example/core/styling/app_styles.dart';
import 'package:practical_google_maps_example/core/utils/animated_snack_dialog.dart';
import 'package:practical_google_maps_example/core/widgets/custom_text_field.dart';
import 'package:practical_google_maps_example/core/widgets/primay_button_widget.dart';
import 'package:practical_google_maps_example/core/widgets/spacing_widgets.dart';
import 'package:practical_google_maps_example/features/add_order_screen/cubit/orders_cubit.dart';
import 'package:practical_google_maps_example/features/auth/cubit/auth_cubit.dart';

class SearchMyOrder extends StatefulWidget {
  const SearchMyOrder({super.key});

  @override
  State<SearchMyOrder> createState() => _SearchMyOrderState();
}

class _SearchMyOrderState extends State<SearchMyOrder> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController orderID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    orderID = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: BlocConsumer<OrdersCubit, OrdersState>(
        listener: (context, state) {
          if (state is GettingOneOrdersError) {
            showAnimatedSnackDialog(context,
                message: state.message, type: AnimatedSnackBarType.error);
          }
          if (state is GettingOneOrdersSuccess) {
            context.push(AppRoutes.userTrackOrderMapScreen, extra: state.order);
          }
        },
        builder: (context, state) {
          if (state is GettingOneOrdersStatus) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeightSpace(28),
                    SizedBox(
                      width: 335.w,
                      child: Text(
                        "Track My Order",
                        style: AppStyles.primaryHeadLinesStyle,
                      ),
                    ),
                    const HeightSpace(8),
                    SizedBox(
                      width: 335.w,
                      child: Text(
                        "it's great to see you again",
                        style: AppStyles.grey12MediumStyle,
                      ),
                    ),
                    const HeightSpace(20),
                    Center(
                      child: Image.asset(
                        AppAssets.order,
                        width: 190.w,
                        height: 190.w,
                      ),
                    ),
                    const HeightSpace(32),
                    Text("Order ID", style: AppStyles.black16w500Style),
                    const HeightSpace(8),
                    CustomTextField(
                      hintText: "Enter By Order Id",
                      controller: orderID,
                      suffixIcon: Icon(
                        Icons.remove_red_eye,
                        color: AppColors.greyColor,
                        size: 20.sp,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Your Order ID";
                        }
                        if (value.length < 5) {
                          return "Password must be at least 5 characters";
                        }
                        return null;
                      },
                    ),
                    const HeightSpace(55),
                    PrimayButtonWidget(
                      buttonText: "Search",
                      onPress: () {
                        if (formKey.currentState!.validate()) {
                          context
                              .read<OrdersCubit>()
                              .getOrderById(orderId: orderID.text);
                        }
                      },
                    ),
                    const HeightSpace(16),
                  ],
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}
