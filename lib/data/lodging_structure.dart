import 'local_database.dart';

class LodgingRoomGroup {
  const LodgingRoomGroup({
    required this.name,
    required this.youth,
  });

  final String name;
  final List<LocalDocumentSnapshot> youth;
}

class LodgingFloorGroup {
  const LodgingFloorGroup({
    required this.number,
    required this.rooms,
  });

  final int? number;
  final List<LodgingRoomGroup> rooms;

  int get youthCount =>
      rooms.fold(0, (total, room) => total + room.youth.length);
}

class LodgingStructure {
  LodgingStructure._();

  static bool isAssigned(LocalDocumentSnapshot youth) {
    final room = (youth['quarto'] ?? '').toString().trim().toLowerCase();
    return room.isNotEmpty &&
        room != 'a definir' &&
        room != 'sem quarto' &&
        room != 'não definido' &&
        room != 'nao definido';
  }

  static int? floorFor(LocalDocumentSnapshot youth) {
    final explicitFloor = (youth['andar'] ?? '').toString().trim();
    final explicitNumber = RegExp(r'\d+').firstMatch(explicitFloor);
    if (explicitNumber != null) {
      final parsed = int.tryParse(explicitNumber.group(0)!);
      if (parsed != null && parsed > 0) return parsed;
    }

    return floorFromRoom((youth['quarto'] ?? '').toString());
  }

  /// Compatibility with older records such as "Bloco A - 101".
  /// The first digit of a three-digit room number identifies the floor.
  static int? floorFromRoom(String room) {
    final match = RegExp(r'(\d{3,})\s*$').firstMatch(room.trim());
    if (match == null) return null;

    final digits = match.group(1)!;
    final floor = int.tryParse(digits.substring(0, digits.length - 2));
    return floor != null && floor > 0 ? floor : null;
  }

  static String floorLabel(int? floor) =>
      floor == null ? 'Andar não informado' : '$floorº andar';

  static List<LodgingFloorGroup> groupByFloor(
    List<LocalDocumentSnapshot> youth,
  ) {
    final grouped = <int?, Map<String, List<LocalDocumentSnapshot>>>{
      1: <String, List<LocalDocumentSnapshot>>{},
      2: <String, List<LocalDocumentSnapshot>>{},
      3: <String, List<LocalDocumentSnapshot>>{},
    };

    for (final person in youth) {
      if (!isAssigned(person)) continue;

      final room = (person['quarto'] ?? '').toString().trim();
      final floor = floorFor(person);
      grouped.putIfAbsent(floor, () => <String, List<LocalDocumentSnapshot>>{});
      grouped[floor]!.putIfAbsent(room, () => <LocalDocumentSnapshot>[]);
      grouped[floor]![room]!.add(person);
    }

    final floorNumbers = grouped.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        return a.compareTo(b);
      });

    return floorNumbers.map((floorNumber) {
      final rooms = grouped[floorNumber]!.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      return LodgingFloorGroup(
        number: floorNumber,
        rooms: rooms.map((entry) {
          final occupants = entry.value
            ..sort(
              (a, b) => (a['nome'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo((b['nome'] ?? '').toString().toLowerCase()),
            );
          return LodgingRoomGroup(name: entry.key, youth: occupants);
        }).toList(),
      );
    }).toList();
  }

  static int countRooms(List<LocalDocumentSnapshot> youth) {
    return groupByFloor(youth).fold(
      0,
      (total, floor) => total + floor.rooms.length,
    );
  }
}
