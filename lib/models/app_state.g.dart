// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppStateCollection on Isar {
  IsarCollection<AppState> get appStates => this.collection();
}

const AppStateSchema = CollectionSchema(
  name: r'AppState',
  id: 7189399113359544372,
  properties: {
    r'isServiceRunning': PropertySchema(
      id: 0,
      name: r'isServiceRunning',
      type: IsarType.bool,
    ),
  },

  estimateSize: _appStateEstimateSize,
  serialize: _appStateSerialize,
  deserialize: _appStateDeserialize,
  deserializeProp: _appStateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _appStateGetId,
  getLinks: _appStateGetLinks,
  attach: _appStateAttach,
  version: '3.3.0-dev.3',
);

int _appStateEstimateSize(
  AppState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _appStateSerialize(
  AppState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isServiceRunning);
}

AppState _appStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppState(
    isServiceRunning: reader.readBoolOrNull(offsets[0]) ?? false,
  );
  object.id = id;
  return object;
}

P _appStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appStateGetId(AppState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appStateGetLinks(AppState object) {
  return [];
}

void _appStateAttach(IsarCollection<dynamic> col, Id id, AppState object) {
  object.id = id;
}

extension AppStateQueryWhereSort on QueryBuilder<AppState, AppState, QWhere> {
  QueryBuilder<AppState, AppState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppStateQueryWhere on QueryBuilder<AppState, AppState, QWhereClause> {
  QueryBuilder<AppState, AppState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AppState, AppState, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppState, AppState, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AppStateQueryFilter
    on QueryBuilder<AppState, AppState, QFilterCondition> {
  QueryBuilder<AppState, AppState, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  isServiceRunningEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isServiceRunning', value: value),
      );
    });
  }
}

extension AppStateQueryObject
    on QueryBuilder<AppState, AppState, QFilterCondition> {}

extension AppStateQueryLinks
    on QueryBuilder<AppState, AppState, QFilterCondition> {}

extension AppStateQuerySortBy on QueryBuilder<AppState, AppState, QSortBy> {
  QueryBuilder<AppState, AppState, QAfterSortBy> sortByIsServiceRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isServiceRunning', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByIsServiceRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isServiceRunning', Sort.desc);
    });
  }
}

extension AppStateQuerySortThenBy
    on QueryBuilder<AppState, AppState, QSortThenBy> {
  QueryBuilder<AppState, AppState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByIsServiceRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isServiceRunning', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByIsServiceRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isServiceRunning', Sort.desc);
    });
  }
}

extension AppStateQueryWhereDistinct
    on QueryBuilder<AppState, AppState, QDistinct> {
  QueryBuilder<AppState, AppState, QDistinct> distinctByIsServiceRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isServiceRunning');
    });
  }
}

extension AppStateQueryProperty
    on QueryBuilder<AppState, AppState, QQueryProperty> {
  QueryBuilder<AppState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppState, bool, QQueryOperations> isServiceRunningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isServiceRunning');
    });
  }
}
