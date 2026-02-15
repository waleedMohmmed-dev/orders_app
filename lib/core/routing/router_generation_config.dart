import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:practical_google_maps_example/core/routing/app_routes.dart';
import 'package:practical_google_maps_example/features/add_order_screen/screens/add_order_screen.dart';
import 'package:practical_google_maps_example/features/add_order_screen/cubit/orders_cubit.dart';
import 'package:practical_google_maps_example/features/add_order_screen/screens/place_picker_screen.dart';
import 'package:practical_google_maps_example/features/auth/screns/login_screen.dart';
import 'package:practical_google_maps_example/features/auth/screns/register_screen.dart';
import 'package:practical_google_maps_example/features/home/home_screen.dart';
import 'package:practical_google_maps_example/features/my_orders/my_orders_screen.dart';
import 'package:practical_google_maps_example/features/order_track_map_screen/orderTrackMap_screen.dart';
import 'package:practical_google_maps_example/features/search_myOrder_screen/search_my_order_screen.dart';
import 'package:practical_google_maps_example/features/splash_screen/splash_screen.dart';
import 'package:practical_google_maps_example/features/user_track_order_map_screen/user_track_order_map_screen.dart';

import '../../features/add_order_screen/model/order_model.dart';
import '../../features/auth/cubit/auth_cubit.dart';
import '../di/dependancy_injection.dart';

class RouterGenerationConfig {
  static GoRouter goRouter =
      GoRouter(initialLocation: AppRoutes.splashScreen, routes: [
    GoRoute(
      name: AppRoutes.splashScreen,
      path: AppRoutes.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: AppRoutes.loginScreen,
      path: AppRoutes.loginScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<AuthCubit>(),
        child: LoginScreen(),
      ),
    ),
    GoRoute(
      name: AppRoutes.registerScreen,
      path: AppRoutes.registerScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<AuthCubit>(),
        child: RegisterScreen(),
      ),
    ),
    GoRoute(
      name: AppRoutes.homeScreen,
      path: AppRoutes.homeScreen,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: AppRoutes.addOrderScreen,
      path: AppRoutes.addOrderScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<OrdersCubit>(),
        child: AddOrderScreen(),
      ),
    ),
    GoRoute(
      name: AppRoutes.placePickerScreen,
      path: AppRoutes.placePickerScreen,
      builder: (context, state) => const PlacePickerScreen(),
    ),
    GoRoute(
      name: AppRoutes.myOrdersScreen,
      path: AppRoutes.myOrdersScreen,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<OrdersCubit>()..getAllOrders(),
        child: MyOrdersScreen(),
      ),
    ),
    GoRoute(
        name: AppRoutes.orderTrackMapScreen,
        path: AppRoutes.orderTrackMapScreen,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => sl<OrdersCubit>()..getAllOrders(),
            child: OrderTrackMapScreen(order: state.extra as OrderModel),
          );
        }),
    GoRoute(
        name: AppRoutes.searchMyOrderScreen,
        path: AppRoutes.searchMyOrderScreen,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => sl<OrdersCubit>()..getAllOrders(),
            child: SearchMyOrder(),
          );
        }),
    GoRoute(
        name: AppRoutes.userTrackOrderMapScreen,
        path: AppRoutes.userTrackOrderMapScreen,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => sl<OrdersCubit>()..getAllOrders(),
            child: UserTrackOrderMapScreen(order: state.extra as OrderModel),
          );
        }),
  ]);
}
