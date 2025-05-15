import 'package:fpdart/src/either.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:testik2/core/error/exception.dart';
import 'package:testik2/core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository{
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);
  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password}) async{
    return _getUser(() async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password
    ));
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password}) async{
      return _getUser(() async => await remoteDataSource.signUpWithEmailPassword(
          name: name,
          email: email,
          password: password
      ));
    }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try{
      final user = await fn();
      return right(user);
    } on sb.AuthException catch(e){
      return left(Failure(e.message));
    } on ServerException catch (e){
      return left(Failure(e.message));
    }
  }

}