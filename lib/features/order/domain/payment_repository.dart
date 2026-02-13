import 'entities/payment_method.dart';

abstract class PaymentRepository {
  Future<List<PaymentMethod>> getPaymentMethods();
}
