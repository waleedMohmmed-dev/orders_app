import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:practical_google_maps_example/data/repo/orders_repo.dart';

import '../../data/model/order_model.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._ordersRepo) : super(OrdersInitial());
  final OrdersRepo _ordersRepo;

  void createOrder({required OrderModel orderModel}) async {
    emit(AddingOrdersStatus());
    final result = await _ordersRepo.createOrder(orderModel: orderModel);
    result.fold(
      (l) => emit(OrdersError(l)),
      (r) => emit(OrdersSuccess("Order created successfully")),
    );
  }

  void getAllOrders() async {
    emit(GettingOrdersStatus());
    final result = await _ordersRepo.getAllOrders();
    result.fold(
      (l) => emit(GettingOrdersError(l)),
      (r) => emit(GettingOrdersSuccess(r)),
    );
  }

  void sendUserNewLocation(
      {required double userLat, required double userLong, required String orderId}) async {
    emit(GettingOrdersStatus());
    await _ordersRepo.editUserLocation(userLat: userLat, userLong: userLong, orderId: orderId);
  }

  void makeOrderDeliverdStatus({required String orderId}) async {
    emit(GettingOrdersStatus());
    final result = await _ordersRepo.makeStatusDeliverd(orderId: orderId);
    result.fold((l) => emit(GettingOrdersError(l)), (r) => emit(orderDeliveredStatus(r)));
  }

  void getOrderById({required String orderId}) async {
    emit(GettingOneOrdersStatus());
    final result = await _ordersRepo.getOrderById(orderId: orderId);
    result.fold(
        (l) => emit(GettingOneOrdersError(l)),
        (r) => emit(GettingOneOrdersSuccess(
              r,
            )));
  }
}
