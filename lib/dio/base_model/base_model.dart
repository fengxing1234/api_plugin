class BaseModel {
  int errorCode;
  dynamic data;
  String errorMsg;

  BaseModel({this.errorCode, this.data, this.errorMsg});

  BaseModel.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    data = json['data'];
    errorMsg = json['errorMsg'];
  }
}
