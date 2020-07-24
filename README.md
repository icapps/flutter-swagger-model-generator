# Model Generator

This model generator can be used to generate JsonSerializable models

[![pub package](https://img.shields.io/pub/v/model_generator.svg)](https://pub.dartlang.org/packages/model_generator)

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
    addresses:
      type: array
      items:
        type: Address
    securityRole:
      type: string
      jsonKey: securityIndicator

Address:
  path: webservice/user
  properties:
    street:
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
```

## Custom object
Support for custom objects that are not generated by the model generator

```
CustomObject:
  path: data/custom/
  type: custom
```
### Required methods outside your class

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
### Required methods

```
{Model_Name} handle{Model_Name}FromJson(object) => {Model_Name}.fromJson(object);

{Original_Type} handle{Model_Name}ToJson({Model_Name} data) => data.toJson();
```

Run: 

`flutter packages run model_generator`