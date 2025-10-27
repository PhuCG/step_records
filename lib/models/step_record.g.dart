// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyStepRecordCollection on Isar {
  IsarCollection<DailyStepRecord> get dailyStepRecords => this.collection();
}

const DailyStepRecordSchema = CollectionSchema(
  name: r'DailyStepRecord',
  id: 865349736777983272,
  properties: {
    r'date': PropertySchema(id: 0, name: r'date', type: IsarType.dateTime),
    r'lastUpdateTime': PropertySchema(
      id: 1,
      name: r'lastUpdateTime',
      type: IsarType.dateTime,
    ),
    r'steps': PropertySchema(id: 2, name: r'steps', type: IsarType.long),
    r'stepsCount': PropertySchema(
      id: 3,
      name: r'stepsCount',
      type: IsarType.long,
    ),
  },

  estimateSize: _dailyStepRecordEstimateSize,
  serialize: _dailyStepRecordSerialize,
  deserialize: _dailyStepRecordDeserialize,
  deserializeProp: _dailyStepRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _dailyStepRecordGetId,
  getLinks: _dailyStepRecordGetLinks,
  attach: _dailyStepRecordAttach,
  version: '3.3.0-dev.3',
);

int _dailyStepRecordEstimateSize(
  DailyStepRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dailyStepRecordSerialize(
  DailyStepRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeDateTime(offsets[1], object.lastUpdateTime);
  writer.writeLong(offsets[2], object.steps);
  writer.writeLong(offsets[3], object.stepsCount);
}

DailyStepRecord _dailyStepRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyStepRecord();
  object.date = reader.readDateTime(offsets[0]);
  object.id = id;
  object.lastUpdateTime = reader.readDateTimeOrNull(offsets[1]);
  object.steps = reader.readLongOrNull(offsets[2]);
  return object;
}

P _dailyStepRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyStepRecordGetId(DailyStepRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyStepRecordGetLinks(DailyStepRecord object) {
  return [];
}

void _dailyStepRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  DailyStepRecord object,
) {
  object.id = id;
}

extension DailyStepRecordQueryWhereSort
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QWhere> {
  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension DailyStepRecordQueryWhere
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QWhereClause> {
  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause> dateEqualTo(
    DateTime date,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'date', value: [date]),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause>
  dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [date],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'date',
                lower: [],
                upper: [date],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause>
  dateGreaterThan(DateTime date, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [date],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause>
  dateLessThan(DateTime date, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [],
          upper: [date],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'date',
          lower: [lowerDate],
          includeLower: includeLower,
          upper: [upperDate],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyStepRecordQueryFilter
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QFilterCondition> {
  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  lastUpdateTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastUpdateTime'),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  lastUpdateTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastUpdateTime'),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  lastUpdateTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUpdateTime', value: value),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
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

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
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

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  lastUpdateTimeBetween(
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

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'steps'),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'steps'),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'steps', value: value),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'steps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'steps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'steps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stepsCount', value: value),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'stepsCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'stepsCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterFilterCondition>
  stepsCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stepsCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyStepRecordQueryObject
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QFilterCondition> {}

extension DailyStepRecordQueryLinks
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QFilterCondition> {}

extension DailyStepRecordQuerySortBy
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QSortBy> {
  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  sortByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  sortByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy> sortBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  sortByStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.desc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  sortByStepsCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepsCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  sortByStepsCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepsCount', Sort.desc);
    });
  }
}

extension DailyStepRecordQuerySortThenBy
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QSortThenBy> {
  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  thenByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  thenByLastUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdateTime', Sort.desc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy> thenBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  thenByStepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'steps', Sort.desc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  thenByStepsCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepsCount', Sort.asc);
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QAfterSortBy>
  thenByStepsCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepsCount', Sort.desc);
    });
  }
}

extension DailyStepRecordQueryWhereDistinct
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QDistinct> {
  QueryBuilder<DailyStepRecord, DailyStepRecord, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QDistinct>
  distinctByLastUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdateTime');
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QDistinct> distinctBySteps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'steps');
    });
  }

  QueryBuilder<DailyStepRecord, DailyStepRecord, QDistinct>
  distinctByStepsCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepsCount');
    });
  }
}

extension DailyStepRecordQueryProperty
    on QueryBuilder<DailyStepRecord, DailyStepRecord, QQueryProperty> {
  QueryBuilder<DailyStepRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyStepRecord, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyStepRecord, DateTime?, QQueryOperations>
  lastUpdateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdateTime');
    });
  }

  QueryBuilder<DailyStepRecord, int?, QQueryOperations> stepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'steps');
    });
  }

  QueryBuilder<DailyStepRecord, int, QQueryOperations> stepsCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepsCount');
    });
  }
}
