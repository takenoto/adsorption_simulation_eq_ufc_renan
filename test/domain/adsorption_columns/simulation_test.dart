import 'package:adsorption_columns_flutterrr/domain/adsorption_colums/adsorption_column_state.dart';
import 'package:adsorption_columns_flutterrr/domain/adsorption_colums/adsorption_columns.dart';
import 'package:adsorption_columns_flutterrr/domain/adsorption_colums/simulation.dart';
import 'package:adsorption_columns_flutterrr/domain/chemistry/chemistry.dart';
import 'package:adsorption_columns_flutterrr/domain/discretization/discretization.dart';
import 'package:adsorption_columns_flutterrr/domain/discretization/values/spherical_coordinates_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('simulation creation', () {
    final simulator = CyllindricalAdsorptionColumnSimulation();
    final adsorb = AdsorbedPhaseConcs(SphericalCoordinateValues.fromDimensions(
        rVectorLength: 1,
        angle1VectorLength: 1,
        angle2VectorLength: 1,
        constructorFromIndexes: (r, a1, a2) => ConcentrationMap({
              'A': 1,
              'B': 2,
            })));

    final liquid = ConcentrationMap({
      'A': 10,
      'B': 20,
    });

    final initialState = CyllindricalAdsorptionColumnState(
        CyllindricalCoordinateValues.fromDimensions(
            zVectorLength: 4,
            rVectorLength: 1,
            angleVectorLength: 1,
            constructorFromIndexes: (z, r, a) {
              return AdsorptionColumnItemData(
                  adsorbedPhaseConcs: adsorb.clone(),
                  fluidPhaseConcs: liquid.clone(),
                  adsorbentTemperature: 293,
                  fluidPhaseTemperature: 293);
              // if (z == 0) {
              //   return AdsorptionColumnItemData(
              //       adsorbedPhaseConcs: adsorb.clone(),
              //       fluidPhaseConcs: liquid.clone(),
              //       adsorbentTemperature: 293,
              //       fluidPhaseTemperature: 293);
              // } else
              //   return AdsorptionColumnItemData(
              //       adsorbedPhaseConcs: null,
              //       fluidPhaseConcs: null,
              //       adsorbentTemperature: 293,
              //       fluidPhaseTemperature: 293);
            }));

    ///Testa se dois estados, um sendo clone do outro, possuem valores independentes.
    test('cloned states do not mix up + fixed values |', () {
      final result = simulator.simulate(
          initialState: initialState.clone(),
          boundaryConditions: initialState.clone(),
          columnDimensions: CyllindricalDimensions(length: 1.5, radius: 0.3),
          numberOfTimeSteps: 2,
          totalTime: 100,
          stepCalc: ({
            required CyllindricalAdsorptionColumnState state,
            required CyllindricalAdsorptionColumnState previousState,
            required int timeStep,
            required int zIndex,
            required int rIndex,
            required int angleIndex,
          }) {
            final data =
                state.state.get(z: zIndex, r: rIndex, angle: angleIndex);

            ///Põe 5 em tudo dentro da partícula.
            data.adsorbedPhaseConcs?.setValueAt(
                value: ConcentrationMap({'A': 5, 'B': 5}),
                r: 0,
                angle1: 0,
                angle2: 0);

            data.fluidPhaseConcs?.setAt('A', 222);
            data.fluidPhaseConcs?.setAt('B', 444);
          });

      //Só foram 2 etapas:
      expect(result.discretization.time.length, 2);
      expect(result.states.length, 2);

      //Os valores do primeiro ponto da simulação são idênticos aos do estado inicial.
      expect(
          result.states.first.state
              .get(z: 0, r: 0, angle: 0)
              .fluidPhaseConcs
              ?.getAt('A'),
          initialState.state
              .get(z: 0, r: 0, angle: 0)
              .fluidPhaseConcs
              ?.getAt('A'));

      //Os valores do segundo ponto são idênticos ao valor que foi forçado na equação.
      //Teste para meio fluido
      expect(
          result.states[1].state
              .get(z: 0, r: 0, angle: 0)
              .fluidPhaseConcs
              ?.getAt('A'),
          222);
      expect(
          result.states[1].state
              .get(z: 0, r: 0, angle: 0)
              .fluidPhaseConcs
              ?.getAt('B'),
          444);
    });
  });

  ///Testes com artigos ou exercícios resolvidos, que já sei os valores que devem dar.
  group('tests with real, tested values', () {
    test('a', () {
      expect(1, 2);
    });
  });
}
