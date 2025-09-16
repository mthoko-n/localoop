import 'package:localoop/services/api_client.dart';
import '../model/register_request.dart';
import '../model/register_response.dart';

class RegisterService {
  final ApiClient api;

  RegisterService({required this.api});

  Future<RegisterResponse> register(RegisterRequest request) async {
    final data = await api.post(
      '/auth/register',
      body: request.toJson(),
    );

    return RegisterResponse.fromJson(data);
  }
}
