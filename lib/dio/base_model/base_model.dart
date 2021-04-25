class BaseModel {
  int state;
  dynamic data;
  String msg;

  BaseModel({this.state, this.data, this.msg});

  BaseModel.fromJson(Map<String, dynamic> json) {
    state = json['state'];
    data = json['data'];
    msg = json['msg'];
  }
}
