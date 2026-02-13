import '../domain/entities/payment_method.dart';
import '../domain/payment_repository.dart';

class MockPaymentRepository implements PaymentRepository {
  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    return const [
      PaymentMethod(
        id: 'bank-bofa',
        type: PaymentMethodType.bankTransfer,
        title: 'Bank of America',
        subtitle: '**** 1842',
        iconName: 'bank',
        feePercent: 0.4,
      ),
      PaymentMethod(
        id: 'bank-wells',
        type: PaymentMethodType.bankTransfer,
        title: 'Wells Fargo',
        subtitle: '**** 0291',
        iconName: 'bank',
        feePercent: 0.5,
      ),
      PaymentMethod(
        id: 'card-visa',
        type: PaymentMethodType.card,
        title: 'Visa',
        subtitle: '**** 5502',
        iconName: 'credit-card',
        feePercent: 1.65,
      ),
      PaymentMethod(
        id: 'card-master',
        type: PaymentMethodType.card,
        title: 'Mastercard',
        subtitle: '**** 9088',
        iconName: 'card-payment',
        feePercent: 1.8,
      ),
      PaymentMethod(
        id: 'ewallet-paypal',
        type: PaymentMethodType.ewallet,
        title: 'PayPal',
        subtitle: 'Connected wallet',
        iconName: 'wallet',
        feePercent: 1.1,
      ),
      PaymentMethod(
        id: 'ewallet-apple',
        type: PaymentMethodType.ewallet,
        title: 'Apple Pay',
        subtitle: 'Primary wallet',
        iconName: 'mobile-payment',
        feePercent: 1.2,
      ),
    ];
  }
}
