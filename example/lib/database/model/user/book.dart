import 'package:drift/drift.dart';
import 'package:model_generator_example/database/model_generator_example_database.dart';
import 'package:model_generator_example/model/user/book.dart';
import 'package:model_generator_example/model/user/person/person.dart';

@DataClassName('DbBook')
class DbBookTable extends Table {
  TextColumn get name => text()();

  DateTimeColumn get publishingDate => dateTime()();

  BoolColumn get isAvailable => boolean()();

  RealColumn get price => real().nullable()();

  IntColumn get pages => integer().nullable()();
}

extension DbBookExtension on DbBook {
  Book getModel({required List<Person> authors, List<Person>? publishers}) =>
      Book(
        name: name,
        publishingDate: publishingDate,
        isAvailable: isAvailable,
        authors: authors,
        price: price,
        pages: pages,
        publishers: publishers,
      );
}

extension BookExtension on Book {
  DbBook get dbModel => DbBook(
        name: name,
        publishingDate: publishingDate,
        isAvailable: isAvailable,
        price: price,
        pages: pages,
      );
}