class Tiktok {
  int? code;
  String? msg;
  double? processedTime;
  Data? data;

  Tiktok({this.code, this.msg, this.processedTime, this.data});

  Tiktok.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    processedTime = json['processed_time'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    data['msg'] = msg;
    data['processed_time'] = processedTime;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  String? title;
  String? cover;
  Author? author;

  Data({this.id, this.title, this.cover, this.author});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    cover = json['cover'];
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['title'] = title;
    data['cover'] = cover;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    return data;
  }
}

class Author {
  String? nickname;

  Author({this.nickname});

  Author.fromJson(Map<String, dynamic> json) {
    nickname = json['nickname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['nickname'] = nickname;
    return data;
  }
}
