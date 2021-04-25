class BaseModel {
  dynamic errorCode;
  dynamic data;
  String errorMsg;

  BaseModel({this.errorCode, this.data, this.errorMsg});

  BaseModel.fromJson(Map<String, dynamic> json) {
    errorCode = json['state'];
    data = json['data'];
    errorMsg = json['msg'];
  }
}
