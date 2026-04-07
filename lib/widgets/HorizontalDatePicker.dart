import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Horizontaldatepicker extends StatefulWidget {
  final DateTime currentDate;
  late final Function(DateTime)? onDateSelected;

  Horizontaldatepicker(
      {super.key, this.onDateSelected, required this.currentDate});

  @override
  State<Horizontaldatepicker> createState() => _HorizontaldatepickerState();
}

class _HorizontaldatepickerState extends State<Horizontaldatepicker> {
  //DateTime selectedDate = DateTime.now();
  late DateTime selectedDate = widget.currentDate;
  List<DateTime> getDates() {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day); // remove time
    return List.generate(15, (i) => base.subtract(Duration(days: 14 - i)));

    // return List.generate(14, (index) {
    //   return DateTime.now().add(Duration(days: index));
    // });
  }

  final _controller = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dates = getDates();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateUtils.isSameDay(date, selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() => selectedDate = date);
              widget.onDateSelected!(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                // gradient: isSelected
                //     ? const LinearGradient(
                //         colors: [
                //           Color(0xFFFF8A00), // light orange
                //           Color(0xFFFF5C00), // main orange
                //         ],
                //         begin: Alignment.topLeft,
                //         end: Alignment.bottomRight,
                //       )
                //     : null,
                color: isSelected ? primaryGreenDark : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
