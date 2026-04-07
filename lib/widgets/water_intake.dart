import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/widgets/gradient_button.dart';
import 'package:calorai/widgets/input_field.dart';
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
  int waterCup = kWaterCup;
  bool isLoading = false;
  TextEditingController _waterController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIntake = widget.total;
  }

  void setWaterCup() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      waterCup = int.parse(preferences.getString("waterCup").toString());
    });
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
                // if (currentIntake >= widget.goal) {
                //   MyUtility.myToast("Goal Done");
                //   return;
                // }
                setState(() {
                  currentIntake += kWaterCup;
                });
                updateWaterIntake(widget.currentDate);
              },
              icon: Icon(Icons.add_circle_outline),
              iconSize: 40,
            ),
          ],
        ),
        // IconButton(
        //   onPressed: () {
        //     showModalBottomSheet(
        //         context: context,
        //         builder: (_) {
        //           return SafeArea(
        //               child: Column(children: [
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceAround,
        //               children: [
        //                 IconButton(
        //                   onPressed: () {
        //                     Navigator.pop(context);
        //                   },
        //                   icon: Icon(
        //                     size: 40,
        //                     Icons.cancel,
        //                     color: Colors.grey,
        //                   ),
        //                 ),
        //                 Text(
        //                   "Watter Settings",
        //                   style: TextStyle(
        //                     color: Colors.black,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                 ),
        //                 IconButton(
        //                   onPressed: () {
        //                     Navigator.pop(context);
        //                   },
        //                   icon: Icon(
        //                     size: 40,
        //                     Icons.water_drop,
        //                     color: primaryOrangeDark,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //             Container(
        //               margin: EdgeInsets.all(20),
        //               child: Column(
        //                 children: [
        //                   InputField(
        //                       controller: _waterController,
        //                       hintText: "Water Intake ML",
        //                       prefixIcon: Icons.water_drop),
        //                   SizedBox(height: 30),
        //                   GradientButton(
        //                     text: "ADD",
        //                     onPressed: () {},
        //                     gradient: const LinearGradient(
        //                       colors: [primaryOrangeDark, primaryOrangeLight],
        //                       begin: Alignment.bottomCenter,
        //                       end: Alignment.topCenter,
        //                     ),
        //                   )
        //                 ],
        //               ),
        //             ),
        //             Container(
        //               margin: EdgeInsets.all(10),
        //               padding: EdgeInsets.all(10),
        //               decoration: kContainerBox,
        //               alignment: Alignment.center,
        //               child: Column(
        //                 children: [
        //                   Text(
        //                     "How much water do you need to stay hydrated?",
        //                     style: TextStyle(
        //                         fontWeight: FontWeight.bold, fontSize: 16),
        //                   ),
        //                   SizedBox(height: 20),
        //                   Text(
        //                     "The National Academies of Sciences, Engineering, and Medicine note that women should consume about 2.7 liters of water per day, while men should consume about 3.7 liters per day. That's about 11.5 cups a day for women and 15.5 cups a day for men. This includes water from both foods and drinks.",
        //                     style: TextStyle(
        //                         fontWeight: FontWeight.normal, fontSize: 12),
        //                   ),
        //                 ],
        //               ),
        //             )
        //           ]));
        //         });
        //   },
        //   icon: Icon(Icons.settings),
        //   iconSize: 30,
        // ),
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
