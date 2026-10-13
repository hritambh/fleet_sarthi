// Matching the public vehicle catalogue's brand and model names to what the rest
// of the app already stores: a vehicle's make and model, and the known-model rows
// (`/vehicle-models`) whose id seeds a new vehicle's fuel baseline.
//
// The two don't spell brands the same way. The catalogue names the company
// ("Tata Motors Limited", "Maruti Suzuki"); a vehicle's make is the marque a
// fleet owner types ("Tata", "Maruti"). So a make matches a brand when the whole
// name matches or when the first word — the marque — does.
import '../../core/api/owner_models.dart';

String _key(String value) =>
    value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

String _marque(String value) => _key(value).split(' ').first;

bool sameMake(String a, String b) =>
    _key(a) == _key(b) || (_marque(a).isNotEmpty && _marque(a) == _marque(b));

/// Two names for the same thing, however they were spelled or spaced. Models
/// are compared with this and not [sameMake]: a marque match would make "Wagon
/// R" and "Wagon Q" the same model.
bool sameName(String a, String b) => _key(a) == _key(b);

/// The catalogue brand a vehicle's stored [make] came from, or null if the
/// catalogue doesn't have it. A whole-name match wins over a marque match.
CatalogBrand? brandForMake(List<CatalogBrand> brands, String make) {
  if (make.trim().isEmpty) return null;
  for (final brand in brands) {
    if (_key(brand.name) == _key(make)) return brand;
  }
  for (final brand in brands) {
    if (sameMake(brand.name, make)) return brand;
  }
  return null;
}

/// The catalogue model name equal to [model], so a dropdown can show the stored
/// value as the chosen one however it was typed.
String? catalogModelFor(List<String> models, String model) {
  if (model.trim().isEmpty) return null;
  for (final name in models) {
    if (_key(name) == _key(model)) return name;
  }
  return null;
}

/// The known-model row for [make]/[model], whose id seeds the fuel baseline and
/// whose fuel type pre-fills the form. Null when the fleet has no such row.
VehicleModel? knownModelFor(
  List<VehicleModel> known, {
  required String make,
  required String model,
}) {
  for (final row in known) {
    if (_key(row.model) == _key(model) && sameMake(row.make, make)) return row;
  }
  return null;
}
