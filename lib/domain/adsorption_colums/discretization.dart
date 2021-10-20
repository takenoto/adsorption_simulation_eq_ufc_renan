
import 'package:adsorption_columns_flutterrr/domain/adsorption_colums/dimensions.dart';

///Armazena os valores reais da discretização em cada eixo.
///
///Para obter dt e dz, por exemplo, você pode pegar o 2º valor do vetor.
///(Já que será igual ao ponto inicial (0) + dt == dt)
class CyllindricalAdsorptionColumnSimulationDiscretization {
  final CyllindricalDimensions dimensions;

  ///Discretização do tempo
  final List<double> time;

  ///Discretização do comprimento
  final List<double> zDiscretization;

  ///Discretização do raio
  final List<double> rDiscretization;

  ///Discretização do ângulo
  ///em radianos.
  final List<double> angleDiscretization;

  CyllindricalAdsorptionColumnSimulationDiscretization(
      {required this.dimensions,
      required this.time,
      required this.zDiscretization,
      required this.rDiscretization,
      required this.angleDiscretization});
}