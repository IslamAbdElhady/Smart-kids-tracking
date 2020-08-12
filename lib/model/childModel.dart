// To parse this JSON data, do
//
//     final childModel = childModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';

ChildModel childModelFromJson(String str) => ChildModel.fromMap(json.decode(str));

String childModelToJson(ChildModel data) => json.encode(data.toMap());

class ChildModel {
  final int id;
  final String name;
  final String babyKey;
  final String kinderName;
  final double homeLan;
  final double homeLng;
  final double kinderLan;
  final double kinderLng;
  final List<Place> otherPlaces;

  ChildModel({
    @required this.babyKey,
    this.id,
    this.name,
    this.kinderName,
    this.homeLan,
    this.homeLng,
    this.kinderLan,
    this.kinderLng,
    this.otherPlaces,
  });

  factory ChildModel.fromJson(String str) => ChildModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ChildModel.fromMap(Map<String, dynamic> json) => ChildModel(
    id: json["id"] == null ? null : json["id"],
    name: json["name"] == null ? null : json["name"],
    kinderName: json["kinder_name"] == null ? null : json["kinder_name"],
    homeLan: json["home_lan"] == null ? null : json["home_lan"].toDouble(),
    homeLng: json["home_lng"] == null ? null : json["home_lng"].toDouble(),
    kinderLan: json["kinder_lan"] == null ? null : json["kinder_lan"].toDouble(),
    kinderLng: json["linder_lng"] == null ? null : json["linder_lng"].toDouble(),
    otherPlaces: json["other_places"] == null ? null : List<Place>.from(json["other_places"].map((x) => Place.fromMap(x))),
    babyKey: json["baby_key"] == null ? null : json["baby_key"],
  );

  Map<String, dynamic> toMap() => {
    "baby_key": id == null ? null : babyKey,
    "id": id == null ? null : id,
    "name": name == null ? null : name,
    "kinder_name": kinderName == null ? null : kinderName,
    "home_lan": homeLan == null ? null : homeLan,
    "home_lng": homeLng == null ? null : homeLng,
    "kinder_lan": kinderLan == null ? null : kinderLan,
    "linder_lng": kinderLng == null ? null : kinderLng,
    "other_places": otherPlaces == null ? null : List<dynamic>.from(otherPlaces.map((x) => x.toMap())),
  };
}

class Place {
  final double lan;
  final double lng;

  Place({
    this.lan,
    this.lng,
  });

  factory Place.fromMap(Map<String, dynamic> json) => Place(
    lan: json["lan"] == null ? null : json["lan"].toDouble(),
    lng: json["lng"] == null ? null : json["lng"].toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "lan": lan == null ? null : lan,
    "lng": lng == null ? null : lng,
  };
}
