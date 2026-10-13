import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/api/owner_models.dart';
import 'package:taxcy_driver/features/owner/vehicle_catalog.dart';
import 'package:taxcy_driver/features/owner/vehicles_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

/// The add-vehicle form's brand and model dropdowns. Both lead with the cab
/// shortlist (`/vehicle-models`, which also carries the fuel type and seeds the
/// fuel baseline) and follow it with the rest of what is sold in India (the
/// public catalogue), with free text last.
void main() {
  Future<Harness> setUpOwner(WidgetTester tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(420, 2000);
    addTearDown(tester.view.reset);
    final h = await Harness.create(
      session: Session.fromJson(sessionJson(roles: ['owner'])),
    );
    addTearDown(h.dispose);
    return h;
  }

  Future<void> open(WidgetTester tester, String key) async {
    final field = find.byKey(Key(key));
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, String key, String option) async {
    await open(tester, key);
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('vehicle-registrationNo')),
      'MH12EF9012',
    );
    await tester.ensureVisible(find.byKey(const Key('vehicle-save')));
    await tester.tap(find.byKey(const Key('vehicle-save')));
    await settle(tester);
  }

  group('matching names across the two lists', () {
    const brands = [
      CatalogBrand(id: 'Q963718', name: 'Maruti Suzuki'),
      CatalogBrand(id: 'Q188514', name: 'Tata Motors Limited'),
    ];

    test('a stored make finds its brand by the marque', () {
      expect(brandForMake(brands, 'Tata')?.id, 'Q188514');
      expect(brandForMake(brands, 'maruti suzuki')?.id, 'Q963718');
      expect(brandForMake(brands, 'Maruti')?.id, 'Q963718');
      expect(brandForMake(brands, 'Kia'), isNull);
      expect(brandForMake(brands, '  '), isNull);
    });

    test('a model matches only on its whole name', () {
      expect(sameName('Wagon R', 'wagon r'), isTrue);
      expect(sameName('Wagon R', 'Wagon Q'), isFalse);
      // Which a marque comparison would get wrong.
      expect(sameMake('Wagon R', 'Wagon Q'), isTrue);
      expect(catalogModelFor(const ['Wagon R', 'Swift'], 'wagon r'), 'Wagon R');
      expect(catalogModelFor(const ['Swift'], 'Dzire'), isNull);
    });

    test(
      'a cab-list row is found though the catalogue spells the brand in full',
      () {
        final known = [
          VehicleModel.fromJson({
            'id': 'model-1',
            'make': 'Maruti',
            'model': 'Ertiga',
            'fuelType': 'petrol_cng',
          }),
        ];
        expect(
          knownModelFor(known, make: 'Maruti Suzuki', model: 'ertiga')?.id,
          'model-1',
        );
        expect(knownModelFor(known, make: 'Tata', model: 'Ertiga'), isNull);
      },
    );
  });

  group('the add-vehicle form', () {
    testWidgets('the brand dropdown leads with the cab makes, then the rest of '
        'India under a heading', (tester) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      await open(tester, 'vehicle-brand');
      expect(find.text('Common cab models'), findsOneWidget);
      expect(find.text('Others sold in India'), findsOneWidget);
      for (final make in ['Maruti Suzuki', 'Tata', 'Hyundai']) {
        expect(find.text(make), findsOneWidget, reason: make);
      }
      // The catalogue's own spelling is dropped where the cab list already has
      // the brand, so a brand is never offered twice.
      expect(find.text('Tata Motors Limited'), findsNothing);
    });

    testWidgets('a cab make offers its cab models first, then that brands '
        'other India models', (tester) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      expect(find.byKey(const Key('vehicle-model-pick')), findsNothing);

      await pick(tester, 'vehicle-brand', 'Maruti Suzuki');
      await open(tester, 'vehicle-model-pick');
      for (final model in ['Dzire', 'Ertiga', 'Swift', 'Wagon R']) {
        expect(find.text(model), findsWidgets, reason: model);
      }
      // Ertiga is on both lists and is only offered once, as a cab model.
      expect(find.text('Ertiga'), findsOneWidget);
      expect(find.text('Nexon'), findsNothing);
    });

    testWidgets('a cab model carries its id and fuel type, which is what seeds '
        'the fuel baseline', (tester) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      await pick(tester, 'vehicle-brand', 'Maruti Suzuki');
      await pick(tester, 'vehicle-model-pick', 'Dzire');
      await save(tester);
      final body = h.owner.last('createVehicle').args;
      expect(body['make'], 'Maruti Suzuki');
      expect(body['model'], 'Dzire');
      expect(body['vehicleModelId'], '0199c7a2-0000-7000-8000-000000000a02');
      expect(body['fuelType'], 'cng');
    });

    testWidgets('a model from the wider India list carries no cab-list id', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      await pick(tester, 'vehicle-brand', 'Hyundai');
      await pick(tester, 'vehicle-model-pick', 'Creta');
      await save(tester);
      final body = h.owner.last('createVehicle').args;
      expect(body['make'], 'Hyundai');
      expect(body['model'], 'Creta');
      expect(body.containsKey('vehicleModelId'), isFalse);
    });

    testWidgets('switching brand drops the model already chosen', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      await pick(tester, 'vehicle-brand', 'Maruti Suzuki');
      await pick(tester, 'vehicle-model-pick', 'Dzire');
      await pick(tester, 'vehicle-brand', 'Tata');
      await open(tester, 'vehicle-model-pick');
      expect(find.text('Tiago'), findsWidgets);
      expect(find.text('Dzire'), findsNothing);
      await tester.tap(find.text('Nexon').last);
      await tester.pumpAndSettle();
      await save(tester);
      final body = h.owner.last('createVehicle').args;
      expect(body['model'], 'Nexon');
      expect(body.containsKey('vehicleModelId'), isFalse);
    });

    testWidgets('picking Other hands the brand and model back as text', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      expect(find.byKey(const Key('vehicle-make')), findsNothing);

      await pick(tester, 'vehicle-brand', 'Other / not listed');
      await tester.enterText(find.byKey(const Key('vehicle-make')), 'Force');
      await tester.enterText(find.byKey(const Key('vehicle-model')), 'Urbania');
      await save(tester);
      final body = h.owner.last('createVehicle').args;
      expect(body['make'], 'Force');
      expect(body['model'], 'Urbania');
    });

    testWidgets('a model can be typed in under a listed brand', (tester) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      await pick(tester, 'vehicle-brand', 'Tata');
      await pick(tester, 'vehicle-model-pick', 'Other / not listed');
      await tester.enterText(find.byKey(const Key('vehicle-model')), 'Indica');
      await save(tester);
      final body = h.owner.last('createVehicle').args;
      expect(body['make'], 'Tata');
      expect(body['model'], 'Indica');
    });

    testWidgets('a vehicle can still be added with both lists empty', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      h.owner.cabModelList = [];
      h.owner.catalogBrandList = [];
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('vehicle-make')), 'Force');
      await tester.enterText(find.byKey(const Key('vehicle-model')), 'Urbania');
      await save(tester);
      expect(h.owner.last('createVehicle').args['make'], 'Force');
    });

    testWidgets('with no cab shortlist the dropdowns still offer India', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      h.owner.cabModelList = [];
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      await open(tester, 'vehicle-brand');
      // One group left, so it needs no heading.
      expect(find.text('Common cab models'), findsNothing);
      expect(find.text('Others sold in India'), findsNothing);
      expect(find.text('Tata Motors Limited'), findsOneWidget);
    });

    testWidgets('editing a vehicle opens on its brand and model', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      final vehicle = Vehicle.fromJson({
        ...vehicleJson(),
        'make': 'Maruti Suzuki',
        'model': 'Dzire',
      });
      await tester.pumpWidget(h.screen(VehicleFormScreen(vehicle: vehicle)));
      await settle(tester);
      expect(find.text('Maruti Suzuki'), findsOneWidget);
      expect(find.text('Dzire'), findsOneWidget);
      expect(find.byKey(const Key('vehicle-make')), findsNothing);
      expect(find.byKey(const Key('vehicle-model')), findsNothing);
    });
  });
}
