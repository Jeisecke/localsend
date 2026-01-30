import 'package:dart_mappable/dart_mappable.dart';
import 'package:localsend_app/gen/strings.g.dart';

part 'network_scan_range.mapper.dart';

/// Defines the network scan range for HTTP-based device discovery.
/// 
/// - [subnet24]: Scans /24 network (255.255.255.0) - 256 addresses
/// - [subnet16]: Scans /16 network (255.255.0.0) - 65,536 addresses
@MappableEnum()
enum NetworkScanRange {
  subnet24,
  subnet16;

  String get humanName {
    switch (this) {
      case NetworkScanRange.subnet24:
        return t.settingsTab.network.scanRangeOptions.subnet24;
      case NetworkScanRange.subnet16:
        return t.settingsTab.network.scanRangeOptions.subnet16;
    }
  }

  String get description {
    switch (this) {
      case NetworkScanRange.subnet24:
        return '/24 (255.255.255.0) - 256 addresses';
      case NetworkScanRange.subnet16:
        return '/16 (255.255.0.0) - 65,536 addresses';
    }
  }

  int get addressCount {
    switch (this) {
      case NetworkScanRange.subnet24:
        return 256;
      case NetworkScanRange.subnet16:
        return 65536;
    }
  }
}
