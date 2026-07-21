import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';
import '../tasks/models/task_model.dart';

class CompletionReportScreen extends StatefulWidget {
  final TaskModel task;

  const CompletionReportScreen({
    super.key,
    required this.task,
  });

  @override
  State<CompletionReportScreen> createState() => _CompletionReportScreenState();
}

class _CompletionReportScreenState extends State<CompletionReportScreen> {
  final TextEditingController _notesController = TextEditingController();
  final List<String> _selectedPhotos = [];
  final List<AttachedDocument> _selectedDocuments = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addPhotoMock() {
    if (_selectedPhotos.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 6 ảnh minh chứng!')),
      );
      return;
    }
    setState(() {
      _selectedPhotos.add('Ảnh minh chứng ${_selectedPhotos.length + 1}');
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _addDocumentMock(String ext) {
    final count = _selectedDocuments.length + 1;
    String name;
    String size;

    switch (ext.toLowerCase()) {
      case 'csv':
        name = 'Nhat_ky_thong_so_do_dac_$count.csv';
        size = '145 KB';
        break;
      case 'docx':
        name = 'Bien_ban_nghiem_thu_thi_cong_$count.docx';
        size = '2.1 MB';
        break;
      case 'xlsx':
        name = 'Bang_ke_chi_phi_vat_tu_$count.xlsx';
        size = '870 KB';
        break;
      case 'pdf':
      default:
        name = 'Ban_ve_so_do_ky_thuat_khu_A_$count.pdf';
        size = '4.2 MB';
        break;
    }

    setState(() {
      _selectedDocuments.add(AttachedDocument(
        name: name,
        extension: ext.toLowerCase(),
        size: size,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã tải lên tệp: $name ($ext.toUpperCase())')),
    );
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  void _showDocumentPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHỌN LOẠI FILE TẢI LÊN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Chọn định dạng tệp minh chứng kết quả làm việc của nhân viên:',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFileTypeCard(
                    ctx,
                    title: 'File CSV',
                    subtitle: '.csv',
                    color: Colors.teal,
                    icon: Icons.table_chart,
                    onTap: () {
                      Navigator.pop(ctx);
                      _addDocumentMock('csv');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFileTypeCard(
                    ctx,
                    title: 'File DOCX',
                    subtitle: '.docx',
                    color: Colors.blue[700]!,
                    icon: Icons.description,
                    onTap: () {
                      Navigator.pop(ctx);
                      _addDocumentMock('docx');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFileTypeCard(
                    ctx,
                    title: 'File XLSX',
                    subtitle: '.xlsx',
                    color: Colors.green[800]!,
                    icon: Icons.grid_on,
                    onTap: () {
                      Navigator.pop(ctx);
                      _addDocumentMock('xlsx');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFileTypeCard(
                    ctx,
                    title: 'File PDF',
                    subtitle: '.pdf',
                    color: Colors.red[700]!,
                    icon: Icons.picture_as_pdf,
                    onTap: () {
                      Navigator.pop(ctx);
                      _addDocumentMock('pdf');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ghi chú hoàn thành công việc!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final repo = AppRepository();
    await repo.submitCompletionReport(
      widget.task.id,
      notes,
      _selectedPhotos,
      _selectedDocuments,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 56),
        title: const Text('GỬI BÁO CÁO THÀNH CÔNG'),
        content: const Text(
          'Báo cáo đã được chuyển sang trạng thái "CHỜ DUYỆT". Quản lý sẽ sớm nghiệm thu.',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to task detail
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BÁO CÁO HOÀN THÀNH'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task context banner card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CÔNG VIỆC THỰC HIỆN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.outline,
                        ),
                      ),
                      Text(
                        widget.task.code,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.task.location,
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notes input
            const Text(
              'Ghi chú hoàn thành *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Mô tả chi tiết kết quả xử lý, thông số sau nghiệm thu, vật tư đã thay...',
              ),
            ),
            const SizedBox(height: 20),

            // Photo Evidence Picker Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hình ảnh minh chứng',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${_selectedPhotos.length}/6 ảnh',
                  style: const TextStyle(fontSize: 12, color: AppColors.outline),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Add photo buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addPhotoMock,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('CHỤP ÁNH'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addPhotoMock,
                    icon: const Icon(Icons.image),
                    label: const Text('THƯ VIỆN'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Preview Grid
            if (_selectedPhotos.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.outline),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có hình ảnh minh chứng nào được chọn',
                      style: TextStyle(fontSize: 13, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ] else ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _selectedPhotos.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image, color: AppColors.primary, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                _selectedPhotos[index],
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 24),

            // Document Attachments Section (CSV, DOCX, XLSX, PDF)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.attach_file, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Tài liệu minh chứng (CSV, DOCX, XLSX, PDF)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_selectedDocuments.length} tệp',
                  style: const TextStyle(fontSize: 12, color: AppColors.outline),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Document Upload Action Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showDocumentPickerOptions,
                icon: const Icon(Icons.file_upload_outlined, color: AppColors.primary),
                label: const Text(
                  'TẢI FILE MINH CHỨNG (.CSV, .DOCX, .XLSX, .PDF)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // List of selected documents
            if (_selectedDocuments.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.insert_drive_file_outlined, size: 36, color: AppColors.outline),
                    SizedBox(height: 6),
                    Text(
                      'Chưa có file tài liệu (CSV, DOCX, XLSX, PDF) nào được tải lên',
                      style: TextStyle(fontSize: 12, color: AppColors.outline),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedDocuments.length,
                itemBuilder: (context, index) {
                  final doc = _selectedDocuments[index];
                  Color extColor = Colors.blue;
                  IconData extIcon = Icons.insert_drive_file;

                  if (doc.extension == 'csv') {
                    extColor = Colors.teal;
                    extIcon = Icons.table_chart;
                  } else if (doc.extension == 'docx') {
                    extColor = Colors.blue[700]!;
                    extIcon = Icons.description;
                  } else if (doc.extension == 'xlsx') {
                    extColor = Colors.green[800]!;
                    extIcon = Icons.grid_on;
                  } else if (doc.extension == 'pdf') {
                    extColor = Colors.red[700]!;
                    extIcon = Icons.picture_as_pdf;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: extColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: extColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(extIcon, color: extColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: extColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      doc.extension.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    doc.size,
                                    style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () => _removeDocument(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Bottom Submit Action Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.8)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitReport,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_isLoading ? 'ĐANG GỬI BÁO CÁO...' : 'GỬI BÁO CÁO NGAY'),
            ),
          ),
        ),
      ),
    );
  }
}
