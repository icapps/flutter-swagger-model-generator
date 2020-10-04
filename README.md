# Model Generator

This model generator can be used to generate JsonSerializable models

[![pub package](https://img.shields.io/pub/v/model_generator.svg)](https://pub.dartlang.org/packages/model_generator)
[![Build Status](https://travis-ci.com/icapps/flutter-model-generator.svg?branch=master)](https://travis-ci.com/icapps/flutter-model-generator)
[![Coverage Status](https://coveralls.io/repos/github/icapps/flutter-model-generator/badge.svg)](https://coveralls.io/github/icapps/flutter-model-generator)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

## Run 

`flutter packages run model_generator`

## Default setup
Example of the `pubspec.yaml` file if you want to use a custom base_directory for all your models
Default is `/lib/model` you can override it for all your models like this:
```
model_generator:
  base_directory: custom_models
```
this will write all your models to /lib/custom_models
`path` will be added after the `base_directory`

##FVM support
If you are using fvm for managing  your flutter version. You can add an option to the model generator as well to run with fvm.
add an option `use_fvm` and set it to true. (by default it is set to false)
```
model_generator:
  use_fvm: true
```

## Default setup
Example of the `model_generator/config.yaml` file
```
UserModel:
  path: webservice/user
  properties:
    id:
      type: int
    name:
      type: string
    salary:
      type: double
    something:
      type: dynamic
    isLoggedIn:
      type: bool
    roles:
      type: array
      items:
        type: string
    birthday:
      type: date
    addresses:
      type: array
      items:
        type: Address
    securityRole:
      type: string
      jsonKey: securityIndicator
    dynamicField:
      type: dynamic
    includeIfNullField:
      includeIfNull: false #If this field is null, this field will not be added to your json object (used for PATCH models)
      type: string
    ignoreField:
      ignore: false #this field will not be final, and not be used in the json parsing
      type: string

Address:
  path: webservice/user
  properties:
    street:
      type: string

#Custom base_directory
CustomBaseDirectoryObject:
  base_directory: custom_models
  path: webservice
  properties:
    path:
      type: string
```

## Enum support
Add enums with custom values

```
Gender:
  path: webservice/user
  type: enum
  properties:
    MALE:
      value: _mAl3
    FEMALE:
      value: femAle
    X:
      value: X
    Y:
```

## Custom object
Support for custom objects that are not generated by the model generator

```
CustomObject:
  path: data/custom/
  type: custom
```
### Required methods inside your class

```
  factory {Model_Name}.fromJson(Map<String, dynamic> json) => _${Model_Name}FromJson(json);

  Map<String, dynamic> toJson() => _${Model_Name}ToJson(this);
```

## fromJson & toJson
Support for custom objects but use fromJson & toJson instead of full object parsing:
```
CustomObjectFromToJson:
  path: data/custom/
  type: custom_from_to_json
```
### Required functions outside your class

```
{Model_Name} handle{Model_Name}FromJson(object) => {Model_Name}.fromJson(object);

{Original_Type} handle{Model_Name}ToJson({Model_Name} data) => data.toJson();
```