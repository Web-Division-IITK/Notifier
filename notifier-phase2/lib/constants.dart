/*RESTAPIs*/
/// auth contains, current account cc-id, email
/// auth : {id,uid}
/// [id] === [user to update cc-id]
/// deafult url
const String URL_INITIALS = "/"; //TODO
/// api for allcouncildata
const String ALL_COUNCIL_DATA_API = URL_INITIALS + 'data.json';
/// api for user creation
/// data = uid and email
const String CREATE_USERDATA_API = URL_INITIALS + "createAccount";
/// api for user creation
/// data = auth
const String FETCH_USERDATA_API = URL_INITIALS + "getSuser";
/// api for user creation
/// data = auth
const String FETCH_PEOPLE_DATA_API = URL_INITIALS + "getPeople";
/// api for setting admin field
/// data = auth, id, council, por is sub
const String MAKE_COORDINATOR_API = URL_INITIALS + "elevatePerson";
/// api to update preferences of user
/// auth, council === [map]
const String UPDATE_PREFERENCES_API = URL_INITIALS + "updatePrefs";
/// api to post creation 
/// data = auth, post uid
const String PUBLISH_POST_API = URL_INITIALS + "approvePosts";
/// api to approve request
/// data = auth, council, sub, title, tags, body, author, owner, url, priority, message, startTime, endTime
const String REQUEST_APPROVAL_POST_API = URL_INITIALS + "makePost";
/// api to update post 
/// data = council, sub, auth, id, title, tags, body, url, priority, message, startTime, endTime
const String UPDATE_REQUEST_APPROVAL_POST_API = URL_INITIALS + "editPost";
/// api to delete post
/// data = auth, owner, post uid, council, sub
const String DELETE_POST_API = URL_INITIALS + "deletePost";
/// api to publish featured post
const String PUBLISH_FEATURED_POST_API = URL_INITIALS + ""; //TODO
/// api to fetch all post
/// timeStamp: Number
const String FETCH_ALLPOST_API = URL_INITIALS + "getPostWithTimestamp";
/// api to fetch post with uid
/// post uid
const String FETCH_POST_WITH_UID_API = URL_INITIALS + "getPostWithID";
/// api to fetch post with permission and council
/// type = permission, council
const String FETCH_PENDINGAPPR_POST_WITH_COUNCIL_API = URL_INITIALS + "getPostWithTypeCouncil";
// /// api to fetch post with persmission and counci with sub field being an array sent from me
// const String FETCH_PENDINGAPPR_POST_WITH_COUNCIL_SUB_API = "";
/// api to get student search data
const String GET_STUDENT_SEARCH_DATA_API = URL_INITIALS + "getAllStudents";
/// api to update student search data 
/// auth, only field to update
const String UPDATE_STUDENT_SEARCH_DATA_API = URL_INITIALS + "updateStudent";
/// url for directory profile picture
const String PROFILE_PIC_URL = "";
/// url for default profile picture
const String PROFILE_PIC_URL_DEFAULT = "";


/* NOTIFICATIONS AND POSTS FIELDS */
/// representation name of notification type = "permission"
const String NOTF_TYPE_PERMISSION = "permission";
/// representation name of notification type = "delete"
const String NOTF_TYPE_DELETE = "delete";
/// representation name of type for notification
const String TYPE = "type";
/// representation name of notfID for notification
const String NOTFS_ID = "notfID";
/// representation name for id field in post
const String ID = "id";
/// representation name of title for notification
const String TITLE = "title";
/// representation name of message for notification
const String MESSAGE = "message";
/// representation name of priority for notification
const String PRIORITY = "priority";
/// representation name to fetch from firebase
const String FETCH_FROM_FF = "fetchFF";
/// representation name of timeStamp field
const String TIMESTAMP = "timeStamp";
/// representation name of startTime field
const String STARTTIME = "startTime";
/// representation name of endTime field
const String ENDTIME = "endTime";
/// representation name for council field in post
const String POST_COUNCIL = "council";
/// representation name for sub field of post. [NOTE] This is an array
const String SUB = "sub";
/// representation name for owner field in post
const String OWNER = "owner";
/// representation name for author field in post
const String AUTHOR = "author";


/* SUPER USER FIELDS*/
/// representation name for preferences field in super user
const String USER_PREFS = "councils";


/* SQL DATABASE AND THEIR TABLE NAMES*/
/// Database name for permission posts
const String PERM_DATABASE = "permission";
/// Table name for permission posts
const String PERM_TABLENAME = "perm";


/* FONT FAMILY NAMES */
/// primary font family RALEWAY
const String PRIMARY_FONTFAMILY = "Raleway";
/// secondary font family RALEWAY
const String SECONDARY_FONTFAMILY = "Nunito";


/// function to determine no. of days in a amonth. Can be used for last date of month.
/// Here month and year are [int]
int noOfDaysInMonths (int month,int year){
  int leapYear() => 29;
  int notLeapYear() => 28;
  int divisibleBy400(year){
    if(year%400 == 0)
      return leapYear();
    else return notLeapYear();
  }
  int divisibleBy100(year){
    if(year%100 == 0)
      return divisibleBy400(year);
    else return leapYear();
  }
  if (month == 2) {
    if(year%4 == 0)
      return divisibleBy100(year);
    return notLeapYear();
  }
  else if(month < 8 ){
    if(month % 2 != 0)
      return 31;
    return 30;
  }
  else {
    if(month % 2 == 0) 
      return 31;
    return 30;
  }
}
