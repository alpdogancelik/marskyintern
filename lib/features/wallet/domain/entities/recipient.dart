class Recipient {
  const Recipient({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarSymbol,
  });

  final String id;
  final String name;
  final String handle;
  final String? avatarSymbol;
}
