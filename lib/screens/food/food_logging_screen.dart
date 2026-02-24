import 'package:flutter/material.dart';

class FoodLogingsScreen extends StatelessWidget {
  const FoodLogingsScreen({super.key});

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
          "Food Logings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: _CircleIconButton(
            onTap: () => () {
              Navigator.pop(context);
            },
            icon: Icons.arrow_back_ios_new_rounded,
            iconColor: Colors.black,
            background: Colors.white,
            borderColor: const Color(0xFFE5E7EB),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CircleIconButton(
              onTap: () {},
              icon: Icons.add,
              iconColor: Colors.white,
              background: const Color(0xFF36B24A),
              borderColor: Colors.transparent,
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: const [
          _SearchBar(),
          SizedBox(height: 16),
          _SegmentedTabs(),
          SizedBox(height: 16),
          _FoodCard(),
          SizedBox(height: 16),
          _FoodCard(),
          SizedBox(height: 16),
          _FoodCard(),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

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
}

class _SegmentedTabs extends StatefulWidget {
  const _SegmentedTabs();

  @override
  State<_SegmentedTabs> createState() => _SegmentedTabsState();
}

class _SegmentedTabsState extends State<_SegmentedTabs> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF49C85A), Color(0xFFBFE9C3)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              selected: index == 0,
              text: "Recent Foods",
              icon: Icons.history_rounded,
              onTap: () => setState(() => index = 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabPill(
              selected: index == 1,
              text: "Favorites",
              icon: Icons.favorite_border_rounded,
              onTap: () => setState(() => index = 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final bool selected;
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _TabPill({
    required this.selected,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3AAE4E) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  "https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg?auto=compress&cs=tinysrgb&w=1200",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Fruit Salad of Bananas & Apple",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MacroTile(
                    label: "Calories",
                    value: "234",
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MacroTile(
                    label: "Carbs",
                    value: "45g",
                    icon: Icons.set_meal_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MacroTile(
                    label: "Proteins",
                    value: "124g",
                    icon: Icons.restaurant_rounded,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MacroTile(
                    label: "Fats",
                    value: "45g",
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
}

class _MacroTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MacroTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
