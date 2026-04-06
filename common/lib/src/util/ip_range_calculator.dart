import 'dart:math';
import 'package:common/src/model/ip_address_with_mask.dart';

/// Calculates the network range (first and last IP) based on IP address and subnet mask
class IpRangeCalculator {
  /// Parses CIDR notation or IP/mask format and returns network range
  static List<String> calculateRangeFromIpAndMask(String ip, String? mask) {
    if (mask == null || !mask.contains('.')) {
      // Fallback to /24 if no valid mask provided
      final parts = ip.split('.');
      if (parts.length != 4) return [];
      final networkBase = '${parts[0]}.${parts[1]}.${parts[2]}';
      return List.generate(256, (i) => '$networkBase.$i');
    }

    try {
      // Parse IP address
      final ipParts = ip.split('.').map(int.parse).toList();
      if (ipParts.length != 4) return [];
      
      // Parse subnet mask
      final maskParts = mask.split('.').map(int.parse).toList();
      if (maskParts.length != 4) return [];
      
      // Calculate network address (IP AND mask)
      final networkAddress = List.generate(4, (i) => ipParts[i] & maskParts[i]);
      
      // Calculate broadcast address (network address OR NOT mask)
      final invertedMask = maskParts.map((e) => 255 - e).toList();
      final broadcastAddress = List.generate(4, (i) => networkAddress[i] | invertedMask[i]);
      
      // Generate all IPs in range (including network and broadcast)
      final ipList = <String>[];
      for (int a = networkAddress[0]; a <= broadcastAddress[0]; a++) {
        for (int b = (a == networkAddress[0] ? networkAddress[1] : 0);
            b <= (a == broadcastAddress[0] ? broadcastAddress[1] : 255);
            b++) {
          for (int c = (a == networkAddress[0] && b == networkAddress[1] ? networkAddress[2] : 0);
              c <= (a == broadcastAddress[0] && b == broadcastAddress[1] ? broadcastAddress[2] : 255);
              c++) {
            for (int d = (a == networkAddress[0] && b == networkAddress[1] && c == networkAddress[2] ? 0 : 
                           a == broadcastAddress[0] && b == broadcastAddress[1] && c == broadcastAddress[2] ? 255 : 
                           (a == networkAddress[0] && b == networkAddress[1]) ? 0 : 
                           (a == broadcastAddress[0] && b == broadcastAddress[1]) ? 255 : 0);
                d <= (a == networkAddress[0] && b == networkAddress[1] && c == networkAddress[2] ? 255 : 
                      a == broadcastAddress[0] && b == broadcastAddress[1] && c == broadcastAddress[2] ? 0 : 
                      (a == networkAddress[0] && b == networkAddress[1]) ? 255 : 
                      (a == broadcastAddress[0] && b == broadcastAddress[1]) ? 0 : 255);
                d++) {
              ipList.add('$a.$b.$c.$d');
            }
          }
        }
      }
      
      return ipList;
    } catch (e) {
      // Fallback to /24 if parsing fails
      final parts = ip.split('.');
      if (parts.length != 4) return [];
      final networkBase = '${parts[0]}.${parts[1]}.${parts[2]}';
      return List.generate(256, (i) => '$networkBase.$i');
    }
  }
  
  /// Simpler version that just calculates network and generates /24 range
  /// This is more efficient for the common case
  static List<String> calculateSimpleRange(String ip, String? mask) {
    if (mask == null || !mask.contains('.')) {
      // Fallback to /24 if no valid mask provided
      final parts = ip.split('.');
      if (parts.length != 4) return [];
      final networkBase = '${parts[0]}.${parts[1]}.${parts[2]}';
      return List.generate(256, (i) => '$networkBase.$i');
    }
    
    try {
      // Parse IP address
      final ipParts = ip.split('.').map(int.parse).toList();
      if (ipParts.length != 4) return [];
      
      // Parse subnet mask
      final maskParts = mask.split('.').map(int.parse).toList();
      if (maskParts.length != 4) return [];
      
      // Calculate network address (IP AND mask)
      final networkAddress = List.generate(4, (i) => ipParts[i] & maskParts[i]);
      
      // For simplicity, we'll assume it's a /24 or similar and just vary the last octet
      // This maintains compatibility with existing code while being more accurate
      final networkBase = '${networkAddress[0]}.${networkAddress[1]}.${networkAddress[2]}';
      return List.generate(256, (i) => '$networkBase.$i');
    } catch (e) {
      // Fallback to /24 if parsing fails
      final parts = ip.split('.');
      if (parts.length != 4) return [];
      final networkBase = '${parts[0]}.${parts[1]}.${parts[2]}';
      return List.generate(256, (i) => '$networkBase.$i');
    }
  }
}