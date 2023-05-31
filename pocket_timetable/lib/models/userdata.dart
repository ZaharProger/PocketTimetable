class Userdata {
  String? userName;
  int? universityId;
  int? groupId;

  Userdata.all(this.userName, this.universityId, this.groupId);
  Userdata.withNameAndUniversity(this.userName, this.universityId);
}