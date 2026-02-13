import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories.dart';
import '../domain/entities/recipient.dart';
import '../domain/entities/wallet_balance.dart';
import '../domain/entities/wallet_payment_method.dart';
import '../domain/entities/wallet_transaction.dart';
import '../domain/recipient_repository.dart';
import '../domain/wallet_repository.dart';

class WalletState {
  const WalletState({
    required this.isLoading,
    required this.isSubmitting,
    required this.balance,
    required this.transactions,
    required this.paymentMethods,
    required this.recipients,
    required this.filteredRecipients,
    required this.recipientQuery,
    required this.depositInput,
    required this.selectedDepositMethodId,
    required this.withdrawInput,
    required this.selectedWithdrawMethodId,
    required this.transferInput,
    required this.selectedRecipientId,
    required this.lastCompletedTransaction,
    this.errorMessage,
  });

  factory WalletState.initial() {
    return const WalletState(
      isLoading: true,
      isSubmitting: false,
      balance: WalletBalance(currency: 'USD', available: 0, pending: 0),
      transactions: <WalletTransaction>[],
      paymentMethods: <WalletPaymentMethod>[],
      recipients: <Recipient>[],
      filteredRecipients: <Recipient>[],
      recipientQuery: '',
      depositInput: '',
      selectedDepositMethodId: null,
      withdrawInput: '',
      selectedWithdrawMethodId: null,
      transferInput: '',
      selectedRecipientId: null,
      lastCompletedTransaction: null,
      errorMessage: null,
    );
  }

  final bool isLoading;
  final bool isSubmitting;
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final List<WalletPaymentMethod> paymentMethods;
  final List<Recipient> recipients;
  final List<Recipient> filteredRecipients;
  final String recipientQuery;

  final String depositInput;
  final String? selectedDepositMethodId;

  final String withdrawInput;
  final String? selectedWithdrawMethodId;

  final String transferInput;
  final String? selectedRecipientId;

  final WalletTransaction? lastCompletedTransaction;
  final String? errorMessage;

  double get depositAmount => _parseInput(depositInput);
  double get withdrawAmount => _parseInput(withdrawInput);
  double get transferAmount => _parseInput(transferInput);

  WalletPaymentMethod? get selectedDepositMethod {
    final id = selectedDepositMethodId;
    if (id == null) {
      return null;
    }
    for (final method in paymentMethods) {
      if (method.id == id) {
        return method;
      }
    }
    return null;
  }

  WalletPaymentMethod? get selectedWithdrawMethod {
    final id = selectedWithdrawMethodId;
    if (id == null) {
      return null;
    }
    for (final method in paymentMethods) {
      if (method.id == id) {
        return method;
      }
    }
    return null;
  }

  Recipient? get selectedRecipient {
    final id = selectedRecipientId;
    if (id == null) {
      return null;
    }
    for (final recipient in recipients) {
      if (recipient.id == id) {
        return recipient;
      }
    }
    return null;
  }

  WalletState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    WalletBalance? balance,
    List<WalletTransaction>? transactions,
    List<WalletPaymentMethod>? paymentMethods,
    List<Recipient>? recipients,
    List<Recipient>? filteredRecipients,
    String? recipientQuery,
    String? depositInput,
    Object? selectedDepositMethodId = _sentinel,
    String? withdrawInput,
    Object? selectedWithdrawMethodId = _sentinel,
    String? transferInput,
    Object? selectedRecipientId = _sentinel,
    Object? lastCompletedTransaction = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      recipients: recipients ?? this.recipients,
      filteredRecipients: filteredRecipients ?? this.filteredRecipients,
      recipientQuery: recipientQuery ?? this.recipientQuery,
      depositInput: depositInput ?? this.depositInput,
      selectedDepositMethodId: identical(selectedDepositMethodId, _sentinel)
          ? this.selectedDepositMethodId
          : selectedDepositMethodId as String?,
      withdrawInput: withdrawInput ?? this.withdrawInput,
      selectedWithdrawMethodId: identical(selectedWithdrawMethodId, _sentinel)
          ? this.selectedWithdrawMethodId
          : selectedWithdrawMethodId as String?,
      transferInput: transferInput ?? this.transferInput,
      selectedRecipientId: identical(selectedRecipientId, _sentinel)
          ? this.selectedRecipientId
          : selectedRecipientId as String?,
      lastCompletedTransaction: identical(lastCompletedTransaction, _sentinel)
          ? this.lastCompletedTransaction
          : lastCompletedTransaction as WalletTransaction?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static double _parseInput(String raw) {
    if (raw.trim().isEmpty || raw.trim() == '.') {
      return 0;
    }
    final value = double.tryParse(raw);
    return value ?? 0;
  }
}

const _sentinel = Object();

final walletControllerProvider =
    StateNotifierProvider<WalletController, WalletState>((ref) {
  final walletRepository = ref.watch(walletRepositoryProvider);
  final recipientRepository = ref.watch(recipientRepositoryProvider);
  return WalletController(
    walletRepository: walletRepository,
    recipientRepository: recipientRepository,
  )..load();
});

class WalletController extends StateNotifier<WalletState> {
  WalletController({
    required WalletRepository walletRepository,
    required RecipientRepository recipientRepository,
  })  : _walletRepository = walletRepository,
        _recipientRepository = recipientRepository,
        super(WalletState.initial());

  final WalletRepository _walletRepository;
  final RecipientRepository _recipientRepository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait<dynamic>([
        _walletRepository.getBalance(),
        _walletRepository.getTransactions(limit: 20, offset: 0),
        _walletRepository.getPaymentMethods(),
        _recipientRepository.listRecipients(),
      ]);

