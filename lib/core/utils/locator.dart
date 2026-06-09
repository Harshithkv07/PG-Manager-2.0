import 'package:get_it/get_it.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/file_storage_service.dart';
import '../../data/services/excel_service.dart';
import '../../data/interfaces/i_student_repository.dart';
import '../../data/database/student_repository.dart';
import '../../data/interfaces/i_room_repository.dart';
import '../../data/database/room_repository.dart';
import '../../data/interfaces/i_accounts_repository.dart';
import '../../data/database/accounts_repository.dart';
import '../../data/interfaces/i_payment_history_repository.dart';
import '../../data/database/payment_history_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => FileStorageService());
  locator.registerLazySingleton(() => ExcelService());
  
  // Data Layer Local Implementation
  locator.registerLazySingleton<IStudentRepository>(() => StudentRepository());
  locator.registerLazySingleton<IRoomRepository>(() => RoomRepository());
  locator.registerLazySingleton<IAccountsRepository>(() => AccountsRepository());
  locator.registerLazySingleton<IPaymentHistoryRepository>(() => PaymentHistoryRepository());
}
