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
    r'currentSessionId': PropertySchema(
      id: 0,
      name: r'currentSessionId',
      type: IsarType.string,
    ),
    r'isServiceRunning': PropertySchema(
      id: 1,
      name: r'isServiceRunning',
      type: IsarType.bool,
    ),
    r'lastDateReset': PropertySchema(
      id: 2,
      name: r'lastDateReset',
      type: IsarType.dateTime,
    ),
    r'lastUpdateTime': PropertySchema(
      id: 3,
      name: r'lastUpdateTime',
      type: IsarType.dateTime,
    ),
    r'serviceStartTime': PropertySchema(
      id: 4,
      name: r'serviceStartTime',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _appStateEstimateSize,
  serialize: _appStateSerialize,
  deserialize: _appStateDeserialize,
  deserializeProp: _appStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'currentSessionId': IndexSchema(
      id: -7457123740971763574,
      name: r'currentSessionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'currentSessionId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
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
  bytesCount += 3 + object.currentSessionId.length * 3;
  return bytesCount;
}

void _appStateSerialize(
  AppState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.currentSessionId);
  writer.writeBool(offsets[1], object.isServiceRunning);
  writer.writeDateTime(offsets[2], object.lastDateReset);
  writer.writeDateTime(offsets[3], object.lastUpdateTime);
  writer.writeDateTime(offsets[4], object.serviceStartTime);
}

AppState _appStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppState(
    currentSessionId: reader.readStringOrNull(offsets[0]) ?? '',
    isServiceRunning: reader.readBoolOrNull(offsets[1]) ?? false,
    lastDateReset: reader.readDateTimeOrNull(offsets[2]),
    lastUpdateTime: reader.readDateTimeOrNull(offsets[3]),
    serviceStartTime: reader.readDateTimeOrNull(offsets[4]),
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
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
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

  QueryBuilder<AppState, AppState, QAfterWhereClause> currentSessionIdEqualTo(
    String currentSessionId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'currentSessionId',
          value: [currentSessionId],
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterWhereClause>
  currentSessionIdNotEqualTo(String currentSessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'currentSessionId',
                lower: [],
                upper: [currentSessionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'currentSessionId',
                lower: [currentSessionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'currentSessionId',
                lower: [currentSessionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'currentSessionId',
                lower: [],
                upper: [currentSessionId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension AppStateQueryFilter
    on QueryBuilder<AppState, AppState, QFilterCondition> {
  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentSessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentSessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentSessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentSessionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentSessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentSessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentSessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentSessionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentSessionId', value: ''),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  currentSessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currentSessionId', value: ''),
      );
    });
  }

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

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  lastDateResetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastDateReset'),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  lastDateResetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastDateReset'),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> lastDateResetEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastDateReset', value: value),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  lastDateResetGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastDateReset',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> lastDateResetLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastDateReset',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> lastDateResetBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastDateReset',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  lastUpdateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastUpdateTime'),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  lastUpdateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastUpdateTime'),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> lastUpdateTimeEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUpdateTime', value: value),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  lastUpdateTimeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastUpdateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  lastUpdateTimeLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastUpdateTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition> lastUpdateTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastUpdateTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  serviceStartTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'serviceStartTime'),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  serviceStartTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'serviceStartTime'),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  serviceStartTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serviceStartTime', value: value),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  serviceStartTimeGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serviceStartTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  serviceStartTimeLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serviceStartTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppState, AppState, QAfterFilterCondition>
  serviceStartTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serviceStartTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AppStateQueryObject
    on QueryBuilder<AppState, AppState, QFilterCondition> {}

extension AppStateQueryLinks
    on QueryBuilder<AppState, AppState, QFilterCondition> {}

extension AppStateQuerySortBy on QueryBuilder<AppState, AppState, QSortBy> {
  QueryBuilder<AppState, AppState, QAfterSortBy> sortByCurrentSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSessionId', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByCurrentSessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSessionId', Sort.desc);
    });
  }

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

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByLastDateReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDateReset', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByLastDateResetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDateReset', Sort.desc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByServiceStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceStartTime', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> sortByServiceStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceStartTime', Sort.desc);
    });
  }
}

extension AppStateQuerySortThenBy
    on QueryBuilder<AppState, AppState, QSortThenBy> {
  QueryBuilder<AppState, AppState, QAfterSortBy> thenByCurrentSessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSessionId', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByCurrentSessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSessionId', Sort.desc);
    });
  }

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

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByLastDateReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDateReset', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByLastDateResetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDateReset', Sort.desc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByServiceStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceStartTime', Sort.asc);
    });
  }

  QueryBuilder<AppState, AppState, QAfterSortBy> thenByServiceStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceStartTime', Sort.desc);
    });
  }
}

extension AppStateQueryWhereDistinct
    on QueryBuilder<AppState, AppState, QDistinct> {
  QueryBuilder<AppState, AppState, QDistinct> distinctByCurrentSessionId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'currentSessionId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AppState, AppState, QDistinct> distinctByIsServiceRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isServiceRunning');
    });
  }

  QueryBuilder<AppState, AppState, QDistinct> distinctByLastDateReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDateReset');
    });
  }

  QueryBuilder<AppState, AppState, QDistinct> distinctByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdateTime');
    });
  }

  QueryBuilder<AppState, AppState, QDistinct> distinctByServiceStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceStartTime');
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

  QueryBuilder<AppState, String, QQueryOperations> currentSessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentSessionId');
    });
  }

  QueryBuilder<AppState, bool, QQueryOperations> isServiceRunningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isServiceRunning');
    });
  }

  QueryBuilder<AppState, DateTime?, QQueryOperations> lastDateResetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDateReset');
    });
  }

  QueryBuilder<AppState, DateTime?, QQueryOperations> lastUpdateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdateTime');
    });
  }

  QueryBuilder<AppState, DateTime?, QQueryOperations>
  serviceStartTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceStartTime');
    });
  }
}
