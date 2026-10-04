import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/product.dart';
import '../../models/local_document.dart';
import '../../services/asset_repository.dart';
import '../../services/api_client.dart';
import '../../services/document_repository.dart';
import '../../services/document_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';
import '../../services/recent_service.dart';
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

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDeleting = false;
  List<LocalDocument> _documents = [];
  StreamSubscription? _syncSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDocuments();
    // Sync-status badges (pending/uploading/synced/failed) should update
    // on their own once a background sync pass touches this asset's
    // documents, without the user having to leave and re-enter the screen.
    _syncSub = SyncService.onSyncEvent.listen((_) => _loadDocuments());
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  String formatDate(DateTime? date) {
    if (date == null) return 'Not added';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool get isWarrantyActive {
    if (widget.product.warrantyExpiry == null) return false;
    return widget.product.warrantyExpiry!.isAfter(DateTime.now());
  }

  int get remainingDays {
    if (widget.product.warrantyExpiry == null) return 0;
    return widget.product.warrantyExpiry!.difference(DateTime.now()).inDays;
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
        title: const Text('Delete product?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This will permanently remove "${widget.product.name}" from your vault.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
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
      RecentService.addRecent(doc.filename, 'File', widget.product.name);
      if (!mounted) return;

      if (doc.mimeType.startsWith('image/')) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => _ImageViewerScreen(file: file)));
      } else {
        final bytes = await file.length();
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Document available offline', style: TextStyle(color: AppColors.textPrimary)),
            content: Text(
              '${doc.filename} (${(bytes / 1024).toStringAsFixed(0)} KB) is saved on this device.\n\n'
              'In-app PDF preview isn\'t built yet -- this confirms the file is really stored locally and can be opened even without internet.',
              style: const TextStyle(color: AppColors.textSecondary),
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
        title: const Text('Remove document?', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('REMOVE', style: TextStyle(color: Colors.redAccent)),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Product Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: _isDeleting ? null : _editProduct,
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                  )
                : const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _isDeleting ? null : _deleteProduct,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.18), AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 35),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(product.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isWarrantyActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.warrantyExpiry == null
                              ? 'No warranty date'
                              : isWarrantyActive
                                  ? 'Warranty Active'
                                  : 'Warranty Expired',
                          style: TextStyle(
                            color: isWarrantyActive ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Warranty'),
                Tab(text: 'Files'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(product),
                _buildWarrantyTab(product),
                _buildFilesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Information',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            _detailRow('Product Name', product.name),
            _detailRow('Category', product.category),
            if (product.brand != null) _detailRow('Brand', product.brand!),
            if (product.modelNumber != null) _detailRow('Model Number', product.modelNumber!),
            _detailRow('Price', product.price == null ? 'Not added' : '₹${product.price!.toStringAsFixed(2)}'),
            _detailRow('Purchase Date', formatDate(product.purchaseDate)),
            _detailRow('Warranty Expiry', formatDate(product.warrantyExpiry)),
            _detailRow('Service Date', formatDate(product.serviceDate)),
            _detailRow('EMI Due Date', formatDate(product.emiDueDate)),
            _detailRow(
              'Notes',
              product.notes == null || product.notes!.trim().isEmpty ? 'No notes added' : product.notes!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarrantyTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warranty Status',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            _detailRow('Expires On', formatDate(product.warrantyExpiry)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: product.warrantyExpiry == null
                    ? AppColors.primary.withOpacity(0.1)
                    : isWarrantyActive
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                product.warrantyExpiry == null
                    ? 'No warranty information'
                    : isWarrantyActive
                        ? '$remainingDays days remaining'
                        : 'Warranty has expired',
                style: TextStyle(
                  color: product.warrantyExpiry == null
                      ? AppColors.primary
                      : isWarrantyActive
                          ? Colors.green
                          : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.product.id == null ? null : _addDocument,
              icon: const Icon(Icons.add),
              label: const Text('ADD DOCUMENT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
        Expanded(
          child: _documents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined, color: AppColors.textSecondary, size: 50),
                      SizedBox(height: 14),
                      Text('No documents added', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6),
                      Text(
                        'Bills and warranty files will appear here',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) => _documentTile(_documents[index]),
                ),
        ),
      ],
    );
  }

  Widget _documentTile(LocalDocument doc) {
    final isImage = doc.mimeType.startsWith('image/');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _viewDocument(doc),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  _syncBadge(doc.syncStatus),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _deleteDocument(doc),
          ),
        ],
      ),
    );
  }

  Widget _syncBadge(DocumentSyncStatus status) {
    late final String label;
    late final Color color;
    late final IconData icon;

    switch (status) {
      case DocumentSyncStatus.synced:
        label = 'Synced';
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case DocumentSyncStatus.uploading:
        label = 'Syncing…';
        color = AppColors.primary;
        icon = Icons.sync;
        break;
      case DocumentSyncStatus.pending:
        label = 'Pending';
        color = Colors.orangeAccent;
        icon = Icons.schedule;
        break;
      case DocumentSyncStatus.failed:
        label = 'Sync failed';
        color = Colors.redAccent;
        icon = Icons.error_outline;
        break;
      case DocumentSyncStatus.deleted:
        label = 'Deleting…';
        color = AppColors.textSecondary;
        icon = Icons.delete_outline;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
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
