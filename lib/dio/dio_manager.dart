import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'base_model/base_model.dart';
import 'base_model/error_model.dart';
import 'dio_api.dart';

enum DIOMethod { GET, POST, DELETE, PUT }

Map<String, dynamic> parseData(String data) {
  return json.decode(data) as Map<String, dynamic>;
}

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
        responseType: ResponseType.plain,
        connectTimeout: 90000,
        receiveTimeout: 3000,
      );
      dio = Dio(options);
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
      };
    }
  }

  static DioManager getInstance({String baseUrl, Map headers}) {
    return _shared._baseUrl(baseUrl, headers);
  }

  //用于指定特定域名，比如cdn和kline首次的http请求
  DioManager _baseUrl(String baseUrl, Map headers) {
    if (dio != null) {
      if (baseUrl != null) {
        dio.options.baseUrl = baseUrl;
      }
      if (headers != null) {
        dio.options.headers = headers;
      }
    }
    return this;
  }

  getHeaders() {
    return {
      "FromData": "application/x-www-form-urlencoded",
      "Content-Type": "application/json",
      "Multipart": '"multipart/form-data',
      "callSource": "mobile",
      "server": "mobile",
      "Authorization":
          "BackType eyJhbGciOiJIUzI1NiJ9.eyJhcHBseU1pY3JvU2VydmljZUNvZGUiOiIwMTAxNTAyMSIsImV4cCI6NDA3MDg4MDAwMDAwMH0.dUPVitXfv-iNFxNGzTtsS6wcWWJZh3SnjoB4xJMRb6s",
    };
  }

  // 请求，返回参数为data
  // method：请求方法，NWMethod.POST等
  // path：请求地址
  // params：请求参数
  // success：请求成功回调
  // error：请求失败回调
  //todo 玩安卓默认添加'/json'
  Future request(DIOMethod method, String path,
      {Map<String, dynamic> params,Map<String, dynamic> queryParams, Function success, Function error}) async {
    try {
      Response response = await dio.request(path,
          queryParameters: queryParams,
          data: params,
          options: Options(
            method: NWMethodValues[method],
          ));
      if (response != null) {
        final Map<String, dynamic> dataNew =
            await compute(parseData, response.data.toString());
        BaseModel entity = BaseModel.fromJson(dataNew);

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

  ///手机中的图片
  String localImagePath = "";

  ///上传的服务器地址
  String netUploadUrl = "";

  ///dio 实现文件上传
  Future fileUpload() async {
    ///创建Dio
    Dio dio = new Dio();

    Map<String, dynamic> map = Map();
    map["auth"] = "12345";
    map["file"] =
        await MultipartFile.fromFile(localImagePath, filename: "xxx23.png");

    ///通过FormData
    FormData formData = FormData.fromMap(map);

    ///发送post
    Response response = await dio.post(
      netUploadUrl, data: formData,

      ///这里是发送请求回调函数
      ///[progress] 当前的进度
      ///[total] 总进度
      onSendProgress: (int progress, int total) {
        print("当前进度是 $progress 总进度是 $total");
      },
    );

    ///服务器响应结果
    var data = response.data;
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
