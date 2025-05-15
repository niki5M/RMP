import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exception.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource{
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
});
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource{

  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try{
      final responce = await supabaseClient.auth.signInWithPassword(
          password: password,
          email: email,
      );
      if (responce.user == null) {
        throw ServerException('User is null');
      }
      return UserModel.fromJson(responce.user!.toJson());

    } catch (e){
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password}) async{
    try{
      final responce = await supabaseClient.auth.signUp(
        password: password,
      email: email,
      data: {'name': name});
      if (responce.user == null) {
        throw ServerException('Please confirm your email to complete registration.');
      }
      return UserModel.fromJson(responce.user!.toJson());

    } catch (e){
      throw ServerException(e.toString());
    }
  }
  
}