import 'package:dotp/dotp.dart';
import 'package:requests/requests.dart';
import 'package:intl/intl.dart';

void main() async {
  // Login
  var loginURL =
      'https://hrvine.sysvine.com/index.php/index/loginpopupsave/?username=SYS1310&password=san@2018';
  await Requests.get(loginURL);

  // Handling 2-factor authentication
  TOTP totp = TOTP("6EMLBKVQMDBJDAX3");
  var otpURL =
      'https://hrvine.sysvine.com/index.php/index/?verfication_code=${totp.now()}&user_id=lzpZSd';
  await Requests.get(otpURL);

  // Formatting current date
  var now = new DateTime.now();
  DateFormat formatter = new DateFormat('dd-MMM-yyyy');
  String formatted = formatter.format(now);

  // Fetching time-entry records
  var timesheetURL =
      'https://hrvine.sysvine.com/index.php/timemanagement/attendance/getemployeeattendance/format/json/';
  var timesheet = await Requests.post(timesheetURL,
      body: {"userId": 199, "selectedDate": "$formatted"},
      bodyEncoding: RequestBodyEncoding.FormURLEncoded);

  // Parsing time-entries
  dynamic json = timesheet.json();
  var totalHours = DateTime.parse("2019-12-06 00:00:00");
  var requiredHours = DateTime.parse("2019-12-06 08:00:00");

  // Looping every punch in/out and calculating total worked hours
  for (var time in json) {
    var outTime, inTime;
    inTime = DateTime.parse(time['punch_in_user_time']);
    if (time['punch_out_user_time'] != null) {
      outTime = DateTime.parse(time['punch_out_user_time']);
    } else {
      outTime = DateTime.parse(DateTime.now().toString());
    }
    totalHours = (totalHours.add(outTime.difference(inTime)));
  }

  print(totalHours);
  print(totalHours.hour);

  // Checking required work hours
  if (totalHours.hour >= 8) {
    print("You have worked more than 8 hours => ${totalHours.toString().split(' ')[1]}");
  } else {
    var shortageHours = requiredHours.difference(totalHours);
    print("You need to clock  $shortageHours");
  }
}
