import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../people/data/person_failure.dart';
import '../../people/data/person_providers.dart';
import 'communication_repository.dart';
import 'notification.dart';

final communicationRepositoryProvider = Provider<CommunicationRepository>((ref) {
  return CommunicationRepository(api: ref.watch(apiClientProvider));
});

class NotificationsListController
    extends AutoDisposeAsyncNotifier<AsyncValue<NotificationPage>> {
  String? _cursor;
  bool _unreadOnly = false;
  static const int _pageSize = 50;

  @override
  Future<AsyncValue<NotificationPage>> build() async {
    _cursor = null;
    return _fetchPage(reset: true);
  }

  Future<void> setUnreadOnly(bool value) async {
    _unreadOnly = value;
    await refresh();
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    final next = await _fetchPage(reset: false);
    state = next.whenData(
      (page) => NotificationPage(
        items: [...current.items, ...page.items],
        nextCursor: page.nextCursor,
      ),
    );
  }

  Future<void> refresh() async {
    _cursor = null;
    state = const AsyncLoading();
    state = await _fetchPage(reset: true);
  }

  Future<AsyncValue<NotificationPage>> _fetchPage({required bool reset}) async {
    final repo = ref.read(communicationRepositoryProvider);
    final result = await repo.listNotifications(
      cursor: reset ? null : _cursor,
      limit: _pageSize,
      unreadOnly: _unreadOnly,
    );
    return switch (result) {
      Ok(:final value) => () {
          _cursor = value.nextCursor;
          return AsyncData(value);
        }(),
      Err(:final error) => AsyncError(error, StackTrace.current),
    };
  }
}

final notificationsListProvider = AsyncNotifierProvider.autoDispose<
    NotificationsListController, AsyncValue<NotificationPage>>(
  NotificationsListController.new,
);
