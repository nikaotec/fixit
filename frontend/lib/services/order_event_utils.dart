class OrderEventUtils {
  static Map<String, dynamic>? extractOrderPayload(Map data) {
    final direct = _asMap(data['order']) ??
        _asMap(data['maintenanceOrder']) ??
        (data.containsKey('equipamento') ? data.cast<String, dynamic>() : null);
    if (direct == null) return null;
    return direct;
  }

  static int? extractOrderId(Map data) {
    final candidates = [
      data['orderId'],
      data['maintenanceOrderId'],
      data['id'],
      (data['order'] is Map ? data['order']['id'] : null),
      (data['maintenanceOrder'] is Map ? data['maintenanceOrder']['id'] : null),
    ];
    for (final value in candidates) {
      final parsed = _parseInt(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static String? extractOrderStatus(Map data) {
    final candidates = [
      data['status'],
      data['orderStatus'],
      data['maintenanceOrderStatus'],
      (data['order'] is Map ? data['order']['status'] : null),
      (data['maintenanceOrder'] is Map
          ? data['maintenanceOrder']['status']
          : null),
    ];
    for (final value in candidates) {
      if (value == null) continue;
      final status = value.toString();
      if (status.isNotEmpty) return status;
    }
    return null;
  }

  static bool isOrderEvent(Map data, {int? orderId}) {
    final type = data['type']?.toString().toLowerCase() ?? '';
    final hasOrderType =
        type.contains('order') || type.contains('execution');
    final extractedId = extractOrderId(data);
    if (orderId != null && extractedId != null) {
      return extractedId.toString() == orderId.toString();
    }
    return hasOrderType || extractedId != null;
  }

  static bool isDeleteEvent(Map data) {
    final type = data['type']?.toString().toLowerCase() ?? '';
    return type.contains('delete') || type.contains('removed');
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return null;
  }
}
