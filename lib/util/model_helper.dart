import 'package:model_generator/config/pubspec_config.dart';
import 'package:model_generator/config/yml_generator_config.dart';
import 'package:model_generator/model/field.dart';
import 'package:model_generator/model/item_type/array_type.dart';
import 'package:model_generator/model/item_type/map_type.dart';
import 'package:model_generator/model/model/object_model.dart';
import 'package:model_generator/util/case_util.dart';
import 'package:model_generator/util/generic_type.dart';
import 'package:model_generator/util/type_checker.dart';

class ModelHelper {
  static const autoGeneratedWarning =
      '// GENERATED CODE - DO NOT MODIFY BY HAND';

  static writeImports({
    required Set<String> initialImports,
    required ObjectModel jsonModel,
    required PubspecConfig pubspecConfig,
    required YmlGeneratorConfig yamlConfig,
    required List<Field> extendsFields,
    required StringBuffer sb,
    bool isForTable = false,
  }) {
    sb
      ..writeln(autoGeneratedWarning)
      ..writeln();
    final imports = initialImports;
    for (final element in ((isForTable
            ? jsonModel.extraImportsForTable
            : jsonModel.extraImports) ??
        pubspecConfig.extraImports)) {
      imports.add('import \'$element\';');
    }
    final extendsModel = jsonModel.extendsModel;

    if (extendsModel != null) {
      if (!TypeChecker.isKnownDartType(extendsModel)) {
        imports.addAll(
            _getImportsFromPath(extendsModel, pubspecConfig, yamlConfig));
      }
    }

    for (final field in jsonModel.fields) {
      final type = field.type;
      if (!TypeChecker.isKnownDartType(type.name) &&
          type.name != jsonModel.name) {
        imports
            .addAll(_getImportsFromPath(type.name, pubspecConfig, yamlConfig));
      }
      if (type is MapType && !TypeChecker.isKnownDartType(type.valueName)) {
        imports.addAll(
            _getImportsFromPath(type.valueName, pubspecConfig, yamlConfig));
      }
    }
    for (final field in extendsFields) {
      imports.addAll(_getImportsFromField(field, pubspecConfig, yamlConfig));
    }

    for (final converter in jsonModel.converters) {
      imports.addAll(_getImportsFromPath(converter, pubspecConfig, yamlConfig));
    }
    (imports.toList()..sort((i1, i2) => i1.compareTo(i2))).forEach(sb.writeln);

    sb.writeln();
  }

  static String getKeyType(Field field) {
    final nullableFlag =
        field.isRequired || field.type.name == 'dynamic' ? '' : '?';
    final keyType = field.type;
    if (keyType is ArrayType) {
      return 'List<${keyType.name}>$nullableFlag';
    } else if (keyType is MapType) {
      return 'Map<${keyType.name}, ${keyType.valueName}>$nullableFlag';
    } else {
      return '${keyType.name}$nullableFlag';
    }
  }

  static Iterable<String> _getImportsFromField(
      Field field, PubspecConfig pubspecConfig, YmlGeneratorConfig yamlConfig) {
    final imports = <String>{};
    final type = field.type;
    if (!TypeChecker.isKnownDartType(type.name)) {
      imports.addAll(_getImportsFromPath(type.name, pubspecConfig, yamlConfig));
    }
    if (type is MapType && !TypeChecker.isKnownDartType(type.valueName)) {
      imports.addAll(
          _getImportsFromPath(type.valueName, pubspecConfig, yamlConfig));
    }
    return imports;
  }

  static Iterable<String> _getImportsFromPath(
      String name, PubspecConfig pubspecConfig, YmlGeneratorConfig yamlConfig) {
    final imports = <String>{};
    for (final leaf in DartType(name).leaves) {
      final projectName = pubspecConfig.projectName;
      final reCaseFieldName = CaseUtil(leaf);
      final paths = yamlConfig.getPathsForName(pubspecConfig, leaf);
      for (final path in paths) {
        String pathWithPackage;
        if (path.startsWith('package:')) {
          pathWithPackage = path;
        } else {
          pathWithPackage = 'package:$projectName/$path';
        }

        if (path.endsWith('.dart')) {
          imports.add("import '$pathWithPackage';");
        } else {
          imports.add(
              "import '$pathWithPackage/${reCaseFieldName.snakeCase}.dart';");
        }
      }
    }
    return imports.toList()..sort((i1, i2) => i1.compareTo(i2));
  }
}
