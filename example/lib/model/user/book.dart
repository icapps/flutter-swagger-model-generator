import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model_generator_example/model/user/person/person.dart';

part 'book.g.dart';

@JsonSerializable(explicitToJson: true)
@immutable
class Book {
  @JsonKey(name: 'name', required: true)
  final String name;
  @JsonKey(name: 'publishingDate', required: true)
  final DateTime publishingDate;
  @JsonKey(name: 'isAvailable', required: true)
  final bool isAvailable;
  @JsonKey(name: 'authors', required: true, includeIfNull: false)
  final List<Person> authors;
  @JsonKey(name: 'price')
  final double? price;
  @JsonKey(name: 'pages')
  final int? pages;
  @JsonKey(name: 'publishers', includeIfNull: false)
  final List<Person>? publishers;

  const Book({
    required this.name,
    required this.publishingDate,
    required this.isAvailable,
    required this.authors,
    this.price,
    this.pages,
    this.publishers,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          publishingDate == other.publishingDate &&
          isAvailable == other.isAvailable &&
          authors == other.authors &&
          price == other.price &&
          pages == other.pages &&
          publishers == other.publishers;

  @override
  int get hashCode =>
      name.hashCode ^
      publishingDate.hashCode ^
      isAvailable.hashCode ^
      authors.hashCode ^
      price.hashCode ^
      pages.hashCode ^
      publishers.hashCode;

  @override
  String toString() => 'Book{'
      'name: $name, '
      'publishingDate: $publishingDate, '
      'isAvailable: $isAvailable, '
      'authors: $authors, '
      'price: $price, '
      'pages: $pages, '
      'publishers: $publishers'
      '}';
}

Book deserializeBook(Map<String, dynamic> json) => Book.fromJson(json);

Map<String, dynamic> serializeBook(Book object) => object.toJson();

List<Book> deserializeBookList(List<Map<String, dynamic>> jsonList) =>
    jsonList.map((json) => Book.fromJson(json)).toList();

List<Map<String, dynamic>> serializeBookList(List<Book> objects) =>
    objects.map((object) => object.toJson()).toList();