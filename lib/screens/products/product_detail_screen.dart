import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../../theme/app_colors.dart';
import '../../utils/format.dart';
import '../../widgets/swiss.dart';
import '../../theme/theme_controller.dart';
import '../../models/product.dart';
import '../../models/local_document.dart';
import '../../services/asset_repository.dart';
import '../../services/api_client.dart';
import '../../services/document_repository.dart';
import '../../services/document_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';
import '../../services/notification_service.dart';
import '../dashboard/add_product_screen.dart';
import '../scanner/document_capture_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with ThemeAwareState {
  bool _isDeleting = false;
  List<LocalDocument> _documents = [];
  StreamSubscription? _syncSub;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    // Sync-status badges (pending/uploading/synced/failed) should update
    // on their own once a background sync pass touches this asset's
    // documents, without the user having to leave and re-enter the screen.
    _syncSub = SyncService.onSyncEvent.listen((_) => _loadDocuments());
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    super.dispose();
  }

  void _loadDocuments() {
    if (!mounted || widget.product.id == null) return;
    setState(() => _documents = DocumentRepository.documentsForAsset(widget.product.id!));
    _refreshFromServer();
  }

  /// Reconciles documents uploaded from another device into the local
  /// list. Silently does nothing when offline -- the local/cached list
  /// from Hive is already showing, this is purely additive.
  Future<void> _refreshFromServer() async {
    if (widget.product.id == null || !ConnectivityService.isOnline) return;
    try {
      final remoteDocs = await DocumentService.listForAsset(widget.product.id!);
      await DocumentRepository.mergeRemoteDocuments(widget.product.id!, remoteDocs);
      if (!mounted) return;
      setState(() => _documents = DocumentRepository.documentsForAsset(widget.product.id!));
    } on ApiException {
      // Stay with whatever the local cache already has.
    }
  }

  String formatDate(DateTime? date) => date == null ? 'Not added' : dayMonthYear(date);

  bool get isWarrantyActive {
    if (widget.product.warrantyExpiry == null) return false;
    return widget.product.warrantyExpiry!.isAfter(DateTime.now());
  }

  int get remainingDays {
    final expiry = widget.product.warrantyExpiry;
    if (expiry == null) return 0;
    // Whole calendar days from today to the end date. Counting elapsed
    // 24-hour blocks instead would show "0 days left" for a warranty that
    // still runs until tomorrow.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(expiry.year, expiry.month, expiry.day);
    return (end.difference(today).inHours / 24).round();
  }

  Future<void> _editProduct() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen(existing: widget.product)),
    );
    if (updated == true && mounted) {
      // The list this screen was opened from needs to re-fetch, so bubble
      // the "changed" result up instead of trying to keep local state in
      // sync with what the backend now has.
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete product?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This will permanently remove "${widget.product.name}" from your vault.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('DELETE', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await AssetRepository.deleteAsset(widget.product.id!);
      await NotificationService.cancelReminder(widget.product.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not delete: ${e.message}')));
    }
  }

  Future<void> _addDocument() async {
    final doc = await Navigator.push<LocalDocument>(
      context,
      MaterialPageRoute(builder: (context) => DocumentCaptureScreen(assetId: widget.product.id!)),
    );
    if (doc != null) _loadDocuments();
  }

  Future<void> _viewDocument(LocalDocument doc) async {
    try {
      final file = await DocumentRepository.ensureLocalFile(doc);
      if (file == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This document has not finished syncing yet -- try again once you are online.')),
        );
        return;
      }
      if (!mounted) return;

      if (doc.mimeType.startsWith('image/')) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => _ImageViewerScreen(file: file)));
      } else {
        // PDFs open in whatever PDF viewer the phone has. If there is none
        // (or the hand-off fails), say so instead of doing nothing.
        final result = await OpenFilex.open(file.path, type: doc.mimeType);
        if (result.type == ResultType.done || !mounted) return;
        final bytes = await file.length();
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Could not open the PDF', style: TextStyle(color: AppColors.textPrimary)),
            content: Text(
              result.type == ResultType.noAppToOpen
                  ? '${doc.filename} (${(bytes / 1024).toStringAsFixed(0)} KB) is saved on this phone, but no app that can show PDFs is installed. Install a PDF viewer and try again.'
                  : '${doc.filename} (${(bytes / 1024).toStringAsFixed(0)} KB) is saved on this phone, but it could not be handed to a PDF viewer.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open document: $e')));
    }
  }

  Future<void> _deleteDocument(LocalDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Remove document?', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('REMOVE', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await DocumentRepository.deleteDocument(doc);
    _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    final expiry = product.warrantyExpiry;
    final soon = isWarrantyActive && remainingDays <= 30;

    String statusText;
    if (expiry == null) {
      statusText = 'No warranty date';
    } else if (!isWarrantyActive) {
      statusText = 'Warranty expired ${dayMonthYear(expiry)}';
    } else {
      statusText = 'Warranty to ${monthYear(expiry)} · $remainingDays ${remainingDays == 1 ? 'day' : 'days'} left';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(
        context,
        'Product',
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: Icon(Icons.edit_outlined, color: AppColors.textPrimary, size: 22),
            onPressed: _isDeleting ? null : _editProduct,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: _isDeleting
                ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                : Icon(Icons.delete_outline, color: AppColors.accent, size: 22),
            onPressed: _isDeleting ? null : _deleteProduct,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          Text(product.category, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 38, height: 1.05, fontWeight: FontWeight.w900, letterSpacing: -1.8),
          ),
          const SizedBox(height: 10),
          Text(
            statusText,
            style: TextStyle(
              color: (soon || (expiry != null && !isWarrantyActive)) ? AppColors.accent : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _statRow(product),
          const SizedBox(height: 28),
          const SwissLabel('Details'),
          _detailRow('Brand', product.brand),
          _detailRow('Model number', product.modelNumber),
          _detailRow('Purchased', product.purchaseDate == null ? null : dayMonthYear(product.purchaseDate!)),
          _detailRow('Warranty ends', expiry == null ? null : dayMonthYear(expiry)),
          _detailRow('Service due', product.serviceDate == null ? null : dayMonthYear(product.serviceDate!)),
          _detailRow('EMI due', product.emiDueDate == null ? null : dayMonthYear(product.emiDueDate!)),
          _detailRow('Reminder', product.reminderEnabled ? 'On' : 'Off'),
          _detailRow('Notes', (product.notes == null || product.notes!.trim().isEmpty) ? null : product.notes!.trim()),
          const SizedBox(height: 28),
          SwissLabel(
            'Files',
            trailing: GestureDetector(
              onTap: widget.product.id == null ? null : _addDocument,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Add', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 15, color: AppColors.accent),
              ]),
            ),
          ),
          if (_documents.isEmpty)
            const SwissMessage('No documents yet', body: 'Bills and warranty cards you add will show up here.')
          else
            for (final doc in _documents) _documentTile(doc),
        ],
      ),
    );
  }

  /// Price / purchased / warranty-ends, in the same ruled three-cell row as Home.
  Widget _statRow(Product product) {
    Widget cell(String label, String value, {bool first = false}) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.fromLTRB(first ? 0 : 12, 12, 8, 12),
          decoration: BoxDecoration(
            border: first ? null : Border(left: BorderSide(color: AppColors.rule, width: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4),
              ),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.rule, width: 0.8),
          bottom: BorderSide(color: AppColors.rule, width: 0.8),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cell('Price', product.price == null ? '—' : formatPrice(product.price!), first: true),
            cell('Purchased', product.purchaseDate == null ? '—' : monthYear(product.purchaseDate!)),
            cell('Warranty', product.warrantyDuration == null ? '—' : '${product.warrantyDuration} mo'),
          ],
        ),
      ),
    );
  }

  Widget _documentTile(LocalDocument doc) {
    return SwissRow(
      soft: true,
      title: doc.filename,
      subtitle: _syncLabel(doc.syncStatus),
      onTap: () => _viewDocument(doc),
      trailing: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: 'Remove',
        icon: Icon(Icons.close, color: AppColors.textSecondary, size: 20),
        onPressed: () => _deleteDocument(doc),
      ),
    );
  }

  String _syncLabel(DocumentSyncStatus status) {
    switch (status) {
      case DocumentSyncStatus.synced:
        return 'Synced';
      case DocumentSyncStatus.uploading:
        return 'Syncing…';
      case DocumentSyncStatus.pending:
        return 'Waiting to upload';
      case DocumentSyncStatus.failed:
        return 'Sync failed, will retry';
      case DocumentSyncStatus.deleted:
        return 'Deleting…';
    }
  }

  /// Label on the left, value on the right, hairline below. Rows with no
  /// value are left out entirely instead of showing "Not added".
  Widget _detailRow(String label, String? value) {
    if (value == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.ruleSoft, width: 0.8))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14))),
          Expanded(
            child: Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ImageViewerScreen extends StatelessWidget {
  final File file;
  const _ImageViewerScreen({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(child: InteractiveViewer(child: Image.file(file))),
    );
  }
}
