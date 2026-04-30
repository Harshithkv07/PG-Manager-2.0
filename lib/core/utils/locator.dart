import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/file_storage_service.dart';
import '../../data/services/excel_service.dart';
import '../../core/network/dio_client.dart';
import '../../data/interfaces/i_student_repository.dart';
import '../../data/api/api_student_repository.dart';
import '../../data/interfaces/i_room_repository.dart';
import '../../data/api/api_room_repository.dart';
import '../../data/interfaces/i_accounts_repository.dart';
import '../../data/api/api_accounts_repository.dart';
import '../../data/interfaces/i_payment_history_repository.dart';
import '../../data/api/api_payment_history_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => FileStorageService());
  locator.registerLazySingleton(() => ExcelService());
  
  // Network
  locator.registerLazySingleton<Dio>(() => createDioClient());
  
  // Data Layer Swapped to Remote API
  locator.registerLazySingleton<IStudentRepository>(() => ApiStudentRepository(locator<Dio>()));
  locator.registerLazySingleton<IRoomRepository>(() => ApiRoomRepository(locator<Dio>()));
  locator.registerLazySingleton<IAccountsRepository>(() => ApiAccountsRepository(locator<Dio>()));
  locator.registerLazySingleton<IPaymentHistoryRepository>(() => ApiPaymentHistoryRepository(locator<Dio>()));
}
