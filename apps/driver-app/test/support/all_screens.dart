import 'package:flutter/material.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/api/owner_models.dart';
import 'package:taxcy_driver/features/common/consent_screen.dart';
import 'package:taxcy_driver/features/fuel/fuel_fill_screen.dart';
import 'package:taxcy_driver/features/account/account_security_screen.dart';
import 'package:taxcy_driver/features/login/login_screen.dart';
import 'package:taxcy_driver/features/driver/driver_documents_screen.dart';
import 'package:taxcy_driver/features/driver/driver_profile_screen.dart';
import 'package:taxcy_driver/features/driver/driver_shell.dart';
import 'package:taxcy_driver/features/driver/driver_trips_screen.dart';
import 'package:taxcy_driver/features/owner/alerts_inbox.dart';
import 'package:taxcy_driver/features/owner/alerts_screen.dart';
import 'package:taxcy_driver/features/owner/analytics_screen.dart';
import 'package:taxcy_driver/features/owner/dashboard_screen.dart';
import 'package:taxcy_driver/features/owner/documents_screen.dart';
import 'package:taxcy_driver/features/owner/fuel_screens.dart';
import 'package:taxcy_driver/features/owner/owner_shell.dart';
import 'package:taxcy_driver/features/owner/people_screens.dart';
import 'package:taxcy_driver/features/owner/review_screen.dart';
import 'package:taxcy_driver/features/owner/settings_screen.dart';
import 'package:taxcy_driver/features/owner/settlements_screen.dart';
import 'package:taxcy_driver/features/owner/trips/create_trip_screen.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trip_detail_screen.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trips_screen.dart';
import 'package:taxcy_driver/features/owner/trip_schedule.dart';
import 'package:taxcy_driver/features/owner/vehicles_screen.dart';
import 'package:taxcy_driver/features/trips/new_trip_screen.dart';
import 'package:taxcy_driver/features/trips/trip_detail_screen.dart';
import 'package:taxcy_driver/features/trips/trip_forms.dart';
import 'package:taxcy_driver/features/trips/trips_screen.dart';

import 'fakes.dart';
import 'harness.dart';
import 'owner_fakes.dart';

/// Every owner and driver screen, with the fake data each needs; shared by
/// the screen tests (small phones in every language, dark mode).
abstract final class AllScreens {
  static final busyTrip = {
    ...tripJson(status: 'started', cancellationPending: true),
    'includedKm': 150,
    'charges': [
      {
        'id': 'c1',
        'kind': 'state_tax',
        'amountPaise': 125000,
        'paidByDriver': true,
        'mediaId': null,
        'note': 'Karnataka border',
        'enteredBy': 'u1',
        'enteredRole': 'driver',
        'voidedAt': null,
        'createdAt': '2026-10-09T04:00:00.000Z',
      },
    ],
    'collections': [
      {
        'id': 'p1',
        'method': 'upi',
        'amountPaise': 100000,
        'reference': 'UPI-1234567890',
        'collectedAt': '2026-10-09T05:00:00.000Z',
      },
    ],
  };
  static final busyTripId = busyTrip['id']! as String;

  /// Owner-mode screens, by name.
  static final owner = <String, Widget>{
    'shell': const OwnerShell(),
    'trips': const OwnerTripsScreen(),
    'create trip': const CreateTripScreen(),
    'trip detail': OwnerTripDetailScreen(tripId: busyTripId),
    'dashboard': DashboardScreen(onOpenTrips: () {}),
    'alerts': const AlertsScreen(),
    'alerts inbox': const AlertsInboxScreen(),
    'alerts inbox (review)': const AlertsInboxScreen(initialTab: 1),
    'more': const MoreScreen(),
    'vehicles': const VehiclesScreen(),
    'vehicle form': VehicleFormScreen(vehicle: Vehicle.fromJson(vehicleJson())),
    'add vehicle': const VehicleFormScreen(),
    'vehicle detail': const VehicleDetailScreen(vehicleId: vehicleId),
    'vehicle schedule': const Scaffold(
      body: TripSchedule(vehicleId: vehicleId),
    ),
    'analytics': const AnalyticsScreen(),
    'vehicle fuel': const VehicleFuelScreen(vehicleId: vehicleId),
    'drivers': const DriversScreen(),
    'driver': DriverScreen(
      driver: Driver.fromJson(
        driverJson(payRule: payRuleJson(kind: 'per_trip')),
      ),
    ),
    'driver schedule': const Scaffold(body: TripSchedule(driverId: driverId)),
    'driver by id': const DriverByIdScreen(driverId: driverId),
    'document form': const DocumentFormScreen(),
    'renew document': DocumentFormScreen(
      renewing: FleetDocument.fromJson(documentJson()),
    ),
    'review': const ReviewScreen(),
    'settlements': const SettlementsScreen(initialDate: '2026-10-09'),
    'settlement': const SettlementDetailScreen(
      date: '2026-10-09',
      driverId: driverId,
    ),
    'settings': const SettingsScreen(),
  };

  /// The fake fleet the owner screens show: a busy trip (cancellation
  /// pending, a charge, a payment), every kind of alert, review items.
  static void prepareOwner(Harness h) {
    h.owner
      ..tripsById[busyTripId] = busyTrip
      ..distanceCheckResult = distanceCheckJson(result: 'inconclusive')
      ..alertList = [
        for (final kind in alertMessages.keys)
          alertJson(id: 'a-$kind', kind: kind, severity: 'critical'),
      ]
      ..reviewList = [
        reviewItemJson(),
        reviewItemJson(
          id: 'r2',
          kind: 'implausible_efficiency',
          subjectType: 'fuel_cycle',
          context: {'reason': 'x', 'reasonCode': 'implausibly_good'},
        ),
      ];
  }

  static final started = Trip.fromJson({
    ...busyTrip,
    'cancellationRequest': null,
  });

  /// Driver-mode screens (and sign-in), by name.
  static final driver = <String, Widget>{
    'login': const LoginScreen(),
    'consent': LocationConsentScreen(onDone: () {}),
    'my trips': const TripsScreen(),
    'driver trip': TripDetailScreen(tripId: busyTripId),
    'start trip': StartTripScreen(trip: Trip.fromJson(tripJson())),
    'end trip': EndTripScreen(trip: started),
    'cancel request': CancelRequestScreen(trip: started),
    'new trip': const NewTripScreen(),
    'log fuel': const FuelFillScreen(),
    'account security': const AccountSecurityScreen(),
    'driver app': const DriverShell(),
    'driver trips': const DriverTripsScreen(),
    'my documents': const DriverDocumentsScreen(),
    'add my document': const DocumentFormScreen(mine: true),
    'profile': const DriverProfileScreen(),
  };

  /// The driver's device: a vehicle to pick and the started trip cached.
  static Future<void> prepareDriver(Harness h) async {
    h.api.vehicleList = [Vehicle.fromJson(vehicleJson())];
    await h.engine.cacheTrip(started);
  }
}
