import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:practical_google_maps_example/core/routing/app_routes.dart';
import 'package:practical_google_maps_example/core/widgets/primay_button_widget.dart';
import 'package:practical_google_maps_example/features/add_order_screen/cubit/orders_cubit.dart';
import 'package:practical_google_maps_example/features/add_order_screen/model/order_model.dart';

import '../../core/styling/app_colors.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            "My Orders ",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: Container(),
          centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(8.sp),
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is GettingOrdersStatus) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is GettingOrdersError) {
              return Center(
                child: Text(state.message),
              );
            }
            if (state is GettingOrdersSuccess) {
              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () async {
                  context.read<OrdersCubit>().getAllOrders();
                },
                child: ListView.builder(
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) {
                      OrderModel orderModel = state.orders[index];
                      return Padding(
                        padding: EdgeInsets.all(8.sp),
                        child: Card(
                            child: Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order Id: #" + orderModel.orderId!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23.sp,
                                ),
                              ),
                              Text(
                                "Order Name: " + orderModel.orderName!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Text("Order Date: " + orderModel.orderDate!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: Colors.green,
                                  )),
                              Text("Order Status: " + orderModel.orderStatus!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: Colors.grey,
                                  )),
                              SizedBox(
                                height: 10.sp,
                              ),
                              PrimayButtonWidget(
                                  buttonText: "Track Order",
                                  onPress: () {
                                    context.pushNamed(
                                        AppRoutes.orderTrackMapScreen,
                                        extra: orderModel);
                                  })
                            ],
                          ),
                        )),
                      );
                    }),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
