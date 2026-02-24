import 'dart:io';

import 'package:flutter/material.dart';
import '../services/steps_service.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carp_serializable/carp_serializable.dart';

final health = Health();

class ConnectHealthScreen extends StatefulWidget {
  const ConnectHealthScreen({super.key});

  @override
  State<ConnectHealthScreen> createState() => _ConnectHealthScreenState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
  SKIN_TEMPERATURE_FEATURE_STATUS,
  HEALTH_CONNECT_STATUS,
  PERMISSIONS_REVOKING,
  PERMISSIONS_REVOKED,
  PERMISSIONS_NOT_REVOKED,
  CHANGES_READY,
  CHANGES_NOT_READY,
}

class _ConnectHealthScreenState extends State<ConnectHealthScreen> {
  final StepsService _stepsService = StepsService();

  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 0;
  List<RecordingMethod> recordingMethodsToFilter = [];
  String? _changesToken;
  String? _previousChangesToken;
  bool _changesTokenExpired = false;
  bool _changesHasMore = false;
  final List<HealthChange> _changes = [];
  final List<HealthDataType> _changeTypes = const [
    HealthDataType.STEPS,
    HealthDataType.WORKOUT,
  ];
  final Map<String, HealthDataPoint> _syncedDataById = {};
  int _lastBeforeCount = 0;
  int _lastAfterCount = 0;
  int _lastInserted = 0;
  int _lastUpdated = 0;
  int _lastRemoved = 0;
  int _lastAppliedUpserts = 0;
  int _lastAppliedDeletes = 0;
  DateTime? _lastChangesAt;

  // All types available depending on platform (iOS ot Android).
  // List<HealthDataType> get types {
  //   if (Platform.isAndroid) return dataTypesAndroid;
  //   if (!Platform.isIOS) return [];
  //
  //   final iosTypes = List<HealthDataType>.from(dataTypesIOS);
  //   if (!_isIOS16OrNewer) {
  //     iosTypes.removeWhere(
  //       (type) => const {
  //         HealthDataType.WATER_TEMPERATURE,
  //         HealthDataType.UNDERWATER_DEPTH,
  //         HealthDataType.UV_INDEX,
  //         HealthDataType.SLEEP_WRIST_TEMPERATURE,
  //       }.contains(type),
  //     );
  //   }
  //
  //   return iosTypes;
  // }

  @override
  void initState() {
    // TODO: implement initState
    health.configure();
    health.getHealthConnectSdkStatus();
    super.initState();
  }

  bool _loading = false;
  String _status = "Not connected";
  int _steps = 0;

  Future<void> _connect() async {
    setState(() {
      _loading = true;
      _status = "Requesting permission...";
    });

    try {
      final granted = await _stepsService.connectAndAuthorize();
      if (!granted) {
        setState(() {
          _status = "Permission denied. Please allow Steps in Health Connect.";
          _loading = false;
        });
        return;
      }

      setState(() {
        _status = "Permission granted. Fetching steps...";
      });

      final todaySteps = await _stepsService.getTodaySteps();

      setState(() {
        _steps = todaySteps;
        _status = "Connected ✅";
        _loading = false;
      });

      if (todaySteps == 0) {
        // Helpful hint on HONOR devices
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Steps are 0. Open Health Connect → Data sources & priority, and ensure a provider (HONOR Health / Google Fit) is writing steps.",
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = "Error: $e";
        _loading = false;
      });
    }
  }

  Future<void> _refreshSteps() async {
    setState(() {
      _loading = true;
      _status = "Refreshing steps...";
    });

    try {
      final todaySteps = await _stepsService.getTodaySteps();
      setState(() {
        _steps = todaySteps;
        _status = "Connected ✅";
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _status = "Error: $e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect to Google Health")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_status, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 10),
                  Text("Today Steps: $_steps",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _connect,
                icon: const Icon(Icons.health_and_safety),
                label: Text(
                    _loading ? "Please wait..." : "Connect to Google Health"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _refreshSteps,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh Steps"),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "If steps stay 0 on HONOR:\n"
              "1) Install/open Health Connect\n"
              "2) Go to Data sources & priority\n"
              "3) Ensure a provider (HONOR Health / Google Fit) is the source\n"
              "4) Grant Steps permission to your app",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
