import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:practical_google_maps_example/core/routing/app_routes.dart';
import 'package:practical_google_maps_example/core/routing/router_generation_config.dart';
import 'package:practical_google_maps_example/features/add_order_screen/cubit/orders_cubit.dart';
import 'package:practical_google_maps_example/features/add_order_screen/model/order_model.dart';

import '../../../core/styling/app_assets.dart';
import '../../../core/styling/app_colors.dart';
import '../../../core/styling/app_styles.dart';
import '../../../core/utils/animated_snack_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primay_button_widget.dart';
import '../../../core/widgets/spacing_widgets.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController orderNameController = TextEditingController();
  final TextEditingController orderArrivalDateController =
      TextEditingController();

  LatLng? orderLocation;
  LatLng? userLocation;
  DateTime? orderArrivalDate;
  String? orderLocationDetails = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BlocConsumer<OrdersCubit, OrdersState>(
          listener: (context, state) {
            if (state is OrdersSuccess) {
              showAnimatedSnackDialog(context,
                  message: state.message, type: AnimatedSnackBarType.success);

              orderIdController.clear();
              orderNameController.clear();
              orderArrivalDateController.clear();
              orderLocation = null;
              orderLocationDetails = "";
            }
            if (state is OrdersError) {
              showAnimatedSnackDialog(context,
                  message: state.message, type: AnimatedSnackBarType.error);
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeightSpace(28),
                    SizedBox(
                      width: 335.w,
                      child: Text(
                        "Create Your new Order",
                        style: AppStyles.primaryHeadLinesStyle,
                      ),
                    ),
                    const HeightSpace(8),
                    SizedBox(
                      width: 335.w,
                      child: Text(
                        "Let’s create New Order.",
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
                    Text("order ID", style: AppStyles.black16w500Style),
                    const HeightSpace(8),
                    CustomTextField(
                      controller: orderIdController,
                      hintText: "Enter Your Order ID",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Your Order ID";
                        }
                        return null;
                      },
                    ),
                    const HeightSpace(10),
                    Text("order Name", style: AppStyles.black16w500Style),
                    HeightSpace(8),
                    CustomTextField(
                      controller: orderNameController,
                      hintText: "Enter Your Order Name",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Your Order Name";
                        }
                        return null;
                      },
                    ),
                    HeightSpace(10),
                    Text("Arrival Date", style: AppStyles.black16w500Style),
                    HeightSpace(8),
                    CustomTextField(
                      readOnly: true,
                      controller: orderArrivalDateController,
                      hintText: "Enter Your Order Date",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Your Order Name";
                        }
                        return null;
                      },
                      onTap: () {
                        showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          initialDate: DateTime.now(),
                        ).then((value) {
                          orderArrivalDate = value;
                          orderArrivalDateController.text =
                              value.toString().split(" ").first;
                        });
                      },
                    ),
                    const HeightSpace(15),
                    PrimayButtonWidget(
                      buttonText: "Select Order Location",
                      icon: Icon(Icons.map_outlined,
                          color: AppColors.whiteColor, size: 24.sp),
                      onPress: () async {
                        final result =
                            await context.push<Map<String, dynamic>?>(
                                AppRoutes.placePickerScreen);

                        if (result != null) {
                          orderLocation = result['latLng'] as LatLng;
                          orderLocationDetails = result['address'] as String;
                          setState(() {});
                        }
                      },
                    ),
                    const HeightSpace(11),
                    orderLocationDetails!.isNotEmpty
                        ? Text(
                            orderLocationDetails!,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : const SizedBox.shrink(),
                    const HeightSpace(25),
                    PrimayButtonWidget(
                      buttonText: "Create Order",
                      onPress: () {
                        if (formKey.currentState!.validate()) {
                          if (orderLocation == null) {
                            showAnimatedSnackDialog(context,
                                message: "Please select order location",
                                type: AnimatedSnackBarType.warning);
                            return;
                          }
                          if (orderArrivalDate == null) {
                            showAnimatedSnackDialog(context,
                                message: "Please select order arrival date",
                                type: AnimatedSnackBarType.warning);
                            return;
                          }
                          OrderModel orderModel = OrderModel(
                            orderDate: DateFormat(
                              'yyyy-MM-dd',
                            ).format(
                              orderArrivalDate!,
                            ),
                            orderLat: orderLocation!.latitude,
                            orderLong: orderLocation!.longitude,
                            orderName: orderNameController.text,
                            orderId: orderIdController.text,
                            orderStatus: "not started",
                            orderUserId: FirebaseAuth.instance.currentUser!.uid,
                            userLat: 0.0,
                            userLong: 0.0,
                          );
                          context.read<OrdersCubit>().createOrder(
                                orderModel: orderModel,
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
