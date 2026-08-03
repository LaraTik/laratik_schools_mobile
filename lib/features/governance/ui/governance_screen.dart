// SPDX-License-Identifier: Proprietary
// Admin "Governance" surface — read-only privacy requests queue
// with per-row approve / process / set-legal-hold actions.
//
// The screen renders the privacy queue with a chip strip that
// groups rows by lifecycle status (Submitted / Under Review /
// Approved / Rejected / Legal Hold). Each row carries:
//   * a 44dp icon (the request-type family — access /
//     deletion / consent / legal hold / governance / other),
//   * the subject's name + id,
//   * the wire status as a colored chip,
//   * the requester + submitted-at sub-line,
//   * the row's notes (when present).
//
// Tapping a row opens a bottom sheet with the per-row
// actions (Approve / Process / Set legal hold / Release
// legal hold). All four actions are write flows; the
// repository mints a fresh UUID for the `Idempotency-Key`
// header on every call (see `lib/platform/transport.dart`)
// and the provider invalidates `privacyRequestsProvider` on
// success so the list re-fetches the latest state.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)]; the chevron mirrors itself
// under RTL so the visual flow stays consistent with the
// text direction.
//
// Reachable from a "Governance" tile on the admin home
// (capability-gated on `can_manage_branches` — same
// admin-only gate as the Operations tile) at
// `/shell/governance`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_empty_state.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../data/governance_failure.dart';
import '../data/governance_providers.dart';
import '../data/governance_request.dart';

/// Read-only governance surface. Reachable from
/// `/shell/governance`.
class GovernanceScreen extends ConsumerWidget {
  const GovernanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.governanceScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l.governanceEvaluateRetentionTooltip,
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () => _onEvaluateRetention(context, ref),
          ),
          IconButton(
            tooltip: l.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(privacyRequestsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: const _PrivacyRequestsBody(),
    );
  }

  Future<void> _onEvaluateRetention(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l = AppLocalizations.of(context);
    final tokens = context.laratik;
    final messenger = ScaffoldMessenger.of(context);
    final result = await evaluateRetention(ref);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          switch (result) {
            Ok() => l.governanceEvaluateRetentionSuccess,
            Err() => l.governanceEvaluateRetentionFailure,
          },
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: switch (result) {
          Ok() => tokens.status.success,
          Err() => tokens.status.error,
        },
      ),
    );
  }
}

