import 'package:adsorption_columns_flutterrr/domain/adsorption_colums/adsorption_columns.dart';
import 'package:adsorption_columns_flutterrr/domain/chemistry/concentration/concentration_map.dart';
import 'package:adsorption_columns_flutterrr/domain/discretization/discretization.dart';
import 'package:adsorption_columns_flutterrr/domain/utils/clonable.dart';

class CyllindricalAdsorptionColumnState implements Clonable {
  final CyllindricalCoordinateValues<AdsorptionColumnItemData> state;
  CyllindricalAdsorptionColumnState(this.state);

  @override
  CyllindricalAdsorptionColumnState clone() {
    return CyllindricalAdsorptionColumnState(this.state.clone());
  }
}
