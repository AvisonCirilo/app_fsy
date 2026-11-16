import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Banco de demonstração em memória, persistido localmente via SharedPreferences.
/// Não sincroniza dados e não deve ser usado para informações reais.
class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  static const List<String> _collections = ['usuarios', 'jovens', 'companhias'];

  final Map<String, LinkedHashMap<String, Map<String, dynamic>>> _data = {};
  final Map<String, StreamController<void>> _changes = {};
  bool _initialized = false;
  int _idCounter = 0;

  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final seeds = _seedData();

    for (final name in _collections) {
      _changes[name] = StreamController<void>.broadcast();
      final raw = prefs.getString(_storageKey(name));

      if (raw == null) {
        _data[name] = _copyCollection(seeds[name] ?? {});
        await _persist(name);
        continue;
      }

      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final collection = LinkedHashMap<String, Map<String, dynamic>>();
        decoded.forEach((id, value) {
          collection[id] = Map<String, dynamic>.from(value as Map);
        });
        _data[name] = collection;
      } catch (_) {
        // Se um armazenamento local estiver inválido, restaura apenas os
        // dados fictícios desta coleção.
        _data[name] = _copyCollection(seeds[name] ?? {});
        await _persist(name);
      }
    }

    _initialized = true;
  }

  String _storageKey(String collection) => 'app_fsy_local_db_$collection';

  LinkedHashMap<String, Map<String, dynamic>> _copyCollection(
    Map<String, Map<String, dynamic>> source,
  ) {
    final result = LinkedHashMap<String, Map<String, dynamic>>();
    source.forEach((id, data) => result[id] = _deepCopy(data));
    return result;
  }

  Map<String, dynamic> _deepCopy(Map source) {
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(source)) as Map,
    );
  }

  Future<void> _persist(String collection) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey(collection),
      jsonEncode(_data[collection] ?? {}),
    );
  }

  void _notify(String collection) {
    _changes[collection]?.add(null);
  }

  Stream<void> _watch(String collection) {
    _changes.putIfAbsent(
      collection,
      () => StreamController<void>.broadcast(),
    );
    return _changes[collection]!.stream;
  }

  LinkedHashMap<String, Map<String, dynamic>> _collectionData(
    String collection,
  ) {
    if (!_initialized) {
      throw StateError(
        'LocalDatabase.initialize() deve ser chamado antes de acessar os dados.',
      );
    }
    return _data.putIfAbsent(
      collection,
      () => LinkedHashMap<String, Map<String, dynamic>>(),
    );
  }

  LocalCollectionReference collection(String name) {
    _collectionData(name);
    return LocalCollectionReference(this, name);
  }

  String _newId() {
    _idCounter++;
    return 'local_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  Future<LocalDocumentReference> _add(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final id = _newId();
    await _set(collection, id, data, merge: false);
    return LocalDocumentReference(this, collection, id);
  }

  Future<void> _set(
    String collection,
    String id,
    Map<String, dynamic> data, {
    required bool merge,
  }) async {
    final records = _collectionData(collection);
    final next = _deepCopy(data);
    if (merge && records.containsKey(id)) {
      records[id] = {...records[id]!, ...next};
    } else {
      records[id] = next;
    }
    await _persist(collection);
    _notify(collection);
  }

  Future<void> _delete(String collection, String id) async {
    _collectionData(collection).remove(id);
    await _persist(collection);
    _notify(collection);
  }

  LocalDocumentSnapshot _document(String collection, String id) {
    final data = _collectionData(collection)[id];
    return LocalDocumentSnapshot(
      id: id,
      exists: data != null,
      value: data ?? <String, dynamic>{},
    );
  }

  LocalQuerySnapshot _querySnapshot(
    String collection, {
    List<LocalFilter> filters = const [],
    String? orderField,
    bool descending = false,
    int? maxResults,
  }) {
    final records = _collectionData(collection).entries.toList();

    records.removeWhere((entry) {
      for (final filter in filters) {
        if (entry.value[filter.field] != filter.value) return true;
      }
      return false;
    });

    if (orderField != null) {
      records.sort((a, b) {
        final left = a.value[orderField];
        final right = b.value[orderField];
        int result;
        if (left == null && right == null) {
          result = 0;
        } else if (left == null) {
          result = -1;
        } else if (right == null) {
          result = 1;
        } else if (left is num && right is num) {
          result = left.compareTo(right);
        } else {
          result = left.toString().compareTo(right.toString());
        }
        return descending ? -result : result;
      });
    }

    final limited = maxResults == null
        ? records
        : records.take(maxResults).toList();

    return LocalQuerySnapshot(
      limited
          .map(
            (entry) => LocalDocumentSnapshot(
              id: entry.key,
              exists: true,
              value: entry.value,
            ),
          )
          .toList(),
    );
  }
}

