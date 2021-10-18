import 'package:adsorption_columns_flutterrr/domain/utils/clonable.dart';

class TridimensionalCoordinateValues<T>
    implements Clonable<TridimensionalCoordinateValues<T>> {
  final Map<int, Map<int, Map<int, T>>> _values;

  final int xVectorLength;
  final int yVectorLength;
  final int zVectorLength;

  T get({int x = 0, int y = 0, int z = 0}) {
    return _values[x]?[y]?[z] ?? (throw _TridimensionalValueNotFound(x, y, z));
  }
  
  ///Put the [value] at the position x, y, z. But ONLY if this position already exists.
  void setValueAt({required T value, required int x, required int y, required int z}) {
    if (_values.containsKey(x)) if (_values[x]!
        .containsKey(y)) if (_values[x]![y]!.containsKey(z)) {
      _values[x]![y]![z] = value;
      return;
    }

    throw _TridimensionalValueNotFound(x, y, z);
  }

  TridimensionalCoordinateValues._(this._values,
      {required this.xVectorLength,
      required this.yVectorLength,
      required this.zVectorLength});

  ///Cria uma vetor para cada dimensão, de 0 até o valor de *n*MaxIndex
  factory TridimensionalCoordinateValues.fromDimensions(
      {required int xVectorLength,
      required int yVectorLength,
      required int zVectorLength,
      required T Function(int xIndex, int yIndex, int zIndex)
          constructorFromIndexes}) {
    //Constrói o map
    final Map<int, Map<int, Map<int, T>>> values = {
      for (int x = 0; x < xVectorLength; x++)
        x: {
          for (int y = 0; y < yVectorLength; y++)
            y: {
              for (int z = 0; z < zVectorLength; z++)
                z: constructorFromIndexes(x, y, z)
            }
        }
    };

    return TridimensionalCoordinateValues._(values,
        xVectorLength: xVectorLength,
        yVectorLength: yVectorLength,
        zVectorLength: zVectorLength);
  }

  @override
  TridimensionalCoordinateValues<T> clone() {
    return TridimensionalCoordinateValues.fromDimensions(
        xVectorLength: xVectorLength,
        yVectorLength: yVectorLength,
        zVectorLength: zVectorLength,
        constructorFromIndexes: (x, y, z) {
          final value = _values[x]![y]![z]!;
          if (value is Clonable) {
            return value.clone();
          } else
            return value;
        });
  }
}

class _TridimensionalValueNotFound implements Exception {
  final int x, y, z;
  _TridimensionalValueNotFound(this.x, this.y, this.z);

  @override
  String toString() => 'There is not value registered for the keys (x: $x) (y: $y) (z: $z).';
}
