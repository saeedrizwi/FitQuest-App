
class UserModel {
  String? id;
  String? name;
  String?age;
  String? email;
  String? profileImage;

  UserModel({this.id, this.name,this.age, this.email, this.profileImage});

  UserModel.fromJson(Map<String, dynamic> json) {
    if(json["id"] is String) {
      id = json["id"];
    }
    if(json["name"] is String) {
      name = json["name"];
    }
    if(json["age"] is String) {
      name = json["age"];
    }
    if(json["email"] is String) {
      email = json["email"];
    }
    if(json["profileImage"] is String) {
      profileImage = json["profileImage"];
    }
  }

  static List<UserModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(UserModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["age"] = age;
    _data["email"] = email;
    _data["profileImage"] = profileImage;
    return _data;
  }
}