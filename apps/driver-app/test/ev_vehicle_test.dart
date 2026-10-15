import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/owner_widgets.dart';
import 'package:taxcy_driver/features/owner/vehicles_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

/// The plate's fill colour.
Color? plateColor(WidgetTester tester, Finder plate) {
  final box = tester.widget<Container>(
    find.descendant(of: plate, matching: find.byType(Container)).first,
  );
  return (box.decoration! as BoxDecoration).color;
}

void main() {
  Future<Harness> owner(WidgetTester tester, {double width = 420}) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = Size(width, 2000);
    addTearDown(tester.view.reset);
    final h = await Harness.create(
      session: Session.fromJson(sessionJson(roles: ['owner'])),
    );
    addTearDown(h.dispose);
    return h;
  }

  testWidgets('an electric vehicle has a green plate, others stay yellow', (
    tester,
  ) async {
    // The plates are on the desktop's vehicle cards.
    final h = await owner(tester, width: 1440);
    h.owner.vehicleList = [
      {...vehicleJson(), 'fuelType': 'ev'},
      vehicleJson(id: vehicle2Id, reg: 'MH12CD5678'),
    ];
    await tester.pumpWidget(h.screen(const VehiclesScreen()));
    await settle(tester);
    final plates = find.byType(NumberPlate);
    expect(plates, findsNWidgets(2));
    expect(plateColor(tester, plates.at(0)), const Color(0xFF007A48));
    expect(plateColor(tester, plates.at(1)), const Color(0xFFFFD43B));
  });

  testWidgets('EV is a fuel type when adding a vehicle', (tester) async {
    final h = await owner(tester);
    await tester.pumpWidget(h.screen(const VehicleFormScreen()));
    await settle(tester);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EV').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('vehicle-registrationNo')),
      'MH12EV0001',
    );
    // A make that is not on the lists is typed in.
    await tester.tap(find.byKey(const Key('vehicle-brand')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other / not listed'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('vehicle-make')), 'Tata');
    await tester.enterText(find.byKey(const Key('vehicle-model')), 'Nexon EV');
    await tester.ensureVisible(find.byKey(const Key('vehicle-save')));
    await tester.tap(find.byKey(const Key('vehicle-save')));
    await settle(tester);
    expect(h.owner.last('createVehicle').args['fuelType'], 'ev');
  });

  test('an electric vehicle takes no fuel fills', () {
    final v = Vehicle.fromJson({...vehicleJson(), 'fuelType': 'ev'});
    expect(v.isElectric, isTrue);
    expect(v.allowedFuels, isEmpty);
    expect(
      Vehicle.fromJson({
        ...vehicleJson(),
        'fuelType': 'petrol_cng',
      }).allowedFuels,
      ['cng', 'petrol'],
    );
  });
}
