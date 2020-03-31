class Notification{
  final String title;
  final String body;
  Notification(this.title,this.body);
}

class Res{
  final String uid;
  final int statusCode;
  final dynamic value;
  Res(
    {this.uid,this.statusCode,this.value}
  );
}
class UpdatePostsFormat{
  final String uid;
  final dynamic value;
  UpdatePostsFormat({
    this.uid,this.value
  });
}
class SortDateTime{
  final String uid;
  final int date;
 dynamic value;
  final String club;
  final String dateasString;
  SortDateTime(this.uid,this.date,this.value,this.club,this.dateasString);
}