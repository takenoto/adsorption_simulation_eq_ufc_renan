
import 'package:adsorption_columns_flutterrr/domain/chemistry/chemistry.dart';

import 'adsorption_column_state.dart';

///Responsável por calcular a variação de concentração dentro daquele delta da coluna, BEM COMO A VARIAÇÃO DE TEMPERATURA, SE HOUVER.
///
///[timeStep] => A interação de tempo atual. Se for 0, indica que é o primeiro dt, por exemplo.
///
///**A função deve EDITAR DIRETAMENTE no [state].**
typedef ConcentrationMap CalculateAdsorptionColumnStepForCyllindricalCoordinates({
  required CyllindricalAdsorptionColumnState state,
  required CyllindricalAdsorptionColumnState previousState,
  required int timeStep,
  required int zIndex,
  required int rIndex,
  required int angleIndex,
});

class CyllindricalAdsorptionColumnSimulation {
  CyllindricalAdsorptionColumnSimulation();

  ///Prefer to do so as to use SI units (meter, second, kg, etc)
  CyllindricalAdsorptionColumnSimulationResult simulate(
      {required CyllindricalAdsorptionColumnState initialState,
      required CyllindricalAdsorptionColumnState boundaryConditions,
      required int numberOfTimeSteps,
      required double totalTime,
      required CalculateAdsorptionColumnStepForCyllindricalCoordinates
          stepCalc,
      String? description}) {
    ///Lista que irá armazenar todos os estados ao longo do tempo.
    final states = <CyllindricalAdsorptionColumnState>[];

    ///Lista que armazena o tempo
    final time = <double>[];

    ///Adiciona o estado inicial.
    states.add(initialState.clone());
    time.add(0);

    final dt = totalTime / numberOfTimeSteps;
    CyllindricalAdsorptionColumnState currentState = initialState.clone();
    CyllindricalAdsorptionColumnState previousState = initialState.clone();
    for (int t = 1; t < numberOfTimeSteps; t++) {
      for (int z = 0; z < initialState.state.lengthIndexLength; z++) {
        for (int r = 0; r < initialState.state.radiusIndexLength; r++) {
          for (int angle = 0;
              angle < initialState.state.angleIndexLength;
              angle++) {
            stepCalc(
              previousState: previousState,
              state: currentState,
              timeStep: t,
              zIndex: z,
              rIndex: r,
              angleIndex: angle,
            );
          }
        }
      }
      time.add(dt * t);
      states.add(currentState);
      previousState = currentState.clone();
    }

    return CyllindricalAdsorptionColumnSimulationResult(
        initialState: initialState,
        boundaryConditions: boundaryConditions,
        totalTime: totalTime,
        states: states,
        numberOfSteps: numberOfTimeSteps,
        time: time,
        description: description);
  }
}

class CyllindricalAdsorptionColumnSimulationResult {
  ///Descrição do que essa simulação representa; parâmetro opcional.
  final String? description;
  final CyllindricalAdsorptionColumnState initialState;
  final CyllindricalAdsorptionColumnState boundaryConditions;

  ///Em quantos intervalos o tempo será dividido.
  final int numberOfSteps;
  final double totalTime;

  ///Os vários estados ao longo do tempo
  final List<CyllindricalAdsorptionColumnState> states;

  ///Discretização do tempo
  final List<double> time;

  CyllindricalAdsorptionColumnSimulationResult(
      {required this.initialState,
      required this.boundaryConditions,
      required this.totalTime,
      required this.numberOfSteps,
      required this.states,
      required this.time,
      this.description})
      : assert(time.length == states.length);
}
