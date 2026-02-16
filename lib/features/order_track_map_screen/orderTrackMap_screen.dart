import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:practical_google_maps_example/core/routing/router_generation_config.dart';
import 'package:practical_google_maps_example/core/styling/app_assets.dart';
import 'package:practical_google_maps_example/core/styling/app_colors.dart';
import 'package:practical_google_maps_example/core/utils/animated_snack_dialog.dart';
import 'package:practical_google_maps_example/core/utils/location_services.dart';
import 'package:practical_google_maps_example/business_logic/cubit/orders_cubit.dart';

import '../../data/model/order_model.dart';

class OrderTrackMapScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackMapScreen({super.key, required this.order});

  @override
  State<OrderTrackMapScreen> createState() => _OrderTrackMapScreenState();
}

class _OrderTrackMapScreenState extends State<OrderTrackMapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  CustomInfoWindowController customInfoWindowController = CustomInfoWindowController();

  Set<Marker> markers = {};

  LatLng? currentUserLocation;

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = ".API_KEY";

  loadOrderLocationAndUserMarker(OrderModel orderModel) async {
    final Uint8List markerIcon = await LocationServices.getBytesFromAsset(AppAssets.order, 50);
    final Uint8List userMarkerIcon =
        await LocationServices.getBytesFromAsset(AppAssets.truck, 50);

    final Marker marker = Marker(
      icon: BitmapDescriptor.bytes(markerIcon),
      markerId: MarkerId(orderModel.orderId.toString()),
      position: LatLng(orderModel.orderLat ?? 30.0596113, orderModel.orderLong ?? 31.1760626),
      onTap: () {
        customInfoWindowController.addInfoWindow!(
          Padding(
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
                ],
              ),
            )),
          ),
          LatLng(orderModel.orderLat ?? 30.0596113, orderModel.orderLong ?? 31.1760626),
        );
      },
    );
    final Marker truckMarker = Marker(
      icon: BitmapDescriptor.bytes(userMarkerIcon),
      markerId: MarkerId(FirebaseAuth.instance.currentUser!.uid.toString()),
      position: LatLng(currentUserLocation?.latitude ?? 30.0596113,
          currentUserLocation?.longitude ?? 31.1760626),
      onTap: () {
        customInfoWindowController.addInfoWindow!(
          Padding(
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
                ],
              ),
            )),
          ),
          LatLng(currentUserLocation?.latitude ?? 30.0596113,
              currentUserLocation?.longitude ?? 31.1760626),
        );
      },
    );

    markers.addAll([marker, truckMarker]);

    setState(() {});
  }

  getCurrentPositionAndAnimateToIT() async {
    try {
      Position position = await LocationServices.determinePosition();
      currentUserLocation = LatLng(position.latitude, position.longitude);
      _animateToPosition(LatLng(position.latitude, position.longitude));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _animateToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: position, zoom: 16)));
  }

  _getPolyline() async {
    polylines = {};
    polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPiKey,
      request: PolylineRequest(
        origin: PointLatLng(currentUserLocation!.latitude, currentUserLocation!.longitude),
        destination: PointLatLng(widget.order.orderLat!, widget.order.orderLong!),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline =
        Polyline(polylineId: id, color: AppColors.primaryColor, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  void initState() {
    getLocationThenLoadMarkers();
    listenToUserLocation();
    super.initState();
  }

  getLocationThenLoadMarkers() async {
    await getCurrentPositionAndAnimateToIT();
    _getPolyline();
    loadOrderLocationAndUserMarker(widget.order);
  }

  listenToUserLocation() {
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
      distanceFilter: 10,
    )).listen((Position? position) {
      if (position != null) {
        currentUserLocation = LatLng(position.latitude, position.longitude);
        updateTruckMarker();
        context.read<OrdersCubit>().sendUserNewLocation(
            userLat: currentUserLocation!.latitude,
            userLong: currentUserLocation!.longitude,
            orderId: widget.order.orderId.toString());

        checkDistanceBetweenToPoints(LatLng(position.latitude, position.longitude),
            LatLng(widget.order.orderLat ?? 0.0, widget.order.orderLong ?? 0.0));
      }
    });
  }

  checkDistanceBetweenToPoints(LatLng currentLocation, LatLng orderLocation) {
    double distance = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      orderLocation.latitude,
      orderLocation.longitude,
    );
    if (distance < 100) {
      context
          .read<OrdersCubit>()
          .makeOrderDeliverdStatus(orderId: widget.order.orderId.toString());
    }
  }

  updateTruckMarker() async {
    final Uint8List userMarkerIcon =
        await LocationServices.getBytesFromAsset(AppAssets.truck, 50);

    final Marker truckMarker = Marker(
      icon: BitmapDescriptor.bytes(userMarkerIcon),
      markerId: MarkerId(FirebaseAuth.instance.currentUser!.uid.toString()),
      position: LatLng(currentUserLocation?.latitude ?? 30.0596113,
          currentUserLocation?.longitude ?? 31.1760626),
      onTap: () {
        customInfoWindowController.addInfoWindow!(
          Padding(
            padding: EdgeInsets.all(8.sp),
            child: Card(
                child: Padding(
              padding: EdgeInsets.all(8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Id: # ${widget.order.orderId}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23.sp,
                    ),
                  ),
                  Text(
                    "Order Name: # ${widget.order.orderName}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text("Order Date: # ${widget.order.orderDate}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.green,
                      )),
                  Text("Order Status: # ${widget.order.orderStatus}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.grey,
                      )),
                  SizedBox(
                    height: 10.sp,
                  ),
                ],
              ),
            )),
          ),
          LatLng(currentUserLocation?.latitude ?? 30.0596113,
              currentUserLocation?.longitude ?? 31.1760626),
        );
      },
    );
    markers.remove(truckMarker);
    markers.add(truckMarker);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersCubit, OrdersState>(
      listener: (context, state) {
        if (state is orderDeliveredStatus) {
          showAnimatedSnackDialog(context,
              message: state.message, type: AnimatedSnackBarType.success);
          context.pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.terrain,
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.order.orderLat ?? 0.0, widget.order.orderLong ?? 0.0),
                zoom: 16,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                customInfoWindowController.googleMapController = controller;
              },
              onTap: (argument) {
                customInfoWindowController.hideInfoWindow!();
              },
              onCameraMove: (position) {
                customInfoWindowController.onCameraMove!();
              },
              markers: markers,
              polylines: Set<Polyline>.of(polylines.values),
            ),
            CustomInfoWindow(
              controller: customInfoWindowController,
              height: 250,
              width: 200,
              offset: 50,
            ),
          ],
        ),
      ),
    );
  }
}
