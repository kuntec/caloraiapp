import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  static const _primary = Color(0xFFFF9800);

  static const _sources = [
    _SourceSection(
      title: 'Calorie & Energy Estimation',
      items: [
        _SourceItem(
          label: 'Resting Energy Expenditure (Mifflin–St Jeor Equation)',
          citation:
              'Mifflin MD, St Jeor ST, Hill LA, Scott BJ, Daugherty SA, Koh YO. '
              '"A new predictive equation for resting energy expenditure in healthy '
              'individuals." Am J Clin Nutr. 1990;51(2):241–247.',
          url: 'https://doi.org/10.1093/ajcn/51.2.241',
        ),
        _SourceItem(
          label: 'Total Daily Energy Expenditure & Activity Multipliers',
          citation:
              'FAO/WHO/UNU Expert Consultation. "Human energy requirements." '
              'FAO Food and Nutrition Technical Report Series 1. Rome: FAO, 2004.',
          url: 'https://www.fao.org/3/y5686e/y5686e.pdf',
        ),
      ],
    ),
    _SourceSection(
      title: 'Macronutrient Recommendations',
      items: [
        _SourceItem(
          label: 'Dietary Reference Intakes for Macronutrients',
          citation:
              'Institute of Medicine. "Dietary Reference Intakes for Energy, '
              'Carbohydrate, Fiber, Fat, Fatty Acids, Cholesterol, Protein, and '
              'Amino Acids." Washington, DC: National Academies Press, 2005.',
          url: 'https://doi.org/10.17226/10490',
        ),
        _SourceItem(
          label: 'Dietary Guidelines for Americans 2020–2025',
          citation:
              'U.S. Department of Agriculture and U.S. Department of Health and '
              'Human Services. "Dietary Guidelines for Americans, 2020–2025." '
              '9th Edition. December 2020.',
          url: 'https://www.dietaryguidelines.gov',
        ),
      ],
    ),
    _SourceSection(
      title: 'Hydration & Water Intake',
      items: [
        _SourceItem(
          label: 'Daily Water Intake Recommendations',
          citation:
              'National Academies of Sciences, Engineering, and Medicine. '
              '"Dietary Reference Intakes for Water, Potassium, Sodium, Chloride, '
              'and Sulfate." Washington, DC: National Academies Press, 2005.',
          url: 'https://doi.org/10.17226/10925',
        ),
      ],
    ),
    _SourceSection(
      title: 'Physical Activity & Exercise',
      items: [
        _SourceItem(
          label: 'Compendium of Physical Activities',
          citation:
              'Ainsworth BE, Haskell WL, Herrmann SD, et al. "2011 Compendium of '
              'Physical Activities: A second update of codes and MET values." '
              'Med Sci Sports Exerc. 2011;43(8):1575–1581.',
          url: 'https://doi.org/10.1249/MSS.0b013e31821ece12',
        ),
        _SourceItem(
          label: 'Physical Activity Guidelines for Americans',
          citation:
              'U.S. Department of Health and Human Services. "Physical Activity '
              'Guidelines for Americans, 2nd edition." Washington, DC: HHS, 2018.',
          url: 'https://health.gov/paguidelines/second-edition/',
        ),
      ],
    ),
    _SourceSection(
      title: 'Body Weight & BMI',
      items: [
        _SourceItem(
          label: 'BMI Classification',
          citation:
              'World Health Organization. "Global Database on Body Mass Index." '
              'Geneva: WHO.',
          url:
              'https://www.who.int/tools/body-mass-index',
        ),
      ],
    ),
    _SourceSection(
      title: 'Goal-Setting & Weight Management',
      items: [
        _SourceItem(
          label: 'Calorie Deficit for Weight Loss',
          citation:
              'Hall KD, Heymsfield SB, Kemnitz JW, et al. "Energy balance and its '
              'components: Implications for body weight regulation." '
              'Am J Clin Nutr. 2012;95(4):989–994.',
          url: 'https://doi.org/10.3945/ajcn.112.036350',
        ),
      ],
    ),
  ];

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        foregroundColor: _primary,
        elevation: 0,
        title: const Text(
          'Scientific Sources',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: _primary),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'CalorAI bases its health calculations on peer-reviewed research '
              'and guidelines from recognised health authorities. Tap any source '
              'to read the original publication.',
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
            ),
          ),
          ..._sources.map((section) => _buildSection(section)),
          const SizedBox(height: 24),
          const Text(
            'CalorAI is designed for general wellness and is not a substitute '
            'for professional medical advice, diagnosis, or treatment. Always '
            'consult a qualified healthcare provider before making significant '
            'changes to your diet or exercise routine.',
            style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(_SourceSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
          child: Text(
            section.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...section.items.map((item) => _buildItem(item)),
      ],
    );
  }

  Widget _buildItem(_SourceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () => _launch(item.url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.article_outlined, size: 16, color: _primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.citation,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.url,
                style: const TextStyle(
                  fontSize: 11,
                  color: _primary,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceSection {
  final String title;
  final List<_SourceItem> items;
  const _SourceSection({required this.title, required this.items});
}

class _SourceItem {
  final String label;
  final String citation;
  final String url;
  const _SourceItem({
    required this.label,
    required this.citation,
    required this.url,
  });
}