      final methods = results[2] as List<WalletPaymentMethod>;
      final recipients = results[3] as List<Recipient>;

      state = state.copyWith(
        isLoading: false,
        balance: results[0] as WalletBalance,
        transactions: results[1] as List<WalletTransaction>,
        paymentMethods: methods,
        recipients: recipients,
        filteredRecipients: recipients,
        selectedDepositMethodId: state.selectedDepositMethodId ??
            (methods.isNotEmpty ? methods.first.id : null),
        selectedWithdrawMethodId: state.selectedWithdrawMethodId ??
            (methods.isNotEmpty ? methods.first.id : null),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void appendDepositKey(String key) {
    state = state.copyWith(depositInput: _appendInput(state.depositInput, key));
  }

  void backspaceDeposit() {
    state = state.copyWith(depositInput: _backspace(state.depositInput));
  }

  void appendWithdrawKey(String key) {
    state =
        state.copyWith(withdrawInput: _appendInput(state.withdrawInput, key));
  }

  void backspaceWithdraw() {
    state = state.copyWith(withdrawInput: _backspace(state.withdrawInput));
  }

  void appendTransferKey(String key) {
    state =
        state.copyWith(transferInput: _appendInput(state.transferInput, key));
  }

  void backspaceTransfer() {
    state = state.copyWith(transferInput: _backspace(state.transferInput));
  }

  void setDepositMethod(String methodId) {
    state = state.copyWith(selectedDepositMethodId: methodId);
  }

  void setWithdrawMethod(String methodId) {
    state = state.copyWith(selectedWithdrawMethodId: methodId);
  }

  void selectRecipient(Recipient recipient) {
    state = state.copyWith(selectedRecipientId: recipient.id);
  }

  void setRecipientQuery(String query) {
    final normalized = query.trim().toLowerCase();
    final filtered = state.recipients.where((recipient) {
      if (normalized.isEmpty) {
        return true;
      }
      return recipient.name.toLowerCase().contains(normalized) ||
          recipient.handle.toLowerCase().contains(normalized);
    }).toList(growable: false);

    state = state.copyWith(
      recipientQuery: query,
      filteredRecipients: filtered,
    );
  }

  Future<bool> submitDeposit() async {
    final amount = state.depositAmount;
    final method = state.selectedDepositMethod;
    if (amount <= 0 || method == null) {
      state = state.copyWith(
        errorMessage: 'Enter an amount and choose a deposit method.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final tx =
          await _walletRepository.deposit(amount: amount, method: method);
      await _refreshWalletData();
      state = state.copyWith(
        isSubmitting: false,
        lastCompletedTransaction: tx,
      );
      return true;
    } catch (error) {
      state =
          state.copyWith(isSubmitting: false, errorMessage: error.toString());
      return false;
    }
  }

  Future<bool> submitWithdraw() async {
    final amount = state.withdrawAmount;
    final method = state.selectedWithdrawMethod;
    if (amount <= 0 || method == null) {
      state = state.copyWith(
        errorMessage: 'Enter an amount and choose a withdraw destination.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final tx =
          await _walletRepository.withdraw(amount: amount, method: method);
      await _refreshWalletData();
      state = state.copyWith(
        isSubmitting: false,
        lastCompletedTransaction: tx,
      );
      return true;
    } catch (error) {
      state =
          state.copyWith(isSubmitting: false, errorMessage: error.toString());
      return false;
    }
  }

  Future<bool> submitTransfer() async {
    final amount = state.transferAmount;
    final recipient = state.selectedRecipient;
    if (amount <= 0 || recipient == null) {
      state = state.copyWith(
        errorMessage: 'Enter an amount and choose a recipient.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final tx = await _walletRepository.transfer(
        amount: amount,
        recipient: recipient,
      );
      await _refreshWalletData();
      state = state.copyWith(
        isSubmitting: false,
        lastCompletedTransaction: tx,
      );
      return true;
    } catch (error) {
      state =
          state.copyWith(isSubmitting: false, errorMessage: error.toString());
      return false;
    }
  }

  void resetDepositFlow() {
    state = state.copyWith(
      depositInput: '',
      lastCompletedTransaction: null,
    );
  }

  void resetWithdrawFlow() {
    state = state.copyWith(
      withdrawInput: '',
      lastCompletedTransaction: null,
    );
  }

  void resetTransferFlow() {
    state = state.copyWith(
      transferInput: '',
      selectedRecipientId: null,
      recipientQuery: '',
      filteredRecipients: state.recipients,
      lastCompletedTransaction: null,
    );
  }

  Future<WalletTransaction?> getTransactionById(String id) {
    return _walletRepository.getTransactionById(id);
  }

  Future<void> _refreshWalletData() async {
    final balance = await _walletRepository.getBalance();
    final transactions =
        await _walletRepository.getTransactions(limit: 20, offset: 0);
    state = state.copyWith(
      balance: balance,
      transactions: transactions,
    );
  }

  String _appendInput(String current, String key) {
    if (key == '.') {
      if (current.contains('.')) {
        return current;
      }
      return current.isEmpty ? '0.' : '$current.';
    }

    if (key == '0' && current == '0') {
      return current;
    }

    if (current == '0') {
      return key;
    }

    final next = '$current$key';
    final decimalIndex = next.indexOf('.');
    if (decimalIndex >= 0 && next.length - decimalIndex > 3) {
      return current;
    }
    return next;
  }

  String _backspace(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input.substring(0, input.length - 1);
  }
}
