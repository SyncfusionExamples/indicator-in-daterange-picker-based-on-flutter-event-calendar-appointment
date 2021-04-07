import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void main() => runApp(CalendarPickerIntegration());

class VisibleDatesDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarPickerIntegration(),
    );
  }
}

class CalendarPickerIntegration extends StatefulWidget {
  @override
  CalendarPickerIntegrationState createState() =>
      CalendarPickerIntegrationState();
}

class CalendarPickerIntegrationState extends State<CalendarPickerIntegration> {
  final CalendarController _calendarController = CalendarController();
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();
  late _AppointmentDataSource _appointmentDataSource;
  late List<DateTime> _specialDates;

  @override
  void initState() {
    _appointmentDataSource = _getCalendarDataSource();
    _specialDates = <DateTime>[];
    for (int i = 0; i < _appointmentDataSource.appointments!.length; i++) {
      _specialDates.add(_appointmentDataSource.appointments![i].startTime);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  height: 100,
                  child: SfDateRangePicker(
                    selectionShape: DateRangePickerSelectionShape.rectangle,
                    selectionColor: Colors.deepPurpleAccent,
                    todayHighlightColor: Colors.deepPurpleAccent,
                    controller: _dateRangePickerController,
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      numberOfWeeksInView: 1,
                      specialDates: _specialDates,
                    ),
                    onSelectionChanged: selectionChanged,
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      specialDatesDecoration: _MonthCellDecoration(
                          borderColor: null,
                          backgroundColor: const Color(0xfff7f4ff),
                          showIndicator: true,
                          indicatorColor: Colors.orange),
                      cellDecoration: _MonthCellDecoration(
                          borderColor: null,
                          backgroundColor: const Color(0xfff7f4ff),
                          showIndicator: false,
                          indicatorColor: Colors.orange),
                      todayCellDecoration: _MonthCellDecoration(
                          borderColor: null,
                          backgroundColor: const Color(0xfff7f4ff),
                          showIndicator: false,
                          indicatorColor: Colors.orange),
                    ),
                  ),
                ),
                Expanded(
                  child: SfCalendar(
                    headerHeight: 0,
                    controller: _calendarController,
                    viewHeaderHeight: 0,
                    dataSource: _appointmentDataSource,
                    onViewChanged: viewChanged,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _calendarController.displayDate = args.value;
    });
  }

  _AppointmentDataSource _getCalendarDataSource() {
    final List<Appointment> appointments = <Appointment>[];
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: 2)),
      endTime: DateTime.now().add(Duration(days: 2, hours: 1)),
      subject: 'Planning',
      color: Colors.red,
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: 3)),
      endTime: DateTime.now().add(Duration(days: 3, hours: 1)),
      subject: 'Meeting',
      color: Colors.blue,
    ));
    return _AppointmentDataSource(appointments);
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _dateRangePickerController.selectedDate =
          viewChangedDetails.visibleDates[0];
      _dateRangePickerController.displayDate =
          viewChangedDetails.visibleDates[0];
    });
  }
}

class _MonthCellDecoration extends Decoration {
  const _MonthCellDecoration(
      {this.borderColor,
      required this.backgroundColor,
      required this.showIndicator,
      required this.indicatorColor});

  final Color? borderColor;
  final Color backgroundColor;
  final bool showIndicator;
  final Color indicatorColor;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MonthCellDecorationPainter(
        borderColor: borderColor,
        backgroundColor: backgroundColor,
        showIndicator: showIndicator,
        indicatorColor: indicatorColor);
  }
}

class _MonthCellDecorationPainter extends BoxPainter {
  _MonthCellDecorationPainter(
      {this.borderColor,
      required this.backgroundColor,
      required this.showIndicator,
      required this.indicatorColor});

  final Color? borderColor;
  final Color backgroundColor;
  final bool showIndicator;
  final Color indicatorColor;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect bounds = offset & configuration.size!;
    _drawDecoration(canvas, bounds);
  }

  void _drawDecoration(Canvas canvas, Rect bounds) {
    final Paint paint = Paint()..color = backgroundColor;
    canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, const Radius.circular(5)), paint);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    if (borderColor != null) {
      paint.color = borderColor!;
      canvas.drawRRect(
          RRect.fromRectAndRadius(bounds, const Radius.circular(5)), paint);
    }

    if (showIndicator) {
      paint.color = indicatorColor;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bounds.right - 6, bounds.top + 6), 2.5, paint);
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
