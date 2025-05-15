import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/data/datasources/auth_remote_data_source.dart';
import 'auth/data/repositories/auth_repositoriy_impl.dart';
import 'auth/domain/repository/auth_repository.dart';
import 'auth/domain/usecases/user_login.dart';
import 'auth/domain/usecases/user_sign_up.dart';
import 'auth/presentation/bloc/auth_bloc.dart';
import 'core/secrets/app_secrets.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async{
  _initAuth();
  final supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      anonKey: AppSecrets.supabaseAnnonKey);
  serviceLocator.registerLazySingleton(() => supabase.client);
}

void _initAuth(){
  serviceLocator.registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(serviceLocator()));
  serviceLocator.registerFactory<AuthRepository>(() => AuthRepositoryImpl(serviceLocator()));
  serviceLocator.registerFactory(() => UserSignUp(serviceLocator()));
  serviceLocator.registerFactory(() => UserLogin(serviceLocator()));
  serviceLocator.registerFactory(() => AuthBloc(
    userSignUp: serviceLocator(),
    userLogin: serviceLocator()
  ));
}