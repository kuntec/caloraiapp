import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/models/FoodData.dart';
import 'package:calorai/models/SearchFoodData.dart';
import 'package:calorai/screens/add_custom_meal.dart';
import 'package:calorai/screens/food/create_food.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogFood extends StatefulWidget {
  const LogFood({super.key});

  @override
  State<LogFood> createState() => _LogFoodState();
}

class _LogFoodState extends State<LogFood> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool isLoading = false;
  dynamic myFoods;
  Future<List<Food>>? _future;
  String _query = '';
  bool _isRefreshing = false;
  int _searchToken = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = searchFood(query: _query);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _load({String? query}) {
    final q = query ?? _query;
    setState(() {
      _query = q;
      _future = searchFood(query: _query);
    });
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    try {
      // re-fetch with current query
      _load(query: _query);
      // Wait for future to complete so RefreshIndicator looks correct
      await _future;
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _onSearchChanged(String text) async {
    _searchToken++;
    final token = _searchToken;

    // debounce: wait 350ms after typing stops
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    if (token != _searchToken) return; // newer keystroke happened

    _load(query: text);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _load(query: '');
    _focus.unfocus();
  }

  Future<List<Food>> searchFood({required String query}) async {
    List<Food> foods = [];

    ApiCall apiCall = ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");
    SearchFoodData searchFoodData = await apiCall.searchFood(token!);
    print(searchFoodData.total);
    foods.addAll(searchFoodData.foods!);
    setState(() {
      myFoods = foods;
    });
    return foods;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Food Log",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CircleIconButton(
              onTap: () {
                MyUtility.changePage(context, CreateFood());
              },
              icon: Icons.add,
              iconColor: Colors.white,
              background: const Color(0xFF36B24A),
              borderColor: Colors.transparent,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          children: [
            // 🔍 SEARCH BAR
            _SearchBar(
              controller: _searchCtrl,
              focusNode: _focus,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),

            // 📋 LIST AREA
            Expanded(
              child: isLoading || myFoods == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => searchFood(query: ""),
                      color: kMainThemeColor,
                      child: myFoods.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 200),
                                Center(child: Text("No Food found")),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: myFoods.length,
                              itemBuilder: (context, index) =>
                                  foodItem(myFoods[index]),
                            ),
                    ),
            ),
          ],
        ),
      ),
      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      //     child: Column(
      //       children: [
      //         _SearchBar(
      //           controller: _searchCtrl,
      //           focusNode: _focus,
      //           onChanged: _onSearchChanged,
      //           onClear: _clearSearch,
      //         ),
      //         // searchBar(),
      //
      //         // Expanded(
      //         //     child: FutureBuilder<List<Food>>(
      //         //         future: _future,
      //         //         builder: (context, snapshot) {
      //         //           // Loading (first load)
      //         //           if (snapshot.connectionState ==
      //         //                   ConnectionState.waiting &&
      //         //               !_isRefreshing) {
      //         //             return const Center(
      //         //                 child: CircularProgressIndicator());
      //         //           }
      //         //           // Error
      //         //           if (snapshot.hasError) {
      //         //             return Container(
      //         //               child: Text("Error"),
      //         //             );
      //         //           }
      //         //           final foods = snapshot.data ?? const <Food>[];
      //         //           if (foods.isEmpty) {
      //         //             return RefreshIndicator(
      //         //               onRefresh: _refresh,
      //         //               child: ListView(
      //         //                 physics: const AlwaysScrollableScrollPhysics(),
      //         //                 padding: const EdgeInsets.all(16),
      //         //                 children: [
      //         //                   const SizedBox(height: 80),
      //         //                   Icon(Icons.search_off,
      //         //                       size: 56, color: Colors.grey.shade500),
      //         //                   const SizedBox(height: 12),
      //         //                   Text(
      //         //                     _query.trim().isEmpty
      //         //                         ? 'No foods found.'
      //         //                         : 'No results for "${_query.trim()}".',
      //         //                     textAlign: TextAlign.center,
      //         //                     style: TextStyle(
      //         //                       color: Colors.grey.shade700,
      //         //                       fontSize: 16,
      //         //                     ),
      //         //                   ),
      //         //                   const SizedBox(height: 12),
      //         //                   OutlinedButton(
      //         //                     onPressed: _query.trim().isEmpty
      //         //                         ? _refresh
      //         //                         : _clearSearch,
      //         //                     child: Text(_query.trim().isEmpty
      //         //                         ? 'Refresh'
      //         //                         : 'Clear search'),
      //         //                   )
      //         //                 ],
      //         //               ),
      //         //             );
      //         //           }
      //         //           return RefreshIndicator(
      //         //               child: ListView.separated(
      //         //                 physics: const AlwaysScrollableScrollPhysics(),
      //         //                 padding:
      //         //                     const EdgeInsets.fromLTRB(16, 12, 16, 16),
      //         //                 itemCount: foods.length,
      //         //                 separatorBuilder: (_, __) =>
      //         //                     const SizedBox(height: 10),
      //         //                 itemBuilder: (context, index) {
      //         //                   return foodItem(foods[index]);
      //         //                 },
      //         //               ),
      //         //               onRefresh: _refresh);
      //         //         })),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget searchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Here",
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget foodItem(Food food) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(14),
            //   child: AspectRatio(
            //     aspectRatio: 16 / 9,
            //     child: Image.network(
            //       "https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg?auto=compress&cs=tinysrgb&w=1200",
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${food.name}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                _CircleIconButton(
                    onTap: () {
                      addFoodLog(food);
                    },
                    icon: Icons.add,
                    iconColor: Colors.white,
                    background: primaryOrangeLight,
                    borderColor: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MacroTile(
                    label: "Calories",
                    value: "${food.nutrients!.calories}",
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MacroTile(
                    label: "Carbs",
                    value: "${food.nutrients!.carbsG}g",
                    icon: Icons.set_meal_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MacroTile(
                    label: "Proteins",
                    value: "${food.nutrients!.proteinG}g",
                    icon: Icons.restaurant_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MacroTile(
                    label: "Fats",
                    value: "${food.nutrients!.fatsG}g",
                    icon: Icons.opacity_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void addFoodLog(Food food) async {
    setState(() {
      isLoading = true;
    });
    ApiCall call = new ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token") ?? "";
    DateTime now = DateTime.now();

// Format date → "2026-02-18"
    String date = DateFormat('yyyy-MM-dd').format(now);
// Format time → "02:00 PM"
    String time = DateFormat('hh:mm a').format(now);
    String mealType = "lunch";
    String foodId = food.id;
    int servings = 1;
    String source = "manual";
    call.addFoodLog(date, time, mealType, foodId, servings, source, token);

    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Food added successfully"),
    ));
  }
}

Widget _MacroTile({dynamic label, dynamic value, dynamic icon}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 28, color: Color(0xFFB7E3BD)),
      ],
    ),
  );
}

/// ---- Widgets ----
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search Here",
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        onPressed: onClear,
                        icon: const Icon(Icons.close),
                      ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    //   child: TextField(
    //     controller: controller,
    //     focusNode: focusNode,
    //     onChanged: onChanged,
    //     textInputAction: TextInputAction.search,
    //     decoration: InputDecoration(
    //       hintText: 'Search foods (e.g., egg, chicken, rice)',
    //       prefixIcon: const Icon(Icons.search),
    //       suffixIcon: controller.text.isEmpty
    //           ? null
    //           : IconButton(
    //               tooltip: 'Clear',
    //               onPressed: onClear,
    //               icon: const Icon(Icons.close),
    //             ),
    //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    //     ),
    //   ),
    // );
  }
}

class _CircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final Color borderColor;

  const _CircleIconButton({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
