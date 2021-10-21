
///Dimensões da coluna de adsorção
class CyllindricalDimensions {
  final double length;
  final double radius;
  CyllindricalDimensions({required this.length, required this.radius});
}

class CyllindricalColumnWithSphericalParticleDimensions implements CyllindricalDimensions{
  @override
  final double length;
  @override
  final double radius;
  
  ///[porosity] must be =<1 and >=0
  final double porosity;
  
  final double particleRadius;
  
  CyllindricalColumnWithSphericalParticleDimensions({
    required this.length,
    required this.radius,
    required this.particleRadius,
    required this.porosity,
  }):assert(0<=porosity && porosity<=1);
}