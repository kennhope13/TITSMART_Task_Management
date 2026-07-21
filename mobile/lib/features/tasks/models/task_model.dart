class TaskHistoryItem {
  final String title;
  final String time;
  final String description;
  final bool isDone;

  TaskHistoryItem({
    required this.title,
    required this.time,
    required this.description,
    this.isDone = true,
  });

  factory TaskHistoryItem.fromJson(Map<String, dynamic> json) {
    return TaskHistoryItem(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      description: json['description'] ?? '',
      isDone: json['is_done'] ?? true,
    );
  }
}

class AttachedDocument {
  final String name;
  final String extension; // 'csv', 'docx', 'xlsx', 'pdf'
  final String size;
  final String? url;

  AttachedDocument({
    required this.name,
    required this.extension,
    required this.size,
    this.url,
  });

  factory AttachedDocument.fromJson(Map<String, dynamic> json) {
    return AttachedDocument(
      name: json['name'] ?? '',
      extension: json['extension'] ?? 'pdf',
      size: json['size'] ?? '1.0 MB',
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extension': extension,
      'size': size,
      'url': url,
    };
  }
}

class TaskModel {
  final int id;
  final String code;
  final String title;
  final String description;
  final String location;
  final String? coordinates;
  final String deadline;
  String status;
  final String managerName;
  String workerName;
  final String teamName;
  final String priority; // 'Cao', 'Trung bình', 'Thấp'
  final String? notes;
  String? rejectionReason;
  List<String> proofPhotos;
  List<AttachedDocument> attachedDocuments;
  final List<TaskHistoryItem> history;

  TaskModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.location,
    this.coordinates,
    required this.deadline,
    required this.status,
    required this.managerName,
    required this.workerName,
    required this.teamName,
    this.priority = 'Trung bình',
    this.notes,
    this.rejectionReason,
    this.proofPhotos = const [],
    this.attachedDocuments = const [],
    required this.history,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    var rawHistory = json['history'] as List? ?? [];
    List<TaskHistoryItem> historyList =
        rawHistory.map((item) => TaskHistoryItem.fromJson(item)).toList();

    var rawPhotos = json['proof_photos'] as List? ?? [];
    List<String> photoList = rawPhotos.map((e) => e.toString()).toList();

    var rawDocs = json['attached_documents'] as List? ?? [];
    List<AttachedDocument> docList =
        rawDocs.map((e) => AttachedDocument.fromJson(Map<String, dynamic>.from(e))).toList();

    return TaskModel(
      id: json['id'] ?? 1,
      code: json['code'] ?? '#TS-100',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      coordinates: json['coordinates'],
      deadline: json['deadline'] ?? '',
      status: json['status'] ?? 'assigned_worker',
      managerName: json['manager_name'] ?? 'Nguyễn Văn A',
      workerName: json['worker_name'] ?? 'Nguyễn Văn An',
      teamName: json['team_name'] ?? 'Đội kỹ thuật số 01',
      priority: json['priority'] ?? 'Trung bình',
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
      proofPhotos: photoList,
      attachedDocuments: docList,
      history: historyList,
    );
  }
}
