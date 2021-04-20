import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';

part 'project.g.dart';

@JsonSerializable()
@immutable
class Project {
  @JsonKey(name: 'name', required: true)
  final String name;
  @JsonKey(name: 'cost')
  final double? cost;

  const Project({
    required this.name,
    this.cost,
  });

  factory Project.fromJson(Object? json) =>
      _$ProjectFromJson(json as Map<String, dynamic>); // ignore: avoid_as

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}