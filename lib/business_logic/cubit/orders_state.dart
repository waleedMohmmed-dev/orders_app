part of 'orders_cubit.dart';

@immutable
sealed class OrdersState {}

final class OrdersInitial extends OrdersState {}

final class AddingOrdersStatus extends OrdersState {}

final class OrdersSuccess extends OrdersState {
  final String message;
  OrdersSuccess(this.message);
}

final class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}

final class GettingOrdersStatus extends OrdersState {}

final class GettingOrdersSuccess extends OrdersState {
  final List<OrderModel> orders;
  GettingOrdersSuccess(this.orders);
}

final class GettingOrdersError extends OrdersState {
  final String message;
  GettingOrdersError(this.message);
}

final class orderDeliveredStatus extends OrdersState {
  final String message;
  orderDeliveredStatus(this.message);
}

final class GettingOneOrdersStatus extends OrdersState {}

final class GettingOneOrdersSuccess extends OrdersState {
  final OrderModel order;
  GettingOneOrdersSuccess(this.order);
}

final class GettingOneOrdersError extends OrdersState {
  final String message;
  GettingOneOrdersError(this.message);
}
