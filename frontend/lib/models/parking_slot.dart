class ParkingSlot {
  final int id;
  final int spaceId;
  final String slotId;
  final String label;
  final bool isOccupied;
  final bool isReserved;
  final bool isActive;
  final String spaceName;
  final String createdAt;

  ParkingSlot({
    required this.id,
    required this.spaceId,
    required this.slotId,
    required this.label,
    required this.isOccupied,
    required this.isReserved,
    required this.isActive,
    required this.spaceName,
    required this.createdAt,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'] ?? 0,
      spaceId: json['space'] ?? 0,
      slotId: json['slot_id'] ?? '',
      label: json['label'] ?? '',
      isOccupied: json['is_occupied'] ?? false,
      isReserved: json['is_reserved'] ?? false,
      isActive: json['is_active'] ?? true,
      spaceName: json['space_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'space': spaceId,
      'slot_id': slotId,
      'label': label,
      'is_occupied': isOccupied,
      'is_reserved': isReserved,
      'is_active': isActive,
      'space_name': spaceName,
      'created_at': createdAt,
    };
  }
}
