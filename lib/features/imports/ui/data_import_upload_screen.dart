// SPDX-License-Identifier: Proprietary
// Data import wizard — upload step.
//
// Reachable from the Data imports surface as the
// `New import` AppBar action at
// `/shell/imports/upload`. The form collects:
//   * source label (required, free-form text)
//   * package file (required, selected via `file_picker`)
// On submit the screen calls
// `upload_school_data_import_package` with a
// `payload: { 'source': <label>, 'package_file':
// <file-name> }` envelope. The repository mints a fresh
// UUID v4 for the `Idempotency-Key` header so a retry of
// the same submit is safe to send again.
//
// Note: the v1 server's `package_file` field expects a
// URL reference (not raw bytes), so the mobile passes
// the file name as a placeholder inside the JSON
// payload. The full multipart upload to Frappe's file
// API is a documented follow-up — a followup note
// surfaces inside the form so the operator understands
// the limitation.
//
// Every user-facing string is locale-aware via
// [AppLocalizations.of(context)].

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/app_theme.dart';
import '../../../ui/design_tokens.dart';
import '../../../ui/widgets/ls_button.dart';
import '../../../ui/widgets/ls_status_chip.dart';
import '../../../ui/widgets/ls_text_field.dart';
import '../data/data_import_failure.dart';
import '../data/data_import_providers.dart';
import '../data/uploaded_data_import.dart';

class DataImportUploadScreen extends ConsumerStatefulWidget {
  const DataImportUploadScreen({super.key});

  @override
  ConsumerState<DataImportUploadScreen> createState() =>
      _DataImportUploadScreenState();
}