class _PrivacyRequestsBody extends ConsumerWidget {
  const _PrivacyRequestsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final async = ref.watch(privacyRequestsProvider);
    return async.when(
      data: (page) {
        if (page.requests.isEmpty) {
          return RefreshIndicator(
            color: tokens.brand.primary,
            onRefresh: () =>
                ref.read(privacyRequestsProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: LsStateView.empty(
                    icon: Icons.privacy_tip_outlined,
                    title: l.governanceEmptyTitle,
                    message: l.governanceEmptyMessage,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: tokens.brand.primary,
          onRefresh: () => ref.read(privacyRequestsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              tokens.space.md,
              tokens.space.md,
              tokens.space.md,
              tokens.space.xl,
            ),
            itemCount: page.requests.length + 1,
            separatorBuilder: (_, __) => SizedBox(height: tokens.space.sm),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _StatusStrip(requests: page.requests);
              }
              return _RequestRow(
                tokens: tokens,
                request: page.requests[index - 1],
              );
            },
          ),
        );
      },
      loading: () => LsStateView.loading(
        title: l.governanceLoadingTitle,
        message: l.governanceLoadingMessage,
      ),
      error: (err, _) => LsStateView.error(
        icon: Icons.error_outline,
        title: l.governanceErrorTitle,
        message: err.toString(),
        action: LsButton.primary(
          label: l.commonTryAgain,
          expand: false,
          onPressed: () => ref.read(privacyRequestsProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.requests});
  final List<PrivacyRequest> requests;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = context.laratik;
    final byStatus = <String, int>{};
    var hold = 0;
    for (final r in requests) {
      byStatus[r.status] = (byStatus[r.status] ?? 0) + 1;
      if (r.legalHold) hold += 1;
    }
    final chips = <Widget>[];
    for (final entry in byStatus.entries) {
      chips.add(
        LsStatusChip(
          label: '${entry.key} · ${entry.value}',
          tone: _toneForStatusFamily(_family(entry.key)),
          icon: _iconForStatusFamily(_family(entry.key)),
        ),
      );
    }
    if (hold > 0) {
      chips.add(
        LsStatusChip(
          label: l.governanceLegalHoldCountChip(hold),
          tone: LsChipTone.warning,
          icon: Icons.gavel_outlined,
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(tokens.space.md),
      decoration: BoxDecoration(
        color: tokens.surface.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.surface.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip_outlined, color: tokens.brand.primary),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Text(
                  l.governanceQueueHeader(requests.length),
                  style: tokens.typography.titleSmall.copyWith(
                    color: tokens.text.primary,
                  ),
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            SizedBox(height: tokens.space.sm),
            Wrap(
              spacing: tokens.space.xs,
              runSpacing: tokens.space.xxs,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }

  String _family(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('completed')) return 'approved';
    if (s.contains('rejected') ||
        s.contains('denied') ||
        s.contains('cancelled')) {
      return 'rejected';
    }
    if (s.contains('legal') || s.contains('hold')) return 'hold';
    if (s.contains('review') || s.contains('processing')) return 'review';
    if (s.contains('submitted') || s.contains('pending')) return 'pending';
    return 'other';
  }

  LsChipTone _toneForStatusFamily(String family) {
    return switch (family) {
      'approved' => LsChipTone.success,
      'rejected' => LsChipTone.error,
      'hold' => LsChipTone.warning,
      'review' => LsChipTone.info,
      'pending' => LsChipTone.brand,
      _ => LsChipTone.neutral,
    };
  }

  IconData _iconForStatusFamily(String family) {
    return switch (family) {
      'approved' => Icons.check_circle_outline,
      'rejected' => Icons.cancel_outlined,
      'hold' => Icons.gavel_outlined,
      'review' => Icons.hourglass_top_outlined,
      'pending' => Icons.inbox_outlined,
      _ => Icons.help_outline,
    };
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.tokens, required this.request});
  final DesignTokens tokens;
  final PrivacyRequest request;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: tokens.surface.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.surface.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _showActionSheet(context),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Semantics(
          button: true,
          label: request.subjectName.isEmpty
              ? request.subject
              : request.subjectName,
          child: Padding(
            padding: EdgeInsets.all(tokens.space.md),
            child: Row(
              children: [
                _FamilyIcon(tokens: tokens, request: request),
                SizedBox(width: tokens.space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        request.subjectName.isEmpty
                            ? (request.subject.isEmpty
                                ? l.governanceUnknownSubject
                                : request.subject)
                            : request.subjectName,
                        style: tokens.typography.titleSmall.copyWith(
                          color: tokens.text.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: tokens.space.xxs),
                      Row(
                        children: [
                          LsStatusChip(
                            label: _humanize(request.requestType),
                            tone: _toneForTypeFamily(request.typeFamily),
                            icon: _iconForTypeFamily(request.typeFamily),
                          ),
                          SizedBox(width: tokens.space.xs),
                          LsStatusChip(
                            label: request.status,
                            tone: _toneForStatusFamily(
                              request.statusFamily,
                            ),
                            icon: _iconForStatusFamily(
                              request.statusFamily,
                            ),
                          ),
                          if (request.legalHold) ...[
                            SizedBox(width: tokens.space.xs),
                            LsStatusChip(
                              label: l.governanceLegalHoldChip,
                              tone: LsChipTone.warning,
                              icon: Icons.gavel_outlined,
                            ),
                          ],
                        ],
                      ),
                      if (request.submittedBy.isNotEmpty ||
                          request.submittedAt.isNotEmpty) ...[
                        SizedBox(height: tokens.space.xxs),
                        Text(
                          _submissionLine(l),
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.text.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (request.notes.isNotEmpty) ...[
                        SizedBox(height: tokens.space.xxs),
                        Text(
                          request.notes,
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.text.tertiary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  // Mirror the chevron under RTL so the visual
                  // "next →" stays consistent with the text flow.
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  color: tokens.text.tertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _submissionLine(AppLocalizations l) {
    final parts = <String>[];
    if (request.submittedBy.isNotEmpty) parts.add(request.submittedBy);
    if (request.submittedAt.isNotEmpty) parts.add(request.submittedAt);
    return parts.join(' · ');
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _RequestActionSheet(request: request);
      },
    );
  }

  LsChipTone _toneForStatusFamily(String family) {
    return switch (family) {
      'approved' => LsChipTone.success,
      'rejected' => LsChipTone.error,
      'hold' => LsChipTone.warning,
      'review' => LsChipTone.info,
      'pending' => LsChipTone.brand,
      _ => LsChipTone.neutral,
    };
  }

  IconData _iconForStatusFamily(String family) {
    return switch (family) {
      'approved' => Icons.check_circle_outline,
      'rejected' => Icons.cancel_outlined,
      'hold' => Icons.gavel_outlined,
      'review' => Icons.hourglass_top_outlined,
      'pending' => Icons.inbox_outlined,
      _ => Icons.help_outline,
    };
  }

  LsChipTone _toneForTypeFamily(String family) {
    return switch (family) {
      'access' => LsChipTone.info,
      'deletion' => LsChipTone.error,
      'consent' => LsChipTone.warning,
      'legal_hold' => LsChipTone.warning,
      'governance' => LsChipTone.brand,
      _ => LsChipTone.neutral,
    };
  }

  IconData _iconForTypeFamily(String family) {
    return switch (family) {
      'access' => Icons.visibility_outlined,
      'deletion' => Icons.delete_outline,
      'consent' => Icons.assignment_late_outlined,
      'legal_hold' => Icons.gavel_outlined,
      'governance' => Icons.policy_outlined,
      _ => Icons.help_outline,
    };
  }

  String _humanize(String type) {
    if (type.isEmpty) return type;
    return type
        .split('_')
        .map((p) => p.isEmpty ? p : (p[0].toUpperCase() + p.substring(1)))
        .join(' ');
  }
}

class _FamilyIcon extends StatelessWidget {
  const _FamilyIcon({required this.tokens, required this.request});
  final DesignTokens tokens;
  final PrivacyRequest request;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, LsChipTone tone) = switch (request.typeFamily) {
      'access' => (Icons.visibility_outlined, LsChipTone.info),
      'deletion' => (Icons.delete_outline, LsChipTone.error),
      'consent' => (Icons.assignment_late_outlined, LsChipTone.warning),
      'legal_hold' => (Icons.gavel_outlined, LsChipTone.warning),
      'governance' => (Icons.policy_outlined, LsChipTone.brand),
      _ => (Icons.privacy_tip_outlined, LsChipTone.neutral),
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _bgFor(tone, tokens),
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: _fgFor(tone, tokens), size: 22),
    );
  }

  Color _bgFor(LsChipTone tone, DesignTokens tokens) {
    return switch (tone) {
      LsChipTone.success => tokens.status.successContainer,
      LsChipTone.warning => tokens.status.warningContainer,
      LsChipTone.error => tokens.status.errorContainer,
      LsChipTone.info => tokens.status.infoContainer,
      LsChipTone.brand => tokens.brand.primaryContainer,
      LsChipTone.neutral => tokens.surface.surfaceContainerHigh,
    };
  }

  Color _fgFor(LsChipTone tone, DesignTokens tokens) {
    return switch (tone) {
      LsChipTone.success => tokens.status.success,
      LsChipTone.warning => tokens.status.warning,
      LsChipTone.error => tokens.status.error,
      LsChipTone.info => tokens.status.info,
      LsChipTone.brand => tokens.brand.onPrimaryContainer,
      LsChipTone.neutral => tokens.text.secondary,
    };
  }
}

class _RequestActionSheet extends ConsumerStatefulWidget {
  const _RequestActionSheet({required this.request});
  final PrivacyRequest request;

  @override
  ConsumerState<_RequestActionSheet> createState() =>
      _RequestActionSheetState();
}

class _RequestActionSheetState extends ConsumerState<_RequestActionSheet> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = context.laratik;
    final canApprove = !widget.request.legalHold &&
        !_isFinalStatus(widget.request.statusFamily);
    final canProcess = widget.request.statusFamily == 'pending';
    final canSetHold = !_isFinalStatus(widget.request.statusFamily);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.surface.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radius.lg),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          tokens.space.md,
          tokens.space.md,
          tokens.space.md,
          tokens.space.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: EdgeInsets.only(bottom: tokens.space.md),
              decoration: BoxDecoration(
                color: tokens.surface.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l.governanceActionsTitle,
              style: tokens.typography.titleMedium.copyWith(
                color: tokens.text.primary,
              ),
            ),
            SizedBox(height: tokens.space.xs),
            Text(
              widget.request.subjectName.isEmpty
                  ? (widget.request.subject.isEmpty
                      ? l.governanceUnknownSubject
                      : widget.request.subject)
                  : widget.request.subjectName,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: tokens.space.md),
            if (_error != null) ...[
              Container(
                padding: EdgeInsets.all(tokens.space.sm),
                decoration: BoxDecoration(
                  color: tokens.status.errorContainer,
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: tokens.status.error,
                      size: 18,
                    ),
                    SizedBox(width: tokens.space.xs),
                    Expanded(
                      child: Text(
                        _error!,
                        style: tokens.typography.bodySmall.copyWith(
                          color: tokens.status.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.space.md),
            ],
            if (canProcess)
              _SheetAction(
                tokens: tokens,
                label: l.governanceActionProcess,
                description: l.governanceActionProcessDescription,
                icon: Icons.hourglass_top_outlined,
                tone: LsChipTone.info,
                busy: _busy,
                onPressed: () => _runAction(
                  l: l,
                  run: () => processPrivacyRequest(
                    ref,
                    requestName: widget.request.id,
                  ),
                ),
              ),
            if (canApprove)
              _SheetAction(
                tokens: tokens,
                label: l.governanceActionApprove,
                description: l.governanceActionApproveDescription,
                icon: Icons.check_circle_outline,
                tone: LsChipTone.success,
                busy: _busy,
                onPressed: () => _runAction(
                  l: l,
                  run: () => approvePrivacyRequest(
                    ref,
                    requestName: widget.request.id,
                  ),
                ),
              ),
            if (canSetHold)
              _SheetAction(
                tokens: tokens,
                label: widget.request.legalHold
                    ? l.governanceActionReleaseHold
                    : l.governanceActionSetHold,
                description: widget.request.legalHold
                    ? l.governanceActionReleaseHoldDescription
                    : l.governanceActionSetHoldDescription,
                icon: widget.request.legalHold
                    ? Icons.lock_open_outlined
                    : Icons.gavel_outlined,
                tone: widget.request.legalHold
                    ? LsChipTone.neutral
                    : LsChipTone.warning,
                busy: _busy,
                onPressed: () => _runAction(
                  l: l,
                  run: () => setPrivacyLegalHold(
                    ref,
                    requestName: widget.request.id,
                    hold: !widget.request.legalHold,
                  ),
                ),
              ),
            SizedBox(height: tokens.space.md),
            LsButton.secondary(
              label: l.commonClose,
              expand: false,
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFinalStatus(String family) {
    return family == 'approved' || family == 'rejected';
  }

  Future<void> _runAction({
    required AppLocalizations l,
    required Future<Result<void, GovernanceFailure>> Function() run,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await run();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = switch (result) {
        Ok() => null,
        Err(error: final e) => e.message,
      };
    });
    if (result is Ok) {
      if (!mounted) return;
      final tokens = context.laratik;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.governanceActionSuccess),
          duration: const Duration(seconds: 2),
          backgroundColor: tokens.status.success,
        ),
      );
    }
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.tokens,
    required this.label,
    required this.description,
    required this.icon,
    required this.tone,
    required this.busy,
    required this.onPressed,
  });
  final DesignTokens tokens;
  final String label;
  final String description;
  final IconData icon;
  final LsChipTone tone;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space.xs),
      child: Material(
        color: tokens.surface.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          side: BorderSide(color: tokens.surface.outlineVariant),
        ),
        child: InkWell(
          onTap: busy ? null : onPressed,
          borderRadius: BorderRadius.circular(tokens.radius.md),
          child: Semantics(
            button: !busy,
            enabled: !busy,
            label: label,
            child: Padding(
              padding: EdgeInsets.all(tokens.space.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _bgFor(tone, tokens),
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      color: _fgFor(tone, tokens),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: tokens.space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: tokens.typography.titleSmall.copyWith(
                            color: tokens.text.primary,
                          ),
                        ),
                        SizedBox(height: tokens.space.xxs),
                        Text(
                          description,
                          style: tokens.typography.bodySmall.copyWith(
                            color: tokens.text.secondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (busy) ...[
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: tokens.brand.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _bgFor(LsChipTone tone, DesignTokens tokens) {
    return switch (tone) {
      LsChipTone.success => tokens.status.successContainer,
      LsChipTone.warning => tokens.status.warningContainer,
      LsChipTone.error => tokens.status.errorContainer,
      LsChipTone.info => tokens.status.infoContainer,
      LsChipTone.brand => tokens.brand.primaryContainer,
      LsChipTone.neutral => tokens.surface.surfaceContainerHigh,
    };
  }

  Color _fgFor(LsChipTone tone, DesignTokens tokens) {
    return switch (tone) {
      LsChipTone.success => tokens.status.success,
      LsChipTone.warning => tokens.status.warning,
      LsChipTone.error => tokens.status.error,
      LsChipTone.info => tokens.status.info,
      LsChipTone.brand => tokens.brand.onPrimaryContainer,
      LsChipTone.neutral => tokens.text.secondary,
    };
  }
}
