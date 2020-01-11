import 'package:dotp/dotp.dart';
import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'package:intl/intl.dart';

void main() async => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  String time = "Press the below button";
  TextEditingController userID = new TextEditingController();

  _fetchData() async {
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
        body: {"userId": userID.text, "selectedDate": "$formatted"},
        bodyEncoding: RequestBodyEncoding.FormURLEncoded);

    // Parsing time-entries
    dynamic json = timesheet.json();
    var totalHours = DateTime.parse("2019-12-06 00:00:00");
    var requiredHours = DateTime.parse("2019-12-06 08:00:00");
    var currentTime = DateTime.parse(DateTime.now().toString());

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
    // Checking required work hours
    setState(() {
      if (totalHours.hour >= 8) {
        time =
            ("You have worked more than 8 hours => ${totalHours.toString().split(' ')[1]}");
      } else {
        time = ("You need to clock  ${requiredHours.difference(totalHours)}, ends on ${(currentTime.add(requiredHours.difference(totalHours))).toString().split(' ')[1]} ");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                  TextField(
                    controller: userID,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Please enter your UserID',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  RaisedButton(
                    child: Text("Time-entry"),
                    onPressed: _fetchData,
                    color: Colors.red,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    splashColor: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
