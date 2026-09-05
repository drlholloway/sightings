// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
      'serial', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hardwareRevMeta =
      const VerificationMeta('hardwareRev');
  @override
  late final GeneratedColumn<String> hardwareRev = GeneratedColumn<String>(
      'hardware_rev', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firmwareRevMeta =
      const VerificationMeta('firmwareRev');
  @override
  late final GeneratedColumn<String> firmwareRev = GeneratedColumn<String>(
      'firmware_rev', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rMt2Meta = const VerificationMeta('rMt2');
  @override
  late final GeneratedColumn<double> rMt2 = GeneratedColumn<double>(
      'r_mt2', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calR1k0Meta =
      const VerificationMeta('calR1k0');
  @override
  late final GeneratedColumn<double> calR1k0 = GeneratedColumn<double>(
      'cal_r1k0', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calR8k2Meta =
      const VerificationMeta('calR8k2');
  @override
  late final GeneratedColumn<double> calR8k2 = GeneratedColumn<double>(
      'cal_r8k2', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calR68kMeta =
      const VerificationMeta('calR68k');
  @override
  late final GeneratedColumn<double> calR68k = GeneratedColumn<double>(
      'cal_r68k', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _calR470kMeta =
      const VerificationMeta('calR470k');
  @override
  late final GeneratedColumn<double> calR470k = GeneratedColumn<double>(
      'cal_r470k', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _firstSeenMsMeta =
      const VerificationMeta('firstSeenMs');
  @override
  late final GeneratedColumn<int> firstSeenMs = GeneratedColumn<int>(
      'first_seen_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastSeenMsMeta =
      const VerificationMeta('lastSeenMs');
  @override
  late final GeneratedColumn<int> lastSeenMs = GeneratedColumn<int>(
      'last_seen_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        serial,
        productName,
        hardwareRev,
        firmwareRev,
        rMt2,
        calR1k0,
        calR8k2,
        calR68k,
        calR470k,
        firstSeenMs,
        lastSeenMs
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('serial')) {
      context.handle(_serialMeta,
          serial.isAcceptableOrUnknown(data['serial']!, _serialMeta));
    } else if (isInserting) {
      context.missing(_serialMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    }
    if (data.containsKey('hardware_rev')) {
      context.handle(
          _hardwareRevMeta,
          hardwareRev.isAcceptableOrUnknown(
              data['hardware_rev']!, _hardwareRevMeta));
    }
    if (data.containsKey('firmware_rev')) {
      context.handle(
          _firmwareRevMeta,
          firmwareRev.isAcceptableOrUnknown(
              data['firmware_rev']!, _firmwareRevMeta));
    }
    if (data.containsKey('r_mt2')) {
      context.handle(
          _rMt2Meta, rMt2.isAcceptableOrUnknown(data['r_mt2']!, _rMt2Meta));
    }
    if (data.containsKey('cal_r1k0')) {
      context.handle(_calR1k0Meta,
          calR1k0.isAcceptableOrUnknown(data['cal_r1k0']!, _calR1k0Meta));
    }
    if (data.containsKey('cal_r8k2')) {
      context.handle(_calR8k2Meta,
          calR8k2.isAcceptableOrUnknown(data['cal_r8k2']!, _calR8k2Meta));
    }
    if (data.containsKey('cal_r68k')) {
      context.handle(_calR68kMeta,
          calR68k.isAcceptableOrUnknown(data['cal_r68k']!, _calR68kMeta));
    }
    if (data.containsKey('cal_r470k')) {
      context.handle(_calR470kMeta,
          calR470k.isAcceptableOrUnknown(data['cal_r470k']!, _calR470kMeta));
    }
    if (data.containsKey('first_seen_ms')) {
      context.handle(
          _firstSeenMsMeta,
          firstSeenMs.isAcceptableOrUnknown(
              data['first_seen_ms']!, _firstSeenMsMeta));
    } else if (isInserting) {
      context.missing(_firstSeenMsMeta);
    }
    if (data.containsKey('last_seen_ms')) {
      context.handle(
          _lastSeenMsMeta,
          lastSeenMs.isAcceptableOrUnknown(
              data['last_seen_ms']!, _lastSeenMsMeta));
    } else if (isInserting) {
      context.missing(_lastSeenMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serial};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      serial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serial'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name']),
      hardwareRev: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hardware_rev']),
      firmwareRev: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firmware_rev']),
      rMt2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}r_mt2']),
      calR1k0: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cal_r1k0']),
      calR8k2: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cal_r8k2']),
      calR68k: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cal_r68k']),
      calR470k: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cal_r470k']),
      firstSeenMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}first_seen_ms'])!,
      lastSeenMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_seen_ms'])!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String serial;
  final String? productName;
  final String? hardwareRev;
  final String? firmwareRev;
  final double? rMt2;
  final double? calR1k0;
  final double? calR8k2;
  final double? calR68k;
  final double? calR470k;
  final int firstSeenMs;
  final int lastSeenMs;
  const Device(
      {required this.serial,
      this.productName,
      this.hardwareRev,
      this.firmwareRev,
      this.rMt2,
      this.calR1k0,
      this.calR8k2,
      this.calR68k,
      this.calR470k,
      required this.firstSeenMs,
      required this.lastSeenMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['serial'] = Variable<String>(serial);
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    if (!nullToAbsent || hardwareRev != null) {
      map['hardware_rev'] = Variable<String>(hardwareRev);
    }
    if (!nullToAbsent || firmwareRev != null) {
      map['firmware_rev'] = Variable<String>(firmwareRev);
    }
    if (!nullToAbsent || rMt2 != null) {
      map['r_mt2'] = Variable<double>(rMt2);
    }
    if (!nullToAbsent || calR1k0 != null) {
      map['cal_r1k0'] = Variable<double>(calR1k0);
    }
    if (!nullToAbsent || calR8k2 != null) {
      map['cal_r8k2'] = Variable<double>(calR8k2);
    }
    if (!nullToAbsent || calR68k != null) {
      map['cal_r68k'] = Variable<double>(calR68k);
    }
    if (!nullToAbsent || calR470k != null) {
      map['cal_r470k'] = Variable<double>(calR470k);
    }
    map['first_seen_ms'] = Variable<int>(firstSeenMs);
    map['last_seen_ms'] = Variable<int>(lastSeenMs);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      serial: Value(serial),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      hardwareRev: hardwareRev == null && nullToAbsent
          ? const Value.absent()
          : Value(hardwareRev),
      firmwareRev: firmwareRev == null && nullToAbsent
          ? const Value.absent()
          : Value(firmwareRev),
      rMt2: rMt2 == null && nullToAbsent ? const Value.absent() : Value(rMt2),
      calR1k0: calR1k0 == null && nullToAbsent
          ? const Value.absent()
          : Value(calR1k0),
      calR8k2: calR8k2 == null && nullToAbsent
          ? const Value.absent()
          : Value(calR8k2),
      calR68k: calR68k == null && nullToAbsent
          ? const Value.absent()
          : Value(calR68k),
      calR470k: calR470k == null && nullToAbsent
          ? const Value.absent()
          : Value(calR470k),
      firstSeenMs: Value(firstSeenMs),
      lastSeenMs: Value(lastSeenMs),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      serial: serializer.fromJson<String>(json['serial']),
      productName: serializer.fromJson<String?>(json['productName']),
      hardwareRev: serializer.fromJson<String?>(json['hardwareRev']),
      firmwareRev: serializer.fromJson<String?>(json['firmwareRev']),
      rMt2: serializer.fromJson<double?>(json['rMt2']),
      calR1k0: serializer.fromJson<double?>(json['calR1k0']),
      calR8k2: serializer.fromJson<double?>(json['calR8k2']),
      calR68k: serializer.fromJson<double?>(json['calR68k']),
      calR470k: serializer.fromJson<double?>(json['calR470k']),
      firstSeenMs: serializer.fromJson<int>(json['firstSeenMs']),
      lastSeenMs: serializer.fromJson<int>(json['lastSeenMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serial': serializer.toJson<String>(serial),
      'productName': serializer.toJson<String?>(productName),
      'hardwareRev': serializer.toJson<String?>(hardwareRev),
      'firmwareRev': serializer.toJson<String?>(firmwareRev),
      'rMt2': serializer.toJson<double?>(rMt2),
      'calR1k0': serializer.toJson<double?>(calR1k0),
      'calR8k2': serializer.toJson<double?>(calR8k2),
      'calR68k': serializer.toJson<double?>(calR68k),
      'calR470k': serializer.toJson<double?>(calR470k),
      'firstSeenMs': serializer.toJson<int>(firstSeenMs),
      'lastSeenMs': serializer.toJson<int>(lastSeenMs),
    };
  }

  Device copyWith(
          {String? serial,
          Value<String?> productName = const Value.absent(),
          Value<String?> hardwareRev = const Value.absent(),
          Value<String?> firmwareRev = const Value.absent(),
          Value<double?> rMt2 = const Value.absent(),
          Value<double?> calR1k0 = const Value.absent(),
          Value<double?> calR8k2 = const Value.absent(),
          Value<double?> calR68k = const Value.absent(),
          Value<double?> calR470k = const Value.absent(),
          int? firstSeenMs,
          int? lastSeenMs}) =>
      Device(
        serial: serial ?? this.serial,
        productName: productName.present ? productName.value : this.productName,
        hardwareRev: hardwareRev.present ? hardwareRev.value : this.hardwareRev,
        firmwareRev: firmwareRev.present ? firmwareRev.value : this.firmwareRev,
        rMt2: rMt2.present ? rMt2.value : this.rMt2,
        calR1k0: calR1k0.present ? calR1k0.value : this.calR1k0,
        calR8k2: calR8k2.present ? calR8k2.value : this.calR8k2,
        calR68k: calR68k.present ? calR68k.value : this.calR68k,
        calR470k: calR470k.present ? calR470k.value : this.calR470k,
        firstSeenMs: firstSeenMs ?? this.firstSeenMs,
        lastSeenMs: lastSeenMs ?? this.lastSeenMs,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      serial: data.serial.present ? data.serial.value : this.serial,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      hardwareRev:
          data.hardwareRev.present ? data.hardwareRev.value : this.hardwareRev,
      firmwareRev:
          data.firmwareRev.present ? data.firmwareRev.value : this.firmwareRev,
      rMt2: data.rMt2.present ? data.rMt2.value : this.rMt2,
      calR1k0: data.calR1k0.present ? data.calR1k0.value : this.calR1k0,
      calR8k2: data.calR8k2.present ? data.calR8k2.value : this.calR8k2,
      calR68k: data.calR68k.present ? data.calR68k.value : this.calR68k,
      calR470k: data.calR470k.present ? data.calR470k.value : this.calR470k,
      firstSeenMs:
          data.firstSeenMs.present ? data.firstSeenMs.value : this.firstSeenMs,
      lastSeenMs:
          data.lastSeenMs.present ? data.lastSeenMs.value : this.lastSeenMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('serial: $serial, ')
          ..write('productName: $productName, ')
          ..write('hardwareRev: $hardwareRev, ')
          ..write('firmwareRev: $firmwareRev, ')
          ..write('rMt2: $rMt2, ')
          ..write('calR1k0: $calR1k0, ')
          ..write('calR8k2: $calR8k2, ')
          ..write('calR68k: $calR68k, ')
          ..write('calR470k: $calR470k, ')
          ..write('firstSeenMs: $firstSeenMs, ')
          ..write('lastSeenMs: $lastSeenMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serial, productName, hardwareRev, firmwareRev,
      rMt2, calR1k0, calR8k2, calR68k, calR470k, firstSeenMs, lastSeenMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.serial == this.serial &&
          other.productName == this.productName &&
          other.hardwareRev == this.hardwareRev &&
          other.firmwareRev == this.firmwareRev &&
          other.rMt2 == this.rMt2 &&
          other.calR1k0 == this.calR1k0 &&
          other.calR8k2 == this.calR8k2 &&
          other.calR68k == this.calR68k &&
          other.calR470k == this.calR470k &&
          other.firstSeenMs == this.firstSeenMs &&
          other.lastSeenMs == this.lastSeenMs);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> serial;
  final Value<String?> productName;
  final Value<String?> hardwareRev;
  final Value<String?> firmwareRev;
  final Value<double?> rMt2;
  final Value<double?> calR1k0;
  final Value<double?> calR8k2;
  final Value<double?> calR68k;
  final Value<double?> calR470k;
  final Value<int> firstSeenMs;
  final Value<int> lastSeenMs;
  final Value<int> rowid;
  const DevicesCompanion({
    this.serial = const Value.absent(),
    this.productName = const Value.absent(),
    this.hardwareRev = const Value.absent(),
    this.firmwareRev = const Value.absent(),
    this.rMt2 = const Value.absent(),
    this.calR1k0 = const Value.absent(),
    this.calR8k2 = const Value.absent(),
    this.calR68k = const Value.absent(),
    this.calR470k = const Value.absent(),
    this.firstSeenMs = const Value.absent(),
    this.lastSeenMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String serial,
    this.productName = const Value.absent(),
    this.hardwareRev = const Value.absent(),
    this.firmwareRev = const Value.absent(),
    this.rMt2 = const Value.absent(),
    this.calR1k0 = const Value.absent(),
    this.calR8k2 = const Value.absent(),
    this.calR68k = const Value.absent(),
    this.calR470k = const Value.absent(),
    required int firstSeenMs,
    required int lastSeenMs,
    this.rowid = const Value.absent(),
  })  : serial = Value(serial),
        firstSeenMs = Value(firstSeenMs),
        lastSeenMs = Value(lastSeenMs);
  static Insertable<Device> custom({
    Expression<String>? serial,
    Expression<String>? productName,
    Expression<String>? hardwareRev,
    Expression<String>? firmwareRev,
    Expression<double>? rMt2,
    Expression<double>? calR1k0,
    Expression<double>? calR8k2,
    Expression<double>? calR68k,
    Expression<double>? calR470k,
    Expression<int>? firstSeenMs,
    Expression<int>? lastSeenMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serial != null) 'serial': serial,
      if (productName != null) 'product_name': productName,
      if (hardwareRev != null) 'hardware_rev': hardwareRev,
      if (firmwareRev != null) 'firmware_rev': firmwareRev,
      if (rMt2 != null) 'r_mt2': rMt2,
      if (calR1k0 != null) 'cal_r1k0': calR1k0,
      if (calR8k2 != null) 'cal_r8k2': calR8k2,
      if (calR68k != null) 'cal_r68k': calR68k,
      if (calR470k != null) 'cal_r470k': calR470k,
      if (firstSeenMs != null) 'first_seen_ms': firstSeenMs,
      if (lastSeenMs != null) 'last_seen_ms': lastSeenMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? serial,
      Value<String?>? productName,
      Value<String?>? hardwareRev,
      Value<String?>? firmwareRev,
      Value<double?>? rMt2,
      Value<double?>? calR1k0,
      Value<double?>? calR8k2,
      Value<double?>? calR68k,
      Value<double?>? calR470k,
      Value<int>? firstSeenMs,
      Value<int>? lastSeenMs,
      Value<int>? rowid}) {
    return DevicesCompanion(
      serial: serial ?? this.serial,
      productName: productName ?? this.productName,
      hardwareRev: hardwareRev ?? this.hardwareRev,
      firmwareRev: firmwareRev ?? this.firmwareRev,
      rMt2: rMt2 ?? this.rMt2,
      calR1k0: calR1k0 ?? this.calR1k0,
      calR8k2: calR8k2 ?? this.calR8k2,
      calR68k: calR68k ?? this.calR68k,
      calR470k: calR470k ?? this.calR470k,
      firstSeenMs: firstSeenMs ?? this.firstSeenMs,
      lastSeenMs: lastSeenMs ?? this.lastSeenMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serial.present) {
      map['serial'] = Variable<String>(serial.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (hardwareRev.present) {
      map['hardware_rev'] = Variable<String>(hardwareRev.value);
    }
    if (firmwareRev.present) {
      map['firmware_rev'] = Variable<String>(firmwareRev.value);
    }
    if (rMt2.present) {
      map['r_mt2'] = Variable<double>(rMt2.value);
    }
    if (calR1k0.present) {
      map['cal_r1k0'] = Variable<double>(calR1k0.value);
    }
    if (calR8k2.present) {
      map['cal_r8k2'] = Variable<double>(calR8k2.value);
    }
    if (calR68k.present) {
      map['cal_r68k'] = Variable<double>(calR68k.value);
    }
    if (calR470k.present) {
      map['cal_r470k'] = Variable<double>(calR470k.value);
    }
    if (firstSeenMs.present) {
      map['first_seen_ms'] = Variable<int>(firstSeenMs.value);
    }
    if (lastSeenMs.present) {
      map['last_seen_ms'] = Variable<int>(lastSeenMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('serial: $serial, ')
          ..write('productName: $productName, ')
          ..write('hardwareRev: $hardwareRev, ')
          ..write('firmwareRev: $firmwareRev, ')
          ..write('rMt2: $rMt2, ')
          ..write('calR1k0: $calR1k0, ')
          ..write('calR8k2: $calR8k2, ')
          ..write('calR68k: $calR68k, ')
          ..write('calR470k: $calR470k, ')
          ..write('firstSeenMs: $firstSeenMs, ')
          ..write('lastSeenMs: $lastSeenMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceSerialMeta =
      const VerificationMeta('deviceSerial');
  @override
  late final GeneratedColumn<String> deviceSerial = GeneratedColumn<String>(
      'device_serial', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES devices (serial)'));
  static const VerificationMeta _startedAtMsMeta =
      const VerificationMeta('startedAtMs');
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
      'started_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMsMeta =
      const VerificationMeta('endedAtMs');
  @override
  late final GeneratedColumn<int> endedAtMs = GeneratedColumn<int>(
      'ended_at_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appVersionMeta =
      const VerificationMeta('appVersion');
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
      'app_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, deviceSerial, startedAtMs, endedAtMs, platform, appVersion, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_serial')) {
      context.handle(
          _deviceSerialMeta,
          deviceSerial.isAcceptableOrUnknown(
              data['device_serial']!, _deviceSerialMeta));
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
          _startedAtMsMeta,
          startedAtMs.isAcceptableOrUnknown(
              data['started_at_ms']!, _startedAtMsMeta));
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('ended_at_ms')) {
      context.handle(
          _endedAtMsMeta,
          endedAtMs.isAcceptableOrUnknown(
              data['ended_at_ms']!, _endedAtMsMeta));
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
          _appVersionMeta,
          appVersion.isAcceptableOrUnknown(
              data['app_version']!, _appVersionMeta));
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceSerial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_serial']),
      startedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at_ms'])!,
      endedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ended_at_ms']),
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      appVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_version'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String? deviceSerial;
  final int startedAtMs;
  final int? endedAtMs;
  final String platform;
  final String appVersion;
  final String? notes;
  const Session(
      {required this.id,
      this.deviceSerial,
      required this.startedAtMs,
      this.endedAtMs,
      required this.platform,
      required this.appVersion,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deviceSerial != null) {
      map['device_serial'] = Variable<String>(deviceSerial);
    }
    map['started_at_ms'] = Variable<int>(startedAtMs);
    if (!nullToAbsent || endedAtMs != null) {
      map['ended_at_ms'] = Variable<int>(endedAtMs);
    }
    map['platform'] = Variable<String>(platform);
    map['app_version'] = Variable<String>(appVersion);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      deviceSerial: deviceSerial == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceSerial),
      startedAtMs: Value(startedAtMs),
      endedAtMs: endedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtMs),
      platform: Value(platform),
      appVersion: Value(appVersion),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      deviceSerial: serializer.fromJson<String?>(json['deviceSerial']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      endedAtMs: serializer.fromJson<int?>(json['endedAtMs']),
      platform: serializer.fromJson<String>(json['platform']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceSerial': serializer.toJson<String?>(deviceSerial),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'endedAtMs': serializer.toJson<int?>(endedAtMs),
      'platform': serializer.toJson<String>(platform),
      'appVersion': serializer.toJson<String>(appVersion),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Session copyWith(
          {int? id,
          Value<String?> deviceSerial = const Value.absent(),
          int? startedAtMs,
          Value<int?> endedAtMs = const Value.absent(),
          String? platform,
          String? appVersion,
          Value<String?> notes = const Value.absent()}) =>
      Session(
        id: id ?? this.id,
        deviceSerial:
            deviceSerial.present ? deviceSerial.value : this.deviceSerial,
        startedAtMs: startedAtMs ?? this.startedAtMs,
        endedAtMs: endedAtMs.present ? endedAtMs.value : this.endedAtMs,
        platform: platform ?? this.platform,
        appVersion: appVersion ?? this.appVersion,
        notes: notes.present ? notes.value : this.notes,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      deviceSerial: data.deviceSerial.present
          ? data.deviceSerial.value
          : this.deviceSerial,
      startedAtMs:
          data.startedAtMs.present ? data.startedAtMs.value : this.startedAtMs,
      endedAtMs: data.endedAtMs.present ? data.endedAtMs.value : this.endedAtMs,
      platform: data.platform.present ? data.platform.value : this.platform,
      appVersion:
          data.appVersion.present ? data.appVersion.value : this.appVersion,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('deviceSerial: $deviceSerial, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, deviceSerial, startedAtMs, endedAtMs, platform, appVersion, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.deviceSerial == this.deviceSerial &&
          other.startedAtMs == this.startedAtMs &&
          other.endedAtMs == this.endedAtMs &&
          other.platform == this.platform &&
          other.appVersion == this.appVersion &&
          other.notes == this.notes);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String?> deviceSerial;
  final Value<int> startedAtMs;
  final Value<int?> endedAtMs;
  final Value<String> platform;
  final Value<String> appVersion;
  final Value<String?> notes;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.deviceSerial = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.endedAtMs = const Value.absent(),
    this.platform = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    this.deviceSerial = const Value.absent(),
    required int startedAtMs,
    this.endedAtMs = const Value.absent(),
    required String platform,
    required String appVersion,
    this.notes = const Value.absent(),
  })  : startedAtMs = Value(startedAtMs),
        platform = Value(platform),
        appVersion = Value(appVersion);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? deviceSerial,
    Expression<int>? startedAtMs,
    Expression<int>? endedAtMs,
    Expression<String>? platform,
    Expression<String>? appVersion,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceSerial != null) 'device_serial': deviceSerial,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (endedAtMs != null) 'ended_at_ms': endedAtMs,
      if (platform != null) 'platform': platform,
      if (appVersion != null) 'app_version': appVersion,
      if (notes != null) 'notes': notes,
    });
  }

  SessionsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? deviceSerial,
      Value<int>? startedAtMs,
      Value<int?>? endedAtMs,
      Value<String>? platform,
      Value<String>? appVersion,
      Value<String?>? notes}) {
    return SessionsCompanion(
      id: id ?? this.id,
      deviceSerial: deviceSerial ?? this.deviceSerial,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      endedAtMs: endedAtMs ?? this.endedAtMs,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceSerial.present) {
      map['device_serial'] = Variable<String>(deviceSerial.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (endedAtMs.present) {
      map['ended_at_ms'] = Variable<int>(endedAtMs.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('deviceSerial: $deviceSerial, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ReadingsTable extends Readings
    with TableInfo<$ReadingsTable, ReadingEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _takenAtMsMeta =
      const VerificationMeta('takenAtMs');
  @override
  late final GeneratedColumn<int> takenAtMs = GeneratedColumn<int>(
      'taken_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<int> config = GeneratedColumn<int>(
      'config', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _flagsMeta = const VerificationMeta('flags');
  @override
  late final GeneratedColumn<int> flags = GeneratedColumn<int>(
      'flags', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rawFrameMeta =
      const VerificationMeta('rawFrame');
  @override
  late final GeneratedColumn<Uint8List> rawFrame = GeneratedColumn<Uint8List>(
      'raw_frame', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _decoderVersionMeta =
      const VerificationMeta('decoderVersion');
  @override
  late final GeneratedColumn<int> decoderVersion = GeneratedColumn<int>(
      'decoder_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _battVMeta = const VerificationMeta('battV');
  @override
  late final GeneratedColumn<double> battV = GeneratedColumn<double>(
      'batt_v', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _v12VMeta = const VerificationMeta('v12V');
  @override
  late final GeneratedColumn<double> v12V = GeneratedColumn<double>(
      'v12_v', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _vrefVMeta = const VerificationMeta('vrefV');
  @override
  late final GeneratedColumn<double> vrefV = GeneratedColumn<double>(
      'vref_v', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        takenAtMs,
        source,
        type,
        config,
        flags,
        rawFrame,
        decoderVersion,
        battV,
        v12V,
        vrefV
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readings';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('taken_at_ms')) {
      context.handle(
          _takenAtMsMeta,
          takenAtMs.isAcceptableOrUnknown(
              data['taken_at_ms']!, _takenAtMsMeta));
    } else if (isInserting) {
      context.missing(_takenAtMsMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('config')) {
      context.handle(_configMeta,
          config.isAcceptableOrUnknown(data['config']!, _configMeta));
    } else if (isInserting) {
      context.missing(_configMeta);
    }
    if (data.containsKey('flags')) {
      context.handle(
          _flagsMeta, flags.isAcceptableOrUnknown(data['flags']!, _flagsMeta));
    } else if (isInserting) {
      context.missing(_flagsMeta);
    }
    if (data.containsKey('raw_frame')) {
      context.handle(_rawFrameMeta,
          rawFrame.isAcceptableOrUnknown(data['raw_frame']!, _rawFrameMeta));
    } else if (isInserting) {
      context.missing(_rawFrameMeta);
    }
    if (data.containsKey('decoder_version')) {
      context.handle(
          _decoderVersionMeta,
          decoderVersion.isAcceptableOrUnknown(
              data['decoder_version']!, _decoderVersionMeta));
    } else if (isInserting) {
      context.missing(_decoderVersionMeta);
    }
    if (data.containsKey('batt_v')) {
      context.handle(
          _battVMeta, battV.isAcceptableOrUnknown(data['batt_v']!, _battVMeta));
    }
    if (data.containsKey('v12_v')) {
      context.handle(
          _v12VMeta, v12V.isAcceptableOrUnknown(data['v12_v']!, _v12VMeta));
    }
    if (data.containsKey('vref_v')) {
      context.handle(
          _vrefVMeta, vrefV.isAcceptableOrUnknown(data['vref_v']!, _vrefVMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      takenAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}taken_at_ms'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      config: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}config'])!,
      flags: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flags'])!,
      rawFrame: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}raw_frame'])!,
      decoderVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}decoder_version'])!,
      battV: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}batt_v']),
      v12V: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}v12_v']),
      vrefV: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vref_v']),
    );
  }

  @override
  $ReadingsTable createAlias(String alias) {
    return $ReadingsTable(attachedDatabase, alias);
  }
}

class ReadingEntity extends DataClass implements Insertable<ReadingEntity> {
  final int id;
  final int sessionId;
  final int takenAtMs;
  final String source;
  final int type;
  final int config;
  final int flags;
  final Uint8List rawFrame;
  final int decoderVersion;
  final double? battV;
  final double? v12V;
  final double? vrefV;
  const ReadingEntity(
      {required this.id,
      required this.sessionId,
      required this.takenAtMs,
      required this.source,
      required this.type,
      required this.config,
      required this.flags,
      required this.rawFrame,
      required this.decoderVersion,
      this.battV,
      this.v12V,
      this.vrefV});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['taken_at_ms'] = Variable<int>(takenAtMs);
    map['source'] = Variable<String>(source);
    map['type'] = Variable<int>(type);
    map['config'] = Variable<int>(config);
    map['flags'] = Variable<int>(flags);
    map['raw_frame'] = Variable<Uint8List>(rawFrame);
    map['decoder_version'] = Variable<int>(decoderVersion);
    if (!nullToAbsent || battV != null) {
      map['batt_v'] = Variable<double>(battV);
    }
    if (!nullToAbsent || v12V != null) {
      map['v12_v'] = Variable<double>(v12V);
    }
    if (!nullToAbsent || vrefV != null) {
      map['vref_v'] = Variable<double>(vrefV);
    }
    return map;
  }

  ReadingsCompanion toCompanion(bool nullToAbsent) {
    return ReadingsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      takenAtMs: Value(takenAtMs),
      source: Value(source),
      type: Value(type),
      config: Value(config),
      flags: Value(flags),
      rawFrame: Value(rawFrame),
      decoderVersion: Value(decoderVersion),
      battV:
          battV == null && nullToAbsent ? const Value.absent() : Value(battV),
      v12V: v12V == null && nullToAbsent ? const Value.absent() : Value(v12V),
      vrefV:
          vrefV == null && nullToAbsent ? const Value.absent() : Value(vrefV),
    );
  }

  factory ReadingEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingEntity(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      takenAtMs: serializer.fromJson<int>(json['takenAtMs']),
      source: serializer.fromJson<String>(json['source']),
      type: serializer.fromJson<int>(json['type']),
      config: serializer.fromJson<int>(json['config']),
      flags: serializer.fromJson<int>(json['flags']),
      rawFrame: serializer.fromJson<Uint8List>(json['rawFrame']),
      decoderVersion: serializer.fromJson<int>(json['decoderVersion']),
      battV: serializer.fromJson<double?>(json['battV']),
      v12V: serializer.fromJson<double?>(json['v12V']),
      vrefV: serializer.fromJson<double?>(json['vrefV']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'takenAtMs': serializer.toJson<int>(takenAtMs),
      'source': serializer.toJson<String>(source),
      'type': serializer.toJson<int>(type),
      'config': serializer.toJson<int>(config),
      'flags': serializer.toJson<int>(flags),
      'rawFrame': serializer.toJson<Uint8List>(rawFrame),
      'decoderVersion': serializer.toJson<int>(decoderVersion),
      'battV': serializer.toJson<double?>(battV),
      'v12V': serializer.toJson<double?>(v12V),
      'vrefV': serializer.toJson<double?>(vrefV),
    };
  }

  ReadingEntity copyWith(
          {int? id,
          int? sessionId,
          int? takenAtMs,
          String? source,
          int? type,
          int? config,
          int? flags,
          Uint8List? rawFrame,
          int? decoderVersion,
          Value<double?> battV = const Value.absent(),
          Value<double?> v12V = const Value.absent(),
          Value<double?> vrefV = const Value.absent()}) =>
      ReadingEntity(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        takenAtMs: takenAtMs ?? this.takenAtMs,
        source: source ?? this.source,
        type: type ?? this.type,
        config: config ?? this.config,
        flags: flags ?? this.flags,
        rawFrame: rawFrame ?? this.rawFrame,
        decoderVersion: decoderVersion ?? this.decoderVersion,
        battV: battV.present ? battV.value : this.battV,
        v12V: v12V.present ? v12V.value : this.v12V,
        vrefV: vrefV.present ? vrefV.value : this.vrefV,
      );
  ReadingEntity copyWithCompanion(ReadingsCompanion data) {
    return ReadingEntity(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      takenAtMs: data.takenAtMs.present ? data.takenAtMs.value : this.takenAtMs,
      source: data.source.present ? data.source.value : this.source,
      type: data.type.present ? data.type.value : this.type,
      config: data.config.present ? data.config.value : this.config,
      flags: data.flags.present ? data.flags.value : this.flags,
      rawFrame: data.rawFrame.present ? data.rawFrame.value : this.rawFrame,
      decoderVersion: data.decoderVersion.present
          ? data.decoderVersion.value
          : this.decoderVersion,
      battV: data.battV.present ? data.battV.value : this.battV,
      v12V: data.v12V.present ? data.v12V.value : this.v12V,
      vrefV: data.vrefV.present ? data.vrefV.value : this.vrefV,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingEntity(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('takenAtMs: $takenAtMs, ')
          ..write('source: $source, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('flags: $flags, ')
          ..write('rawFrame: $rawFrame, ')
          ..write('decoderVersion: $decoderVersion, ')
          ..write('battV: $battV, ')
          ..write('v12V: $v12V, ')
          ..write('vrefV: $vrefV')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      takenAtMs,
      source,
      type,
      config,
      flags,
      $driftBlobEquality.hash(rawFrame),
      decoderVersion,
      battV,
      v12V,
      vrefV);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingEntity &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.takenAtMs == this.takenAtMs &&
          other.source == this.source &&
          other.type == this.type &&
          other.config == this.config &&
          other.flags == this.flags &&
          $driftBlobEquality.equals(other.rawFrame, this.rawFrame) &&
          other.decoderVersion == this.decoderVersion &&
          other.battV == this.battV &&
          other.v12V == this.v12V &&
          other.vrefV == this.vrefV);
}

class ReadingsCompanion extends UpdateCompanion<ReadingEntity> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> takenAtMs;
  final Value<String> source;
  final Value<int> type;
  final Value<int> config;
  final Value<int> flags;
  final Value<Uint8List> rawFrame;
  final Value<int> decoderVersion;
  final Value<double?> battV;
  final Value<double?> v12V;
  final Value<double?> vrefV;
  const ReadingsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.takenAtMs = const Value.absent(),
    this.source = const Value.absent(),
    this.type = const Value.absent(),
    this.config = const Value.absent(),
    this.flags = const Value.absent(),
    this.rawFrame = const Value.absent(),
    this.decoderVersion = const Value.absent(),
    this.battV = const Value.absent(),
    this.v12V = const Value.absent(),
    this.vrefV = const Value.absent(),
  });
  ReadingsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int takenAtMs,
    required String source,
    required int type,
    required int config,
    required int flags,
    required Uint8List rawFrame,
    required int decoderVersion,
    this.battV = const Value.absent(),
    this.v12V = const Value.absent(),
    this.vrefV = const Value.absent(),
  })  : sessionId = Value(sessionId),
        takenAtMs = Value(takenAtMs),
        source = Value(source),
        type = Value(type),
        config = Value(config),
        flags = Value(flags),
        rawFrame = Value(rawFrame),
        decoderVersion = Value(decoderVersion);
  static Insertable<ReadingEntity> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? takenAtMs,
    Expression<String>? source,
    Expression<int>? type,
    Expression<int>? config,
    Expression<int>? flags,
    Expression<Uint8List>? rawFrame,
    Expression<int>? decoderVersion,
    Expression<double>? battV,
    Expression<double>? v12V,
    Expression<double>? vrefV,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (takenAtMs != null) 'taken_at_ms': takenAtMs,
      if (source != null) 'source': source,
      if (type != null) 'type': type,
      if (config != null) 'config': config,
      if (flags != null) 'flags': flags,
      if (rawFrame != null) 'raw_frame': rawFrame,
      if (decoderVersion != null) 'decoder_version': decoderVersion,
      if (battV != null) 'batt_v': battV,
      if (v12V != null) 'v12_v': v12V,
      if (vrefV != null) 'vref_v': vrefV,
    });
  }

  ReadingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int>? takenAtMs,
      Value<String>? source,
      Value<int>? type,
      Value<int>? config,
      Value<int>? flags,
      Value<Uint8List>? rawFrame,
      Value<int>? decoderVersion,
      Value<double?>? battV,
      Value<double?>? v12V,
      Value<double?>? vrefV}) {
    return ReadingsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      takenAtMs: takenAtMs ?? this.takenAtMs,
      source: source ?? this.source,
      type: type ?? this.type,
      config: config ?? this.config,
      flags: flags ?? this.flags,
      rawFrame: rawFrame ?? this.rawFrame,
      decoderVersion: decoderVersion ?? this.decoderVersion,
      battV: battV ?? this.battV,
      v12V: v12V ?? this.v12V,
      vrefV: vrefV ?? this.vrefV,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (takenAtMs.present) {
      map['taken_at_ms'] = Variable<int>(takenAtMs.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (config.present) {
      map['config'] = Variable<int>(config.value);
    }
    if (flags.present) {
      map['flags'] = Variable<int>(flags.value);
    }
    if (rawFrame.present) {
      map['raw_frame'] = Variable<Uint8List>(rawFrame.value);
    }
    if (decoderVersion.present) {
      map['decoder_version'] = Variable<int>(decoderVersion.value);
    }
    if (battV.present) {
      map['batt_v'] = Variable<double>(battV.value);
    }
    if (v12V.present) {
      map['v12_v'] = Variable<double>(v12V.value);
    }
    if (vrefV.present) {
      map['vref_v'] = Variable<double>(vrefV.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('takenAtMs: $takenAtMs, ')
          ..write('source: $source, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('flags: $flags, ')
          ..write('rawFrame: $rawFrame, ')
          ..write('decoderVersion: $decoderVersion, ')
          ..write('battV: $battV, ')
          ..write('v12V: $v12V, ')
          ..write('vrefV: $vrefV')
          ..write(')'))
        .toString();
  }
}

class $ReadingParamsTable extends ReadingParams
    with TableInfo<$ReadingParamsTable, ReadingParam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingParamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _readingIdMeta =
      const VerificationMeta('readingId');
  @override
  late final GeneratedColumn<int> readingId = GeneratedColumn<int>(
      'reading_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES readings (id) ON DELETE CASCADE'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [readingId, key, value, unit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_params';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingParam> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reading_id')) {
      context.handle(_readingIdMeta,
          readingId.isAcceptableOrUnknown(data['reading_id']!, _readingIdMeta));
    } else if (isInserting) {
      context.missing(_readingIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {readingId, key};
  @override
  ReadingParam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingParam(
      readingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
    );
  }

  @override
  $ReadingParamsTable createAlias(String alias) {
    return $ReadingParamsTable(attachedDatabase, alias);
  }
}

class ReadingParam extends DataClass implements Insertable<ReadingParam> {
  final int readingId;
  final String key;
  final double value;
  final String unit;
  const ReadingParam(
      {required this.readingId,
      required this.key,
      required this.value,
      required this.unit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reading_id'] = Variable<int>(readingId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    return map;
  }

  ReadingParamsCompanion toCompanion(bool nullToAbsent) {
    return ReadingParamsCompanion(
      readingId: Value(readingId),
      key: Value(key),
      value: Value(value),
      unit: Value(unit),
    );
  }

  factory ReadingParam.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingParam(
      readingId: serializer.fromJson<int>(json['readingId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'readingId': serializer.toJson<int>(readingId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
    };
  }

  ReadingParam copyWith(
          {int? readingId, String? key, double? value, String? unit}) =>
      ReadingParam(
        readingId: readingId ?? this.readingId,
        key: key ?? this.key,
        value: value ?? this.value,
        unit: unit ?? this.unit,
      );
  ReadingParam copyWithCompanion(ReadingParamsCompanion data) {
    return ReadingParam(
      readingId: data.readingId.present ? data.readingId.value : this.readingId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingParam(')
          ..write('readingId: $readingId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(readingId, key, value, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingParam &&
          other.readingId == this.readingId &&
          other.key == this.key &&
          other.value == this.value &&
          other.unit == this.unit);
}

class ReadingParamsCompanion extends UpdateCompanion<ReadingParam> {
  final Value<int> readingId;
  final Value<String> key;
  final Value<double> value;
  final Value<String> unit;
  final Value<int> rowid;
  const ReadingParamsCompanion({
    this.readingId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingParamsCompanion.insert({
    required int readingId,
    required String key,
    required double value,
    required String unit,
    this.rowid = const Value.absent(),
  })  : readingId = Value(readingId),
        key = Value(key),
        value = Value(value),
        unit = Value(unit);
  static Insertable<ReadingParam> custom({
    Expression<int>? readingId,
    Expression<String>? key,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (readingId != null) 'reading_id': readingId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingParamsCompanion copyWith(
      {Value<int>? readingId,
      Value<String>? key,
      Value<double>? value,
      Value<String>? unit,
      Value<int>? rowid}) {
    return ReadingParamsCompanion(
      readingId: readingId ?? this.readingId,
      key: key ?? this.key,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (readingId.present) {
      map['reading_id'] = Variable<int>(readingId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingParamsCompanion(')
          ..write('readingId: $readingId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartsTable extends Parts with TableInfo<$PartsTable, PartEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _partNumberMeta =
      const VerificationMeta('partNumber');
  @override
  late final GeneratedColumn<String> partNumber = GeneratedColumn<String>(
      'part_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _manufacturerMeta =
      const VerificationMeta('manufacturer');
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
      'manufacturer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
      'family', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, partNumber, manufacturer, description, family];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parts';
  @override
  VerificationContext validateIntegrity(Insertable<PartEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('part_number')) {
      context.handle(
          _partNumberMeta,
          partNumber.isAcceptableOrUnknown(
              data['part_number']!, _partNumberMeta));
    } else if (isInserting) {
      context.missing(_partNumberMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
          _manufacturerMeta,
          manufacturer.isAcceptableOrUnknown(
              data['manufacturer']!, _manufacturerMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('family')) {
      context.handle(_familyMeta,
          family.isAcceptableOrUnknown(data['family']!, _familyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {partNumber, manufacturer},
      ];
  @override
  PartEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      partNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_number'])!,
      manufacturer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manufacturer']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      family: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family']),
    );
  }

  @override
  $PartsTable createAlias(String alias) {
    return $PartsTable(attachedDatabase, alias);
  }
}

class PartEntity extends DataClass implements Insertable<PartEntity> {
  final int id;
  final String partNumber;
  final String? manufacturer;
  final String? description;
  final String? family;
  const PartEntity(
      {required this.id,
      required this.partNumber,
      this.manufacturer,
      this.description,
      this.family});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['part_number'] = Variable<String>(partNumber);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || family != null) {
      map['family'] = Variable<String>(family);
    }
    return map;
  }

  PartsCompanion toCompanion(bool nullToAbsent) {
    return PartsCompanion(
      id: Value(id),
      partNumber: Value(partNumber),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      family:
          family == null && nullToAbsent ? const Value.absent() : Value(family),
    );
  }

  factory PartEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartEntity(
      id: serializer.fromJson<int>(json['id']),
      partNumber: serializer.fromJson<String>(json['partNumber']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      description: serializer.fromJson<String?>(json['description']),
      family: serializer.fromJson<String?>(json['family']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partNumber': serializer.toJson<String>(partNumber),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'description': serializer.toJson<String?>(description),
      'family': serializer.toJson<String?>(family),
    };
  }

  PartEntity copyWith(
          {int? id,
          String? partNumber,
          Value<String?> manufacturer = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> family = const Value.absent()}) =>
      PartEntity(
        id: id ?? this.id,
        partNumber: partNumber ?? this.partNumber,
        manufacturer:
            manufacturer.present ? manufacturer.value : this.manufacturer,
        description: description.present ? description.value : this.description,
        family: family.present ? family.value : this.family,
      );
  PartEntity copyWithCompanion(PartsCompanion data) {
    return PartEntity(
      id: data.id.present ? data.id.value : this.id,
      partNumber:
          data.partNumber.present ? data.partNumber.value : this.partNumber,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      description:
          data.description.present ? data.description.value : this.description,
      family: data.family.present ? data.family.value : this.family,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartEntity(')
          ..write('id: $id, ')
          ..write('partNumber: $partNumber, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('description: $description, ')
          ..write('family: $family')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, partNumber, manufacturer, description, family);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartEntity &&
          other.id == this.id &&
          other.partNumber == this.partNumber &&
          other.manufacturer == this.manufacturer &&
          other.description == this.description &&
          other.family == this.family);
}

class PartsCompanion extends UpdateCompanion<PartEntity> {
  final Value<int> id;
  final Value<String> partNumber;
  final Value<String?> manufacturer;
  final Value<String?> description;
  final Value<String?> family;
  const PartsCompanion({
    this.id = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.description = const Value.absent(),
    this.family = const Value.absent(),
  });
  PartsCompanion.insert({
    this.id = const Value.absent(),
    required String partNumber,
    this.manufacturer = const Value.absent(),
    this.description = const Value.absent(),
    this.family = const Value.absent(),
  }) : partNumber = Value(partNumber);
  static Insertable<PartEntity> custom({
    Expression<int>? id,
    Expression<String>? partNumber,
    Expression<String>? manufacturer,
    Expression<String>? description,
    Expression<String>? family,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partNumber != null) 'part_number': partNumber,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (description != null) 'description': description,
      if (family != null) 'family': family,
    });
  }

  PartsCompanion copyWith(
      {Value<int>? id,
      Value<String>? partNumber,
      Value<String?>? manufacturer,
      Value<String?>? description,
      Value<String?>? family}) {
    return PartsCompanion(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      description: description ?? this.description,
      family: family ?? this.family,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partNumber.present) {
      map['part_number'] = Variable<String>(partNumber.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartsCompanion(')
          ..write('id: $id, ')
          ..write('partNumber: $partNumber, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('description: $description, ')
          ..write('family: $family')
          ..write(')'))
        .toString();
  }
}

class $BinsTable extends Bins with TableInfo<$BinsTable, BinEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<int> partId = GeneratedColumn<int>(
      'part_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES parts (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMsMeta =
      const VerificationMeta('createdAtMs');
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
      'created_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, partId, name, createdAtMs, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bins';
  @override
  VerificationContext validateIntegrity(Insertable<BinEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('part_id')) {
      context.handle(_partIdMeta,
          partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta));
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
          _createdAtMsMeta,
          createdAtMs.isAcceptableOrUnknown(
              data['created_at_ms']!, _createdAtMsMeta));
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {partId, name},
      ];
  @override
  BinEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BinEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      partId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}part_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at_ms'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $BinsTable createAlias(String alias) {
    return $BinsTable(attachedDatabase, alias);
  }
}

class BinEntity extends DataClass implements Insertable<BinEntity> {
  final int id;
  final int partId;
  final String name;
  final int createdAtMs;
  final String? notes;
  const BinEntity(
      {required this.id,
      required this.partId,
      required this.name,
      required this.createdAtMs,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['part_id'] = Variable<int>(partId);
    map['name'] = Variable<String>(name);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BinsCompanion toCompanion(bool nullToAbsent) {
    return BinsCompanion(
      id: Value(id),
      partId: Value(partId),
      name: Value(name),
      createdAtMs: Value(createdAtMs),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory BinEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BinEntity(
      id: serializer.fromJson<int>(json['id']),
      partId: serializer.fromJson<int>(json['partId']),
      name: serializer.fromJson<String>(json['name']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partId': serializer.toJson<int>(partId),
      'name': serializer.toJson<String>(name),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BinEntity copyWith(
          {int? id,
          int? partId,
          String? name,
          int? createdAtMs,
          Value<String?> notes = const Value.absent()}) =>
      BinEntity(
        id: id ?? this.id,
        partId: partId ?? this.partId,
        name: name ?? this.name,
        createdAtMs: createdAtMs ?? this.createdAtMs,
        notes: notes.present ? notes.value : this.notes,
      );
  BinEntity copyWithCompanion(BinsCompanion data) {
    return BinEntity(
      id: data.id.present ? data.id.value : this.id,
      partId: data.partId.present ? data.partId.value : this.partId,
      name: data.name.present ? data.name.value : this.name,
      createdAtMs:
          data.createdAtMs.present ? data.createdAtMs.value : this.createdAtMs,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BinEntity(')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('name: $name, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, partId, name, createdAtMs, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BinEntity &&
          other.id == this.id &&
          other.partId == this.partId &&
          other.name == this.name &&
          other.createdAtMs == this.createdAtMs &&
          other.notes == this.notes);
}

class BinsCompanion extends UpdateCompanion<BinEntity> {
  final Value<int> id;
  final Value<int> partId;
  final Value<String> name;
  final Value<int> createdAtMs;
  final Value<String?> notes;
  const BinsCompanion({
    this.id = const Value.absent(),
    this.partId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.notes = const Value.absent(),
  });
  BinsCompanion.insert({
    this.id = const Value.absent(),
    required int partId,
    required String name,
    required int createdAtMs,
    this.notes = const Value.absent(),
  })  : partId = Value(partId),
        name = Value(name),
        createdAtMs = Value(createdAtMs);
  static Insertable<BinEntity> custom({
    Expression<int>? id,
    Expression<int>? partId,
    Expression<String>? name,
    Expression<int>? createdAtMs,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partId != null) 'part_id': partId,
      if (name != null) 'name': name,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (notes != null) 'notes': notes,
    });
  }

  BinsCompanion copyWith(
      {Value<int>? id,
      Value<int>? partId,
      Value<String>? name,
      Value<int>? createdAtMs,
      Value<String?>? notes}) {
    return BinsCompanion(
      id: id ?? this.id,
      partId: partId ?? this.partId,
      name: name ?? this.name,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<int>(partId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BinsCompanion(')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('name: $name, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ReadingTagsTable extends ReadingTags
    with TableInfo<$ReadingTagsTable, ReadingTagEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _readingIdMeta =
      const VerificationMeta('readingId');
  @override
  late final GeneratedColumn<int> readingId = GeneratedColumn<int>(
      'reading_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES readings (id) ON DELETE CASCADE'));
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<int> partId = GeneratedColumn<int>(
      'part_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES parts (id) ON DELETE SET NULL'));
  static const VerificationMeta _binIdMeta = const VerificationMeta('binId');
  @override
  late final GeneratedColumn<int> binId = GeneratedColumn<int>(
      'bin_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES bins (id) ON DELETE SET NULL'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _starredMeta =
      const VerificationMeta('starred');
  @override
  late final GeneratedColumn<bool> starred = GeneratedColumn<bool>(
      'starred', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("starred" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMsMeta =
      const VerificationMeta('updatedAtMs');
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
      'updated_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [readingId, partId, binId, label, notes, starred, updatedAtMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_tags';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingTagEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reading_id')) {
      context.handle(_readingIdMeta,
          readingId.isAcceptableOrUnknown(data['reading_id']!, _readingIdMeta));
    }
    if (data.containsKey('part_id')) {
      context.handle(_partIdMeta,
          partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta));
    }
    if (data.containsKey('bin_id')) {
      context.handle(
          _binIdMeta, binId.isAcceptableOrUnknown(data['bin_id']!, _binIdMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('starred')) {
      context.handle(_starredMeta,
          starred.isAcceptableOrUnknown(data['starred']!, _starredMeta));
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
          _updatedAtMsMeta,
          updatedAtMs.isAcceptableOrUnknown(
              data['updated_at_ms']!, _updatedAtMsMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {readingId};
  @override
  ReadingTagEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingTagEntity(
      readingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_id'])!,
      partId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}part_id']),
      binId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bin_id']),
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      starred: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}starred'])!,
      updatedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_ms'])!,
    );
  }

  @override
  $ReadingTagsTable createAlias(String alias) {
    return $ReadingTagsTable(attachedDatabase, alias);
  }
}

class ReadingTagEntity extends DataClass
    implements Insertable<ReadingTagEntity> {
  final int readingId;
  final int? partId;
  final int? binId;
  final String? label;
  final String? notes;
  final bool starred;
  final int updatedAtMs;
  const ReadingTagEntity(
      {required this.readingId,
      this.partId,
      this.binId,
      this.label,
      this.notes,
      required this.starred,
      required this.updatedAtMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reading_id'] = Variable<int>(readingId);
    if (!nullToAbsent || partId != null) {
      map['part_id'] = Variable<int>(partId);
    }
    if (!nullToAbsent || binId != null) {
      map['bin_id'] = Variable<int>(binId);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['starred'] = Variable<bool>(starred);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  ReadingTagsCompanion toCompanion(bool nullToAbsent) {
    return ReadingTagsCompanion(
      readingId: Value(readingId),
      partId:
          partId == null && nullToAbsent ? const Value.absent() : Value(partId),
      binId:
          binId == null && nullToAbsent ? const Value.absent() : Value(binId),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      starred: Value(starred),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory ReadingTagEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingTagEntity(
      readingId: serializer.fromJson<int>(json['readingId']),
      partId: serializer.fromJson<int?>(json['partId']),
      binId: serializer.fromJson<int?>(json['binId']),
      label: serializer.fromJson<String?>(json['label']),
      notes: serializer.fromJson<String?>(json['notes']),
      starred: serializer.fromJson<bool>(json['starred']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'readingId': serializer.toJson<int>(readingId),
      'partId': serializer.toJson<int?>(partId),
      'binId': serializer.toJson<int?>(binId),
      'label': serializer.toJson<String?>(label),
      'notes': serializer.toJson<String?>(notes),
      'starred': serializer.toJson<bool>(starred),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  ReadingTagEntity copyWith(
          {int? readingId,
          Value<int?> partId = const Value.absent(),
          Value<int?> binId = const Value.absent(),
          Value<String?> label = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? starred,
          int? updatedAtMs}) =>
      ReadingTagEntity(
        readingId: readingId ?? this.readingId,
        partId: partId.present ? partId.value : this.partId,
        binId: binId.present ? binId.value : this.binId,
        label: label.present ? label.value : this.label,
        notes: notes.present ? notes.value : this.notes,
        starred: starred ?? this.starred,
        updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      );
  ReadingTagEntity copyWithCompanion(ReadingTagsCompanion data) {
    return ReadingTagEntity(
      readingId: data.readingId.present ? data.readingId.value : this.readingId,
      partId: data.partId.present ? data.partId.value : this.partId,
      binId: data.binId.present ? data.binId.value : this.binId,
      label: data.label.present ? data.label.value : this.label,
      notes: data.notes.present ? data.notes.value : this.notes,
      starred: data.starred.present ? data.starred.value : this.starred,
      updatedAtMs:
          data.updatedAtMs.present ? data.updatedAtMs.value : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingTagEntity(')
          ..write('readingId: $readingId, ')
          ..write('partId: $partId, ')
          ..write('binId: $binId, ')
          ..write('label: $label, ')
          ..write('notes: $notes, ')
          ..write('starred: $starred, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(readingId, partId, binId, label, notes, starred, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingTagEntity &&
          other.readingId == this.readingId &&
          other.partId == this.partId &&
          other.binId == this.binId &&
          other.label == this.label &&
          other.notes == this.notes &&
          other.starred == this.starred &&
          other.updatedAtMs == this.updatedAtMs);
}

class ReadingTagsCompanion extends UpdateCompanion<ReadingTagEntity> {
  final Value<int> readingId;
  final Value<int?> partId;
  final Value<int?> binId;
  final Value<String?> label;
  final Value<String?> notes;
  final Value<bool> starred;
  final Value<int> updatedAtMs;
  const ReadingTagsCompanion({
    this.readingId = const Value.absent(),
    this.partId = const Value.absent(),
    this.binId = const Value.absent(),
    this.label = const Value.absent(),
    this.notes = const Value.absent(),
    this.starred = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  ReadingTagsCompanion.insert({
    this.readingId = const Value.absent(),
    this.partId = const Value.absent(),
    this.binId = const Value.absent(),
    this.label = const Value.absent(),
    this.notes = const Value.absent(),
    this.starred = const Value.absent(),
    required int updatedAtMs,
  }) : updatedAtMs = Value(updatedAtMs);
  static Insertable<ReadingTagEntity> custom({
    Expression<int>? readingId,
    Expression<int>? partId,
    Expression<int>? binId,
    Expression<String>? label,
    Expression<String>? notes,
    Expression<bool>? starred,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (readingId != null) 'reading_id': readingId,
      if (partId != null) 'part_id': partId,
      if (binId != null) 'bin_id': binId,
      if (label != null) 'label': label,
      if (notes != null) 'notes': notes,
      if (starred != null) 'starred': starred,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  ReadingTagsCompanion copyWith(
      {Value<int>? readingId,
      Value<int?>? partId,
      Value<int?>? binId,
      Value<String?>? label,
      Value<String?>? notes,
      Value<bool>? starred,
      Value<int>? updatedAtMs}) {
    return ReadingTagsCompanion(
      readingId: readingId ?? this.readingId,
      partId: partId ?? this.partId,
      binId: binId ?? this.binId,
      label: label ?? this.label,
      notes: notes ?? this.notes,
      starred: starred ?? this.starred,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (readingId.present) {
      map['reading_id'] = Variable<int>(readingId.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<int>(partId.value);
    }
    if (binId.present) {
      map['bin_id'] = Variable<int>(binId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (starred.present) {
      map['starred'] = Variable<bool>(starred.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingTagsCompanion(')
          ..write('readingId: $readingId, ')
          ..write('partId: $partId, ')
          ..write('binId: $binId, ')
          ..write('label: $label, ')
          ..write('notes: $notes, ')
          ..write('starred: $starred, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $SweepsTable extends Sweeps with TableInfo<$SweepsTable, SweepEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SweepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _readingIdMeta =
      const VerificationMeta('readingId');
  @override
  late final GeneratedColumn<int> readingId = GeneratedColumn<int>(
      'reading_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES readings (id) ON DELETE SET NULL'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paramsJsonMeta =
      const VerificationMeta('paramsJson');
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
      'params_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _xLabelMeta = const VerificationMeta('xLabel');
  @override
  late final GeneratedColumn<String> xLabel = GeneratedColumn<String>(
      'x_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yLabelMeta = const VerificationMeta('yLabel');
  @override
  late final GeneratedColumn<String> yLabel = GeneratedColumn<String>(
      'y_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMsMeta =
      const VerificationMeta('startedAtMs');
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
      'started_at_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cancelledMeta =
      const VerificationMeta('cancelled');
  @override
  late final GeneratedColumn<bool> cancelled = GeneratedColumn<bool>(
      'cancelled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("cancelled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        readingId,
        kind,
        paramsJson,
        xLabel,
        yLabel,
        startedAtMs,
        durationMs,
        cancelled,
        error
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sweeps';
  @override
  VerificationContext validateIntegrity(Insertable<SweepEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('reading_id')) {
      context.handle(_readingIdMeta,
          readingId.isAcceptableOrUnknown(data['reading_id']!, _readingIdMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('params_json')) {
      context.handle(
          _paramsJsonMeta,
          paramsJson.isAcceptableOrUnknown(
              data['params_json']!, _paramsJsonMeta));
    } else if (isInserting) {
      context.missing(_paramsJsonMeta);
    }
    if (data.containsKey('x_label')) {
      context.handle(_xLabelMeta,
          xLabel.isAcceptableOrUnknown(data['x_label']!, _xLabelMeta));
    } else if (isInserting) {
      context.missing(_xLabelMeta);
    }
    if (data.containsKey('y_label')) {
      context.handle(_yLabelMeta,
          yLabel.isAcceptableOrUnknown(data['y_label']!, _yLabelMeta));
    } else if (isInserting) {
      context.missing(_yLabelMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
          _startedAtMsMeta,
          startedAtMs.isAcceptableOrUnknown(
              data['started_at_ms']!, _startedAtMsMeta));
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('cancelled')) {
      context.handle(_cancelledMeta,
          cancelled.isAcceptableOrUnknown(data['cancelled']!, _cancelledMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SweepEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SweepEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      readingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_id']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      paramsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}params_json'])!,
      xLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}x_label'])!,
      yLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}y_label'])!,
      startedAtMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at_ms'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms']),
      cancelled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}cancelled'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
    );
  }

  @override
  $SweepsTable createAlias(String alias) {
    return $SweepsTable(attachedDatabase, alias);
  }
}

class SweepEntity extends DataClass implements Insertable<SweepEntity> {
  final int id;
  final int sessionId;
  final int? readingId;
  final String kind;
  final String paramsJson;
  final String xLabel;
  final String yLabel;
  final int startedAtMs;
  final int? durationMs;
  final bool cancelled;
  final String? error;
  const SweepEntity(
      {required this.id,
      required this.sessionId,
      this.readingId,
      required this.kind,
      required this.paramsJson,
      required this.xLabel,
      required this.yLabel,
      required this.startedAtMs,
      this.durationMs,
      required this.cancelled,
      this.error});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || readingId != null) {
      map['reading_id'] = Variable<int>(readingId);
    }
    map['kind'] = Variable<String>(kind);
    map['params_json'] = Variable<String>(paramsJson);
    map['x_label'] = Variable<String>(xLabel);
    map['y_label'] = Variable<String>(yLabel);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['cancelled'] = Variable<bool>(cancelled);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  SweepsCompanion toCompanion(bool nullToAbsent) {
    return SweepsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      readingId: readingId == null && nullToAbsent
          ? const Value.absent()
          : Value(readingId),
      kind: Value(kind),
      paramsJson: Value(paramsJson),
      xLabel: Value(xLabel),
      yLabel: Value(yLabel),
      startedAtMs: Value(startedAtMs),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      cancelled: Value(cancelled),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
    );
  }

  factory SweepEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SweepEntity(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      readingId: serializer.fromJson<int?>(json['readingId']),
      kind: serializer.fromJson<String>(json['kind']),
      paramsJson: serializer.fromJson<String>(json['paramsJson']),
      xLabel: serializer.fromJson<String>(json['xLabel']),
      yLabel: serializer.fromJson<String>(json['yLabel']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      cancelled: serializer.fromJson<bool>(json['cancelled']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'readingId': serializer.toJson<int?>(readingId),
      'kind': serializer.toJson<String>(kind),
      'paramsJson': serializer.toJson<String>(paramsJson),
      'xLabel': serializer.toJson<String>(xLabel),
      'yLabel': serializer.toJson<String>(yLabel),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'durationMs': serializer.toJson<int?>(durationMs),
      'cancelled': serializer.toJson<bool>(cancelled),
      'error': serializer.toJson<String?>(error),
    };
  }

  SweepEntity copyWith(
          {int? id,
          int? sessionId,
          Value<int?> readingId = const Value.absent(),
          String? kind,
          String? paramsJson,
          String? xLabel,
          String? yLabel,
          int? startedAtMs,
          Value<int?> durationMs = const Value.absent(),
          bool? cancelled,
          Value<String?> error = const Value.absent()}) =>
      SweepEntity(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        readingId: readingId.present ? readingId.value : this.readingId,
        kind: kind ?? this.kind,
        paramsJson: paramsJson ?? this.paramsJson,
        xLabel: xLabel ?? this.xLabel,
        yLabel: yLabel ?? this.yLabel,
        startedAtMs: startedAtMs ?? this.startedAtMs,
        durationMs: durationMs.present ? durationMs.value : this.durationMs,
        cancelled: cancelled ?? this.cancelled,
        error: error.present ? error.value : this.error,
      );
  SweepEntity copyWithCompanion(SweepsCompanion data) {
    return SweepEntity(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      readingId: data.readingId.present ? data.readingId.value : this.readingId,
      kind: data.kind.present ? data.kind.value : this.kind,
      paramsJson:
          data.paramsJson.present ? data.paramsJson.value : this.paramsJson,
      xLabel: data.xLabel.present ? data.xLabel.value : this.xLabel,
      yLabel: data.yLabel.present ? data.yLabel.value : this.yLabel,
      startedAtMs:
          data.startedAtMs.present ? data.startedAtMs.value : this.startedAtMs,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      cancelled: data.cancelled.present ? data.cancelled.value : this.cancelled,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SweepEntity(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('readingId: $readingId, ')
          ..write('kind: $kind, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('xLabel: $xLabel, ')
          ..write('yLabel: $yLabel, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('cancelled: $cancelled, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, readingId, kind, paramsJson,
      xLabel, yLabel, startedAtMs, durationMs, cancelled, error);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SweepEntity &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.readingId == this.readingId &&
          other.kind == this.kind &&
          other.paramsJson == this.paramsJson &&
          other.xLabel == this.xLabel &&
          other.yLabel == this.yLabel &&
          other.startedAtMs == this.startedAtMs &&
          other.durationMs == this.durationMs &&
          other.cancelled == this.cancelled &&
          other.error == this.error);
}

class SweepsCompanion extends UpdateCompanion<SweepEntity> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int?> readingId;
  final Value<String> kind;
  final Value<String> paramsJson;
  final Value<String> xLabel;
  final Value<String> yLabel;
  final Value<int> startedAtMs;
  final Value<int?> durationMs;
  final Value<bool> cancelled;
  final Value<String?> error;
  const SweepsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.readingId = const Value.absent(),
    this.kind = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.xLabel = const Value.absent(),
    this.yLabel = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.cancelled = const Value.absent(),
    this.error = const Value.absent(),
  });
  SweepsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    this.readingId = const Value.absent(),
    required String kind,
    required String paramsJson,
    required String xLabel,
    required String yLabel,
    required int startedAtMs,
    this.durationMs = const Value.absent(),
    this.cancelled = const Value.absent(),
    this.error = const Value.absent(),
  })  : sessionId = Value(sessionId),
        kind = Value(kind),
        paramsJson = Value(paramsJson),
        xLabel = Value(xLabel),
        yLabel = Value(yLabel),
        startedAtMs = Value(startedAtMs);
  static Insertable<SweepEntity> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? readingId,
    Expression<String>? kind,
    Expression<String>? paramsJson,
    Expression<String>? xLabel,
    Expression<String>? yLabel,
    Expression<int>? startedAtMs,
    Expression<int>? durationMs,
    Expression<bool>? cancelled,
    Expression<String>? error,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (readingId != null) 'reading_id': readingId,
      if (kind != null) 'kind': kind,
      if (paramsJson != null) 'params_json': paramsJson,
      if (xLabel != null) 'x_label': xLabel,
      if (yLabel != null) 'y_label': yLabel,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (cancelled != null) 'cancelled': cancelled,
      if (error != null) 'error': error,
    });
  }

  SweepsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int?>? readingId,
      Value<String>? kind,
      Value<String>? paramsJson,
      Value<String>? xLabel,
      Value<String>? yLabel,
      Value<int>? startedAtMs,
      Value<int?>? durationMs,
      Value<bool>? cancelled,
      Value<String?>? error}) {
    return SweepsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      readingId: readingId ?? this.readingId,
      kind: kind ?? this.kind,
      paramsJson: paramsJson ?? this.paramsJson,
      xLabel: xLabel ?? this.xLabel,
      yLabel: yLabel ?? this.yLabel,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      durationMs: durationMs ?? this.durationMs,
      cancelled: cancelled ?? this.cancelled,
      error: error ?? this.error,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (readingId.present) {
      map['reading_id'] = Variable<int>(readingId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (xLabel.present) {
      map['x_label'] = Variable<String>(xLabel.value);
    }
    if (yLabel.present) {
      map['y_label'] = Variable<String>(yLabel.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (cancelled.present) {
      map['cancelled'] = Variable<bool>(cancelled.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SweepsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('readingId: $readingId, ')
          ..write('kind: $kind, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('xLabel: $xLabel, ')
          ..write('yLabel: $yLabel, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('cancelled: $cancelled, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }
}

class $SweepTracesTable extends SweepTraces
    with TableInfo<$SweepTracesTable, SweepTraceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SweepTracesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sweepIdMeta =
      const VerificationMeta('sweepId');
  @override
  late final GeneratedColumn<int> sweepId = GeneratedColumn<int>(
      'sweep_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sweeps (id) ON DELETE CASCADE'));
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
      'idx', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nPointsMeta =
      const VerificationMeta('nPoints');
  @override
  late final GeneratedColumn<int> nPoints = GeneratedColumn<int>(
      'n_points', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<Uint8List> points = GeneratedColumn<Uint8List>(
      'points', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sweepId, idx, label, nPoints, points];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sweep_traces';
  @override
  VerificationContext validateIntegrity(Insertable<SweepTraceEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sweep_id')) {
      context.handle(_sweepIdMeta,
          sweepId.isAcceptableOrUnknown(data['sweep_id']!, _sweepIdMeta));
    } else if (isInserting) {
      context.missing(_sweepIdMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
          _idxMeta, idx.isAcceptableOrUnknown(data['idx']!, _idxMeta));
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('n_points')) {
      context.handle(_nPointsMeta,
          nPoints.isAcceptableOrUnknown(data['n_points']!, _nPointsMeta));
    } else if (isInserting) {
      context.missing(_nPointsMeta);
    }
    if (data.containsKey('points')) {
      context.handle(_pointsMeta,
          points.isAcceptableOrUnknown(data['points']!, _pointsMeta));
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SweepTraceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SweepTraceEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sweepId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sweep_id'])!,
      idx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}idx'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      nPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}n_points'])!,
      points: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}points'])!,
    );
  }

  @override
  $SweepTracesTable createAlias(String alias) {
    return $SweepTracesTable(attachedDatabase, alias);
  }
}

class SweepTraceEntity extends DataClass
    implements Insertable<SweepTraceEntity> {
  final int id;
  final int sweepId;
  final int idx;
  final String label;
  final int nPoints;

  /// Little-endian float64 pairs `[x0, y0, x1, y1, ...]`.
  final Uint8List points;
  const SweepTraceEntity(
      {required this.id,
      required this.sweepId,
      required this.idx,
      required this.label,
      required this.nPoints,
      required this.points});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sweep_id'] = Variable<int>(sweepId);
    map['idx'] = Variable<int>(idx);
    map['label'] = Variable<String>(label);
    map['n_points'] = Variable<int>(nPoints);
    map['points'] = Variable<Uint8List>(points);
    return map;
  }

  SweepTracesCompanion toCompanion(bool nullToAbsent) {
    return SweepTracesCompanion(
      id: Value(id),
      sweepId: Value(sweepId),
      idx: Value(idx),
      label: Value(label),
      nPoints: Value(nPoints),
      points: Value(points),
    );
  }

  factory SweepTraceEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SweepTraceEntity(
      id: serializer.fromJson<int>(json['id']),
      sweepId: serializer.fromJson<int>(json['sweepId']),
      idx: serializer.fromJson<int>(json['idx']),
      label: serializer.fromJson<String>(json['label']),
      nPoints: serializer.fromJson<int>(json['nPoints']),
      points: serializer.fromJson<Uint8List>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sweepId': serializer.toJson<int>(sweepId),
      'idx': serializer.toJson<int>(idx),
      'label': serializer.toJson<String>(label),
      'nPoints': serializer.toJson<int>(nPoints),
      'points': serializer.toJson<Uint8List>(points),
    };
  }

  SweepTraceEntity copyWith(
          {int? id,
          int? sweepId,
          int? idx,
          String? label,
          int? nPoints,
          Uint8List? points}) =>
      SweepTraceEntity(
        id: id ?? this.id,
        sweepId: sweepId ?? this.sweepId,
        idx: idx ?? this.idx,
        label: label ?? this.label,
        nPoints: nPoints ?? this.nPoints,
        points: points ?? this.points,
      );
  SweepTraceEntity copyWithCompanion(SweepTracesCompanion data) {
    return SweepTraceEntity(
      id: data.id.present ? data.id.value : this.id,
      sweepId: data.sweepId.present ? data.sweepId.value : this.sweepId,
      idx: data.idx.present ? data.idx.value : this.idx,
      label: data.label.present ? data.label.value : this.label,
      nPoints: data.nPoints.present ? data.nPoints.value : this.nPoints,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SweepTraceEntity(')
          ..write('id: $id, ')
          ..write('sweepId: $sweepId, ')
          ..write('idx: $idx, ')
          ..write('label: $label, ')
          ..write('nPoints: $nPoints, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sweepId, idx, label, nPoints, $driftBlobEquality.hash(points));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SweepTraceEntity &&
          other.id == this.id &&
          other.sweepId == this.sweepId &&
          other.idx == this.idx &&
          other.label == this.label &&
          other.nPoints == this.nPoints &&
          $driftBlobEquality.equals(other.points, this.points));
}

class SweepTracesCompanion extends UpdateCompanion<SweepTraceEntity> {
  final Value<int> id;
  final Value<int> sweepId;
  final Value<int> idx;
  final Value<String> label;
  final Value<int> nPoints;
  final Value<Uint8List> points;
  const SweepTracesCompanion({
    this.id = const Value.absent(),
    this.sweepId = const Value.absent(),
    this.idx = const Value.absent(),
    this.label = const Value.absent(),
    this.nPoints = const Value.absent(),
    this.points = const Value.absent(),
  });
  SweepTracesCompanion.insert({
    this.id = const Value.absent(),
    required int sweepId,
    required int idx,
    required String label,
    required int nPoints,
    required Uint8List points,
  })  : sweepId = Value(sweepId),
        idx = Value(idx),
        label = Value(label),
        nPoints = Value(nPoints),
        points = Value(points);
  static Insertable<SweepTraceEntity> custom({
    Expression<int>? id,
    Expression<int>? sweepId,
    Expression<int>? idx,
    Expression<String>? label,
    Expression<int>? nPoints,
    Expression<Uint8List>? points,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sweepId != null) 'sweep_id': sweepId,
      if (idx != null) 'idx': idx,
      if (label != null) 'label': label,
      if (nPoints != null) 'n_points': nPoints,
      if (points != null) 'points': points,
    });
  }

  SweepTracesCompanion copyWith(
      {Value<int>? id,
      Value<int>? sweepId,
      Value<int>? idx,
      Value<String>? label,
      Value<int>? nPoints,
      Value<Uint8List>? points}) {
    return SweepTracesCompanion(
      id: id ?? this.id,
      sweepId: sweepId ?? this.sweepId,
      idx: idx ?? this.idx,
      label: label ?? this.label,
      nPoints: nPoints ?? this.nPoints,
      points: points ?? this.points,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sweepId.present) {
      map['sweep_id'] = Variable<int>(sweepId.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (nPoints.present) {
      map['n_points'] = Variable<int>(nPoints.value);
    }
    if (points.present) {
      map['points'] = Variable<Uint8List>(points.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SweepTracesCompanion(')
          ..write('id: $id, ')
          ..write('sweepId: $sweepId, ')
          ..write('idx: $idx, ')
          ..write('label: $label, ')
          ..write('nPoints: $nPoints, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }
}

class $SchemaMetaTable extends SchemaMeta
    with TableInfo<$SchemaMetaTable, SchemaMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchemaMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_meta';
  @override
  VerificationContext validateIntegrity(Insertable<SchemaMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SchemaMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchemaMetaData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SchemaMetaTable createAlias(String alias) {
    return $SchemaMetaTable(attachedDatabase, alias);
  }
}

class SchemaMetaData extends DataClass implements Insertable<SchemaMetaData> {
  final String key;
  final String value;
  const SchemaMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SchemaMetaCompanion toCompanion(bool nullToAbsent) {
    return SchemaMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SchemaMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchemaMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SchemaMetaData copyWith({String? key, String? value}) => SchemaMetaData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SchemaMetaData copyWithCompanion(SchemaMetaCompanion data) {
    return SchemaMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchemaMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class SchemaMetaCompanion extends UpdateCompanion<SchemaMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SchemaMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchemaMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SchemaMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchemaMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SchemaMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final $ReadingParamsTable readingParams = $ReadingParamsTable(this);
  late final $PartsTable parts = $PartsTable(this);
  late final $BinsTable bins = $BinsTable(this);
  late final $ReadingTagsTable readingTags = $ReadingTagsTable(this);
  late final $SweepsTable sweeps = $SweepsTable(this);
  late final $SweepTracesTable sweepTraces = $SweepTracesTable(this);
  late final $SchemaMetaTable schemaMeta = $SchemaMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        devices,
        sessions,
        readings,
        readingParams,
        parts,
        bins,
        readingTags,
        sweeps,
        sweepTraces,
        schemaMeta
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('readings',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reading_params', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('parts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('bins', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('readings',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reading_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('parts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reading_tags', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bins',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reading_tags', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('readings',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('sweeps', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('sweeps',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('sweep_traces', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String serial,
  Value<String?> productName,
  Value<String?> hardwareRev,
  Value<String?> firmwareRev,
  Value<double?> rMt2,
  Value<double?> calR1k0,
  Value<double?> calR8k2,
  Value<double?> calR68k,
  Value<double?> calR470k,
  required int firstSeenMs,
  required int lastSeenMs,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> serial,
  Value<String?> productName,
  Value<String?> hardwareRev,
  Value<String?> firmwareRev,
  Value<double?> rMt2,
  Value<double?> calR1k0,
  Value<double?> calR8k2,
  Value<double?> calR68k,
  Value<double?> calR470k,
  Value<int> firstSeenMs,
  Value<int> lastSeenMs,
  Value<int> rowid,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDatabase, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sessions,
          aliasName: 'devices__serial__sessions__device_serial');

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions).filter(
        (f) =>
            f.deviceSerial.serial.sqlEquals($_itemColumn<String>('serial')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serial => $composableBuilder(
      column: $table.serial, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hardwareRev => $composableBuilder(
      column: $table.hardwareRev, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firmwareRev => $composableBuilder(
      column: $table.firmwareRev, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rMt2 => $composableBuilder(
      column: $table.rMt2, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calR1k0 => $composableBuilder(
      column: $table.calR1k0, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calR8k2 => $composableBuilder(
      column: $table.calR8k2, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calR68k => $composableBuilder(
      column: $table.calR68k, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calR470k => $composableBuilder(
      column: $table.calR470k, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get firstSeenMs => $composableBuilder(
      column: $table.firstSeenMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastSeenMs => $composableBuilder(
      column: $table.lastSeenMs, builder: (column) => ColumnFilters(column));

  Expression<bool> sessionsRefs(
      Expression<bool> Function($$SessionsTableFilterComposer f) f) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serial,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.deviceSerial,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serial => $composableBuilder(
      column: $table.serial, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hardwareRev => $composableBuilder(
      column: $table.hardwareRev, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firmwareRev => $composableBuilder(
      column: $table.firmwareRev, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rMt2 => $composableBuilder(
      column: $table.rMt2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calR1k0 => $composableBuilder(
      column: $table.calR1k0, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calR8k2 => $composableBuilder(
      column: $table.calR8k2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calR68k => $composableBuilder(
      column: $table.calR68k, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calR470k => $composableBuilder(
      column: $table.calR470k, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get firstSeenMs => $composableBuilder(
      column: $table.firstSeenMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastSeenMs => $composableBuilder(
      column: $table.lastSeenMs, builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<String> get hardwareRev => $composableBuilder(
      column: $table.hardwareRev, builder: (column) => column);

  GeneratedColumn<String> get firmwareRev => $composableBuilder(
      column: $table.firmwareRev, builder: (column) => column);

  GeneratedColumn<double> get rMt2 =>
      $composableBuilder(column: $table.rMt2, builder: (column) => column);

  GeneratedColumn<double> get calR1k0 =>
      $composableBuilder(column: $table.calR1k0, builder: (column) => column);

  GeneratedColumn<double> get calR8k2 =>
      $composableBuilder(column: $table.calR8k2, builder: (column) => column);

  GeneratedColumn<double> get calR68k =>
      $composableBuilder(column: $table.calR68k, builder: (column) => column);

  GeneratedColumn<double> get calR470k =>
      $composableBuilder(column: $table.calR470k, builder: (column) => column);

  GeneratedColumn<int> get firstSeenMs => $composableBuilder(
      column: $table.firstSeenMs, builder: (column) => column);

  GeneratedColumn<int> get lastSeenMs => $composableBuilder(
      column: $table.lastSeenMs, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
      Expression<T> Function($$SessionsTableAnnotationComposer a) f) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.serial,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.deviceSerial,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, $$DevicesTableReferences),
    Device,
    PrefetchHooks Function({bool sessionsRefs})> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> serial = const Value.absent(),
            Value<String?> productName = const Value.absent(),
            Value<String?> hardwareRev = const Value.absent(),
            Value<String?> firmwareRev = const Value.absent(),
            Value<double?> rMt2 = const Value.absent(),
            Value<double?> calR1k0 = const Value.absent(),
            Value<double?> calR8k2 = const Value.absent(),
            Value<double?> calR68k = const Value.absent(),
            Value<double?> calR470k = const Value.absent(),
            Value<int> firstSeenMs = const Value.absent(),
            Value<int> lastSeenMs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            serial: serial,
            productName: productName,
            hardwareRev: hardwareRev,
            firmwareRev: firmwareRev,
            rMt2: rMt2,
            calR1k0: calR1k0,
            calR8k2: calR8k2,
            calR68k: calR68k,
            calR470k: calR470k,
            firstSeenMs: firstSeenMs,
            lastSeenMs: lastSeenMs,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String serial,
            Value<String?> productName = const Value.absent(),
            Value<String?> hardwareRev = const Value.absent(),
            Value<String?> firmwareRev = const Value.absent(),
            Value<double?> rMt2 = const Value.absent(),
            Value<double?> calR1k0 = const Value.absent(),
            Value<double?> calR8k2 = const Value.absent(),
            Value<double?> calR68k = const Value.absent(),
            Value<double?> calR470k = const Value.absent(),
            required int firstSeenMs,
            required int lastSeenMs,
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            serial: serial,
            productName: productName,
            hardwareRev: hardwareRev,
            firmwareRev: firmwareRev,
            rMt2: rMt2,
            calR1k0: calR1k0,
            calR8k2: calR8k2,
            calR68k: calR68k,
            calR470k: calR470k,
            firstSeenMs: firstSeenMs,
            lastSeenMs: lastSeenMs,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DevicesTable, Device>(table),
                    $$DevicesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedData<Device, $DevicesTable, Session>(
                        currentTable: table,
                        referencedTable:
                            $$DevicesTableReferences._sessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DevicesTableReferences(db, table, p0)
                                .sessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.deviceSerial == item.serial),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, $$DevicesTableReferences),
    Device,
    PrefetchHooks Function({bool sessionsRefs})>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String?> deviceSerial,
  required int startedAtMs,
  Value<int?> endedAtMs,
  required String platform,
  required String appVersion,
  Value<String?> notes,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String?> deviceSerial,
  Value<int> startedAtMs,
  Value<int?> endedAtMs,
  Value<String> platform,
  Value<String> appVersion,
  Value<String?> notes,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceSerialTable(_$AppDatabase db) =>
      db.devices.createAlias('sessions__device_serial__devices__serial');

  $$DevicesTableProcessedTableManager? get deviceSerial {
    final $_column = $_itemColumn<String>('device_serial');
    if ($_column == null) return null;
    final manager = $$DevicesTableTableManager($_db, $_db.devices)
        .filter((f) => f.serial.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceSerialTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ReadingsTable, List<ReadingEntity>>
      _readingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readings,
              aliasName: 'sessions__id__readings__session_id');

  $$ReadingsTableProcessedTableManager get readingsRefs {
    final manager = $$ReadingsTableTableManager($_db, $_db.readings)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SweepsTable, List<SweepEntity>> _sweepsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sweeps,
          aliasName: 'sessions__id__sweeps__session_id');

  $$SweepsTableProcessedTableManager get sweepsRefs {
    final manager = $$SweepsTableTableManager($_db, $_db.sweeps)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sweepsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAtMs => $composableBuilder(
      column: $table.startedAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endedAtMs => $composableBuilder(
      column: $table.endedAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$DevicesTableFilterComposer get deviceSerial {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceSerial,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.serial,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableFilterComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> readingsRefs(
      Expression<bool> Function($$ReadingsTableFilterComposer f) f) {
    final $$ReadingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableFilterComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sweepsRefs(
      Expression<bool> Function($$SweepsTableFilterComposer f) f) {
    final $$SweepsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sweeps,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepsTableFilterComposer(
              $db: $db,
              $table: $db.sweeps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
      column: $table.startedAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endedAtMs => $composableBuilder(
      column: $table.endedAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$DevicesTableOrderingComposer get deviceSerial {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceSerial,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.serial,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableOrderingComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
      column: $table.startedAtMs, builder: (column) => column);

  GeneratedColumn<int> get endedAtMs =>
      $composableBuilder(column: $table.endedAtMs, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
      column: $table.appVersion, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceSerial {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deviceSerial,
        referencedTable: $db.devices,
        getReferencedColumn: (t) => t.serial,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DevicesTableAnnotationComposer(
              $db: $db,
              $table: $db.devices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> readingsRefs<T extends Object>(
      Expression<T> Function($$ReadingsTableAnnotationComposer a) f) {
    final $$ReadingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableAnnotationComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sweepsRefs<T extends Object>(
      Expression<T> Function($$SweepsTableAnnotationComposer a) f) {
    final $$SweepsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sweeps,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepsTableAnnotationComposer(
              $db: $db,
              $table: $db.sweeps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function(
        {bool deviceSerial, bool readingsRefs, bool sweepsRefs})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceSerial = const Value.absent(),
            Value<int> startedAtMs = const Value.absent(),
            Value<int?> endedAtMs = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> appVersion = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            deviceSerial: deviceSerial,
            startedAtMs: startedAtMs,
            endedAtMs: endedAtMs,
            platform: platform,
            appVersion: appVersion,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> deviceSerial = const Value.absent(),
            required int startedAtMs,
            Value<int?> endedAtMs = const Value.absent(),
            required String platform,
            required String appVersion,
            Value<String?> notes = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            deviceSerial: deviceSerial,
            startedAtMs: startedAtMs,
            endedAtMs: endedAtMs,
            platform: platform,
            appVersion: appVersion,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SessionsTable, Session>(table),
                    $$SessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {deviceSerial = false,
              readingsRefs = false,
              sweepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (readingsRefs) db.readings,
                if (sweepsRefs) db.sweeps
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (deviceSerial) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deviceSerial,
                    referencedTable:
                        $$SessionsTableReferences._deviceSerialTable(db),
                    referencedColumn:
                        $$SessionsTableReferences._deviceSerialTable(db).serial,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (readingsRefs)
                    await $_getPrefetchedData<Session, $SessionsTable,
                            ReadingEntity>(
                        currentTable: table,
                        referencedTable:
                            $$SessionsTableReferences._readingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0)
                                .readingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items),
                  if (sweepsRefs)
                    await $_getPrefetchedData<Session, $SessionsTable,
                            SweepEntity>(
                        currentTable: table,
                        referencedTable:
                            $$SessionsTableReferences._sweepsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0).sweepsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function(
        {bool deviceSerial, bool readingsRefs, bool sweepsRefs})>;
typedef $$ReadingsTableCreateCompanionBuilder = ReadingsCompanion Function({
  Value<int> id,
  required int sessionId,
  required int takenAtMs,
  required String source,
  required int type,
  required int config,
  required int flags,
  required Uint8List rawFrame,
  required int decoderVersion,
  Value<double?> battV,
  Value<double?> v12V,
  Value<double?> vrefV,
});
typedef $$ReadingsTableUpdateCompanionBuilder = ReadingsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> takenAtMs,
  Value<String> source,
  Value<int> type,
  Value<int> config,
  Value<int> flags,
  Value<Uint8List> rawFrame,
  Value<int> decoderVersion,
  Value<double?> battV,
  Value<double?> v12V,
  Value<double?> vrefV,
});

final class $$ReadingsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingsTable, ReadingEntity> {
  $$ReadingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('readings__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ReadingParamsTable, List<ReadingParam>>
      _readingParamsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readingParams,
              aliasName: 'readings__id__reading_params__reading_id');

  $$ReadingParamsTableProcessedTableManager get readingParamsRefs {
    final manager = $$ReadingParamsTableTableManager($_db, $_db.readingParams)
        .filter((f) => f.readingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingParamsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReadingTagsTable, List<ReadingTagEntity>>
      _readingTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readingTags,
              aliasName: 'readings__id__reading_tags__reading_id');

  $$ReadingTagsTableProcessedTableManager get readingTagsRefs {
    final manager = $$ReadingTagsTableTableManager($_db, $_db.readingTags)
        .filter((f) => f.readingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SweepsTable, List<SweepEntity>> _sweepsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sweeps,
          aliasName: 'readings__id__sweeps__reading_id');

  $$SweepsTableProcessedTableManager get sweepsRefs {
    final manager = $$SweepsTableTableManager($_db, $_db.sweeps)
        .filter((f) => f.readingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sweepsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get takenAtMs => $composableBuilder(
      column: $table.takenAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get config => $composableBuilder(
      column: $table.config, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flags => $composableBuilder(
      column: $table.flags, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get rawFrame => $composableBuilder(
      column: $table.rawFrame, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get decoderVersion => $composableBuilder(
      column: $table.decoderVersion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get battV => $composableBuilder(
      column: $table.battV, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get v12V => $composableBuilder(
      column: $table.v12V, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vrefV => $composableBuilder(
      column: $table.vrefV, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> readingParamsRefs(
      Expression<bool> Function($$ReadingParamsTableFilterComposer f) f) {
    final $$ReadingParamsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingParams,
        getReferencedColumn: (t) => t.readingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingParamsTableFilterComposer(
              $db: $db,
              $table: $db.readingParams,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> readingTagsRefs(
      Expression<bool> Function($$ReadingTagsTableFilterComposer f) f) {
    final $$ReadingTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingTags,
        getReferencedColumn: (t) => t.readingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingTagsTableFilterComposer(
              $db: $db,
              $table: $db.readingTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sweepsRefs(
      Expression<bool> Function($$SweepsTableFilterComposer f) f) {
    final $$SweepsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sweeps,
        getReferencedColumn: (t) => t.readingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepsTableFilterComposer(
              $db: $db,
              $table: $db.sweeps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get takenAtMs => $composableBuilder(
      column: $table.takenAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get config => $composableBuilder(
      column: $table.config, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flags => $composableBuilder(
      column: $table.flags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get rawFrame => $composableBuilder(
      column: $table.rawFrame, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get decoderVersion => $composableBuilder(
      column: $table.decoderVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get battV => $composableBuilder(
      column: $table.battV, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get v12V => $composableBuilder(
      column: $table.v12V, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vrefV => $composableBuilder(
      column: $table.vrefV, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get takenAtMs =>
      $composableBuilder(column: $table.takenAtMs, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<int> get flags =>
      $composableBuilder(column: $table.flags, builder: (column) => column);

  GeneratedColumn<Uint8List> get rawFrame =>
      $composableBuilder(column: $table.rawFrame, builder: (column) => column);

  GeneratedColumn<int> get decoderVersion => $composableBuilder(
      column: $table.decoderVersion, builder: (column) => column);

  GeneratedColumn<double> get battV =>
      $composableBuilder(column: $table.battV, builder: (column) => column);

  GeneratedColumn<double> get v12V =>
      $composableBuilder(column: $table.v12V, builder: (column) => column);

  GeneratedColumn<double> get vrefV =>
      $composableBuilder(column: $table.vrefV, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> readingParamsRefs<T extends Object>(
      Expression<T> Function($$ReadingParamsTableAnnotationComposer a) f) {
    final $$ReadingParamsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingParams,
        getReferencedColumn: (t) => t.readingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingParamsTableAnnotationComposer(
              $db: $db,
              $table: $db.readingParams,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> readingTagsRefs<T extends Object>(
      Expression<T> Function($$ReadingTagsTableAnnotationComposer a) f) {
    final $$ReadingTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingTags,
        getReferencedColumn: (t) => t.readingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.readingTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sweepsRefs<T extends Object>(
      Expression<T> Function($$SweepsTableAnnotationComposer a) f) {
    final $$SweepsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sweeps,
        getReferencedColumn: (t) => t.readingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepsTableAnnotationComposer(
              $db: $db,
              $table: $db.sweeps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingsTable,
    ReadingEntity,
    $$ReadingsTableFilterComposer,
    $$ReadingsTableOrderingComposer,
    $$ReadingsTableAnnotationComposer,
    $$ReadingsTableCreateCompanionBuilder,
    $$ReadingsTableUpdateCompanionBuilder,
    (ReadingEntity, $$ReadingsTableReferences),
    ReadingEntity,
    PrefetchHooks Function(
        {bool sessionId,
        bool readingParamsRefs,
        bool readingTagsRefs,
        bool sweepsRefs})> {
  $$ReadingsTableTableManager(_$AppDatabase db, $ReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int> takenAtMs = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<int> config = const Value.absent(),
            Value<int> flags = const Value.absent(),
            Value<Uint8List> rawFrame = const Value.absent(),
            Value<int> decoderVersion = const Value.absent(),
            Value<double?> battV = const Value.absent(),
            Value<double?> v12V = const Value.absent(),
            Value<double?> vrefV = const Value.absent(),
          }) =>
              ReadingsCompanion(
            id: id,
            sessionId: sessionId,
            takenAtMs: takenAtMs,
            source: source,
            type: type,
            config: config,
            flags: flags,
            rawFrame: rawFrame,
            decoderVersion: decoderVersion,
            battV: battV,
            v12V: v12V,
            vrefV: vrefV,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required int takenAtMs,
            required String source,
            required int type,
            required int config,
            required int flags,
            required Uint8List rawFrame,
            required int decoderVersion,
            Value<double?> battV = const Value.absent(),
            Value<double?> v12V = const Value.absent(),
            Value<double?> vrefV = const Value.absent(),
          }) =>
              ReadingsCompanion.insert(
            id: id,
            sessionId: sessionId,
            takenAtMs: takenAtMs,
            source: source,
            type: type,
            config: config,
            flags: flags,
            rawFrame: rawFrame,
            decoderVersion: decoderVersion,
            battV: battV,
            v12V: v12V,
            vrefV: vrefV,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReadingsTable, ReadingEntity>(table),
                    $$ReadingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {sessionId = false,
              readingParamsRefs = false,
              readingTagsRefs = false,
              sweepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (readingParamsRefs) db.readingParams,
                if (readingTagsRefs) db.readingTags,
                if (sweepsRefs) db.sweeps
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$ReadingsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$ReadingsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (readingParamsRefs)
                    await $_getPrefetchedData<ReadingEntity, $ReadingsTable,
                            ReadingParam>(
                        currentTable: table,
                        referencedTable: $$ReadingsTableReferences
                            ._readingParamsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ReadingsTableReferences(db, table, p0)
                                .readingParamsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.readingId == item.id),
                        typedResults: items),
                  if (readingTagsRefs)
                    await $_getPrefetchedData<ReadingEntity, $ReadingsTable,
                            ReadingTagEntity>(
                        currentTable: table,
                        referencedTable:
                            $$ReadingsTableReferences._readingTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ReadingsTableReferences(db, table, p0)
                                .readingTagsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.readingId == item.id),
                        typedResults: items),
                  if (sweepsRefs)
                    await $_getPrefetchedData<ReadingEntity, $ReadingsTable,
                            SweepEntity>(
                        currentTable: table,
                        referencedTable:
                            $$ReadingsTableReferences._sweepsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ReadingsTableReferences(db, table, p0).sweepsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.readingId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ReadingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingsTable,
    ReadingEntity,
    $$ReadingsTableFilterComposer,
    $$ReadingsTableOrderingComposer,
    $$ReadingsTableAnnotationComposer,
    $$ReadingsTableCreateCompanionBuilder,
    $$ReadingsTableUpdateCompanionBuilder,
    (ReadingEntity, $$ReadingsTableReferences),
    ReadingEntity,
    PrefetchHooks Function(
        {bool sessionId,
        bool readingParamsRefs,
        bool readingTagsRefs,
        bool sweepsRefs})>;
typedef $$ReadingParamsTableCreateCompanionBuilder = ReadingParamsCompanion
    Function({
  required int readingId,
  required String key,
  required double value,
  required String unit,
  Value<int> rowid,
});
typedef $$ReadingParamsTableUpdateCompanionBuilder = ReadingParamsCompanion
    Function({
  Value<int> readingId,
  Value<String> key,
  Value<double> value,
  Value<String> unit,
  Value<int> rowid,
});

final class $$ReadingParamsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingParamsTable, ReadingParam> {
  $$ReadingParamsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ReadingsTable _readingIdTable(_$AppDatabase db) =>
      db.readings.createAlias('reading_params__reading_id__readings__id');

  $$ReadingsTableProcessedTableManager get readingId {
    final $_column = $_itemColumn<int>('reading_id')!;

    final manager = $$ReadingsTableTableManager($_db, $_db.readings)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_readingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReadingParamsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingParamsTable> {
  $$ReadingParamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  $$ReadingsTableFilterComposer get readingId {
    final $$ReadingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableFilterComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingParamsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingParamsTable> {
  $$ReadingParamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  $$ReadingsTableOrderingComposer get readingId {
    final $$ReadingsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableOrderingComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingParamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingParamsTable> {
  $$ReadingParamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  $$ReadingsTableAnnotationComposer get readingId {
    final $$ReadingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableAnnotationComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingParamsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingParamsTable,
    ReadingParam,
    $$ReadingParamsTableFilterComposer,
    $$ReadingParamsTableOrderingComposer,
    $$ReadingParamsTableAnnotationComposer,
    $$ReadingParamsTableCreateCompanionBuilder,
    $$ReadingParamsTableUpdateCompanionBuilder,
    (ReadingParam, $$ReadingParamsTableReferences),
    ReadingParam,
    PrefetchHooks Function({bool readingId})> {
  $$ReadingParamsTableTableManager(_$AppDatabase db, $ReadingParamsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingParamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingParamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingParamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> readingId = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingParamsCompanion(
            readingId: readingId,
            key: key,
            value: value,
            unit: unit,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int readingId,
            required String key,
            required double value,
            required String unit,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingParamsCompanion.insert(
            readingId: readingId,
            key: key,
            value: value,
            unit: unit,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReadingParamsTable, ReadingParam>(table),
                    $$ReadingParamsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({readingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (readingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.readingId,
                    referencedTable:
                        $$ReadingParamsTableReferences._readingIdTable(db),
                    referencedColumn:
                        $$ReadingParamsTableReferences._readingIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReadingParamsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingParamsTable,
    ReadingParam,
    $$ReadingParamsTableFilterComposer,
    $$ReadingParamsTableOrderingComposer,
    $$ReadingParamsTableAnnotationComposer,
    $$ReadingParamsTableCreateCompanionBuilder,
    $$ReadingParamsTableUpdateCompanionBuilder,
    (ReadingParam, $$ReadingParamsTableReferences),
    ReadingParam,
    PrefetchHooks Function({bool readingId})>;
typedef $$PartsTableCreateCompanionBuilder = PartsCompanion Function({
  Value<int> id,
  required String partNumber,
  Value<String?> manufacturer,
  Value<String?> description,
  Value<String?> family,
});
typedef $$PartsTableUpdateCompanionBuilder = PartsCompanion Function({
  Value<int> id,
  Value<String> partNumber,
  Value<String?> manufacturer,
  Value<String?> description,
  Value<String?> family,
});

final class $$PartsTableReferences
    extends BaseReferences<_$AppDatabase, $PartsTable, PartEntity> {
  $$PartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BinsTable, List<BinEntity>> _binsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.bins,
          aliasName: 'parts__id__bins__part_id');

  $$BinsTableProcessedTableManager get binsRefs {
    final manager = $$BinsTableTableManager($_db, $_db.bins)
        .filter((f) => f.partId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_binsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReadingTagsTable, List<ReadingTagEntity>>
      _readingTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readingTags,
              aliasName: 'parts__id__reading_tags__part_id');

  $$ReadingTagsTableProcessedTableManager get readingTagsRefs {
    final manager = $$ReadingTagsTableTableManager($_db, $_db.readingTags)
        .filter((f) => f.partId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PartsTableFilterComposer extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get family => $composableBuilder(
      column: $table.family, builder: (column) => ColumnFilters(column));

  Expression<bool> binsRefs(
      Expression<bool> Function($$BinsTableFilterComposer f) f) {
    final $$BinsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bins,
        getReferencedColumn: (t) => t.partId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BinsTableFilterComposer(
              $db: $db,
              $table: $db.bins,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> readingTagsRefs(
      Expression<bool> Function($$ReadingTagsTableFilterComposer f) f) {
    final $$ReadingTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingTags,
        getReferencedColumn: (t) => t.partId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingTagsTableFilterComposer(
              $db: $db,
              $table: $db.readingTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PartsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get family => $composableBuilder(
      column: $table.family, builder: (column) => ColumnOrderings(column));
}

class $$PartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partNumber => $composableBuilder(
      column: $table.partNumber, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
      column: $table.manufacturer, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  Expression<T> binsRefs<T extends Object>(
      Expression<T> Function($$BinsTableAnnotationComposer a) f) {
    final $$BinsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bins,
        getReferencedColumn: (t) => t.partId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BinsTableAnnotationComposer(
              $db: $db,
              $table: $db.bins,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> readingTagsRefs<T extends Object>(
      Expression<T> Function($$ReadingTagsTableAnnotationComposer a) f) {
    final $$ReadingTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingTags,
        getReferencedColumn: (t) => t.partId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.readingTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PartsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PartsTable,
    PartEntity,
    $$PartsTableFilterComposer,
    $$PartsTableOrderingComposer,
    $$PartsTableAnnotationComposer,
    $$PartsTableCreateCompanionBuilder,
    $$PartsTableUpdateCompanionBuilder,
    (PartEntity, $$PartsTableReferences),
    PartEntity,
    PrefetchHooks Function({bool binsRefs, bool readingTagsRefs})> {
  $$PartsTableTableManager(_$AppDatabase db, $PartsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> partNumber = const Value.absent(),
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> family = const Value.absent(),
          }) =>
              PartsCompanion(
            id: id,
            partNumber: partNumber,
            manufacturer: manufacturer,
            description: description,
            family: family,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String partNumber,
            Value<String?> manufacturer = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> family = const Value.absent(),
          }) =>
              PartsCompanion.insert(
            id: id,
            partNumber: partNumber,
            manufacturer: manufacturer,
            description: description,
            family: family,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PartsTable, PartEntity>(table),
                    $$PartsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({binsRefs = false, readingTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (binsRefs) db.bins,
                if (readingTagsRefs) db.readingTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (binsRefs)
                    await $_getPrefetchedData<PartEntity, $PartsTable,
                            BinEntity>(
                        currentTable: table,
                        referencedTable:
                            $$PartsTableReferences._binsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PartsTableReferences(db, table, p0).binsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.partId == item.id),
                        typedResults: items),
                  if (readingTagsRefs)
                    await $_getPrefetchedData<PartEntity, $PartsTable,
                            ReadingTagEntity>(
                        currentTable: table,
                        referencedTable:
                            $$PartsTableReferences._readingTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PartsTableReferences(db, table, p0)
                                .readingTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.partId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PartsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PartsTable,
    PartEntity,
    $$PartsTableFilterComposer,
    $$PartsTableOrderingComposer,
    $$PartsTableAnnotationComposer,
    $$PartsTableCreateCompanionBuilder,
    $$PartsTableUpdateCompanionBuilder,
    (PartEntity, $$PartsTableReferences),
    PartEntity,
    PrefetchHooks Function({bool binsRefs, bool readingTagsRefs})>;
typedef $$BinsTableCreateCompanionBuilder = BinsCompanion Function({
  Value<int> id,
  required int partId,
  required String name,
  required int createdAtMs,
  Value<String?> notes,
});
typedef $$BinsTableUpdateCompanionBuilder = BinsCompanion Function({
  Value<int> id,
  Value<int> partId,
  Value<String> name,
  Value<int> createdAtMs,
  Value<String?> notes,
});

final class $$BinsTableReferences
    extends BaseReferences<_$AppDatabase, $BinsTable, BinEntity> {
  $$BinsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PartsTable _partIdTable(_$AppDatabase db) =>
      db.parts.createAlias('bins__part_id__parts__id');

  $$PartsTableProcessedTableManager get partId {
    final $_column = $_itemColumn<int>('part_id')!;

    final manager = $$PartsTableTableManager($_db, $_db.parts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ReadingTagsTable, List<ReadingTagEntity>>
      _readingTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readingTags,
              aliasName: 'bins__id__reading_tags__bin_id');

  $$ReadingTagsTableProcessedTableManager get readingTagsRefs {
    final manager = $$ReadingTagsTableTableManager($_db, $_db.readingTags)
        .filter((f) => f.binId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BinsTableFilterComposer extends Composer<_$AppDatabase, $BinsTable> {
  $$BinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$PartsTableFilterComposer get partId {
    final $$PartsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableFilterComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> readingTagsRefs(
      Expression<bool> Function($$ReadingTagsTableFilterComposer f) f) {
    final $$ReadingTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingTags,
        getReferencedColumn: (t) => t.binId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingTagsTableFilterComposer(
              $db: $db,
              $table: $db.readingTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BinsTableOrderingComposer extends Composer<_$AppDatabase, $BinsTable> {
  $$BinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$PartsTableOrderingComposer get partId {
    final $$PartsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableOrderingComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BinsTable> {
  $$BinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
      column: $table.createdAtMs, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PartsTableAnnotationComposer get partId {
    final $$PartsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableAnnotationComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> readingTagsRefs<T extends Object>(
      Expression<T> Function($$ReadingTagsTableAnnotationComposer a) f) {
    final $$ReadingTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingTags,
        getReferencedColumn: (t) => t.binId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.readingTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BinsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BinsTable,
    BinEntity,
    $$BinsTableFilterComposer,
    $$BinsTableOrderingComposer,
    $$BinsTableAnnotationComposer,
    $$BinsTableCreateCompanionBuilder,
    $$BinsTableUpdateCompanionBuilder,
    (BinEntity, $$BinsTableReferences),
    BinEntity,
    PrefetchHooks Function({bool partId, bool readingTagsRefs})> {
  $$BinsTableTableManager(_$AppDatabase db, $BinsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> partId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> createdAtMs = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              BinsCompanion(
            id: id,
            partId: partId,
            name: name,
            createdAtMs: createdAtMs,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int partId,
            required String name,
            required int createdAtMs,
            Value<String?> notes = const Value.absent(),
          }) =>
              BinsCompanion.insert(
            id: id,
            partId: partId,
            name: name,
            createdAtMs: createdAtMs,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$BinsTable, BinEntity>(table),
                    $$BinsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({partId = false, readingTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (readingTagsRefs) db.readingTags],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (partId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.partId,
                    referencedTable: $$BinsTableReferences._partIdTable(db),
                    referencedColumn: $$BinsTableReferences._partIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (readingTagsRefs)
                    await $_getPrefetchedData<BinEntity, $BinsTable,
                            ReadingTagEntity>(
                        currentTable: table,
                        referencedTable:
                            $$BinsTableReferences._readingTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BinsTableReferences(db, table, p0)
                                .readingTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.binId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BinsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BinsTable,
    BinEntity,
    $$BinsTableFilterComposer,
    $$BinsTableOrderingComposer,
    $$BinsTableAnnotationComposer,
    $$BinsTableCreateCompanionBuilder,
    $$BinsTableUpdateCompanionBuilder,
    (BinEntity, $$BinsTableReferences),
    BinEntity,
    PrefetchHooks Function({bool partId, bool readingTagsRefs})>;
typedef $$ReadingTagsTableCreateCompanionBuilder = ReadingTagsCompanion
    Function({
  Value<int> readingId,
  Value<int?> partId,
  Value<int?> binId,
  Value<String?> label,
  Value<String?> notes,
  Value<bool> starred,
  required int updatedAtMs,
});
typedef $$ReadingTagsTableUpdateCompanionBuilder = ReadingTagsCompanion
    Function({
  Value<int> readingId,
  Value<int?> partId,
  Value<int?> binId,
  Value<String?> label,
  Value<String?> notes,
  Value<bool> starred,
  Value<int> updatedAtMs,
});

final class $$ReadingTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingTagsTable, ReadingTagEntity> {
  $$ReadingTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReadingsTable _readingIdTable(_$AppDatabase db) =>
      db.readings.createAlias('reading_tags__reading_id__readings__id');

  $$ReadingsTableProcessedTableManager get readingId {
    final $_column = $_itemColumn<int>('reading_id')!;

    final manager = $$ReadingsTableTableManager($_db, $_db.readings)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_readingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PartsTable _partIdTable(_$AppDatabase db) =>
      db.parts.createAlias('reading_tags__part_id__parts__id');

  $$PartsTableProcessedTableManager? get partId {
    final $_column = $_itemColumn<int>('part_id');
    if ($_column == null) return null;
    final manager = $$PartsTableTableManager($_db, $_db.parts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BinsTable _binIdTable(_$AppDatabase db) =>
      db.bins.createAlias('reading_tags__bin_id__bins__id');

  $$BinsTableProcessedTableManager? get binId {
    final $_column = $_itemColumn<int>('bin_id');
    if ($_column == null) return null;
    final manager = $$BinsTableTableManager($_db, $_db.bins)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_binIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReadingTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingTagsTable> {
  $$ReadingTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get starred => $composableBuilder(
      column: $table.starred, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
      column: $table.updatedAtMs, builder: (column) => ColumnFilters(column));

  $$ReadingsTableFilterComposer get readingId {
    final $$ReadingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableFilterComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PartsTableFilterComposer get partId {
    final $$PartsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableFilterComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BinsTableFilterComposer get binId {
    final $$BinsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.binId,
        referencedTable: $db.bins,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BinsTableFilterComposer(
              $db: $db,
              $table: $db.bins,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingTagsTable> {
  $$ReadingTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get starred => $composableBuilder(
      column: $table.starred, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
      column: $table.updatedAtMs, builder: (column) => ColumnOrderings(column));

  $$ReadingsTableOrderingComposer get readingId {
    final $$ReadingsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableOrderingComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PartsTableOrderingComposer get partId {
    final $$PartsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableOrderingComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BinsTableOrderingComposer get binId {
    final $$BinsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.binId,
        referencedTable: $db.bins,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BinsTableOrderingComposer(
              $db: $db,
              $table: $db.bins,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingTagsTable> {
  $$ReadingTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get starred =>
      $composableBuilder(column: $table.starred, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
      column: $table.updatedAtMs, builder: (column) => column);

  $$ReadingsTableAnnotationComposer get readingId {
    final $$ReadingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableAnnotationComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PartsTableAnnotationComposer get partId {
    final $$PartsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.partId,
        referencedTable: $db.parts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PartsTableAnnotationComposer(
              $db: $db,
              $table: $db.parts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BinsTableAnnotationComposer get binId {
    final $$BinsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.binId,
        referencedTable: $db.bins,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BinsTableAnnotationComposer(
              $db: $db,
              $table: $db.bins,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingTagsTable,
    ReadingTagEntity,
    $$ReadingTagsTableFilterComposer,
    $$ReadingTagsTableOrderingComposer,
    $$ReadingTagsTableAnnotationComposer,
    $$ReadingTagsTableCreateCompanionBuilder,
    $$ReadingTagsTableUpdateCompanionBuilder,
    (ReadingTagEntity, $$ReadingTagsTableReferences),
    ReadingTagEntity,
    PrefetchHooks Function({bool readingId, bool partId, bool binId})> {
  $$ReadingTagsTableTableManager(_$AppDatabase db, $ReadingTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> readingId = const Value.absent(),
            Value<int?> partId = const Value.absent(),
            Value<int?> binId = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> starred = const Value.absent(),
            Value<int> updatedAtMs = const Value.absent(),
          }) =>
              ReadingTagsCompanion(
            readingId: readingId,
            partId: partId,
            binId: binId,
            label: label,
            notes: notes,
            starred: starred,
            updatedAtMs: updatedAtMs,
          ),
          createCompanionCallback: ({
            Value<int> readingId = const Value.absent(),
            Value<int?> partId = const Value.absent(),
            Value<int?> binId = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> starred = const Value.absent(),
            required int updatedAtMs,
          }) =>
              ReadingTagsCompanion.insert(
            readingId: readingId,
            partId: partId,
            binId: binId,
            label: label,
            notes: notes,
            starred: starred,
            updatedAtMs: updatedAtMs,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReadingTagsTable, ReadingTagEntity>(table),
                    $$ReadingTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {readingId = false, partId = false, binId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (readingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.readingId,
                    referencedTable:
                        $$ReadingTagsTableReferences._readingIdTable(db),
                    referencedColumn:
                        $$ReadingTagsTableReferences._readingIdTable(db).id,
                  ) as T;
                }
                if (partId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.partId,
                    referencedTable:
                        $$ReadingTagsTableReferences._partIdTable(db),
                    referencedColumn:
                        $$ReadingTagsTableReferences._partIdTable(db).id,
                  ) as T;
                }
                if (binId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.binId,
                    referencedTable:
                        $$ReadingTagsTableReferences._binIdTable(db),
                    referencedColumn:
                        $$ReadingTagsTableReferences._binIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReadingTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingTagsTable,
    ReadingTagEntity,
    $$ReadingTagsTableFilterComposer,
    $$ReadingTagsTableOrderingComposer,
    $$ReadingTagsTableAnnotationComposer,
    $$ReadingTagsTableCreateCompanionBuilder,
    $$ReadingTagsTableUpdateCompanionBuilder,
    (ReadingTagEntity, $$ReadingTagsTableReferences),
    ReadingTagEntity,
    PrefetchHooks Function({bool readingId, bool partId, bool binId})>;
typedef $$SweepsTableCreateCompanionBuilder = SweepsCompanion Function({
  Value<int> id,
  required int sessionId,
  Value<int?> readingId,
  required String kind,
  required String paramsJson,
  required String xLabel,
  required String yLabel,
  required int startedAtMs,
  Value<int?> durationMs,
  Value<bool> cancelled,
  Value<String?> error,
});
typedef $$SweepsTableUpdateCompanionBuilder = SweepsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int?> readingId,
  Value<String> kind,
  Value<String> paramsJson,
  Value<String> xLabel,
  Value<String> yLabel,
  Value<int> startedAtMs,
  Value<int?> durationMs,
  Value<bool> cancelled,
  Value<String?> error,
});

final class $$SweepsTableReferences
    extends BaseReferences<_$AppDatabase, $SweepsTable, SweepEntity> {
  $$SweepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('sweeps__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ReadingsTable _readingIdTable(_$AppDatabase db) =>
      db.readings.createAlias('sweeps__reading_id__readings__id');

  $$ReadingsTableProcessedTableManager? get readingId {
    final $_column = $_itemColumn<int>('reading_id');
    if ($_column == null) return null;
    final manager = $$ReadingsTableTableManager($_db, $_db.readings)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_readingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SweepTracesTable, List<SweepTraceEntity>>
      _sweepTracesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sweepTraces,
              aliasName: 'sweeps__id__sweep_traces__sweep_id');

  $$SweepTracesTableProcessedTableManager get sweepTracesRefs {
    final manager = $$SweepTracesTableTableManager($_db, $_db.sweepTraces)
        .filter((f) => f.sweepId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sweepTracesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SweepsTableFilterComposer
    extends Composer<_$AppDatabase, $SweepsTable> {
  $$SweepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paramsJson => $composableBuilder(
      column: $table.paramsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get xLabel => $composableBuilder(
      column: $table.xLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get yLabel => $composableBuilder(
      column: $table.yLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAtMs => $composableBuilder(
      column: $table.startedAtMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cancelled => $composableBuilder(
      column: $table.cancelled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ReadingsTableFilterComposer get readingId {
    final $$ReadingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableFilterComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> sweepTracesRefs(
      Expression<bool> Function($$SweepTracesTableFilterComposer f) f) {
    final $$SweepTracesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sweepTraces,
        getReferencedColumn: (t) => t.sweepId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepTracesTableFilterComposer(
              $db: $db,
              $table: $db.sweepTraces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SweepsTableOrderingComposer
    extends Composer<_$AppDatabase, $SweepsTable> {
  $$SweepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paramsJson => $composableBuilder(
      column: $table.paramsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get xLabel => $composableBuilder(
      column: $table.xLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get yLabel => $composableBuilder(
      column: $table.yLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
      column: $table.startedAtMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cancelled => $composableBuilder(
      column: $table.cancelled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ReadingsTableOrderingComposer get readingId {
    final $$ReadingsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableOrderingComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SweepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SweepsTable> {
  $$SweepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get paramsJson => $composableBuilder(
      column: $table.paramsJson, builder: (column) => column);

  GeneratedColumn<String> get xLabel =>
      $composableBuilder(column: $table.xLabel, builder: (column) => column);

  GeneratedColumn<String> get yLabel =>
      $composableBuilder(column: $table.yLabel, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
      column: $table.startedAtMs, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<bool> get cancelled =>
      $composableBuilder(column: $table.cancelled, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ReadingsTableAnnotationComposer get readingId {
    final $$ReadingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.readingId,
        referencedTable: $db.readings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingsTableAnnotationComposer(
              $db: $db,
              $table: $db.readings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> sweepTracesRefs<T extends Object>(
      Expression<T> Function($$SweepTracesTableAnnotationComposer a) f) {
    final $$SweepTracesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sweepTraces,
        getReferencedColumn: (t) => t.sweepId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepTracesTableAnnotationComposer(
              $db: $db,
              $table: $db.sweepTraces,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SweepsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SweepsTable,
    SweepEntity,
    $$SweepsTableFilterComposer,
    $$SweepsTableOrderingComposer,
    $$SweepsTableAnnotationComposer,
    $$SweepsTableCreateCompanionBuilder,
    $$SweepsTableUpdateCompanionBuilder,
    (SweepEntity, $$SweepsTableReferences),
    SweepEntity,
    PrefetchHooks Function(
        {bool sessionId, bool readingId, bool sweepTracesRefs})> {
  $$SweepsTableTableManager(_$AppDatabase db, $SweepsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SweepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SweepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SweepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int?> readingId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> paramsJson = const Value.absent(),
            Value<String> xLabel = const Value.absent(),
            Value<String> yLabel = const Value.absent(),
            Value<int> startedAtMs = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<bool> cancelled = const Value.absent(),
            Value<String?> error = const Value.absent(),
          }) =>
              SweepsCompanion(
            id: id,
            sessionId: sessionId,
            readingId: readingId,
            kind: kind,
            paramsJson: paramsJson,
            xLabel: xLabel,
            yLabel: yLabel,
            startedAtMs: startedAtMs,
            durationMs: durationMs,
            cancelled: cancelled,
            error: error,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            Value<int?> readingId = const Value.absent(),
            required String kind,
            required String paramsJson,
            required String xLabel,
            required String yLabel,
            required int startedAtMs,
            Value<int?> durationMs = const Value.absent(),
            Value<bool> cancelled = const Value.absent(),
            Value<String?> error = const Value.absent(),
          }) =>
              SweepsCompanion.insert(
            id: id,
            sessionId: sessionId,
            readingId: readingId,
            kind: kind,
            paramsJson: paramsJson,
            xLabel: xLabel,
            yLabel: yLabel,
            startedAtMs: startedAtMs,
            durationMs: durationMs,
            cancelled: cancelled,
            error: error,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SweepsTable, SweepEntity>(table),
                    $$SweepsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {sessionId = false, readingId = false, sweepTracesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sweepTracesRefs) db.sweepTraces],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$SweepsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$SweepsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }
                if (readingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.readingId,
                    referencedTable:
                        $$SweepsTableReferences._readingIdTable(db),
                    referencedColumn:
                        $$SweepsTableReferences._readingIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sweepTracesRefs)
                    await $_getPrefetchedData<SweepEntity, $SweepsTable,
                            SweepTraceEntity>(
                        currentTable: table,
                        referencedTable:
                            $$SweepsTableReferences._sweepTracesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SweepsTableReferences(db, table, p0)
                                .sweepTracesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sweepId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SweepsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SweepsTable,
    SweepEntity,
    $$SweepsTableFilterComposer,
    $$SweepsTableOrderingComposer,
    $$SweepsTableAnnotationComposer,
    $$SweepsTableCreateCompanionBuilder,
    $$SweepsTableUpdateCompanionBuilder,
    (SweepEntity, $$SweepsTableReferences),
    SweepEntity,
    PrefetchHooks Function(
        {bool sessionId, bool readingId, bool sweepTracesRefs})>;
typedef $$SweepTracesTableCreateCompanionBuilder = SweepTracesCompanion
    Function({
  Value<int> id,
  required int sweepId,
  required int idx,
  required String label,
  required int nPoints,
  required Uint8List points,
});
typedef $$SweepTracesTableUpdateCompanionBuilder = SweepTracesCompanion
    Function({
  Value<int> id,
  Value<int> sweepId,
  Value<int> idx,
  Value<String> label,
  Value<int> nPoints,
  Value<Uint8List> points,
});

final class $$SweepTracesTableReferences
    extends BaseReferences<_$AppDatabase, $SweepTracesTable, SweepTraceEntity> {
  $$SweepTracesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SweepsTable _sweepIdTable(_$AppDatabase db) =>
      db.sweeps.createAlias('sweep_traces__sweep_id__sweeps__id');

  $$SweepsTableProcessedTableManager get sweepId {
    final $_column = $_itemColumn<int>('sweep_id')!;

    final manager = $$SweepsTableTableManager($_db, $_db.sweeps)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sweepIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SweepTracesTableFilterComposer
    extends Composer<_$AppDatabase, $SweepTracesTable> {
  $$SweepTracesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get idx => $composableBuilder(
      column: $table.idx, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nPoints => $composableBuilder(
      column: $table.nPoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnFilters(column));

  $$SweepsTableFilterComposer get sweepId {
    final $$SweepsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sweepId,
        referencedTable: $db.sweeps,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepsTableFilterComposer(
              $db: $db,
              $table: $db.sweeps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SweepTracesTableOrderingComposer
    extends Composer<_$AppDatabase, $SweepTracesTable> {
  $$SweepTracesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get idx => $composableBuilder(
      column: $table.idx, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nPoints => $composableBuilder(
      column: $table.nPoints, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnOrderings(column));

  $$SweepsTableOrderingComposer get sweepId {
    final $$SweepsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sweepId,
        referencedTable: $db.sweeps,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepsTableOrderingComposer(
              $db: $db,
              $table: $db.sweeps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SweepTracesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SweepTracesTable> {
  $$SweepTracesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get nPoints =>
      $composableBuilder(column: $table.nPoints, builder: (column) => column);

  GeneratedColumn<Uint8List> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  $$SweepsTableAnnotationComposer get sweepId {
    final $$SweepsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sweepId,
        referencedTable: $db.sweeps,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SweepsTableAnnotationComposer(
              $db: $db,
              $table: $db.sweeps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SweepTracesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SweepTracesTable,
    SweepTraceEntity,
    $$SweepTracesTableFilterComposer,
    $$SweepTracesTableOrderingComposer,
    $$SweepTracesTableAnnotationComposer,
    $$SweepTracesTableCreateCompanionBuilder,
    $$SweepTracesTableUpdateCompanionBuilder,
    (SweepTraceEntity, $$SweepTracesTableReferences),
    SweepTraceEntity,
    PrefetchHooks Function({bool sweepId})> {
  $$SweepTracesTableTableManager(_$AppDatabase db, $SweepTracesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SweepTracesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SweepTracesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SweepTracesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sweepId = const Value.absent(),
            Value<int> idx = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> nPoints = const Value.absent(),
            Value<Uint8List> points = const Value.absent(),
          }) =>
              SweepTracesCompanion(
            id: id,
            sweepId: sweepId,
            idx: idx,
            label: label,
            nPoints: nPoints,
            points: points,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sweepId,
            required int idx,
            required String label,
            required int nPoints,
            required Uint8List points,
          }) =>
              SweepTracesCompanion.insert(
            id: id,
            sweepId: sweepId,
            idx: idx,
            label: label,
            nPoints: nPoints,
            points: points,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SweepTracesTable, SweepTraceEntity>(table),
                    $$SweepTracesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sweepId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sweepId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sweepId,
                    referencedTable:
                        $$SweepTracesTableReferences._sweepIdTable(db),
                    referencedColumn:
                        $$SweepTracesTableReferences._sweepIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SweepTracesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SweepTracesTable,
    SweepTraceEntity,
    $$SweepTracesTableFilterComposer,
    $$SweepTracesTableOrderingComposer,
    $$SweepTracesTableAnnotationComposer,
    $$SweepTracesTableCreateCompanionBuilder,
    $$SweepTracesTableUpdateCompanionBuilder,
    (SweepTraceEntity, $$SweepTracesTableReferences),
    SweepTraceEntity,
    PrefetchHooks Function({bool sweepId})>;
typedef $$SchemaMetaTableCreateCompanionBuilder = SchemaMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SchemaMetaTableUpdateCompanionBuilder = SchemaMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SchemaMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SchemaMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SchemaMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SchemaMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchemaMetaTable,
    SchemaMetaData,
    $$SchemaMetaTableFilterComposer,
    $$SchemaMetaTableOrderingComposer,
    $$SchemaMetaTableAnnotationComposer,
    $$SchemaMetaTableCreateCompanionBuilder,
    $$SchemaMetaTableUpdateCompanionBuilder,
    (
      SchemaMetaData,
      BaseReferences<_$AppDatabase, $SchemaMetaTable, SchemaMetaData>
    ),
    SchemaMetaData,
    PrefetchHooks Function()> {
  $$SchemaMetaTableTableManager(_$AppDatabase db, $SchemaMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchemaMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchemaMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchemaMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SchemaMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SchemaMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SchemaMetaTable, SchemaMetaData>(table),
                    BaseReferences<_$AppDatabase, $SchemaMetaTable,
                        SchemaMetaData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SchemaMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchemaMetaTable,
    SchemaMetaData,
    $$SchemaMetaTableFilterComposer,
    $$SchemaMetaTableOrderingComposer,
    $$SchemaMetaTableAnnotationComposer,
    $$SchemaMetaTableCreateCompanionBuilder,
    $$SchemaMetaTableUpdateCompanionBuilder,
    (
      SchemaMetaData,
      BaseReferences<_$AppDatabase, $SchemaMetaTable, SchemaMetaData>
    ),
    SchemaMetaData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$ReadingParamsTableTableManager get readingParams =>
      $$ReadingParamsTableTableManager(_db, _db.readingParams);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db, _db.parts);
  $$BinsTableTableManager get bins => $$BinsTableTableManager(_db, _db.bins);
  $$ReadingTagsTableTableManager get readingTags =>
      $$ReadingTagsTableTableManager(_db, _db.readingTags);
  $$SweepsTableTableManager get sweeps =>
      $$SweepsTableTableManager(_db, _db.sweeps);
  $$SweepTracesTableTableManager get sweepTraces =>
      $$SweepTracesTableTableManager(_db, _db.sweepTraces);
  $$SchemaMetaTableTableManager get schemaMeta =>
      $$SchemaMetaTableTableManager(_db, _db.schemaMeta);
}
