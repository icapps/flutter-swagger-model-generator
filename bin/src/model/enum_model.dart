import 'model.dart';

class EnumModel extends Model {
  final List<EnumField> fields;

  EnumModel(
    String name,
    String path,
    this.fields,
  ) : super(name, path);
}

class EnumField {
  final String name;
  final String serializedName;
  final String value;

  EnumField._(this.name, this.serializedName, this.value);

  factory EnumField(String name, String value) =>
      EnumField._(name, name.toUpperCase(), value);
}