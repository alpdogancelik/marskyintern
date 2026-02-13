import 'entities/recipient.dart';

abstract class RecipientRepository {
  Future<List<Recipient>> listRecipients();

  Future<List<Recipient>> searchRecipients(String query);
}
