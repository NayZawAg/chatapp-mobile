import 'package:dio/dio.dart';
import 'package:flutter_frontend/model/StarLists.dart';
import 'package:retrofit/http.dart';

part 'star_list.service.g.dart';

@RestApi(baseUrl: 'https://cmmteam3-backend-api.onrender.com/starlists')
abstract class StarListsService {
  factory StarListsService(Dio dio) => _StarListsService(dio);

  @GET('')
  Future<StarLists> getAllStarList(
      @Query("user_id") int userId, @Header('Authorization') String token);
}
