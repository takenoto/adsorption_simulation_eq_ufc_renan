import 'package:adsorption_columns_flutterrr/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('can run column', () {
    final s1Key = 'substance_1';
    final s2Key = 'substance_2';
    final L = 1; //cm
    final divisions = 5;
    final spaceVector = UnidimensionalDiscretization(
        List.generate(divisions, (index) => L * (index / divisions)));
    final zeros = UnidimensionalDiscretization(
        spaceVector.clone().values.map((e) => 0.0).toList());
    final ones = UnidimensionalDiscretization(
        spaceVector.clone().values.map((e) => 1.0).toList());
    final concsZero = UnidimensionalConcentration<String>({
      s1Key: ones,
      s2Key: zeros,
    });
    final initialState = UnidimensionalColumnState(
        fluidPhaseConcs: concsZero,
        adsorbedPhaseConcs: concsZero,
        space: spaceVector);
    final idealColumn = IdealUnidimensionalChromatographicColumn(
        initialState: initialState,
        u: 0.5,
        nu: 10,
        porosity: 0.3,
        dax: 0.5,
        //TODO colocar uma equação real linear para testar
        dqDt: LumpedDqDtCalculator<String>({
          //TODO será que a solução é passar o dt? pra que mesmo os modelos "não deriváveis" possam ser usados?
          s1Key: ({required double C, required double q}) =>
              C * 0.1 / 100 + q / 100,
          s2Key: ({required double C, required double q}) =>
              C * 0.7 / 220 + q / 100,
        }));

    final derivatives = idealColumn.calculateDerivatives(initialState);

    final newState = idealColumn.newStateUsingDerivatives(
        current: initialState, derivatives: derivatives, dt: 1);
    print(initialState.fluidPhaseConcs.concs[s1Key]!.values);
    print(newState.fluidPhaseConcs.concs[s1Key]!.values);
    print(initialState.adsorbedPhaseConcs.concs[s1Key]!.values);
    print(newState.adsorbedPhaseConcs.concs[s1Key]!.values);
  });

  test(
      'Article: Mathematical modeling and experimental breakthrough curves of cephalosporin C adsorption in a fixed-bed column',
      () {
    //Tive que assumir pq ele não deu
    final C0 = 1.0;

    final kf = 7.64; //m/h
    final qMax = 87.44; //mg/L
    final k1 = 2.40e-2; //L/mg.h
    final k2 = 0.67; //h^-1
    final D1 = 1.39e-5; //n²/h^-1
    final porosity = 0.25; //adimensional

    final u = 0.19; //m/h
    final L = 0.16; //m
    //Acho que é o tempo até atingir 90% da capacidade de saturação
    final t09 = 9.84; //h

    final s1Key = 'substance_1';
    final divisions = 5;
    final spaceVector = UnidimensionalDiscretization(
        List.generate(divisions, (index) => L * (index / divisions)));
    final ones = UnidimensionalDiscretization(
        spaceVector.clone().values.map((e) => 1.0).toList());
    final concsZero = UnidimensionalConcentration<String>({
      s1Key: ones,
    });
    final initialState = UnidimensionalColumnState(
        fluidPhaseConcs: concsZero,
        adsorbedPhaseConcs: concsZero,
        space: spaceVector);
    final idealColumn = IdealUnidimensionalChromatographicColumn(
        initialState: initialState,
        u: u,
        nu: 10,
        porosity: porosity,
        dax: D1,
        dqDt: LumpedDqDtCalculator<String>({
          s1Key: ({required double C, required double q}) =>
              k1 * C * (qMax - q) - k2 * q
        }));

    final previousState = initialState;
    final boundariesDcDx = UnidimensionalBoundaryConditions<String>({
      s1Key: List<double?>.generate(divisions, (index) {
        if (index == 0) {
          return C0;
        }
      })
    });

    ///Zera a derivada segunda do espaço em z=0 e z=L
    final boundariesD2cDx2 = UnidimensionalBoundaryConditions<String>({
      s1Key: List<double?>.generate(divisions, (index) {
        if (index == 0 || index >= divisions - 1) {
          return 0;
        }
      })
    });

    final simulator = AdsorptionColumnSimulator();
    final time = UnidimensionalDiscretization(
        List.generate(divisions, (index) => index / 3000));
    final result =
        simulator.simulate(idealColumn, time, boundariesDcDx, boundariesD2cDx2);

    for (var r in result) {
      print('t = ${r.t}');
      print(r.state.fluidPhaseConcs.concs[s1Key]?.values);
      print(r.state.adsorbedPhaseConcs.concs[s1Key]?.values);
    }
  });
}
