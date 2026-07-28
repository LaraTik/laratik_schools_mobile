import 'package:equatable/equatable.dart';
import 'package:laratik_schools_api/laratik_schools_api.dart';

@immutable
class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.priority,
    required this.read,
    required this.sentAt,
    required this.deepLink,
    required this.raw,
  });

  factory NotificationItem.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    bool pickBool(String key) {
      final v = json[key];
      if (v is bool) return v;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    return NotificationItem(
      id: pickString('name') ?? pickString('id') ?? '',
      title: pickString('title') ?? pickString('subject') ?? '',
      body: pickString('body') ?? pickString('message') ?? '',
      category: pickString('category') ?? pickString('type') ?? 'General',
      priority: pickString('priority') ?? 'Normal',
      read: pickBool('read'),
      sentAt: pickString('sent_at') ??
          pickString('creation') ??
          pickString('received_at'),
      deepLink: pickString('deep_link') ?? pickString('href'),
      raw: json,
    );
  }

  final String id;
  final String title;
  final String body;
  final String category;
  final String priority;
  final bool read;
  final String? sentAt;
  final String? deepLink;
  final JsonMap raw;

  bool get isHighPriority => priority.toLowerCase() == 'high';

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        category,
        priority,
        read,
        sentAt,
        deepLink,
      ];
}

@immutable
class CommunicationLogEntry extends Equatable {
  const CommunicationLogEntry({
    required this.id,
    required this.subject,
    required this.body,
    required this.channel,
    required this.recipientCount,
    required this.status,
    required this.sentAt,
    required this.raw,
  });

  factory CommunicationLogEntry.fromJson(JsonMap json) {
    String? pickString(String key) {
      final v = json[key];
      if (v is String) return v.isEmpty ? null : v;
      return null;
    }

    int? pickInt(String key) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return CommunicationLogEntry(
      id: pickString('name') ?? pickString('id') ?? '',
      subject: pickString('subject') ?? pickString('title') ?? '',
      body: pickString('body') ?? pickString('message') ?? '',
      channel: pickString('channel') ?? pickString('type') ?? '',
      recipientCount: pickInt('recipient_count') ?? pickInt('recipients') ?? 0,
      status: pickString('status') ?? 'Sent',
      sentAt: pickString('sent_at') ?? pickString('creation'),
      raw: json,
    );
  }

  final String id;
  final String subject;
  final String body;
  final String channel;
  final int recipientCount;
  final String status;
  final String? sentAt;
  final JsonMap raw;

  @override
  List<Object?> get props => [
        id,
        subject,
        body,
        channel,
        recipientCount,
        status,
        sentAt,
      ];
}
