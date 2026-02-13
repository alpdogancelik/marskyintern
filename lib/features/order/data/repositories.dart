import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/order_repository.dart';
import '../domain/payment_repository.dart';
import 'mock_order_repository.dart';
import 'mock_payment_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return MockOrderRepository();
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return MockPaymentRepository();
});
