import 'package:get_it/get_it.dart';
import 'package:practical_google_maps_example/business_logic/cubit/auth_cubit.dart';

import '../../business_logic/cubit/orders_cubit.dart';
import '../../data/repo/orders_repo.dart';
import '../../data/repo/auth_repo.dart';

GetIt sl = GetIt.instance;

void setUpServiceLocator() {
  sl.registerSingleton<AuthRepo>(AuthRepo());
  sl.registerLazySingleton<OrdersRepo>(() => OrdersRepo());

  sl.registerFactory(() => OrdersCubit(sl<OrdersRepo>()));
  sl.registerFactory(() => AuthCubit(sl<AuthRepo>()));
}
