import 'package:adsorption_columns_flutterrr/domain/adsorption_columns/column_simple.dart';
import 'package:adsorption_columns_flutterrr/domain/discretization/discretization.dart';

import 'calculators.dart';

class AdsorptionColumnSimulator {
  ///Retorna uma lista com os valores calculados.
  List<UnidimensionalColumnSimulationOutput> simulate(
      IdealUnidimensionalChromatographicColumn column,
      //O tempo discretizado. Determina a quantidade de resultados que será "devolvida"
      UnidimensionalDiscretization time,
      UnidimensionalBoundaryConditions<String> dc_dxBoundaries,
      UnidimensionalBoundaryConditions<String> d2c_dx2Boundaries) {
    List<UnidimensionalColumnSimulationOutput> output = [];
    var previousState = column.initialState.clone();
    double t = 0;
    double dt = 0;
    for (int i = 0; i < time.values.length; i++) {
      t = time.values[i];
      if (i == 0) {
        output.add(UnidimensionalColumnSimulationOutput(t, previousState));
        continue;
      }
      dt = time.values[i] - time.values[i-1];
      //Novo estado:
      final derivatives = column.calculateDerivatives(previousState,
          dc_dxBoundaries: dc_dxBoundaries,
          d2c_dx2Boundaries: d2c_dx2Boundaries);
      final newState = column.newStateUsingDerivatives(
          current: previousState, derivatives: derivatives, dt: dt);
          output.add(UnidimensionalColumnSimulationOutput(t, newState));
      //Põe o novo estado como o antigo
      previousState = newState;
    }

    return output;
  }
}

class UnidimensionalColumnSimulationOutput {
  final double t;
  final UnidimensionalColumnState state;
  UnidimensionalColumnSimulationOutput(this.t, this.state);
}
