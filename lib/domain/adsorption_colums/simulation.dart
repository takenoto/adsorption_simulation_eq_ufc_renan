import 'package:adsorption_columns_flutterrr/domain/chemistry/chemistry.dart';

import 'adsorption_column_state.dart';
import 'dart:math' as math;

import 'adsorption_columns.dart';

///Responsável por calcular a variação de concentração dentro daquele delta da coluna, BEM COMO A VARIAÇÃO DE TEMPERATURA, SE HOUVER.
///
///[timeStep] => A interação de tempo atual. Se for 0, indica que é o primeiro dt, por exemplo.
///
///**A função deve EDITAR DIRETAMENTE no [state].**
typedef void CalculateAdsorptionColumnStepForCyllindricalCoordinates({
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
      required double totalTime,
      required int numberOfTimeSteps,
      required CyllindricalDimensions columnDimensions,
      required CalculateAdsorptionColumnStepForCyllindricalCoordinates stepCalc,
      String? description}) {
    ///Lista que irá armazenar todos os estados ao longo do tempo.
    final states = <CyllindricalAdsorptionColumnState>[];

    ///Lista que armazena o tempo
    final time = <double>[
      for (int t = 0; t < numberOfTimeSteps; t++)
        (t / numberOfTimeSteps) * totalTime
    ];
    final zDisc = <double>[
      for (int z = 0; z < initialState.state.lengthIndexLength; z++)
        (z / initialState.state.lengthIndexLength) * columnDimensions.length
    ];
    final rDisc = <double>[
      for (int r = 0; r < initialState.state.radiusIndexLength; r++)
        (r / initialState.state.radiusIndexLength) * columnDimensions.radius
    ];

    ///In radians
    final angleDisc = <double>[
      for (int angle = 0; angle < initialState.state.angleIndexLength; angle++)
        (angle / initialState.state.angleIndexLength) * 2 * math.pi
    ];

    ///Discretização
    final disc = CyllindricalAdsorptionColumnSimulationDiscretization(
        time: time,
        zDiscretization: zDisc,
        rDiscretization: rDisc,
        angleDiscretization: angleDisc,
        dimensions: columnDimensions);

    ///Adiciona o estado inicial.
    states.add(initialState.clone());

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
      states.add(currentState.clone());
      previousState = currentState.clone();
    }

    return CyllindricalAdsorptionColumnSimulationResult(
        initialState: initialState,
        boundaryConditions: boundaryConditions,
        states: states,
        discretization: disc,
        description: description);
  }
}
