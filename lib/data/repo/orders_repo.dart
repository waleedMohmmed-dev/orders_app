import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/user_data.dart';
import '../model/order_model.dart';

class OrdersRepo {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Either<String, String>> createOrder({required OrderModel orderModel}) async {
    try {
      await firestore.collection("orders").doc().set({
        "orderDate": orderModel.orderDate,
        "orderLat": orderModel.orderLat,
        "orderLong": orderModel.orderLong,
        "orderName": orderModel.orderName,
        "orderId": orderModel.orderId,
        "orderStatus": orderModel.orderStatus,
        "orderUserId": orderModel.orderUserId,
        "userLat": orderModel.userLat,
        "userLong": orderModel.userLong,
      });
      return Right("Order created successfully");
    } catch (e) {
      return Left("Something went wrong $e");
    }
  }

  Future<Either<String, List<OrderModel>>> getAllOrders() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection("orders")
          .where(
            "orderUserId",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .get();

      List<OrderModel> orders = [];
      for (var element in querySnapshot.docs) {
        orders.add(OrderModel.fromJson(element.data()));
      }
      return Right(orders);
    } catch (e) {
      return Left("Something went wrong $e");
    }
  }

  Future<Either<String, String>> editUserLocation(
      {required double userLat, required double userLong, required String orderId}) async {
    try {
      await firestore
          .collection("orders")
          .where("orderId", isEqualTo: orderId)
          .get()
          .then((value) {
        value.docs.first.reference.update(
          {
            "userLat": userLat,
            "userLong": userLong,
            "orderStatus": "On The Way",
          },
        );
      });
      return Right("User location updated successfully");
    } catch (e) {
      return Left("Something went wrong $e");
    }
  }

  Future<Either<String, String>> makeStatusDeliverd({required String orderId}) async {
    try {
      await firestore
          .collection("orders")
          .where("orderId", isEqualTo: orderId)
          .get()
          .then((value) {
        value.docs.first.reference.update(
          {
            "orderStatus": "Delivered",
          },
        );
      });
      return Right("User location updated successfully");
    } catch (e) {
      return Left("Something went wrong $e");
    }
  }

  Future<Either<String, OrderModel>> getOrderById({required String orderId}) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await firestore
          .collection("orders")
          .where("orderId", isEqualTo: orderId)
          .get()
          .then((value) => value.docs.first);
      return Right(OrderModel.fromJson(querySnapshot.data()!));
    } catch (e) {
      return Left("Something went wrong $e");
    }
  }
}
