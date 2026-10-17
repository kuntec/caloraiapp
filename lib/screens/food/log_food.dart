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

class _LogFoodState extends State<LogFood> with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  late TabController _tabController;

  // ── All Foods pagination state ──
  List<Food> _allFoods = [];
  int _allPage = 1;
  bool _allHasMore = true;
  bool _allLoading = false;
  bool _allLoadingMore = false;

  // ── My Foods pagination state ──
  List<Food> _myFoods = [];
  int _myPage = 1;
  bool _myHasMore = true;
  bool _myLoading = false;
  bool _myLoadingMore = false;

  bool _addingFood = false;
  String _query = '';
  int _searchToken = 0;

  bool get _isMyFoodsTab => _tabController.index == 1;
  bool get isLoading => _isMyFoodsTab ? _myLoading : _allLoading;
  bool get _isLoadingMore => _isMyFoodsTab ? _myLoadingMore : _allLoadingMore;
  bool get _hasMore => _isMyFoodsTab ? _myHasMore : _allHasMore;
  List<Food> get _currentList => _isMyFoodsTab ? _myFoods : _allFoods;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _focus.unfocus();
      if (!_tabController.indexIsChanging) _resetAndLoad(query: _query);
    });
    _scrollCtrl.addListener(_onScroll);
    _resetAndLoad(query: '');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focus.dispose();
    _tabController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// Reset page to 1 and reload (used on new search or tab switch)
  void _resetAndLoad({String? query}) {
    final q = query ?? _query;
    if (_isMyFoodsTab) {
      setState(() {
        _myFoods = [];
        _myPage = 1;
        _myHasMore = true;
        _query = q;
      });
      _fetchMyFoods(q, page: 1, reset: true);
    } else {
      setState(() {
        _allFoods = [];
        _allPage = 1;
        _allHasMore = true;
        _query = q;
      });
      _fetchAllFoods(q, page: 1, reset: true);
    }
  }

  /// Load next page (triggered by scroll)
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    if (_isMyFoodsTab) {
      await _fetchMyFoods(_query, page: _myPage + 1, reset: false);
    } else {
      await _fetchAllFoods(_query, page: _allPage + 1, reset: false);
    }
  }

  void _onSearchChanged(String text) async {
    _searchToken++;
    final token = _searchToken;
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted || token != _searchToken) return;
    _resetAndLoad(query: text);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _resetAndLoad(query: '');
    _focus.unfocus();
  }

  Future<void> _fetchAllFoods(String query,
      {required int page, required bool reset}) async {
    if (reset) {
      setState(() => _allLoading = true);
    } else {
      if (_allLoadingMore || !_allHasMore) return;
      setState(() => _allLoadingMore = true);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? '';
      final data = await ApiCall().searchFood(token, query, page: page);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _allFoods = data.foods ?? [];
        } else {
          _allFoods = [..._allFoods, ...(data.foods ?? [])];
        }
        _allPage = page;
        _allHasMore = data.hasMore;
      });
    } catch (_) {
    } finally {
      if (mounted)
        setState(() {
          _allLoading = false;
          _allLoadingMore = false;
        });
    }
  }

  Future<void> _fetchMyFoods(String query,
      {required int page, required bool reset}) async {
    if (reset) {
      setState(() => _myLoading = true);
    } else {
      if (_myLoadingMore || !_myHasMore) return;
      setState(() => _myLoadingMore = true);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? '';
      final data = await ApiCall().searchMyFood(token, query, page: page);
      if (!mounted) return;
      setState(() {
        if (reset) {
          _myFoods = data.foods ?? [];
        } else {
          _myFoods = [..._myFoods, ...(data.foods ?? [])];
        }
        _myPage = page;
        _myHasMore = data.hasMore;
      });
    } catch (_) {
    } finally {
      if (mounted)
        setState(() {
          _myLoading = false;
          _myLoadingMore = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
              fontSize: 16,
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
          bottom: TabBar(
            controller: _tabController,
            labelColor: primaryOrangeDark,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryOrangeDark,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: 'All Foods'),
              Tab(text: 'My Foods'),
            ],
          ),
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
              const SizedBox(height: 8),

              // 📋 LIST AREA
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: primaryOrangeLight))
                    : RefreshIndicator(
                        onRefresh: () async => _resetAndLoad(query: _query),
                        color: kMainThemeColor,
                        child: _currentList.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 200),
                                  Center(
                                    child: Text(
                                      _isMyFoodsTab
                                          ? 'No personal foods yet.\nTap + to create your first food.'
                                          : 'No foods found.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                controller: _scrollCtrl,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _currentList.length +
                                    (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _currentList.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: primaryOrangeLight,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }
                                  return foodItem(_currentList[index]);
                                },
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
      ), // Scaffold
    ); // GestureDetector
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

  // ── ORIGINAL foodItem (tall ~160px, 2×2 macro grid) — kept for reference ────
  // Widget foodItem(Food food) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 10, top: 10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(18),
  //       boxShadow: const [
  //         BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 10)),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(14),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text("${food.name}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
  //               _CircleIconButton(onTap: () { addFoodLog(food); }, icon: Icons.add, iconColor: Colors.white, background: primaryOrangeLight, borderColor: Colors.white),
  //             ],
  //           ),
  //           const SizedBox(height: 10),
  //           Row(children: [
  //             Expanded(child: _MacroTile(label: "Calories", value: "${food.nutrients!.calories}", icon: Icons.local_fire_department_outlined)),
  //             SizedBox(width: 12),
  //             Expanded(child: _MacroTile(label: "Carbs", value: "${food.nutrients!.carbsG} g", icon: Icons.set_meal_outlined)),
  //           ]),
  //           const SizedBox(height: 12),
  //           Row(children: [
  //             Expanded(child: _MacroTile(label: "Proteins", value: "${food.nutrients!.proteinG} g", icon: Icons.restaurant_rounded)),
  //             SizedBox(width: 12),
  //             Expanded(child: _MacroTile(label: "Fats", value: "${food.nutrients!.fatsG} g", icon: Icons.opacity_outlined)),
  //           ]),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ── COMPACT foodItem (~68px tall — shows 4-5 cards without scrolling) ────────
  Widget foodItem(Food food) {
    final cal = food.nutrients?.calories ?? 0;
    final prot = food.nutrients?.proteinG ?? 0;
    final carb = food.nutrients?.carbsG ?? 0;
    final fat = food.nutrients?.fatsG ?? 0;

    String _fmt(num v) =>
        v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: primaryOrangeLight, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Food icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryOrangeLight.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_rounded,
                  color: primaryOrangeLight, size: 18),
            ),
            const SizedBox(width: 10),

            // Name + macro pills
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    food.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MacroPill(
                          '🔥 ${_fmt(cal)} kcal', const Color(0xFFFF8B00)),
                      const SizedBox(width: 4),
                      _MacroPill('P ${_fmt(prot)}g', const Color(0xFF2196F3)),
                      const SizedBox(width: 4),
                      _MacroPill('C ${_fmt(carb)}g', const Color(0xFF4CAF50)),
                      const SizedBox(width: 4),
                      _MacroPill('F ${_fmt(fat)}g', const Color(0xFF9C27B0)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Add button
            GestureDetector(
              onTap: () => addFoodLog(food),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: primaryOrangeLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryOrangeLight.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _MacroPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void addFoodLog(Food food) async {
    setState(() {
      _addingFood = true;
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
      _addingFood = false;
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
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: primaryGreenDark),
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
      height: 60,
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
                    fontSize: 14),
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
        width: 30,
        height: 30,
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
