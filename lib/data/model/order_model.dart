class OrderModel {
  String? orderName;
  String? orderId;
  double? orderLong;
  double? orderLat;
  double? userLat;
  double? userLong;
  String? orderUserId;
  String? orderDate;
  String? orderStatus;

  OrderModel({
    this.orderDate,
    this.orderLat,
    this.orderLong,
    this.orderName,
    this.orderId,
    this.orderStatus,
    this.orderUserId,
    this.userLat,
    this.userLong,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
        orderDate: json['orderDate'],
        orderLat: json['orderLat'],
        orderLong: json['orderLong'],
        orderName: json['orderName'],
        orderId: json['orderId'],
        orderStatus: json['orderStatus'],
        orderUserId: json['orderUserId'],
        userLat: json['userLat'],
        userLong: json['userLong']);
  }

  Map<String, dynamic> toJson() {
    return {
      'orderDate': orderDate,
      'orderLat': orderLat,
      'orderLong': orderLong,
      'orderName': orderName,
      'orderId': orderId,
      'orderStatus': orderStatus,
      'orderUserId': orderUserId,
      'userLat': userLat,
      'userLong': userLong,
    };
  }
}
