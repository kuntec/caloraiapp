import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterIntakeWidget extends StatefulWidget {
  int goal;
  int total;
  String currentDate;
  WaterIntakeWidget(
      {required this.goal,
      required this.total,
      required this.currentDate,
      super.key});

  @override
  State<WaterIntakeWidget> createState() => _WaterIntakeWidgetState();
}

class _WaterIntakeWidgetState extends State<WaterIntakeWidget> {
  int currentIntake = 0;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIntake = widget.total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: kContainerBox,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: kContainerBox.copyWith(color: primaryOrangeDark),
            child: Icon(
              Icons.water_drop,
              color: Colors.white,
            )),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Water",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            isLoading
                ? CircularProgressIndicator(
                    color: primaryOrangeLight,
                  )
                : Text(
                    "${currentIntake} ml / ${widget.goal} ml",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (currentIntake == 0) {
                  return;
                }

                setState(() {
                  currentIntake -= kWaterCup;
                });
                updateWaterIntake(widget.currentDate);
              },
              icon: Icon(Icons.remove_circle_outline_outlined),
              iconSize: 40,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  currentIntake += kWaterCup;
                });
                updateWaterIntake(widget.currentDate);
              },
              icon: Icon(Icons.add_circle_outline),
              iconSize: 40,
            ),
          ],
        )
      ]),
    );
  }

  Future<void> updateWaterIntake(String date) async {
    setState(() {
      isLoading = true;
    });
    ApiCall apiCall = new ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token").toString();
    await apiCall.updateWaterIntake(currentIntake, token, date);
    setState(() {
      widget.total = currentIntake;
      isLoading = false;
    });
  }
}
