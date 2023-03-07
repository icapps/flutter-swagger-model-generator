import 'dart:io';

import 'package:args/args.dart';
import 'package:model_generator/config/pubspec_config.dart';
import 'package:model_generator/config/yml_generator_config.dart';
import 'package:model_generator/model/model/custom_model.dart';
import 'package:model_generator/model/model/enum_model.dart';
import 'package:model_generator/model/model/json_converter_model.dart';
import 'package:model_generator/model/model/model.dart';
import 'package:model_generator/model/model/object_model.dart';
import 'package:model_generator/writer/drift_dao_storage_writer.dart';
import 'package:model_generator/writer/drift_model_writer.dart';
import 'package:model_generator/writer/enum_model_writer.dart';
import 'package:model_generator/writer/object_model_writer.dart';
import 'package:path/path.dart';

Future<void> main(List<String> args) async {
  final argParser = ArgParser()
    ..addOption('path', help: 'Override the default model configuration path. This value will be used instead of the default OR what you have configured in pubspec.yaml')
    ..addFlag('help', help: 'Displays this help screen', defaultsTo: false, negatable: false);

  final results = argParser.parse(args);
  if (results['help']) {
    print(argParser.usage);
    return;
  }

  final pubspecYaml = File(join(Directory.current.path, 'pubspec.yaml'));
  if (!pubspecYaml.existsSync()) {
    throw Exception('This program should be run from the root of a flutter/dart project');
  }
  final pubspecContent = pubspecYaml.readAsStringSync();
  final pubspecConfig = PubspecConfig(pubspecContent);

  final configPath = results['path'] ?? pubspecConfig.configPath;
  String absolutePath;
  if (isAbsolute(configPath)) {
    absolutePath = configPath;
  } else {
    absolutePath = join(Directory.current.path, configPath);
  }
  final FileSystemEntity configEntity;
  switch (FileSystemEntity.typeSync(absolutePath)) {
    case FileSystemEntityType.directory:
      configEntity = Directory(absolutePath);
      break;
    case FileSystemEntityType.file:
    default:
      configEntity = File(absolutePath);
      break;
  }

  if (!configEntity.existsSync()) {
    throw Exception('This program requires a config file/dir. `$configPath` does not exist');
  }
  final YmlGeneratorConfig modelGeneratorConfig;
  if (configEntity is Directory) {
    modelGeneratorConfig = readConfigFilesInDirectory(pubspecConfig, configEntity, configPath);
  } else {
    final modelGeneratorContent = (configEntity as File).readAsStringSync();
    modelGeneratorConfig = YmlGeneratorConfig(pubspecConfig, modelGeneratorContent, configPath);
  }
  modelGeneratorConfig.checkIfTypesAvailable();
  if (modelGeneratorConfig.models.isEmpty) {
    print('No models defined in config files, skipping generation');
  }

  writeToFiles(pubspecConfig, modelGeneratorConfig);
  await generateJsonGeneratedModels(useFvm: pubspecConfig.useFvm);
  print('Done!!!');
}

YmlGeneratorConfig readConfigFilesInDirectory(PubspecConfig config, Directory configEntity, String directoryPath) {
  final configFiles = configEntity.listSync(recursive: true).whereType<File>().where((element) => extension(element.path) == '.yaml' || extension(element.path) == '.yml');
  final configs = configFiles.map((e) => YmlGeneratorConfig(config, e.readAsStringSync(), relative(e.path)));
  return YmlGeneratorConfig.merge(configs, directoryPath);
}

void writeToFiles(PubspecConfig pubspecConfig, YmlGeneratorConfig modelGeneratorConfig) {
  for (final model in modelGeneratorConfig.models) {
    final modelDirectory = Directory(join('lib', model.baseDirectory));
    if (!modelDirectory.existsSync()) {
      modelDirectory.createSync(recursive: true);
    }
    String? content;
    if (model is ObjectModel) {
      content = ObjectModelWriter(
        pubspecConfig,
        model,
        modelGeneratorConfig,
      ).write();
      if (model.generateDriftTable == true) {
        final tableContent = DriftModelWriter(
          pubspecConfig,
          model,
          modelGeneratorConfig,
        ).write();
        _saveFile(
          model,
          tableContent,
          directories: ['database', 'tables'],
          suffix: '_table',
        );
      }
      if (model.generateDriftDaoStorage == true && !_getFile(model, directories: ['database', 'tables'], suffix: '_dao_storage').existsSync()) {
        final tableContent = DriftDaoStorageWriter(
          pubspecConfig,
          model,
          modelGeneratorConfig,
        ).write();
        _saveFile(
          model,
          tableContent,
          directories: ['database', 'tables'],
          suffix: '_dao_storage',
        );
      }
    } else if (model is EnumModel) {
      content = EnumModelWriter(model).write();
    } else if (model is JsonConverterModel) {
      continue;
    } else if (model is CustomModel) {
      continue;
    }
    if (content == null) {
      throw Exception('content is null for ${model.name}. File a bug report on github. This is not normal. https://github.com/icapps/flutter-model-generator/issues');
    }
    _saveFile(model, content);
  }
}

void _saveFile(Model model, String content, {List<String>? directories, String? suffix}) {
  final file = _getFile(model, directories: directories, suffix: suffix);
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }
  file.writeAsStringSync(content);
}

File _getFile(Model model, {List<String>? directories, String? suffix}) {
  final path = [
    'lib',
    ...?directories,
    directories == null ? model.baseDirectory : null,
    model.path,
    '${model.fileName}${suffix ?? ''}.dart',
  ].whereType<String>();
  return File(joinAll(path));
}

Future<void> generateJsonGeneratedModels({required bool useFvm}) async {
  ProcessResult result;
  if (useFvm) {
    result = Process.runSync('fvm', [
      'flutter',
      'packages',
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);
  } else {
    result = Process.runSync('flutter', [
      'packages',
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);
  }
  if (result.exitCode == 0) {
    print('Successfully generated the jsonSerializable generated files');
    print('');
  } else {
    print('Failed to run `${useFvm ? 'fvm ' : ''}flutter packages pub run build_runner build --delete-conflicting-outputs`');
    print('StdErr: ${result.stderr}');
    print('StdOut: ${result.stdout}');
  }
}
