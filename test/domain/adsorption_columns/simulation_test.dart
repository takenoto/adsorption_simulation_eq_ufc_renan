import 'package:adsorption_columns_flutterrr/domain/adsorption_colums/adsorption_column_state.dart';
import 'package:adsorption_columns_flutterrr/domain/adsorption_colums/adsorption_columns.dart';
import 'package:adsorption_columns_flutterrr/domain/adsorption_colums/simulation.dart';
import 'package:adsorption_columns_flutterrr/domain/chemistry/chemistry.dart';
import 'package:adsorption_columns_flutterrr/domain/discretization/discretization.dart';
import 'package:adsorption_columns_flutterrr/domain/discretization/values/spherical_coordinates_values.dart';
import 'package:adsorption_columns_flutterrr/domain/domain.dart';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

/// Precisa ter: (Pg 242 do livro Preparative Chrmatography of Fine Chemicals)
/// - Convection
/// - Dispersion
/// - Mass transfer from the bulk phase into the boundary layer of the particle
/// - Diffusion inside the pores of the particle (pore diffusion)
/// - Diffusion along the surface of the solid phase (surface diffusion)
/// - Adsorption equilibrium or adsorption kinetics

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
          dimensions: CyllindricalColumnWithSphericalParticleDimensions(
              length: 1.5, radius: 0.3, particleRadius: 1e-4, porosity: 0.3),
          numberOfTimeSteps: 2,
          totalTime: 100,
          stepCalc: (
              {required CyllindricalAdsorptionColumnState state,
              required CyllindricalAdsorptionColumnState previousState,
              required int timeStep,
              required int zIndex,
              required int rIndex,
              required int angleIndex,
              required CyllindricalAdsorptionColumnSimulationDiscretization
                  discretization,
              required CyllindricalColumnWithSphericalParticleDimensions
                  dimensions}) {
            final data =
                state.state.get(z: zIndex, r: rIndex, angle: angleIndex);

            ///P??e 5 em tudo dentro da part??cula.
            data.adsorbedPhaseConcs?.setValueAt(
                value: ConcentrationMap({'A': 5, 'B': 5}),
                r: 0,
                angle1: 0,
                angle2: 0);

            data.fluidPhaseConcs?.setValueAt('A', 222);
            data.fluidPhaseConcs?.setValueAt('B', 444);
          });

      //S?? foram 2 etapas:
      expect(result.discretization.time.length, 2);
      expect(result.states.length, 2);

      //Os valores do primeiro ponto da simula????o s??o id??nticos aos do estado inicial.
      expect(
          result.states.first.state
              .get(z: 0, r: 0, angle: 0)
              .fluidPhaseConcs
              ?.getAt('A'),
          initialState.state
              .get(z: 0, r: 0, angle: 0)
              .fluidPhaseConcs
              ?.getAt('A'));

      //Os valores do segundo ponto s??o id??nticos ao valor que foi for??ado na equa????o.
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

  ///Testes com artigos ou exerc??cios resolvidos, que j?? sei os valores que devem dar.
  group('tests with real, tested values', () {
    final singleDev = SingleDerivativeCalculatorFiniteDifference();
    final secondDev = SecondDerivativeCalculatorFiniteDifference();
    final simulator = CyllindricalAdsorptionColumnSimulation();
    final R = 8.31446261815324; // J / K.mol

    //Modeling and Simulation of Fixed bed Adsorption column: Effect of Velocity Variation
    group('B.V. Babu 2005', () {
      //TODO
    });

    //A Methodology to Estimate the Sorption Parameters from Batch and Column Tests: The Case Study of Methylene Blue Sorption onto Banana Peels
    group('Stavrinou, 2020 |', () {
      final langmuirEa = 9.30;
      final langmuirLnAa = -5.6;
      final langmuirEd = 29.02;
      final langmuirLnAd = 4.29;

      double getKa(
          {required double lnAa, required double Ea, required double T}) {
        return math.exp(lnAa - (Ea / (R * T)));
      }

      double getKd(
          {required double lnAd, required double Ed, required double T}) {
        return math.exp(lnAd - (Ed / (R * T)));
      }

      final methyleneBlue = 'MB';

      //As dimens??es n??o interessam nesse 1?? caso porque ?? um simples equil??brio!
      //O que vai ser checado ?? a conc. na fase estacion??ria ao longo do tempo.
      //Figure 4: Experimental vs. numerically predicted transient response of MB sorption onto BP for the three kinetic models
      //Problema: n??o sei como relacionar esse S da figura 4. Qual a conc??? Assim n??o tem como...

      group('FIGURE 4: T=25??C', () {
        //Eu tava trocando dz por dt zzzzzzzzzz

        ///For measuring performance
        final stopwatch = Stopwatch()..start();

        final columnDiameter = 0.168; //m
        final T = 298; //K
        //final S_max = 160.3; //mg/g --> kg/g. From Figure 3.a)
        final porosity = 0.35;
        final rho_b = 590; //kg/m??
        final Dm = 4.6e-10; //m??/s
        final F = 4.0;
        final C0_1 = 0.1; //kg/m??
        final C0_2 = 0.2; //kg/m??
        final u0_1 = 2.15e-4; //m/2
        final u0_2 = 6.45e-4; //m/2
        final area = math.pi * (math.pow(columnDiameter, 2)) / 4;
        //Table 7
        final dg = 3e-4; //m
        final aL = dg;
        
        final Lb = 1.107 * columnDiameter;

        final columnDimensionsGeneral =
            CyllindricalColumnWithSphericalParticleDimensions(
                length: Lb,
                //length: 1.86e-2, //Figura 5.a) O Lb ?? 1.86 cm...
                radius: 0.0168 / 2,
                particleRadius:
                    1, //inventei, n??o achei no artigo. Mas n??o faz diferen??a nesse teste.
                porosity: 0.35);
        //4 (a) - Langmuir Kinetic Model, T = 288K
        test('Table 8 - row 1', () {
          
          //From table 8, row 1:
          final a = 2.195e-5; //s^-1
          final S_max = 0.190; //kg/kg.
          final Q = 1.0 * (1e-6) / 60; //mL/min --> m??/s
          final u0 = Q /
              (porosity *
                  area); //converte para segundos e divide pela ??rea e porosidade

          final columnDimensionsGeneral =
              CyllindricalColumnWithSphericalParticleDimensions(
                  length: Lb,
                  radius: columnDiameter / 2,
                  particleRadius:
                      1, //inventei, n??o achei no artigo. Mas n??o faz diferen??a nesse teste.
                  porosity: 0.35);

          final initialState = CyllindricalAdsorptionColumnState(
              CyllindricalCoordinateValues.fromDimensions(
                  zVectorLength: 25, //50,
                  rVectorLength: 1,
                  angleVectorLength: 1,
                  constructorFromIndexes: (z, r, a) {
                    return AdsorptionColumnItemData(
                      //Inicializa em C0 tamb??m
                      fluidPhaseConcs:
                          ConcentrationMap({methyleneBlue: z == 0 ? C0_1 : 0}),
                      fluidPhaseTemperature: 298,
                      adsorbedPhaseConcs: AdsorbedPhaseConcs(
                          SphericalCoordinateValues.fromDimensions(
                              rVectorLength: 1,
                              angle1VectorLength: 1,
                              angle2VectorLength: 1,
                              //Inicializa em 0 mesmo --> Adsorvente est?? "limpo" no in??cio
                              constructorFromIndexes: (r, a1, a2) =>
                                  ConcentrationMap({methyleneBlue: 0}))),
                      adsorbentTemperature: 298,
                    );
                  }));
          final result = simulator.simulate(
              initialState: initialState.clone(),
              boundaryConditions: initialState.clone(),
              totalTime: 250000, //30956324.1,//esse n??mero ?? aprox. 10.k de tau, que ?? o adimensional.// 80e3, //500 * 60, //500 min * 60 s/min
              numberOfTimeSteps: 350, //100, //8,
              dimensions: columnDimensionsGeneral,
              stepCalc: (
                  {required CyllindricalAdsorptionColumnState state,
                  required CyllindricalAdsorptionColumnState previousState,
                  required int timeStep,
                  required int zIndex,
                  required int rIndex,
                  required int angleIndex,
                  required CyllindricalAdsorptionColumnSimulationDiscretization
                      discretization,
                  required CyllindricalColumnWithSphericalParticleDimensions
                      dimensions}) {
                final data =
                    state.state.get(r: rIndex, z: zIndex, angle: angleIndex);

                ///Eq. 14 do artigo, p??gina 7
                ///(eq 14) | dc/dt = D_L * (d??C/dz??) - u0*(dC/dz) - (??b/??)*dS/dt
                ///(eq 15) | dS/dt = a[S_eq(C) - S]
                ///(eq 16) | D_L = (Dm/F??)  + a_L*u_0
                ///
                ///Dimensionless variables;
                ///C* = C/C0
                ///
                if (zIndex == 0) {
                  //Na entrada, na posi????o 0, C(methyleneBlue) = C0_1 90.1 kg/m??
                  //data.fluidPhaseConcs?.setValueAt(methyleneBlue, C0_1);
                  //na entrada, a concentra????o ?? C0
                  state.state.setValueAt(
                      value: data
                        ..fluidPhaseConcs?.setValueAt(methyleneBlue, C0_1),
                      z: zIndex,
                      r: rIndex,
                      angle: angleIndex);
                }

                final S =
                    data.adsorbedPhaseConcs?.getAt().getAt(methyleneBlue) ?? 0;
                final C = data.fluidPhaseConcs?.getAt(methyleneBlue) ?? 0;

                //1?? calcula as derivadas do espa??o
                //1.1) derivada segunda
                double d2cdz2 = 0;
                if (zIndex >= 1 && zIndex < state.state.lengthIndexLength - 1) {
                  // print(
                  //     'f[n-1] = ${state.state.get(r: rIndex, z: zIndex - 1, angle: angleIndex).fluidPhaseConcs?.getAt(methyleneBlue)}');
                  // print(
                  //     'f[n] = ${state.state.get(r: rIndex, z: zIndex, angle: angleIndex).fluidPhaseConcs?.getAt(methyleneBlue)}');
                  // print(
                  //     'f[n+1] = ${state.state.get(r: rIndex, z: zIndex + 1, angle: angleIndex).fluidPhaseConcs?.getAt(methyleneBlue)}');
                  d2cdz2 = secondDev.d2ydx2(SecondDerivativeInput(
                      f_minus_1: state.state
                              .get(r: rIndex, z: zIndex - 1, angle: angleIndex)
                              .fluidPhaseConcs
                              ?.getAt(methyleneBlue) ??
                          0,
                      f_0: state.state
                              .get(r: rIndex, z: zIndex, angle: angleIndex)
                              .fluidPhaseConcs
                              ?.getAt(methyleneBlue) ??
                          0,
                      f_plus_1: state.state
                              .get(r: rIndex, z: zIndex + 1, angle: angleIndex)
                              .fluidPhaseConcs
                              ?.getAt(methyleneBlue) ??
                          0,
                      h: (discretization.zDiscretization[zIndex + 1] -
                              discretization.zDiscretization[zIndex - 1]) /
                          2));
                }
                double dcdz = 0;
                //1.2) derivada primeira
                if (zIndex >= 1) {
                  dcdz = singleDev.dydx(
                      ValuePair(
                          state.state
                                  .get(
                                      r: rIndex,
                                      z: zIndex - 1,
                                      angle: angleIndex)
                                  .fluidPhaseConcs
                                  ?.getAt(methyleneBlue) ??
                              0,
                          state.state
                                  .get(r: rIndex, z: zIndex, angle: angleIndex)
                                  .fluidPhaseConcs
                                  ?.getAt(methyleneBlue) ??
                              0),
                      ValuePair(discretization.zDiscretization[zIndex - 1],
                          discretization.zDiscretization[zIndex]));
                }

                //Para langmuir:
                //A 25??C:
                final KL = 141.9; //m??/Kg || from table 8 (t?? no t??tulo)
                //From figure 3
                //final Ce = 153 * 1e-3; //mg/L --> kg/m??

                //eq 1
                //final Seq = KL * S_max * Ce / (1 + KL * Ce);
                //Acho que ?? s?? a C normal, n??o Ce. Sei l??.
                final Seq = KL * S_max * C / (1 + KL * C);

                //final dSdt = a * (Seq * C - S);
                //TODO ver essa equa????o a??
                //double a = kd*(1 + KL*C);
                double dSdt = a * (Seq - S);
                if (false && zIndex == 0) {
                  dSdt = 0;
                }

                //eq 16:
                final D_L = Dm / (F * porosity) + aL * u0;
                if (false && zIndex % 10 == 0 && timeStep % 10 == 0) {
                  print('t = $timeStep');
                  print('zIndex = $zIndex');
                  print('Seq = $Seq');
                  print('d2cdz2 = $d2cdz2');
                  print('dcdz = $dcdz');
                  print('DL = $D_L');
                  print('u0 = $u0');
                  print('termo dc = ${u0 * dcdz}');
                  print('termo d2c = ${D_L * (d2cdz2)}');
                  print('S = $S');
                  print('Seq = $Seq');
                  print('dSdt = $dSdt');
                }
                //FIXME tirei o dsdt  porque suspeito que os autores tenham esquecido zzz
                //de usar dsdt pra diminuir, deixaram s?? pra aumentar...
                double dcdt =
                    D_L * (d2cdz2) - u0 * dcdz; // - (rho_b / porosity) * dSdt;
                if (zIndex == 0) {
                  dcdt = 0;
                }

                if (false && zIndex == 1) {
                  print('C(z) = $C');
                  print(
                      'C(z-1) = ${state.state.get(r: rIndex, z: zIndex - 1, angle: angleIndex).fluidPhaseConcs?.getAt(methyleneBlue)}');
                  print('dz = ${discretization.zDiscretization[1]}');
                  print('dc/dz = $dcdz');
                  print('d??cdz?? = $d2cdz2');
                  print('dsdt = $dSdt');
                  print('dcdt = $dcdt');
                  print('C after = ${C + dcdt * discretization.time[1]}');
                  print('\n-----------------\n');
                }
                //P??e novos valores de C e S
                data.fluidPhaseConcs!
                  ..setValueAt(
                      methyleneBlue, C + dcdt * discretization.time[1]);
                final adsorbedMap =
                    data.adsorbedPhaseConcs!.getAt(r: 0, angle1: 0, angle2: 0);
                data.adsorbedPhaseConcs!
                  ..setValueAt(
                      r: 0,
                      angle1: 0,
                      angle2: 0,
                      value: adsorbedMap
                        ..setValueAt(
                            methyleneBlue, S + dSdt * discretization.time[1]));
                state.state.setValueAt(
                    value: data, z: zIndex, r: rIndex, angle: angleIndex);
              });

          print('elapsed: ${stopwatch.elapsed.inSeconds} s');
          //Faz novo vetor com os valores de conc na posi????o final
          String fixedTimeAllZs = 'z , solidPhase, liquidPhase \n';

          final liquidPhaseConcs = <double>[];
          final solidPhaseConcs = <double>[];

          final v20 = result.states[240].state;
          for (int z = 0; z < v20.lengthIndexLength; z++) {
            final data = v20.get(z: z, r: 0, angle: 0);

            //coloca o eixo z
            fixedTimeAllZs += ' ${result.discretization.zDiscretization[z]} , ';

            //coloca o s??lido
            fixedTimeAllZs +=
                ' ${data.adsorbedPhaseConcs?.getAtSurface().getAt(methyleneBlue) ?? 0}, ';

            //coloca o l??quido
            fixedTimeAllZs +=
                '${data.fluidPhaseConcs?.getAt(methyleneBlue) ?? 0} \n';
          }

          for (var s in result.states) {
            liquidPhaseConcs.add(s.state
                    .get(z: s.state.lengthIndexLength - 1, r: 0, angle: 0)
                    .fluidPhaseConcs
                    ?.getAt(methyleneBlue) ??
                0);
            solidPhaseConcs.add((s.state
                    .get(z: s.state.lengthIndexLength - 1, r: 0, angle: 0)
                    .adsorbedPhaseConcs
                    ?.getAtSurface()
                    .getAt(methyleneBlue) ??
                0));
            //       0));
            // for (int z = 0; z < s.state.lengthIndexLength; z++) {
            //   liquidPhaseConcs.add(s.state
            //           .get(z: s.state.lengthIndexLength, r: 0, angle: 0)
            //           .fluidPhaseConcs
            //           ?.getAt(methyleneBlue) ??
            //       0);
            //   solidPhaseConcs.add((s.state
            //           .get(z: z, r: 0, angle: 0)
            //           .adsorbedPhaseConcs
            //           ?.getAtSurface()
            //           .getAt(methyleneBlue) ??
            //       0));
            // }
          }
          String fixedZIsMax_AllTimes = 't , C_fluid, C_solid \n';

          ///Estado buscado:
          for (int si = 0; si<result.states.length; si++) {
            final s = result.states[si];
            final t = result.discretization.time[si];
            final z = s.state.lengthIndexLength-1;
            final valuesOnZ = s.state.get(z: z);
            fixedZIsMax_AllTimes +=
                ' ${result.discretization.time[si]} ,';
            fixedZIsMax_AllTimes +=
                ' ${valuesOnZ.fluidPhaseConcs?.getAt(methyleneBlue)} ,';
            fixedZIsMax_AllTimes +=
                ' ${valuesOnZ.adsorbedPhaseConcs?.getAtSurface().getAt(methyleneBlue)} \n';
          }
          print('\n\n\n');
          print('string:');
          print('\n');
          //print(fixedTimeAllZs);
          print(fixedZIsMax_AllTimes);
          print('\n\n\n');

          // print('---------------------------');
          // print('Liquid Concs:');
          // print(liquidPhaseConcs);
          // print('---------------------------');
          // print('Solid Concs:');
          // print(solidPhaseConcs);

          //C(z=0, t = 0) = C_01 (condi????o de contorno: C(z=0) = C0)
          expect(
              result.states.first.state
                  .get(z: 0, r: 0, angle: 0)
                  .fluidPhaseConcs
                  ?.getAt(methyleneBlue),
              C0_1);
          //C(z=0, t = totalTime) = C_01 (condi????o de contorno: C(z=0) = C0)
          expect(
              result.states.last.state
                  .get(z: 0, r: 0, angle: 0)
                  .fluidPhaseConcs
                  ?.getAt(methyleneBlue),
              C0_1);
          //C(z=L, t=0) = 0
          expect(
              result.states.first.state
                  .get(
                      z: result.states.last.state.lengthIndexLength - 1,
                      r: 0,
                      angle: 0)
                  .fluidPhaseConcs
                  ?.getAt(methyleneBlue),
              0);

          //TODO 1) testa se praticamente n??o muda o valor entre t = 400 e t = 500
          //TODO 2) testa se mudan??a ?? de quase 100% entre t=0 e t = 400
          //TODO 3) testa se em t=100 min, S = aprox. 62 mg/g
        });
      });
    });

    //validar com o artigo de ***Lead Removal***
    ///#1 - grupo de teste para figura 7
    ///#1.1 - teste da concentra????o no tempo 0 igual a 0
    ///#1.2 - teste da concentra????o em tempo intermedi??rio
    ///#1.3 - teste da concentra????o no tempo em que Ct aprox. = C0

    //teste comparativo: compara 2 simula????es, um com menor e outra com maior velocidade,
    //e v?? se a conc. est?? maior na correta.
    //throw UnimplementedError();
    test('a', () {
      expect(1, 2);
    });
  });
}
