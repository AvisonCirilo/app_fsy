import 'package:flutter_test/flutter_test.dart';

import 'package:app_fsy/data/local_database.dart';
import 'package:app_fsy/data/lodging_structure.dart';

LocalDocumentSnapshot youth(
  String id,
  String name,
  String room, {
  int? floor,
}) {
  return LocalDocumentSnapshot(
    id: id,
    exists: true,
    value: {
      'nome': name,
      'quarto': room,
      if (floor != null) 'andar': floor,
    },
  );
}

void main() {
  group('Estrutura de alojamentos', () {
    test('infere o andar de quartos antigos pelo número', () {
      expect(
        LodgingStructure.floorFromRoom('Bloco A - 101'),
        1,
      );
      expect(
        LodgingStructure.floorFromRoom('Bloco B - 201'),
        2,
      );
      expect(
        LodgingStructure.floorFromRoom('Quarto sem numeração'),
        isNull,
      );
    });

    test('o andar salvo explicitamente prevalece sobre o número do quarto', () {
      final person = youth(
        '1',
        'Ana',
        'Bloco A - 101',
        floor: 3,
      );

      expect(LodgingStructure.floorFor(person), 3);
    });

    test('agrupa jovens por andar e quarto e conta quartos únicos', () {
      final people = [
        youth('1', 'Lucas', 'Bloco A - 101'),
        youth('2', 'Mariana', 'Bloco A - 101'),
        youth('3', 'Sofia', 'Bloco B - 201'),
        youth('4', 'João', ''),
      ];

      final floors = LodgingStructure.groupByFloor(people);

      expect(floors, hasLength(2));
      expect(floors[0].number, 1);
      expect(floors[0].rooms, hasLength(1));
      expect(floors[0].rooms[0].youth, hasLength(2));
      expect(floors[0].rooms[0].youth.first['nome'], 'Lucas');
      expect(floors[1].number, 2);
      expect(LodgingStructure.countRooms(people), 2);
    });

    test('não considera "A Definir" como quarto ocupado', () {
      final people = [
        youth('1', 'Ana', 'A Definir'),
        youth('2', 'Bia', 'Sem quarto'),
      ];

      expect(LodgingStructure.countRooms(people), 0);
      expect(
        people.where(LodgingStructure.isAssigned),
        isEmpty,
      );
    });
  });
}
