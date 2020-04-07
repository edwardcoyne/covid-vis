
import 'package:flutter/material.dart';
import 'dart:collection';

enum EntryType {
  INFO,
  DEBUG,
  ERROR,
}

class LogEntry {
  String message;
  EntryType type;
  LogEntry({this.message, this.type});
}

// Logging class that will both write to printf output and also to the log
// displayed in the app.
class Log {
  info(message) {
    print(message);
    log.add(LogEntry(message: message, type: EntryType.INFO));
    updated();
  }
  debug(message) {
    print(message);
    log.add(LogEntry(message: message, type: EntryType.DEBUG));
    updated();
  }
  error(message) {
    print(message);
    log.add(LogEntry(message: message, type: EntryType.ERROR));
    updated();
  }

  updated() {
    if (log.length > kHistory) {
      log.removeFirst();
    }
    if (listener != null) {
      listener();
    }
  }

  static const kHistory = 300;
  var log = new Queue<LogEntry>();
  var listener;
}

Log log = Log();

class LogView extends StatefulWidget {
  @override
  LogViewState createState() => LogViewState();
}

class LogViewState extends State<LogView> {
  static const textStyle = TextStyle(color: Colors.white);
  ScrollController scroll = ScrollController();

  @override
  void dispose() {
    log.listener = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.listener = () {setState((){});};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scroll.animateTo(scroll.position.maxScrollExtent,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOut);
    });
    return Container(
      child: ListView(
        children: createEntries(),
        controller: scroll,
      ),
      width: 500.0,
      color: Colors.blueGrey.withOpacity(0.96),
    );
  }

  List<Widget> createEntries() {
    var out = List<Widget>();
    for (var entry in log.log) {
      out.add(Container(
        child: Text(entry.message, textAlign: TextAlign.left, style: textStyle,),
        color: backgroundColor(entry.type),
        width: 500.0,
        padding: const EdgeInsets.all(8.0),
      ));
    }
    return out;
  }

  Color backgroundColor(EntryType type) {
    if (type == EntryType.ERROR){
      return Colors.red;
    } else { // Info and debug are the same color here.
      return Colors.black12;
    }
  }
}