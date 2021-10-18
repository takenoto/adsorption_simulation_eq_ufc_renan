import 'package:adsorption_columns_flutterrr/domain/utils/utils.dart';

import 'tridimensional_coordinates_values.dart';

///[T] é o tipo de coisa que é armazenada
class CyllindricalCoordinateValues<T> implements Clonable {
  ///Reúsa essa classe internamente para facilitar a vida.
  ///
  ///O mapa é feito assim:
  ///
  ///[cyllindrical] = 3D
  ///
  ///[z] = [x]
  ///
  ///[r] = [y]
  ///
  ///[angle] = [z]
  final TridimensionalCoordinateValues<T> _v;

  ///O index máximo no eixo do comprimento. Útil para processo iterativos e para saber as dimensões.
  int get lengthIndexLength => _v.xVectorLength;

  ///O index máximo no eixo do raio. Útil para processo iterativos e para saber as dimensões.
  int get radiusIndexLength => _v.yVectorLength;

  ///O index máximo no eixo do ângulo. Útil para processo iterativos e para saber as dimensões.
  int get angleIndexLength => _v.zVectorLength;

  CyllindricalCoordinateValues._(this._v);

  T get({int z = 0, int r = 0, int angle = 0}) {
    return _v.get(x: z, y: r, z: angle);
  }

  void setValueAt(
      {required T value, required int z, required int r, required int angle}) {
        this._v.setValueAt(value: value, x: z, y: r, z: angle);
      }

  @override
  CyllindricalCoordinateValues<T> clone() {
    return CyllindricalCoordinateValues._(this._v.clone());
  }

  ///Cria uma vetor para cada dimensão, de 0 até o valor de *n*MaxIndex
  factory CyllindricalCoordinateValues.fromDimensions(
      {required int zVectorLength,
      required int rVectorLength,
      required int angleVectorLength,
      required T Function(int zIndex, int rIndex, int angleIndex)
          constructorFromIndexes}) {
    ///Cria as novas coordenadas 3D
    final newV = TridimensionalCoordinateValues.fromDimensions(
        xVectorLength: zVectorLength,
        yVectorLength: rVectorLength,
        zVectorLength: angleVectorLength,
        constructorFromIndexes: constructorFromIndexes);

    return CyllindricalCoordinateValues._(
      newV,
    );
  }
}
