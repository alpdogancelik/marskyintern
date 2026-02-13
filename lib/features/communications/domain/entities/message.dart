enum MessageType { text, image, voice }

enum AttachmentType { image, card }

class Attachment {
  const Attachment({
    required this.type,
    required this.title,
    required this.subtitle,
    this.previewAsset,
  });

  final AttachmentType type;
  final String title;
  final String subtitle;
  final String? previewAsset;
}

class Message {
  const Message({
    required this.id,
    required this.threadId,
    required this.sender,
    required this.timestamp,
    required this.type,
    required this.isOutgoing,
    this.text,
    this.attachment,
    this.voiceDuration,
  });

  final String id;
  final String threadId;
  final String sender;
  final String? text;
  final DateTime timestamp;
  final MessageType type;
  final Attachment? attachment;
  final Duration? voiceDuration;
  final bool isOutgoing;
}
