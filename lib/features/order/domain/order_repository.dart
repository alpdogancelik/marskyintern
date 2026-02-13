import 'entities/order_item.dart';
import 'entities/order_summary.dart';
import 'entities/payment_method.dart';
import 'entities/promo_code.dart';

abstract class OrderRepository {
  OrderSummary computeSummary({
    required OrderItem item,
    required PaymentMethod paymentMethod,
    PromoCode? promo,
  });

  PromoCode? validatePromoCode(String rawCode);

  List<PromoCode> getAvailablePromoCodes();
}
