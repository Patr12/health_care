import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioProvider {
  //to get token
  Future<dynamic> getToken(String email, String password) async {
  try {
    var response = await Dio().post(
      'http://192.168.100.198:8000/api/login',
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final token = response.data['token']; // 🔁 FIXED KEY
      if (token != null && token.isNotEmpty) {
        print("Login successful! Token: $token");

        // ✅ Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return true;
      } else {
        print("Login failed: token is null or empty");
        return false;
      }
    } else {
      print("Login failed: ${response.statusCode} - ${response.data}");
      return false;
    }
  } catch (e) {
    print("Dio error: $e");
    return false;
  }
}


//to get user data
  Future<dynamic> getUser(String token) async {
    try {
      var user = await Dio().get('http://192.168.100.198:8000/api/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (user.statusCode == 200 && user.data != '') {
        return json.encode(user.data);
      }
    } catch (error) {
      return error;
    }
  }

  //to register new user 
  Future<dynamic> registerUser(String username, String email, String password) async {
    try {
      var user = await Dio().post('http://192.168.100.198:8000/api/register',
          data: {'name': username, 'email': email, 'password': password});

      if (user.statusCode == 201 && user.data != '') {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

  //store booking details 
  Future<dynamic> bookAppointment(String date, String day, String time, int doctor, String token) async {
    try {
      var response = await Dio().post('http://192.168.100.198:8000/api/book',
          data: {'date': date, 'day': day, 'time': time, 'doctor_id':doctor},
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //retrieve booking details 
  Future<dynamic> getAppointments(String token) async {
    try {
      var response = await Dio().get('http://192.168.100.198:8000/api/appointments',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  //store ratings details 
  Future<dynamic> storeReviews(String reviews, double ratings, int id, int doctor, String token) async {
    try {
      var response = await Dio().post('http://192.168.100.198:8000/api/reviews',
          data: {'ratings': ratings, 'reviews': reviews, 'appointment_id': id, 'doctor_id':doctor},
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
}