class LocalCollectionReference {
  LocalCollectionReference(this._database, this.id);

  final LocalDatabase _database;
  final String id;

  LocalDocumentReference doc(String documentId) {
    return LocalDocumentReference(_database, id, documentId);
  }

  Future<LocalDocumentReference> add(Map<String, dynamic> data) {
    return _database._add(id, data);
  }

  LocalQuery where(String field, {dynamic isEqualTo}) {
    return LocalQuery(
      _database,
      id,
      filters: [LocalFilter(field, isEqualTo)],
    );
  }

  LocalQuery orderBy(String field, {bool descending = false}) {
    return LocalQuery(
      _database,
      id,
      orderField: field,
      descending: descending,
    );
  }

  Stream<LocalQuerySnapshot> snapshots() {
    return LocalQuery(_database, id).snapshots();
  }
}

class LocalQuery {
  LocalQuery(
    this._database,
    this.collection, {
    this.filters = const [],
    this.orderField,
    this.descending = false,
    this.maxResults,
  });

  final LocalDatabase _database;
  final String collection;
  final List<LocalFilter> filters;
  final String? orderField;
  final bool descending;
  final int? maxResults;

  LocalQuery where(String field, {dynamic isEqualTo}) {
    return LocalQuery(
      _database,
      collection,
      filters: [...filters, LocalFilter(field, isEqualTo)],
      orderField: orderField,
      descending: descending,
      maxResults: maxResults,
    );
  }

  LocalQuery orderBy(String field, {bool descending = false}) {
    return LocalQuery(
      _database,
      collection,
      filters: filters,
      orderField: field,
      descending: descending,
      maxResults: maxResults,
    );
  }

  LocalQuery limit(int count) {
    return LocalQuery(
      _database,
      collection,
      filters: filters,
      orderField: orderField,
      descending: descending,
      maxResults: count,
    );
  }

  LocalQuerySnapshot _currentSnapshot() {
    return _database._querySnapshot(
      collection,
      filters: filters,
      orderField: orderField,
      descending: descending,
      maxResults: maxResults,
    );
  }

  Stream<LocalQuerySnapshot> snapshots() async* {
    yield _currentSnapshot();
    yield* _database
        ._watch(collection)
        .map((_) => _currentSnapshot());
  }
}

class LocalDocumentReference {
  LocalDocumentReference(this._database, this.collection, this.id);

  final LocalDatabase _database;
  final String collection;
  final String id;

  Future<LocalDocumentSnapshot> get() async {
    return _database._document(collection, id);
  }

  Future<void> set(Map<String, dynamic> data) {
    return _database._set(collection, id, data, merge: false);
  }

  Future<void> update(Map<String, dynamic> data) async {
    final current = await get();
    if (!current.exists) {
      throw StateError('Registro local não encontrado: $id');
    }
    await _database._set(collection, id, data, merge: true);
  }

  Future<void> delete() {
    return _database._delete(collection, id);
  }
}

class LocalDocumentSnapshot {
  LocalDocumentSnapshot({
    required this.id,
    required this.exists,
    required Map<String, dynamic> value,
  }) : _value = Map<String, dynamic>.from(value);

  final String id;
  final bool exists;
  final Map<String, dynamic> _value;

  Map<String, dynamic> data() => Map<String, dynamic>.from(
        jsonDecode(jsonEncode(_value)) as Map,
      );

  dynamic operator [](String field) {
    final value = _value[field];
    return value == null ? null : jsonDecode(jsonEncode(value));
  }
}

class LocalQuerySnapshot {
  const LocalQuerySnapshot(this.docs);

  final List<LocalDocumentSnapshot> docs;

