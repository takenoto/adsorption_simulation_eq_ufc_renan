import 'package:adsorption_columns_flutterrr/domain/utils/utils.dart';

///Mapa com a concentração de substâncias
class ConcentrationMap implements Clonable {
  final Map<String, double> _concs;
  ConcentrationMap(this._concs);

  double? getAt(String key) {
    return _concs[key];
  }

  void setValueAt(String key, double value) {
    _concs[key] = value;
  }

  @override
  ConcentrationMap clone() {
    final newMap = <String, double>{};
    for (var key in _concs.keys) {
      newMap[key] = _concs[key]!;
    }

    return ConcentrationMap(newMap);
  }
}
