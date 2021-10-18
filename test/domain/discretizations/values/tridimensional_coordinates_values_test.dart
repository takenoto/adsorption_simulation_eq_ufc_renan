import 'package:adsorption_columns_flutterrr/domain/discretization/discretization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  

  group('3D coordinate values test |', () {
     final t = TridimensionalCoordinateValues<double>.fromDimensions(
      xVectorLength: 2,
      yVectorLength: 2,
      zVectorLength: 3,
      constructorFromIndexes: (x, y, z) {
        if (x == 0 || x == 2) {
          return -10;
        } else
          return 1;
      });
    
    test('creation == success', () {
      // for (int x = 0; x < t.xVectorLength; x++)
      //   for (int y = 0; y < t.yVectorLength; y++)
      //     for (int z = 0; z < t.zVectorLength; z++)
      //       print(t.get(x: x, y: y, z: z));

     expect(t.get(x: 0, y:0, z:0), -10);
     expect(t.get(x: 1, y:1, z:1), 1);
    });

    test('clone test', (){
      final clone = t.clone();
      t.setValueAt(value: 987, x: 1, y: 1, z: 1);
      clone.setValueAt(value: 123, x: 1, y: 1, z: 1);

      expect(t.get(x: 1, y: 1, z: 1), 987);
      expect(clone.get(x: 1, y: 1, z: 1), 123);
    });

    test('fails to set value out ot limits', (){
      final clone = t.clone();
      expect(() => clone.setValueAt(value: 12, x: 999, y: 12345, z: 789654123), throwsException);
    });
  });
}

