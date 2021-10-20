import 'package:adsorption_columns_flutterrr/domain/chemistry/concentration/concentration_map.dart';
import 'package:adsorption_columns_flutterrr/domain/discretization/values/spherical_coordinates_values.dart';
import 'package:adsorption_columns_flutterrr/domain/utils/clonable.dart';

///Armazena os dados básicos do que é armazenado em uma coluna de adsorção.
///
///Os valores são nullable para facilitar a aplicação de condições de contorno posteriormente.
class AdsorptionColumnItemData implements Clonable {
  final double? fluidPhaseTemperature;
  final double? adsorbentTemperature;
  final ConcentrationMap? fluidPhaseConcs;
  final AdsorbedPhaseConcs? adsorbedPhaseConcs;

  AdsorptionColumnItemData(
      {required this.adsorbedPhaseConcs,
      required this.fluidPhaseConcs,
      required this.adsorbentTemperature,
      required this.fluidPhaseTemperature});

  @override
  AdsorptionColumnItemData clone() {
    return AdsorptionColumnItemData(
        adsorbedPhaseConcs: adsorbedPhaseConcs?.clone(),
        fluidPhaseConcs: fluidPhaseConcs?.clone(),
        fluidPhaseTemperature: fluidPhaseTemperature,
        adsorbentTemperature: adsorbentTemperature);
  }
}

///As concentrações dentro do adsorvente.
class AdsorbedPhaseConcs extends Clonable {
  ///Armazena, em cada ponto de raio e angle 1 e 2, as concentrações para cada substância.
  final SphericalCoordinateValues<ConcentrationMap> _values;

  ///Pega o valor do raio mais externo
  ConcentrationMap getAtSurface() =>
      _values.get(r: _values.radiusIndexLength - 1, angle1: 0, angle2: 0);

  ConcentrationMap getAt({int r = 0, int angle1 = 0, int angle2 = 0}) =>
      _values.get(r: r, angle1: angle1, angle2: angle2);

  int get radiusIndexLength => _values.radiusIndexLength;
  int get angle1IndexLength => _values.angle1IndexLength;
  int get angle2IndexLength => _values.angle2IndexLength;

  void setValueAt(
      {required ConcentrationMap value,
      required int r,
      required int angle1,
      required int angle2}) {
    _values.setValueAt(value: value, r: r, angle1: angle1, angle2: angle2);
  }

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