  int get size => docs.length;
  bool get isEmpty => docs.isEmpty;
}

class LocalFilter {
  const LocalFilter(this.field, this.value);

  final String field;
  final dynamic value;
}

Map<String, Map<String, Map<String, dynamic>>> _seedData() {
  final agora = DateTime.now().toIso8601String();

  return {
    'usuarios': {
      'demo_admin': {
        'nome': 'Administrador FSY',
        'funcao': 'Administrador',
        'usuario': 'admin',
        'companhia': 'Companhia 01',
        'saude': 'Nenhuma',
        'medicamento': '',
        'adjunta': '',
        'qtdJovens': '0',
        'quarto': '',
        'criadoEm': agora,
      },
      'demo_diretor': {
        'nome': 'Diretor de Demonstração',
        'funcao': 'Diretor',
        'usuario': 'diretor',
        'companhia': 'Companhia 01',
        'saude': 'Nenhuma',
        'medicamento': '',
        'criadoEm': agora,
      },
      'demo_coordenador': {
        'nome': 'Coordenador de Demonstração',
        'funcao': 'Coordenador',
        'usuario': 'coordenador',
        'companhia': 'Companhia 01',
        'saude': 'Nenhuma',
        'medicamento': '',
        'criadoEm': agora,
      },
      'demo_assistente': {
        'nome': 'Assistente de Demonstração',
        'funcao': 'Coordenador Assistente',
        'usuario': 'assistente',
        'companhia': 'Companhia 02',
        'saude': 'Nenhuma',
        'medicamento': '',
        'criadoEm': agora,
      },
      'demo_logistica': {
        'nome': 'Equipe de Logística',
        'funcao': 'Logística',
        'usuario': 'logistica',
        'companhia': 'Companhia 01',
        'saude': 'Nenhuma',
        'medicamento': '',
        'criadoEm': agora,
      },
      'demo_consultor': {
        'nome': 'Consultor de Demonstração',
        'funcao': 'Consultor',
        'usuario': 'consultor',
        'companhia': 'Companhia 01',
        'saude': 'Nenhuma',
        'medicamento': '',
        'criadoEm': agora,
      },
    },
    'companhias': {
      'demo_companhia_01': {
        'nome': 'Companhia 01',
        'criadoEm': agora,
        'metas': [
          {'texto': 'Realizar uma atividade em equipe', 'concluido': false},
          {'texto': 'Concluir o estudo em grupo', 'concluido': true},
        ],
      },
      'demo_companhia_02': {
        'nome': 'Companhia 02',
        'criadoEm': agora,
        'metas': [
          {'texto': 'Fortalecer a integração da companhia', 'concluido': false},
        ],
      },
    },
    'jovens': {
      'demo_jovem_01': {
        'nome': 'Lucas de Demonstração',
        'idade': '16',
        'genero': 'Masculino',
        'saude': 'Nenhuma',
        'medicamento': '',
        'companhia': 'Companhia 01',
        'quarto': 'Bloco A - 101',
        'membro': true,
        'consultor': 'Consultor de Demonstração',
        'criadoEm': agora,
      },
      'demo_jovem_02': {
        'nome': 'Mariana de Demonstração',
        'idade': '17',
        'genero': 'Feminino',
        'saude': 'Nenhuma',
        'medicamento': '',
        'companhia': 'Companhia 01',
        'quarto': 'Bloco A - 101',
        'membro': true,
        'consultor': 'Consultor de Demonstração',
        'criadoEm': agora,
      },
      'demo_jovem_03': {
        'nome': 'João de Demonstração',
        'idade': '15',
        'genero': 'Masculino',
        'saude': 'Alergia fictícia para teste',
        'medicamento': '',
        'companhia': 'Companhia 01',
        'quarto': '',
        'membro': false,
        'consultor': 'A Definir',
        'criadoEm': agora,
      },
      'demo_jovem_04': {
        'nome': 'Sofia de Demonstração',
        'idade': '16',
        'genero': 'Feminino',
        'saude': 'Nenhuma',
        'medicamento': '',
        'companhia': 'Companhia 02',
        'quarto': 'Bloco B - 201',
        'membro': true,
        'consultor': 'A Definir',
        'criadoEm': agora,
      },
    },
  };
}
