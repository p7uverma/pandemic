import 'dart:convert';

class UrlResponseModel {
  final String message;
  final int id;
  final String error;
  final String type;
  final String code;
  final String service;
  UrlResponseModel({
    required this.message,
    required this.id,
    required this.error,
    required this.type,
    required this.code,
    required this.service,
  });

  UrlResponseModel copyWith({
    String? message,
    int? id,
    String? error,
    String? type,
    String? code,
    String? service,
  }) {
    return UrlResponseModel(
      message: message ?? this.message,
      id: id ?? this.id,
      error: error ?? this.error,
      type: type ?? this.type,
      code: code ?? this.code,
      service: service ?? this.service,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'message': message});
    result.addAll({'id': id});
    result.addAll({'error': error});
    result.addAll({'type': type});
    result.addAll({'code': code});
    result.addAll({'service': service});

    return result;
  }

  factory UrlResponseModel.fromMap(Map<String, dynamic> map) {
    return UrlResponseModel(
      message: map['message'] ?? '',
      id: map['id']?.toInt() ?? 0,
      error: map['error'] ?? '',
      type: map['type'] ?? '',
      code: map['code'] ?? '',
      service: map['service'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UrlResponseModel.fromJson(String source) =>
      UrlResponseModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UrlResponseModel(message: $message, id: $id, error: $error, type: $type, code: $code, service: $service)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UrlResponseModel &&
        other.message == message &&
        other.id == id &&
        other.error == error &&
        other.type == type &&
        other.code == code &&
        other.service == service;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        id.hashCode ^
        error.hashCode ^
        type.hashCode ^
        code.hashCode ^
        service.hashCode;
  }
}
