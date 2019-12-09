import 'package:dotp/dotp.dart';
import 'package:requests/requests.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import "dart:io";

void main() async {
  
  // Login
  var loginURL = 'https://hrvine.sysvine.com/index.php/index/loginpopupsave/?username=SYS1310&password=san@2018';
  await Requests.get(loginURL);

  // Handling 2-factor authentication
  TOTP totp = TOTP("6EMLBKVQMDBJDAX3");
  var otpURL = 'https://hrvine.sysvine.com/index.php/index/?verfication_code=${totp.now()}&user_id=lzpZSd';
  await Requests.get(otpURL);

  // Formatting current date
  var now = new DateTime.now();
  DateFormat formatter = new DateFormat('dd-MMM-yyyy');
  String formatted = formatter.format(now);

  // Fetching time-entry records
  var timesheetURL = 'https://hrvine.sysvine.com/index.php/timemanagement/attendance/getemployeeattendance/format/json/';
  var timesheet = await Requests.post(timesheetURL, body:{"userId":199,"selectedDate": "$formatted"},bodyEncoding: RequestBodyEncoding.FormURLEncoded);

  // Parsing time-entries
  dynamic json = timesheet.json();
  var totalHours = DateTime.parse("2019-12-06 00:00:00");
  var requriedHours = DateTime.parse('2019-12-06 08:00:00');

  for (var time in json) {
      if (time['punch_in_user_time'] != null && time['punch_out_user_time'] != null) {
        var inTime = DateTime.parse(time['punch_in_user_time']);
        var outTime = DateTime.parse(time['punch_out_user_time']);
        print(inTime);
        print(outTime);
        totalHours = (totalHours.add(outTime.difference(inTime)));
      }
  }

  //print(totalHours < requriedHours);

  print(totalHours.toString().split(' ')[1]);
}