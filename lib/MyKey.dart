import 'dart:convert';

MyKey myKeyFromJson(Map object) => MyKey.fromJson(object);

String myKeyToJson(MyKey data) => json.encode(data.toJson());

class MyKey {
  int leftAmount;
  String leftDirection;
  int rightAmount;
  String rightDirection;
  String key;

  MyKey({
    this.leftAmount,
    this.leftDirection,
    this.rightAmount,
    this.rightDirection,
    this.key,
  });

  factory MyKey.fromJson(Map<String, dynamic> json) => MyKey(
        leftAmount: json["leftAmount"],
        leftDirection: json["leftDirection"],
        rightAmount: json["rightAmount"],
        rightDirection: json["rightDirection"],
        key: json["key"],
      );

  Map<String, dynamic> toJson() => {
        "leftAmount": leftAmount,
        "leftDirection": leftDirection,
        "rightAmount": rightAmount,
        "rightDirection": rightDirection,
        "key": key,
      };
}
