import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _coordsCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController(text: '17:00 - 28/10/2023');
  final _notesCtrl = TextEditingController();

  String _selectedTeam = 'Đội kỹ thuật số 01';
  String _selectedWorker = 'Trần Thị B';
  String _selectedManager = 'Nguyễn Văn An (Quản lý)';
  String _selectedPriority = 'Trung bình';

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository();
    final workers = repo.staffList.map((s) => s.name).toList();
    workers.insert(0, 'Chưa phân công');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tạo / Giao công việc', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section Card 1
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('THÔNG TIN CHÍNH',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên công việc *',
                      hintText: 'Nhập tên nhiệm vụ...',
                      prefixIcon: Icon(Icons.task),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên công việc' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả chi tiết',
                      hintText: 'Nội dung hướng dẫn thực hiện...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Card 2: Location & Deadline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ĐỊA ĐIỂM & THỜI HẠN',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Địa điểm công trình / Trạm *',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập địa điểm' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _coordsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tọa độ GPS (Nếu có)',
                      hintText: '10.7769° N, 106.7009° E',
                      prefixIcon: Icon(Icons.my_location),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _deadlineCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Hạn hoàn thành *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập hạn hoàn thành' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Card 3: Assignment & Priority
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PHÂN CÔNG & MỨC ƯU TIÊN',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedTeam,
                    items: repo.teams.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedTeam = val!),
                    decoration: const InputDecoration(labelText: 'Chọn Đội/Nhóm *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: workers.contains(_selectedWorker) ? _selectedWorker : workers.first,
                    items: workers.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                    onChanged: (val) => setState(() => _selectedWorker = val!),
                    decoration: const InputDecoration(labelText: 'Nhân viên thực hiện *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    items: const [
                      DropdownMenuItem(value: 'Cao', child: Text('Cao (Gấp)')),
                      DropdownMenuItem(value: 'Trung bình', child: Text('Trung bình')),
                      DropdownMenuItem(value: 'Thấp', child: Text('Thấp')),
                    ],
                    onChanged: (val) => setState(() => _selectedPriority = val!),
                    decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú thêm',
                      hintText: 'Ghi chú cho nhân viên...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons: Save draft vs Assign
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.outline),
                    ),
                    onPressed: () => _submitTask(isDraft: true),
                    child: const Text('Lưu nháp'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _submitTask(isDraft: false),
                    child: const Text('Giao việc ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _submitTask({required bool isDraft}) {
    if (_formKey.currentState!.validate()) {
      AppRepository().createTask(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        location: _locationCtrl.text,
        coordinates: _coordsCtrl.text.isNotEmpty ? _coordsCtrl.text : null,
        deadline: _deadlineCtrl.text,
        teamName: _selectedTeam,
        workerName: isDraft ? 'Chưa phân công' : _selectedWorker,
        managerName: _selectedManager,
        priority: _selectedPriority,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDraft ? 'Đã lưu bản nháp công việc!' : 'Đã tạo và giao việc thành công!'),
          backgroundColor: Colors.green[800],
        ),
      );
      Navigator.pop(context);
    }
  }
}
