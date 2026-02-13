import '../domain/recipient_repository.dart';
import '../domain/entities/recipient.dart';

class MockRecipientRepository implements RecipientRepository {
  final List<Recipient> _items = const [
    Recipient(
        id: 'r-1',
        name: 'Aileen Fulbright',
        handle: 'a.fulbright@marsky.io',
        avatarSymbol: 'BTC'),
    Recipient(
        id: 'r-2',
        name: 'Leif Floyd',
        handle: 'leif.floyd@marsky.io',
        avatarSymbol: 'ETH'),
    Recipient(
        id: 'r-3',
        name: 'Tyra Dhillon',
        handle: 'tyra.dhillon@marsky.io',
        avatarSymbol: 'USDT'),
    Recipient(
        id: 'r-4',
        name: 'Marielle Wrighton',
        handle: 'marielle@marsky.io',
        avatarSymbol: 'SOL'),
    Recipient(
        id: 'r-5',
        name: 'Freda Warren',
        handle: 'freda.warren@marsky.io',
        avatarSymbol: 'ADA'),
    Recipient(
        id: 'r-6',
        name: 'Tyrell Eddings',
        handle: 'tyrell.eddings@marsky.io',
        avatarSymbol: 'BNB'),
  ];

  @override
  Future<List<Recipient>> listRecipients() async {
    return _items;
  }

  @override
  Future<List<Recipient>> searchRecipients(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _items;
    }

    return _items.where((recipient) {
      return recipient.name.toLowerCase().contains(normalized) ||
          recipient.handle.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }
}
