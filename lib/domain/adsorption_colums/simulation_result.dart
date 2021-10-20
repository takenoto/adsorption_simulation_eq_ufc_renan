
import 'adsorption_columns.dart';

class CyllindricalAdsorptionColumnSimulationResult {
  ///Descrição do que essa simulação representa; parâmetro opcional.
  final String? description;
  final CyllindricalAdsorptionColumnState initialState;
  final CyllindricalAdsorptionColumnState boundaryConditions;

  final CyllindricalAdsorptionColumnSimulationDiscretization discretization;

  ///Os vários estados ao longo do tempo
  final List<CyllindricalAdsorptionColumnState> states;

  CyllindricalAdsorptionColumnSimulationResult(
      {required this.initialState,
      required this.boundaryConditions,
      required this.states,
      required this.discretization,
      this.description})
      : assert(states.length == discretization.time.length);
}
