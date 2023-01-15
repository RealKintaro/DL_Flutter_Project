// ignore_for_file: use_key_in_widget_constructors

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleBarChart extends StatefulWidget {
  final dynamic doc;
  final bool animate;

  const SimpleBarChart(this.doc, this.animate);

  @override
  // ignore: no_logic_in_create_state
  SimpleBarChartState createState() => SimpleBarChartState(doc, animate);
}

class SimpleBarChartState extends State<SimpleBarChart> {
  dynamic doc;
  bool animate;
  List<Data> data = [];

  late List<charts.Series<dynamic, String>> series;

  SimpleBarChartState(this.doc, this.animate);

  @override
  void initState() {
    super.initState();
    // pars doc to map
    doc = doc.data();
    for (var entry in doc!.entries) {
      if (entry.key != 'Time') {
        data.add(Data(entry.key, entry.value ~/ 1000));
      }
    }

    series = [
      charts.Series<Data, String>(
          id: 'Sessions',
          data: data,
          domainFn: (Data key, _) => key.key,
          measureFn: (Data key, _) => key.value),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      series,
      animate: widget.animate,
    );
  }
}

class Data {
  final String key;
  final int value;
  Data(this.key, this.value);
}
