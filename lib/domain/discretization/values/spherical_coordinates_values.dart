import 'package:adsorption_columns_flutterrr/domain/utils/utils.dart';

import 'tridimensional_coordinates_values.dart';

///[T] é o tipo de coisa que é armazenada
class SphericalCoordinateValues<T> implements Clonable {
  ///Reúsa essa classe internamente para facilitar a vida.
  ///
  ///O mapa é feito assim:
  ///
  ///[spherical] = 3D
  ///
  ///[r] = [x]
  ///
  ///[angle1] = [y]
  ///
  ///[angle2] = [z]
  final TridimensionalCoordinateValues<T> _v;

  ///O index máximo no eixo do comprimento. Útil para processo iterativos e para saber as dimensões.
  int get radiusIndexLength => _v.xVectorLength;

  ///O index máximo no eixo do raio. Útil para processo iterativos e para saber as dimensões.
  int get angle1IndexLength => _v.yVectorLength;

  ///O index máximo no eixo do ângulo. Útil para processo iterativos e para saber as dimensões.
  int get angle2IndexLength => _v.zVectorLength;

  SphericalCoordinateValues._(this._v);

  T get({int r = 0, int angle1 = 0, int angle2 = 0}) {
    return _v.get(x: r, y: angle1, z: angle2);
  }

  void setValueAt(
      {required T value,
      required int r,
      required int angle1,
      required int angle2}) {
    this._v.setValueAt(value: value, x: r, y: angle1, z: angle2);
  }

  @override
  SphericalCoordinateValues<T> clone() {
    return SphericalCoordinateValues._(this._v.clone());
  }

  ///Cria uma vetor para cada dimensão, de 0 até o valor de *n*MaxIndex
  factory SphericalCoordinateValues.fromDimensions(
      {required int rVectorLength,
      required int angle1VectorLength,
      required int angle2VectorLength,
      required T Function(int rIndex, int angle1Index, int angle2Index)
          constructorFromIndexes}) {
    ///Cria as novas coordenadas 3D
    final newV = TridimensionalCoordinateValues.fromDimensions(
        xVectorLength: rVectorLength,
        yVectorLength: angle1VectorLength,
        zVectorLength: angle2VectorLength,
        constructorFromIndexes: constructorFromIndexes);

    return SphericalCoordinateValues._(
      newV,
    );
  }
}
