import 'package:get_it/get_it.dart';
import 'package:practical_google_maps_example/features/auth/cubit/auth_cubit.dart';

import '../../features/add_order_screen/cubit/orders_cubit.dart';
import '../../features/add_order_screen/repo/orders_repo.dart';
import '../../features/auth/repo/auth_repo.dart';

GetIt sl = GetIt.instance;

void setUpServiceLocator() {
  sl.registerSingleton<AuthRepo>(AuthRepo());
  sl.registerLazySingleton<OrdersRepo>(() => OrdersRepo());

  sl.registerFactory(() => OrdersCubit(sl<OrdersRepo>()));
  sl.registerFactory(() => AuthCubit(sl<AuthRepo>()));
}
