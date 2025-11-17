// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_log_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStepLogEntryCollection on Isar {
  IsarCollection<StepLogEntry> get stepLogEntrys => this.collection();
}

const StepLogEntrySchema = CollectionSchema(
  name: r'StepLogEntry',
  id: -8137316397992394953,
  properties: {
    r'name': PropertySchema(id: 0, name: r'name', type: IsarType.string),
    r'stepNumber': PropertySchema(
      id: 1,
      name: r'stepNumber',
      type: IsarType.long,
    ),
    r'time': PropertySchema(id: 2, name: r'time', type: IsarType.dateTime),
    r'vehicleId': PropertySchema(
      id: 3,
      name: r'vehicleId',
      type: IsarType.string,
    ),
  },

  estimateSize: _stepLogEntryEstimateSize,
  serialize: _stepLogEntrySerialize,
  deserialize: _stepLogEntryDeserialize,
  deserializeProp: _stepLogEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'time': IndexSchema(
      id: -2250472054110640942,
      name: r'time',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'time',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _stepLogEntryGetId,
  getLinks: _stepLogEntryGetLinks,
  attach: _stepLogEntryAttach,
  version: '3.3.0-dev.3',
);

int _stepLogEntryEstimateSize(
  StepLogEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.vehicleId.length * 3;
  return bytesCount;
}

void _stepLogEntrySerialize(
  StepLogEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
  writer.writeLong(offsets[1], object.stepNumber);
  writer.writeDateTime(offsets[2], object.time);
  writer.writeString(offsets[3], object.vehicleId);
}

StepLogEntry _stepLogEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StepLogEntry();
  object.id = id;
  object.name = reader.readString(offsets[0]);
  object.stepNumber = reader.readLong(offsets[1]);
  object.time = reader.readDateTime(offsets[2]);
  object.vehicleId = reader.readString(offsets[3]);
  return object;
}

P _stepLogEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stepLogEntryGetId(StepLogEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stepLogEntryGetLinks(StepLogEntry object) {
  return [];
}

void _stepLogEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  StepLogEntry object,
) {
  object.id = id;
}

extension StepLogEntryQueryWhereSort
    on QueryBuilder<StepLogEntry, StepLogEntry, QWhere> {
  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhere> anyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'time'),
      );
    });
  }
}

extension StepLogEntryQueryWhere
    on QueryBuilder<StepLogEntry, StepLogEntry, QWhereClause> {
  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> timeEqualTo(
    DateTime time,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'time', value: [time]),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> timeNotEqualTo(
    DateTime time,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'time',
                lower: [],
                upper: [time],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'time',
                lower: [time],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'time',
                lower: [time],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'time',
                lower: [],
                upper: [time],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> timeGreaterThan(
    DateTime time, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'time',
          lower: [time],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> timeLessThan(
    DateTime time, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'time',
          lower: [],
          upper: [time],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterWhereClause> timeBetween(
    DateTime lowerTime,
    DateTime upperTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'time',
          lower: [lowerTime],
          includeLower: includeLower,
          upper: [upperTime],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StepLogEntryQueryFilter
    on QueryBuilder<StepLogEntry, StepLogEntry, QFilterCondition> {
  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  stepNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stepNumber', value: value),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  stepNumberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stepNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  stepNumberLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stepNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  stepNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stepNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> timeEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'time', value: value),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  timeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'time',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> timeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'time',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition> timeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'time',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'vehicleId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'vehicleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'vehicleId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'vehicleId', value: ''),
      );
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterFilterCondition>
  vehicleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'vehicleId', value: ''),
      );
    });
  }
}

extension StepLogEntryQueryObject
    on QueryBuilder<StepLogEntry, StepLogEntry, QFilterCondition> {}

extension StepLogEntryQueryLinks
    on QueryBuilder<StepLogEntry, StepLogEntry, QFilterCondition> {}

extension StepLogEntryQuerySortBy
    on QueryBuilder<StepLogEntry, StepLogEntry, QSortBy> {
  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> sortByStepNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepNumber', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy>
  sortByStepNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepNumber', Sort.desc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }
}

extension StepLogEntryQuerySortThenBy
    on QueryBuilder<StepLogEntry, StepLogEntry, QSortThenBy> {
  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenByStepNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepNumber', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy>
  thenByStepNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepNumber', Sort.desc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QAfterSortBy> thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }
}

extension StepLogEntryQueryWhereDistinct
    on QueryBuilder<StepLogEntry, StepLogEntry, QDistinct> {
  QueryBuilder<StepLogEntry, StepLogEntry, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QDistinct> distinctByStepNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepNumber');
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<StepLogEntry, StepLogEntry, QDistinct> distinctByVehicleId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId', caseSensitive: caseSensitive);
    });
  }
}

extension StepLogEntryQueryProperty
    on QueryBuilder<StepLogEntry, StepLogEntry, QQueryProperty> {
  QueryBuilder<StepLogEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StepLogEntry, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<StepLogEntry, int, QQueryOperations> stepNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepNumber');
    });
  }

  QueryBuilder<StepLogEntry, DateTime, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<StepLogEntry, String, QQueryOperations> vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }
}
