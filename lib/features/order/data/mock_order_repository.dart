import '../domain/entities/order_item.dart';
import '../domain/entities/order_summary.dart';
import '../domain/entities/payment_method.dart';
import '../domain/entities/promo_code.dart';
import '../domain/order_repository.dart';

class MockOrderRepository implements OrderRepository {
  static const _networkFeePercent = 0.65;
  static const _platformFeePercent = 0.35;

  final List<PromoCode> _promos = const [
    PromoCode(
      code: 'UPTO5',
      title: 'Up to 5% off',
      discountPercent: 5,
    ),
    PromoCode(
      code: 'SAVE12',
      title: 'Up to \$12 discount',
      discountAmount: 12,
    ),
    PromoCode(
      code: 'FREEFEE',
      title: 'No platform fee',
      discountPercent: 1,
    ),
  ];

  @override
  OrderSummary computeSummary({
    required OrderItem item,
    required PaymentMethod paymentMethod,
    PromoCode? promo,
  }) {
    final subtotal = item.subtotal;
    final paymentFee = subtotal * (paymentMethod.feePercent / 100);
    final networkFee = subtotal * (_networkFeePercent / 100);
    final platformFee = subtotal * (_platformFeePercent / 100);
    var fees = paymentFee + networkFee + platformFee;

    if (promo?.code.toUpperCase() == 'FREEFEE') {
      fees -= platformFee;
    }

    final discount = promo == null
        ? 0.0
        : _clampAmount(
            promo.discountFor(subtotal),
            lower: 0,
            upper: subtotal + fees,
          );

    final total = _clampAmount(subtotal + fees - discount,
        lower: 0, upper: double.infinity);

    return OrderSummary(
      subtotal: subtotal,
      fees: fees,
      discount: discount,
      total: total,
    );
  }

  @override
  PromoCode? validatePromoCode(String rawCode) {
    final normalized = rawCode.trim().toUpperCase();
    if (normalized.isEmpty) {
      return null;
    }
    for (final promo in _promos) {
      if (promo.code.toUpperCase() == normalized) {
        return promo;
      }
    }
    return null;
  }

  @override
  List<PromoCode> getAvailablePromoCodes() {
    return List<PromoCode>.unmodifiable(_promos);
  }

  double _clampAmount(
    double value, {
    required double lower,
    required double upper,
  }) {
    if (value < lower) {
      return lower;
    }
    if (value > upper) {
      return upper;
    }
    return value;
  }
}
