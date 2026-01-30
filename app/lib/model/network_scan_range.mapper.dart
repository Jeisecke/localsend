// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'network_scan_range.dart';

class NetworkScanRangeMapper extends EnumMapper<NetworkScanRange> {
  NetworkScanRangeMapper._();

  static NetworkScanRangeMapper? _instance;
  static NetworkScanRangeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NetworkScanRangeMapper._());
    }
    return _instance!;
  }

  static NetworkScanRange fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  NetworkScanRange decode(dynamic value) {
    switch (value) {
      case 'subnet24':
        return NetworkScanRange.subnet24;
      case 'subnet16':
        return NetworkScanRange.subnet16;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(NetworkScanRange self) {
    switch (self) {
      case NetworkScanRange.subnet24:
        return 'subnet24';
      case NetworkScanRange.subnet16:
        return 'subnet16';
    }
  }
}

extension NetworkScanRangeMapperExtension on NetworkScanRange {
  String toValue() {
    NetworkScanRangeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<NetworkScanRange>(this) as String;
  }
}
