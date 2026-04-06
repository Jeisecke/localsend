import 'dart:io';

/// Represents an IP address with its associated subnet mask
class IpAddressWithMask {
  final String ip;
  final String? mask;

  IpAddressWithMask({
    required this.ip,
    this.mask,
  });

  /// Returns true if this is an IPv4 address with a valid mask
  bool get isIpv4WithMask =>
      ip.contains('.') && mask != null && mask.contains('.');

  @override
  String toString() => mask != null ? '$ip/$mask' : ip;
}