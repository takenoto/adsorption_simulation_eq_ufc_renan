import 'package:adsorption_columns_flutterrr/domain/chemistry/concentration/concentration_map.dart';
import 'package:adsorption_columns_flutterrr/domain/discretization/values/spherical_coordinates_values.dart';
import 'package:adsorption_columns_flutterrr/domain/utils/clonable.dart';

///Armazena os dados básicos do que é armazenado em uma coluna de adsorção.
class AdsorptionColumnItemData implements Clonable {
  final double fluidPhaseTemperature;
  final double adsorbentTemperature;
  final ConcentrationMap fluidPhaseConcs;
  final AdsorbedPhaseConcs adsorbedPhaseConcs;

  AdsorptionColumnItemData(
      {required this.adsorbedPhaseConcs,
      required this.fluidPhaseConcs,
      required this.adsorbentTemperature,
      required this.fluidPhaseTemperature});

  @override
  AdsorptionColumnItemData clone() {
    return AdsorptionColumnItemData(
        adsorbedPhaseConcs: adsorbedPhaseConcs.clone(),
        fluidPhaseConcs: fluidPhaseConcs.clone(),
        fluidPhaseTemperature: fluidPhaseTemperature,
        adsorbentTemperature: adsorbentTemperature);
  }
}

///As concentrações dentro do adsorvente.
class AdsorbedPhaseConcs extends Clonable {
  ///Armazena, em cada ponto de raio e angle 1 e 2, as concentrações para cada substância.
  final SphericalCoordinateValues<ConcentrationMap> _values;

  AdsorbedPhaseConcs(this._values);

  @override
  AdsorbedPhaseConcs clone() {
    final newSphericalSystem =
        SphericalCoordinateValues<ConcentrationMap>.fromDimensions(
            rVectorLength: _values.radiusIndexLength,
            angle1VectorLength: _values.angle1IndexLength,
            angle2VectorLength: _values.angle2IndexLength,
            constructorFromIndexes: (r, a1, a2) {
              final v = _values.get(r: r, angle1: a1, angle2: a2);
              return v.clone();
            });
    return AdsorbedPhaseConcs(newSphericalSystem);
  }
}
