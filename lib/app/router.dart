import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/app_shell/presentation/app_shell_screen.dart';
import '../features/activity/presentation/activity_screens.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/auth_state.dart' as domain;
import '../features/auth/presentation/auth_screens.dart';
import '../features/communications/presentation/communications_screens.dart';
import '../features/coins/presentation/market_list_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/order/presentation/order_screens.dart';
import '../features/portfolio/presentation/portfolio_screens.dart';
import '../features/settings/presentation/settings_screens.dart';
import '../features/stocks/presentation/stocks_screens.dart';
import '../features/wallet/presentation/wallet_screens.dart';
import '../ui/home/home_screen.dart';
import '../ui/onboarding/get_started_screens.dart';
import '../ui/onboarding/onboarding_pager_screen.dart';
import '../ui/onboarding/splash_screen.dart';

const String _kHomeRoute = '/app/home';
const String _kLoginRoute = '/auth/login';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final refresh = GoRouterRefreshStream(authRepository.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      return resolveAppAuthRedirect(
        location: state.matchedLocation,
        authState: authRepository.currentAuthState,
      );
    },
    errorBuilder: (context, state) => _RouterNotFoundScreen(state: state),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPagerScreen(),
      ),
      GoRoute(
        path: '/get-started-v1',
        builder: (context, state) => const GetStartedScreenV1(),
      ),
      GoRoute(
        path: '/get-started-v2',
        builder: (context, state) => const GetStartedScreenV2(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/success',
        builder: (context, state) => const PasswordResetSuccessScreen(),
      ),
      GoRoute(
        path: '/auth/verify',
        builder: (context, state) => VerificationCodeScreen(
          email: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(
        path: '/auth/biometric-face',
        builder: (context, state) => const BiometricFaceScreen(),
      ),
      GoRoute(
        path: '/auth/biometric-fingerprint',
        builder: (context, state) => const BiometricFingerprintScreen(),
      ),
      GoRoute(
        path: '/login',
        redirect: (_, __) => '/auth/login',
      ),
      GoRoute(
        path: '/register',
        redirect: (_, __) => '/auth/signup',
      ),
      GoRoute(
        path: '/market',
        builder: (context, state) => const MarketListScreen(),
      ),
      GoRoute(
        path: '/order/crypto',
        builder: (context, state) => OrderCryptoScreen(
          symbol: state.uri.queryParameters['symbol'] ?? 'BTC',
        ),
      ),
      GoRoute(
        path: '/order/payment-method',
        builder: (context, state) => const OrderPaymentMethodScreen(),
      ),
      GoRoute(
        path: '/order/promo',
        builder: (context, state) => const OrderPromoCodeScreen(),
      ),
      GoRoute(
        path: '/order/confirm',
        builder: (context, state) => const OrderConfirmScreen(),
      ),
      GoRoute(
        path: '/order/success',
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: '/order/receipt',
        builder: (context, state) => const OrderReceiptScreen(),
      ),
      GoRoute(
        path: '/portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => ActivityDetailScreen(
              transactionId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
        routes: [
          GoRoute(
            path: 'topup',
            builder: (context, state) => const WalletTopupAmountScreen(),
            routes: [
              GoRoute(
                path: 'method',
                builder: (context, state) => const WalletTopupMethodScreen(),
              ),
              GoRoute(
                path: 'preview',
                builder: (context, state) => const WalletTopupPreviewScreen(),
              ),
              GoRoute(
                path: 'success',
                builder: (context, state) => const WalletTopupSuccessScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'withdraw',
            builder: (context, state) => const WalletWithdrawAmountScreen(),
            routes: [
              GoRoute(
                path: 'destination',
                builder: (context, state) =>
                    const WalletWithdrawDestinationScreen(),
              ),
              GoRoute(
                path: 'preview',
                builder: (context, state) =>
                    const WalletWithdrawPreviewScreen(),
              ),
              GoRoute(
                path: 'success',
                builder: (context, state) =>
                    const WalletWithdrawSuccessScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'transfer',
            builder: (context, state) => const WalletTransferAmountScreen(),
            routes: [
              GoRoute(
                path: 'recipients',
                builder: (context, state) =>
                    const WalletTransferRecipientsScreen(),
              ),
              GoRoute(
                path: 'preview',
                builder: (context, state) =>
                    const WalletTransferPreviewScreen(),
              ),
              GoRoute(
                path: 'success',
                builder: (context, state) =>
                    const WalletTransferSuccessScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'tx/:id',
            builder: (context, state) => WalletTransactionDetailScreen(
              transactionId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
        routes: [
          GoRoute(
            path: 'personal',
            builder: (context, state) => const PersonalDataScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const PersonalDataEditScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'banks',
            builder: (context, state) => const BankAccountsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const BankAccountAddScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => BankAccountDetailScreen(
                  bankId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'withdraw-destination',
            builder: (context, state) => WithdrawDestinationScreen(
              pickerMode: state.uri.queryParameters['picker'] == '1',
            ),
          ),
          GoRoute(
            path: 'social',
            builder: (context, state) => const SocialLinksScreen(),
          ),
          GoRoute(
            path: 'payment-methods',
            builder: (context, state) => const PaymentMethodsScreen(),
            routes: [
              GoRoute(
                path: 'add-card',
                builder: (context, state) => const AddCardScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguageScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const PushNotificationsScreen(),
          ),
          GoRoute(
            path: 'verify-identity',
            builder: (context, state) => const IdentityVerificationScreen(),
          ),
          GoRoute(
            path: 'two-step',
            builder: (context, state) => const TwoStepVerificationScreen(),
          ),
          GoRoute(
            path: 'create-pin',
            builder: (context, state) => const CreatePinScreen(),
          ),
          GoRoute(
            path: 'reset-password',
            builder: (context, state) => const ResetPasswordRequestScreen(),
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutAppScreen(),
          ),
          GoRoute(
            path: 'help',
            builder: (context, state) => const HelpCenterScreen(),
          ),
          GoRoute(
            path: 'faq',
            builder: (context, state) => const FaqScreen(),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: 'terms',
            builder: (context, state) => const TermsConditionScreen(),
          ),
          GoRoute(
            path: 'referral',
            builder: (context, state) => const ReferralCodeScreen(),
            routes: [
              GoRoute(
                path: 'share',
                builder: (context, state) => const ReferralShareScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesListScreen(),
        routes: [
          GoRoute(
            path: 'search',
            builder: (context, state) => const MessagesSearchScreen(),
          ),
          GoRoute(
            path: 'thread/:id',
            builder: (context, state) => MessageThreadScreen(
              threadId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => NotificationDetailScreen(
              notificationId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/app',
        redirect: (context, state) => _kHomeRoute,
      ),
      GoRoute(
        path: '/stocks',
        builder: (context, state) => StocksMarketScreen(
          initialSector: state.uri.queryParameters['sector'],
        ),
        routes: [
          GoRoute(
            path: 'sectors',
            builder: (context, state) => const StocksSectorsScreen(),
          ),
          GoRoute(
            path: 'search',
            builder: (context, state) => const StocksSearchScreen(),
          ),
          GoRoute(
            path: 'portfolio',
            builder: (context, state) => const StocksPortfolioScreen(),
          ),
          GoRoute(
            path: 'exchange',
            builder: (context, state) => const StocksExchangeScreen(),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const StocksHistoryScreen(),
          ),
          GoRoute(
            path: 'buy/:symbol',
            builder: (context, state) => BuyStockScreen(
              symbol: state.pathParameters['symbol'] ?? 'AAPL',
            ),
          ),
          GoRoute(
            path: 'sell/:symbol',
            builder: (context, state) => SellStockScreen(
              symbol: state.pathParameters['symbol'] ?? 'AAPL',
            ),
          ),
          GoRoute(
            path: ':symbol',
            builder: (context, state) {
              final symbol = state.pathParameters['symbol'] ?? 'AAPL';
              final darkVariant =
                  state.uri.queryParameters['variant'] == 'dark';
              return StockDetailScreen(
                symbol: symbol,
                darkVariant: darkVariant,
              );
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

enum _RouteAccess { public, protected }

const Set<String> _publicRoutes = {
  '/splash',
  '/onboarding',
  '/get-started-v1',
  '/get-started-v2',
  '/login',
  '/register',
};

_RouteAccess _routeAccessForLocation(String location) {
  if (location.startsWith('/auth') || _publicRoutes.contains(location)) {
    return _RouteAccess.public;
  }
  return _RouteAccess.protected;
}

@visibleForTesting
String? resolveAppAuthRedirect({
  required String location,
  required domain.AuthState authState,
}) {
  final isAuthenticated = authState.isAuthenticated;
  final routeAccess = _routeAccessForLocation(location);
  final isPublicRoute = routeAccess == _RouteAccess.public;

  if (!isAuthenticated && !isPublicRoute) {
    return _kLoginRoute;
  }
  if (isAuthenticated && location.startsWith('/auth')) {
    return _kHomeRoute;
  }
  if (isAuthenticated && location == '/splash') {
    return _kHomeRoute;
  }
  return null;
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
          onError: (_, __) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _RouterNotFoundScreen extends StatelessWidget {
  const _RouterNotFoundScreen({required this.state});

  final GoRouterState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No route matched "${state.uri.path}".',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go(_kHomeRoute),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
