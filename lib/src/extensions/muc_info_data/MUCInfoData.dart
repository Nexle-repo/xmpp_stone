class MUCInfoData {
  final String? subject;
  final String? coverUrl;
  final String? membersAddedEncoded;
  final String? membersRemovedEncoded;
  final bool? isMuted;
  final bool? isMarkRead;
  final bool? isMarkUnRead;
  MUCInfoData({
    this.subject,
    this.coverUrl,
    this.membersRemovedEncoded,
    this.membersAddedEncoded,
    this.isMuted,
    this.isMarkRead,
    this.isMarkUnRead,
  });
}
