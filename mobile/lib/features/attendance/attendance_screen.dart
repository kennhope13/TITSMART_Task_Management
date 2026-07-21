import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_repository.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isFakeGps = false; // Toggle to demonstrate fake GPS warning detection
  bool _isCheckedInSuccess = false;

  double _lat = 10.7769;
  double _lng = 106.7009;
  String _address = 'Khu công nghệ cao, Phường Tân Phú, TP.Thủ Đức, TP.HCM';
  String _timeString = '';
  bool _hasSelfie = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _refreshLocation() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _lat = 10.7769 + (DateTime.now().second % 10) * 0.0001;
        _lng = 106.7009 + (DateTime.now().second % 5) * 0.0001;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật tọa độ GPS mới nhất!')),
      );
    });
  }

  Future<void> _handleCheckIn() async {
    if (!_hasSelfie) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chụp ảnh selfie trước khi điểm danh!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final repo = AppRepository();
    final res = await repo.checkIn(
      lat: _lat,
      lng: _lng,
      address: _address,
      notes: _notesController.text.trim(),
      isFakeGps: _isFakeGps,
    );

    setState(() {
      _isLoading = false;
    });

    if (res.success) {
      final now = DateTime.now();
      setState(() {
        _isCheckedInSuccess = true;
        _timeString =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day}/${now.month}/${now.year}';
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 48),
          title: const Text('CẢNH BÁO GPS GIẢ LẬP'),
          content: Text(res.message ?? 'Phát hiện fake GPS.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ĐIỂM DANH HIỆN TRƯỜNG'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Screen if already checked in
            if (_isCheckedInSuccess) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.statusCompletedBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.statusCompletedFg, width: 1),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.statusCompletedFg, size: 56),
                    const SizedBox(height: 12),
                    const Text(
                      'ĐIỂM DANH THÀNH CÔNG!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusCompletedFg,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Thời gian: $_timeString',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusCompletedFg,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.statusCompletedFg),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: AppColors.statusCompletedFg),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _address,
                            style: const TextStyle(fontSize: 13, color: AppColors.statusCompletedFg),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isCheckedInSuccess = false;
                          _hasSelfie = false;
                          _notesController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusCompletedFg,
                      ),
                      child: const Text('Điểm danh lại'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Fake GPS Simulator Test Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bug_report, size: 18, color: AppColors.outline),
                        SizedBox(width: 6),
                        Text(
                          'Mô phỏng Fake GPS (Testing)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isFakeGps,
                      activeColor: AppColors.error,
                      onChanged: (val) {
                        setState(() {
                          _isFakeGps = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Fake GPS Alert Banner if enabled
              if (_isFakeGps) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning, color: AppColors.error),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'CẢNH BÁO: Hệ thống đang phát hiện tọa độ GPS giả lập (Mock Location App)!',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // GPS Location Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.my_location, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'VỊ TRÍ HIỆN TẠI (GPS)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _isLoading ? null : _refreshLocation,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Lấy lại vị trí'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _address,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tọa độ: $_lat, $_lng',
                      style: const TextStyle(fontSize: 12, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Selfie Camera Upload Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant, width: 0.8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ẢNH CHỤP SELFIE HIỆN TRƯỜNG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.outline,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_hasSelfie) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _hasSelfie = true;
                          });
                        },
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary,
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt, size: 48, color: AppColors.primary),
                              SizedBox(height: 8),
                              Text(
                                'Bấm để chụp ảnh Selfie',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '(Yêu cầu mở camera nhận diện khuôn mặt)',
                                style: TextStyle(fontSize: 11, color: AppColors.outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Stack(
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.face_retouching_natural, size: 64, color: AppColors.primary),
                                SizedBox(height: 6),
                                Text(
                                  'Đã chụp ảnh selfie thành công',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              style: IconButton.styleFrom(backgroundColor: Colors.black54),
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _hasSelfie = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes Input
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú điểm danh',
                  hintText: 'Nhập ghi chú tình hình hiện trường...',
                ),
              ),
              const SizedBox(height: 24),

              // Attendance Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCheckIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_isLoading ? 'ĐANG ĐIỂM DANH...' : 'ĐIỂM DANH NGAY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
