
import 'usermodel.dart';

class GroupModel {
  String? id;
  String? name;
  String? description;
  String? profileUrl;
  List<dynamic>? members;
  String? createdAt;
  String? createdBy;
  String? status;
  String? lastMessage;
  String? lastMessageTime;
  String? lastMessageBy;
  int? unReadCount;
  String? timestamp;

  GroupModel({this.id, this.name, this.description, this.profileUrl, this.members, this.createdAt, this.createdBy, this.status, this.lastMessage, this.lastMessageTime, this.lastMessageBy, this.unReadCount, this.timestamp});

  GroupModel.fromJson(Map<String, dynamic> json) {
    if(json["id"] is String) {
      id = json["id"];
    }
    if(json["name"] is String) {
      name = json["name"];
    }
    if(json["description"] is String) {
      description = json["description"];
    }
    if(json["profileUrl"] is String) {
      profileUrl = json["profileUrl"];
    }
    if(json["members"] is Map) {
      members = json["members"] ?? [];
      json["members"]==null ? null : UserModel.fromJson(json["members"]);
    }
    if(json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
    if(json["createdBy"] is String) {
      createdBy = json["createdBy"];
    }
    if(json["status"] is String) {
      status = json["status"];
    }
    if(json["lastMessage"] is String) {
      lastMessage = json["lastMessage"];
    }
    if(json["lastMessageTime"] is String) {
      lastMessageTime = json["lastMessageTime"];
    }
    if(json["lastMessageBy"] is String) {
      lastMessageBy = json["lastMessageBy"];
    }
    if(json["unReadCount"] is int) {
      unReadCount = json["unReadCount"];
    }
    if(json["timestamp"] is String) {
      timestamp = json["timestamp"];
    }
  }

  static List<GroupModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(GroupModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["description"] = description;
    _data["profileUrl"] = profileUrl;
    if(members != null) {
      _data["members"] = members;
    }
    _data["createdAt"] = createdAt;
    _data["createdBy"] = createdBy;
    _data["status"] = status;
    _data["lastMessage"] = lastMessage;
    _data["lastMessageTime"] = lastMessageTime;
    _data["lastMessageBy"] = lastMessageBy;
    _data["unReadCount"] = unReadCount;
    _data["timestamp"] = timestamp;
    return _data;
  }
}