class _DataImportUploadScreenState
    extends ConsumerState<DataImportUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  String? _fileName;
  String? _filePath;
  int? _fileSize;
  bool _submitting = false;
  DataImportFailure? _error;
  UploadedDataImport? _result;

  // The wizard's local file size limit. The v1 server
  // doesn't enforce a hard cap; this is a mobile-side
  // guard so the operator doesn't try to upload a 2 GB
  // file that the JSON payload can't carry.
  static const int _maxFileSizeBytes = 25 * 1024 * 1024;

  // The set of extensions the wizard accepts. The v1
  // server expects a CSV / XLSX / JSON package; anything
  // else is rejected at the form layer (better UX than a
  // server-side 400).
  static const Set<String> _allowedExtensions = {
    '.csv',
    '.xlsx',
    '.json',
  };

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'xlsx', 'json'],
        withData: false,
      );
      if (!context.mounted) return;
      if (result == null || result.files.isEmpty) {
        // Operator cancelled — leave the form state alone.
        return;
      }
      final file = result.files.single;
      final path = file.path;
      final name = file.name;
      final size = file.size;
      final ext = _extension(name);
      if (ext.isEmpty) {
        setState(() {
          _error = DataImportFailure(
            code: 'FILE_MISSING_EXTENSION',
            message: l.dataImportsUploadFileMissingExtension,
          );
          _fileName = null;
          _filePath = null;
          _fileSize = null;
        });
        return;
      }
      if (!_allowedExtensions.contains(ext)) {
        setState(() {
          _error = DataImportFailure(
            code: 'FILE_TYPE_UNSUPPORTED',
            message: l.dataImportsUploadFileTypeUnsupported,
          );
          _fileName = null;
          _filePath = null;
          _fileSize = null;
        });
        return;
      }
      if (size > _maxFileSizeBytes) {
        setState(() {
          _error = DataImportFailure(
            code: 'FILE_TOO_LARGE',
            message: l.dataImportsUploadFileTooLarge,
          );
          _fileName = null;
          _filePath = null;
          _fileSize = null;
        });
        return;
      }
      // Confirm the file actually exists on disk. The
      // `file_picker` plugin returns the picked file's
      // path; on Android the path is a content URI in
      // some Android 11+ cases — fall back to the bare
      // name as a last resort.
      final exists = path != null && File(path).existsSync();
      setState(() {
        _fileName = name;
        _filePath = exists ? path : name;
        _fileSize = size;
      });
      if (!exists) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l.dataImportsUploadFilePicked(name)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on Exception catch (e) {
      if (!context.mounted) return;
      setState(() {
        _error = DataImportFailure(
          code: 'FILE_PICKER_ERROR',
          message: e.toString(),
        );
      });
    }
  }

  String _extension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return '.${name.substring(dot + 1).toLowerCase()}';
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_fileName == null || _filePath == null) {
      setState(() {
        _error = DataImportFailure(
          code: 'FILE_REQUIRED',
          message: AppLocalizations.of(context)
              .dataImportsUploadFileRequired,
        );
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    final outcome = await uploadDataImportPackage(
      ref,
      source: _sourceController.text.trim(),
      packageFile: _filePath!,
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _result = outcome.isOk
          ? (outcome as Ok<UploadedDataImport, DataImportFailure>).value
          : null;
      _error = outcome.isErr
          ? (outcome as Err<UploadedDataImport, DataImportFailure>).error
          : null;
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          switch (outcome) {
            Ok(:final value) => value.hasBatch
                ? l.dataImportsUploadSuccess(value.batch)
                : l.dataImportsUploadSuccessFallback,
            Err(:final error) => l.dataImportsUploadError(error.message),
          },
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: switch (outcome) {
          Ok() => tokens.status.success,
          Err() => tokens.status.error,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.laratik;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: tokens.surface.canvas,
      appBar: AppBar(
        backgroundColor: tokens.surface.surface,
        elevation: 0,
        title: Text(
          l.dataImportsUploadScreenTitle,
          style: tokens.typography.titleLarge.copyWith(
            color: tokens.text.primary,
          ),
        ),
        leading: IconButton(
          tooltip: l.commonBack,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _result != null ? _buildSuccess(tokens, l) : _buildForm(tokens, l),
    );
  }

  Widget _buildForm(DesignTokens tokens, AppLocalizations l) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          _SectionLabel(l.dataImportsUploadSourceLabel, tokens: tokens),
          LsTextField(
            label: l.dataImportsUploadSourceLabel,
            required: true,
            controller: _sourceController,
            hint: l.dataImportsUploadSourceHint,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l.dataImportsUploadSourceRequired;
              }
              return null;
            },
          ),
          SizedBox(height: tokens.space.md),
          _SectionLabel(l.dataImportsUploadFileLabel, tokens: tokens),
          Container(
            padding: EdgeInsets.all(tokens.space.md),
            decoration: BoxDecoration(
              color: tokens.surface.surface,
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(color: tokens.surface.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      color: _fileName == null
                          ? tokens.text.tertiary
                          : tokens.brand.primary,
                    ),
                    SizedBox(width: tokens.space.sm),
                    Expanded(
                      child: Text(
                        _fileName ??
                            l.dataImportsUploadFilePickerAction,
                        style: tokens.typography.bodyMedium.copyWith(
                          color: _fileName == null
                              ? tokens.text.secondary
                              : tokens.text.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_fileSize != null)
                      LsStatusChip(
                        label: _formatFileSize(_fileSize!),
                        tone: LsChipTone.neutral,
                        icon: Icons.straighten_outlined,
                      ),
                  ],
                ),
                SizedBox(height: tokens.space.sm),
                LsButton.secondary(
                  label: l.dataImportsUploadFilePickerAction,
                  icon: Icons.upload_file_outlined,
                  expand: false,
                  onPressed: _submitting ? null : _pickFile,
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space.md),
          Container(
            padding: EdgeInsets.all(tokens.space.md),
            decoration: BoxDecoration(
              color: tokens.status.warningContainer,
              borderRadius: BorderRadius.circular(tokens.radius.md),
              border: Border.all(color: tokens.status.warning),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: tokens.status.warning),
                SizedBox(width: tokens.space.sm),
                Expanded(
                  child: Text(
                    l.dataImportsUploadFollowupNote,
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.text.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space.lg),
          if (_error != null) ...[
            Container(
              padding: EdgeInsets.all(tokens.space.md),
              decoration: BoxDecoration(
                color: tokens.status.errorContainer,
                borderRadius: BorderRadius.circular(tokens.radius.md),
                border: Border.all(color: tokens.status.error),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: tokens.status.error),
                  SizedBox(width: tokens.space.sm),
                  Expanded(
                    child: Text(
                      _error!.message,
                      style: tokens.typography.bodyMedium.copyWith(
                        color: tokens.status.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.space.md),
          ],
          LsButton.primary(
            label: _submitting
                ? l.dataImportsUploadSubmitLoading
                : l.dataImportsUploadSubmitAction,
            icon: Icons.cloud_upload_outlined,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          SizedBox(height: tokens.space.lg),
        ],
      ),
    );
  }

  Widget _buildSuccess(DesignTokens tokens, AppLocalizations l) {
    return Padding(
      padding: EdgeInsets.all(tokens.space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: tokens.status.success),
              SizedBox(width: tokens.space.sm),
              Text(
                _result!.hasBatch
                    ? l.dataImportsUploadSuccess(_result!.batch)
                    : l.dataImportsUploadSuccessFallback,
                style: tokens.typography.titleLarge.copyWith(
                  color: tokens.text.primary,
                ),
              ),
            ],
          ),
          if (_result!.packageHash != null) ...[
            SizedBox(height: tokens.space.sm),
            Text(
              l.dataImportsHashChip(_result!.packageHash!),
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.text.secondary,
              ),
            ),
          ],
          if (_result!.counts.isNotEmpty) ...[
            SizedBox(height: tokens.space.md),
            Wrap(
              spacing: tokens.space.xs,
              runSpacing: tokens.space.xxs,
              children: [
                for (final entry in _result!.counts.entries)
                  LsStatusChip(
                    label: '${entry.key} · ${entry.value}',
                    tone: LsChipTone.info,
                    icon: Icons.layers_outlined,
                  ),
              ],
            ),
          ],
          SizedBox(height: tokens.space.lg),
          LsButton.primary(
            label: l.commonBack,
            icon: Icons.arrow_back,
            expand: false,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {required this.tokens});
  final String title;
  final DesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: tokens.space.xs),
      child: Text(
        title,
        style: tokens.typography.titleSmall.copyWith(
          color: tokens.text.secondary,
        ),
      ),
    );
  }
}
