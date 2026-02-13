import 'entities/portfolio_snapshot.dart';

abstract class PortfolioRepository {
  Future<PortfolioSnapshot> getPortfolioSnapshot();
}
