class ReportRequest {
  final String reporter;
  final String reporterModel;
  final String content;
  final String type;
  final String reportedId;
  final String? postId;

  ReportRequest({
    required this.reporter,
    required this.reporterModel,
    required this.content,
    required this.type,
    required this.reportedId,
    this.postId,
  });

  // Chuyển sang Map để gửi lên Server qua Body
  Map<String, dynamic> toJson() {
    return {
      'reporter': reporter,
      'reporterModel': reporterModel,
      'content': content,
      'type': type,
      'reportedId': reportedId,
      'postId': postId,
    };
  }
}
