import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';

class ProviderTypeAdapter extends TypeAdapter<ProviderType> {
  @override
  final int typeId = 7;

  @override
  ProviderType read(BinaryReader reader) {
    final index = reader.readByte();
    return ProviderType.values[index];
  }

  @override
  void write(BinaryWriter writer, ProviderType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AuthMethodAdapter extends TypeAdapter<AuthMethod> {
  @override
  final int typeId = 8;

  @override
  AuthMethod read(BinaryReader reader) {
    final index = reader.readByte();
    return AuthMethod.values[index];
  }

  @override
  void write(BinaryWriter writer, AuthMethod obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AuthorizationAdapter extends TypeAdapter<Authorization> {
  @override
  final int typeId = 9;

  @override
  Authorization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Authorization(
      method: fields[0] as AuthMethod,
      key: fields[1] as String?,
      value: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Authorization obj) {
    writer
      ..writeByte(3) // number of fields
      ..writeByte(0)
      ..write(obj.method)
      ..writeByte(1)
      ..write(obj.key)
      ..writeByte(2)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthorizationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConfigurationAdapter extends TypeAdapter<Configuration> {
  @override
  final int typeId = 10;

  @override
  Configuration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Configuration(
      httpProxy: _decodeMap(fields[0] as String),
      socksProxy: _decodeMap(fields[1] as String),
      supportStream: fields[2] as bool? ?? true,
      headers: _decodeMap(fields[3] as String),
      responsesApi: fields[4] as bool? ?? false,
      customListModelsUrl: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Configuration obj) {
    writer
      ..writeByte(6) // number of fields
      ..writeByte(0)
      ..write(_encodeMap(obj.httpProxy))
      ..writeByte(1)
      ..write(_encodeMap(obj.socksProxy))
      ..writeByte(2)
      ..write(obj.supportStream)
      ..writeByte(3)
      ..write(_encodeMap(obj.headers))
      ..writeByte(4)
      ..write(obj.responsesApi)
      ..writeByte(5)
      ..write(obj.customListModelsUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  // Encode Map<String, dynamic> to JSON string
  String _encodeMap(Map<String, dynamic> map) {
    try {
      return json.encode(map);
    } catch (e) {
      return '{}';
    }
  }

  // Decode JSON string back to Map<String, dynamic>
  Map<String, dynamic> _decodeMap(String mapJson) {
    try {
      final decoded = json.decode(mapJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}

class LlmProviderInfoAdapter extends TypeAdapter<LlmProviderInfo> {
  @override
  final int typeId = 11;

  @override
  LlmProviderInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return LlmProviderInfo(
      id: fields[0] as String?,
      name: fields[1] as String?,
      type: fields[2] as ProviderType,
      auth: fields[3] as Authorization?,
      icon: fields[4] as String?,
      baseUrl: fields[5] as String?,
      config: fields[6] as Configuration,
    );
  }

  @override
  void write(BinaryWriter writer, LlmProviderInfo obj) {
    writer
      ..writeByte(7) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.auth)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.baseUrl)
      ..writeByte(6)
      ..write(obj.config);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlmProviderInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
