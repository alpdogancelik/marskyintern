import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coins/data/coins_repository_impl.dart';
import '../../coins/domain/coins_repository.dart';
import '../../coins/domain/entities/coin.dart';
import '../data/repositories.dart';
import '../domain/entities/order_item.dart';
import '../domain/entities/order_status.dart';
import '../domain/entities/order_summary.dart';
import '../domain/entities/payment_method.dart';
import '../domain/entities/promo_code.dart';
import '../domain/order_repository.dart';
import '../domain/payment_repository.dart';

class OrderState {
  const OrderState({
    required this.symbol,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
    required this.appliedPromo,
    required this.availablePromos,
    required this.summary,
    required this.status,
    required this.isInitializing,
    required this.isSubmitting,
    this.errorMessage,
    this.promoError,
  });

  factory OrderState.initial() {
    return const OrderState(
      symbol: '',
      name: '',
      unitPrice: 0,
      quantity: 0,
      paymentMethods: <PaymentMethod>[],
      selectedPaymentMethod: null,
      appliedPromo: null,
      availablePromos: <PromoCode>[],
      summary: OrderSummary.empty,
      status: OrderStatus.draft,
      isInitializing: false,
      isSubmitting: false,
      errorMessage: null,
      promoError: null,
    );
  }

  final String symbol;
  final String name;
  final double unitPrice;
  final double quantity;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final PromoCode? appliedPromo;
  final List<PromoCode> availablePromos;
  final OrderSummary summary;
  final OrderStatus status;
  final bool isInitializing;
  final bool isSubmitting;
  final String? errorMessage;
  final String? promoError;

  bool get hasAsset => symbol.trim().isNotEmpty;
  bool get isQuantityValid => quantity > 0;
  bool get canPreview =>
      !isInitializing &&
      !isSubmitting &&
      isQuantityValid &&
      selectedPaymentMethod != null;

  OrderItem get currentItem => OrderItem(
        symbol: symbol,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity,
      );

  OrderState copyWith({
    String? symbol,
    String? name,
    double? unitPrice,
    double? quantity,
    List<PaymentMethod>? paymentMethods,
    Object? selectedPaymentMethod = _sentinel,
    Object? appliedPromo = _sentinel,
    List<PromoCode>? availablePromos,
    OrderSummary? summary,
    OrderStatus? status,
    bool? isInitializing,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
    Object? promoError = _sentinel,
  }) {
    return OrderState(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod: identical(selectedPaymentMethod, _sentinel)
          ? this.selectedPaymentMethod
          : selectedPaymentMethod as PaymentMethod?,
      appliedPromo: identical(appliedPromo, _sentinel)
          ? this.appliedPromo
          : appliedPromo as PromoCode?,
      availablePromos: availablePromos ?? this.availablePromos,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      isInitializing: isInitializing ?? this.isInitializing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      promoError: identical(promoError, _sentinel)
          ? this.promoError
          : promoError as String?,
    );
  }
}

const _sentinel = Object();

final orderControllerProvider =
    StateNotifierProvider<OrderController, OrderState>((ref) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  final paymentRepository = ref.watch(paymentRepositoryProvider);
  final coinsRepository = ref.watch(coinsRepositoryProvider);
  return OrderController(
    orderRepository: orderRepository,
    paymentRepository: paymentRepository,
    coinsRepository: coinsRepository,
  );
});

class OrderController extends StateNotifier<OrderState> {
  OrderController({
    required OrderRepository orderRepository,
    required PaymentRepository paymentRepository,
    required CoinsRepository coinsRepository,
  })  : _orderRepository = orderRepository,
        _paymentRepository = paymentRepository,
        _coinsRepository = coinsRepository,
        super(OrderState.initial());

  final OrderRepository _orderRepository;
  final PaymentRepository _paymentRepository;
  final CoinsRepository _coinsRepository;

  static const _baseBudgetUsd = 2000.0;

  Future<void> startCryptoOrder({required String symbol}) async {
    final normalizedSymbol = symbol.trim().toUpperCase();
    if (normalizedSymbol.isEmpty) {
      return;
    }

    state = OrderState.initial().copyWith(
      symbol: normalizedSymbol,
      name: _fallbackNameFor(normalizedSymbol),
      isInitializing: true,
      availablePromos: _orderRepository.getAvailablePromoCodes(),
    );

    try {
      final methods = await _paymentRepository.getPaymentMethods();
      final selectedMethod = methods.isEmpty ? null : methods.first;
      final coin = await _findCoinBySymbol(normalizedSymbol);
      final item = OrderItem(
        symbol: normalizedSymbol,
        name: coin?.name ?? _fallbackNameFor(normalizedSymbol),
        unitPrice: coin?.price ?? _fallbackPriceFor(normalizedSymbol),
        quantity: 0,
      );

      final summary = selectedMethod == null
          ? OrderSummary.empty
          : _orderRepository.computeSummary(
              item: item,
              paymentMethod: selectedMethod,
            );

      state = state.copyWith(
        name: item.name,
        unitPrice: item.unitPrice,
        quantity: 0,
        paymentMethods: methods,
        selectedPaymentMethod: selectedMethod,
        summary: summary,
        status: OrderStatus.draft,
        isInitializing: false,
        isSubmitting: false,
        errorMessage: null,
        promoError: null,
      );
    } catch (_) {
      final fallbackItem = OrderItem(
        symbol: normalizedSymbol,
        name: _fallbackNameFor(normalizedSymbol),
        unitPrice: _fallbackPriceFor(normalizedSymbol),
        quantity: 0,
      );
      state = state.copyWith(
        name: fallbackItem.name,
        unitPrice: fallbackItem.unitPrice,
        isInitializing: false,
        errorMessage: 'Unable to refresh live price. Using fallback data.',
      );
      _recompute();
    }
  }

