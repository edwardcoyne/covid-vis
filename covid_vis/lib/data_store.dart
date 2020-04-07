import 'package:covid_vis/log.dart';
import 'package:csv/csv.dart';

import 'data.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

final kKeys = ["San Mateo, California, US", "San Francisco, California, US", "Santa Clara, California, US"];
final kStartDate = new DateTime.utc(2020, 3, 22);
final kUrlBase = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/";

class DataStore {
  DateTime lastProcessed = kStartDate;
  DateTime highestLocal;

  List<DataPoint> data = [];
  var timer;

  final updateCallback;

  DataStore(this.updateCallback);

  void StartProcessing() async {
    data = new List<DataPoint>();

    var date = kStartDate;
    while (DateTime.now().add(Duration(days: 1)).isAfter(date)) {
      File file = await GetFile(date);
      if (!file.existsSync()) break;
      data.add(ProcessFile(date, file));
      lastProcessed = date;
    }

    updateCallback(data);

    FetchNext();
  }

  void FetchNext() async {
    var nextDate = lastProcessed.add(Duration(days: 1));
    while (nextDate.isBefore(DateTime.now())) {
      var response = await fetchFile(nextDate);
      if (response.statusCode != 200) {
        log.error("Error fetching data: ${response.statusCode} : ${response.body} - ${response.request.url}");
        break;
      }

      var file = await GetFile(nextDate);
      if (!file.existsSync()) {
        file.create();
      }
      file.writeAsStringSync(response.body);

      data.add(ProcessFile(nextDate, file));
      updateCallback(data);

      lastProcessed = nextDate;
      nextDate = nextDate.add(Duration(days: 1));
    }
    timer = new Timer(Duration(hours: 1), FetchNext);
  }

  DataPoint ProcessFile(DateTime date, File file) {
    var lines = file.readAsStringSync().split('\n');
    int confirmed = 0;
    int deaths = 0;
    for (var line in lines) {
      var csv = CsvToListConverter().convert(line);
      if (csv.length < 1 || csv[0].length < 12) {
        print(line);
        continue;
      }
      var fields = csv[0];
      var key = fields[11];
      //print(key);
      if (kKeys.contains(key)) {
        print(line);
        confirmed += fields[7];
        deaths += fields[8];
      }
    }
    log.info("Processed data (${lines.length}) for $date");
    return DataPoint(date, confirmed, deaths);
  }

  String FileName(DateTime date) {
    return sprintf("%02d-%02d-%04d.csv", [date.month, date.day, date.year]);
  }

  Future<File> GetFile(DateTime date) async {
    final path = await getApplicationDocumentsDirectory();
    if (!path.existsSync()) {
      path.create();
    }
    return File('${path.path}/${FileName(date)}');
  }

  Future<http.Response> fetchFile(DateTime date) {
    return http.get(kUrlBase + FileName(date));
  }

}