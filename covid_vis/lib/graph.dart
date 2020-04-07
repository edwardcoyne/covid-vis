import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'data.dart';
import 'log.dart';

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final String title;

  SimpleLineChart(this.seriesList, {this.animate, this.title});

  factory SimpleLineChart.withData(List<DataPoint> data, var color, var color2, var title) {
    return new SimpleLineChart(
      FromData(data, color, color2),
      animate: false,
      title: title
    );
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = charts.TextStyleSpec(color: charts.Color.white);
    return new Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: new charts.TimeSeriesChart(
          seriesList,
          defaultRenderer:
          new charts.LineRendererConfig(includeArea: true),
          animate: animate,
          domainAxis: charts.DateTimeAxisSpec(
            renderSpec: new charts.SmallTickRendererSpec(
              // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
              fontSize: 18, // size in Pts.
              color: charts.MaterialPalette.gray.shadeDefault),


          )),
          primaryMeasureAxis: new charts.NumericAxisSpec(
              renderSpec: new charts.GridlineRendererSpec(

                // Tick and Label styling here.
                  labelStyle: new charts.TextStyleSpec(
                      fontSize: 18, // size in Pts.
                      color: charts.MaterialPalette.gray.shadeDefault),

                  // Change the line colors to match text color.
                  lineStyle: new charts.LineStyleSpec(
                      color: charts.MaterialPalette.gray.shadeDefault))),
          behaviors: [
            new charts.SeriesLegend(entryTextStyle: textStyle),
            new charts.ChartTitle(title,
                behaviorPosition: charts.BehaviorPosition.start,
                titleStyleSpec: textStyle,
                titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
          ],
          ),
        );
  }

  static List<charts.Series<DataPoint, DateTime>> FromData(
      List<DataPoint> data, var color, var color2) {
    var colorl = color.shadeDefault.lighter;
    charts.Color fill1 = new charts.Color(a:200, r:colorl.r, g:colorl.g, b:colorl.b);
    return [
      new charts.Series<DataPoint, DateTime>(
        id: 'Confirmed',
        colorFn: (_, __) => color.shadeDefault,
        areaColorFn: (_, __) => fill1,
        domainFn: (DataPoint datum, _) => datum.date,
        measureFn: (DataPoint datum, _) => datum.confirmed,
        data: data,
      ),
      new charts.Series<DataPoint, DateTime>(
        id: 'Deaths',
        colorFn: (_, __) => color2.shadeDefault,
        areaColorFn: (_, __) =>
        color2.shadeDefault.lighter,
        domainFn: (DataPoint datum, _) => datum.date,
        measureFn: (DataPoint datum, _) => datum.deaths,
        data: data,
      )
    ];
  }
}
