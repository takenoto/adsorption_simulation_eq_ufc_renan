import 'package:adsorption_columns_flutterrr/domain/discretization/discretization.dart';
import 'package:adsorption_columns_flutterrr/domain/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final nZ = 12;
  final nR = 2;
  final nAngle = 1;

  final c = CyllindricalCoordinateValues<double>.fromDimensions(
      zVectorLength: nZ,
      rVectorLength: nR,
      angleVectorLength: nAngle,
      constructorFromIndexes: (z, r, angle) => 12345);

  group('CyllindricalCoordinatesTest |', () {
    test('creation success', () {
      for (int z = 0; z < nZ; z++)
        for (int r = 0; r < nR; r++)
          for (int angle = 0; angle < nAngle; angle++)
            expect(c.get(z: z, r: r, angle: angle), 12345);
    });


    test('clone success', (){
      final clone = c.clone();
      clone.setValueAt(value: 202, z: 2, r: 0, angle: 0);
      expect(clone.get(z: 2, r:0, angle: 0), 202);
    });

    
  });
}
