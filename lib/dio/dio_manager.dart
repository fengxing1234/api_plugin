import 'package:dio/dio.dart';

import 'base_model/base_model.dart';
import 'base_model/error_model.dart';
import 'dio_api.dart';

enum DIOMethod { GET, POST, DELETE, PUT }

const NWMethodValues = {
  DIOMethod.GET: "get",
  DIOMethod.POST: "post",
  DIOMethod.DELETE: "delete",
  DIOMethod.PUT: "put"
};

class DioManager {
  static final DioManager _shared = DioManager._internal();

  factory DioManager() => _shared;
  Dio dio;

  DioManager._internal() {
    if (dio == null) {
      BaseOptions options = BaseOptions(
        baseUrl: DioApi.baseApi,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        receiveDataWhenStatusError: false,
        connectTimeout: 30000,
        receiveTimeout: 3000,
      );
      dio = Dio(options);
    }
  }

  // 请求，返回参数为data
  // method：请求方法，NWMethod.POST等
  // path：请求地址
  // params：请求参数
  // success：请求成功回调
  // error：请求失败回调
  //todo 玩安卓默认添加'/json'
  Future request(DIOMethod method, String path,
      {Map<String, String> params, Function success, Function error}) async {
    try {
      Response response = await dio.request(path + '',
          queryParameters: params,
          options: Options(
              method: NWMethodValues[method],
              ));
      if (response != null) {
        BaseModel entity = BaseModel.fromJson(response.data);
        if (entity.errorCode == 0) {
          success(entity.data);
        } else {
          error(ErrorModel(code: entity.errorCode, message: entity.errorMsg));
        }
      } else {
        error(ErrorModel(code: -1, message: "未知错误"));
      }
    } on DioError catch (e) {
      error(createErrorEntity(e));
    }
  }

  // 错误信息
  ErrorModel createErrorEntity(DioError error) {
    switch (error.type) {
      case DioErrorType.CANCEL:
        {
          return ErrorModel(code: -1, message: "请求取消");
        }
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        {
          return ErrorModel(code: -1, message: "连接超时");
        }
        break;
      case DioErrorType.SEND_TIMEOUT:
        {
          return ErrorModel(code: -1, message: "请求超时");
        }
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        {
          return ErrorModel(code: -1, message: "响应超时");
        }
        break;
      case DioErrorType.RESPONSE:
        {
          try {
            int errCode = error.response.statusCode;
            String errMsg = error.response.statusMessage;
            return ErrorModel(code: errCode, message: errMsg);
          } on Exception catch (_) {
            return ErrorModel(code: -1, message: "未知错误");
          }
        }
        break;
      default:
        {
          return ErrorModel(code: -1, message: error.message);
        }
    }
  }
}