  void setQuantity(double quantity) {
    final normalized = quantity.isFinite ? quantity : 0.0;
    state = state.copyWith(
      quantity: normalized < 0 ? 0.0 : normalized,
      promoError: null,
      status: OrderStatus.draft,
    );
    _recompute();
  }

  void setQuantityFromInput(String raw) {
    final normalized = raw.replaceAll(',', '.').trim();
    if (normalized.isEmpty) {
      setQuantity(0);
      return;
    }
    final parsed = double.tryParse(normalized);
    setQuantity(parsed ?? 0);
  }

  void setQuantityByPercent(int percent) {
    if (state.unitPrice <= 0) {
      return;
    }
    final safePercent = percent.clamp(1, 100).toDouble();
    final amountUsd = _baseBudgetUsd * (safePercent / 100);
    final quantity = amountUsd / state.unitPrice;
    setQuantity(_round(quantity, precision: 6));
  }

  void selectPaymentMethod(String paymentMethodId) {
    PaymentMethod? selected;
    for (final method in state.paymentMethods) {
      if (method.id == paymentMethodId) {
        selected = method;
        break;
      }
    }
    if (selected == null) {
      return;
    }
    state = state.copyWith(
      selectedPaymentMethod: selected,
      status: OrderStatus.draft,
      promoError: null,
    );
    _recompute();
  }

  bool applyPromoCode(String rawCode) {
    final promo = _orderRepository.validatePromoCode(rawCode);
    if (promo == null) {
      state = state.copyWith(
        promoError: 'Promo code not found. Please try another code.',
      );
      return false;
    }

    state = state.copyWith(
      appliedPromo: promo,
      promoError: null,
      status: OrderStatus.draft,
    );
    _recompute();
    return true;
  }

  void applyPromo(PromoCode promo) {
    state = state.copyWith(
      appliedPromo: promo,
      promoError: null,
      status: OrderStatus.draft,
    );
    _recompute();
  }

  void clearPromo() {
    state = state.copyWith(
      appliedPromo: null,
      promoError: null,
      status: OrderStatus.draft,
    );
    _recompute();
  }

  Future<bool> submitOrder() async {
    if (!state.canPreview) {
      state = state.copyWith(
        errorMessage: 'Please enter a valid amount before placing your order.',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      status: OrderStatus.pending,
      errorMessage: null,
      promoError: null,
    );

    await Future<void>.delayed(const Duration(milliseconds: 650));

    state = state.copyWith(
      isSubmitting: false,
      status: OrderStatus.success,
      errorMessage: null,
    );
    return true;
  }

  void clearOrder() {
    state = OrderState.initial();
  }

  void clearTransientError() {
    state = state.copyWith(errorMessage: null, promoError: null);
  }

  void _recompute() {
    final method = state.selectedPaymentMethod;
    if (method == null || !state.hasAsset) {
      state = state.copyWith(summary: OrderSummary.empty);
      return;
    }

    final summary = _orderRepository.computeSummary(
      item: state.currentItem,
      paymentMethod: method,
      promo: state.appliedPromo,
    );
    state = state.copyWith(summary: summary);
  }

  Future<Coin?> _findCoinBySymbol(String symbol) async {
    final batch = await _coinsRepository.getCoins(
      limit: 200,
      offset: 0,
      orderBy: 'marketCap',
      orderDirection: 'desc',
    );
    for (final coin in batch) {
      if (coin.symbol.toUpperCase() == symbol.toUpperCase()) {
        return coin;
      }
    }
    return null;
  }

  String _fallbackNameFor(String symbol) {
    return switch (symbol) {
      'BTC' => 'Bitcoin',
      'ETH' => 'Ethereum',
      'BNB' => 'BNB',
      'SOL' => 'Solana',
      'XRP' => 'XRP',
      _ => symbol,
    };
  }

  double _fallbackPriceFor(String symbol) {
    return switch (symbol) {
      'BTC' => 61245,
      'ETH' => 3250,
      'BNB' => 560,
      'SOL' => 142,
      'XRP' => 0.61,
      _ => 1,
    };
  }

  double _round(double value, {required int precision}) {
    final factor = BigInt.from(10).pow(precision).toDouble();
    return (value * factor).round() / factor;
  }
}
