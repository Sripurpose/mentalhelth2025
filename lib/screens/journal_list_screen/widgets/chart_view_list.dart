import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import '../../../utils/core/image_constant.dart';
import '../../../widgets/functions/popup.dart';

class ChartViewList extends StatelessWidget {
  const ChartViewList({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      // ✅ Makes the whole section scrollable
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          const ChartCircularWidget(),
          const EmotionBreakdownList(), // ✅ scrolls together
        ],
      ),
    );
  }
}

/// --------------------
/// PIE CHART SECTION
/// --------------------
class ChartCircularWidget extends StatefulWidget {
  const ChartCircularWidget({Key? key}) : super(key: key);

  @override
  ChartCircularWidgetState createState() => ChartCircularWidgetState();
}

class ChartCircularWidgetState extends State<ChartCircularWidget> {
  late TooltipBehavior tooltip;
  List<ChartData> data = [];
  final Map<String, Color> colorMap = {
    'Optimal': ColorsContent.optimalStateColor,
    'Stressful': ColorsContent.stressFullStateColor,
    'Passive': ColorsContent.passiveStateColor,
    'Destructive': ColorsContent.destructiveStateColor,
  };

  var logger = Logger();

  @override
  void initState() {
    super.initState();
    tooltip = TooltipBehavior(enable: true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final provider = Provider.of<JournalListProvider>(context, listen: false);
    await provider.fetchJournalChartView(context: context);

    if (provider.journalChartViewModel != null) {
      setState(() {
        data = [
          ChartData(
              'Optimal',
              provider.journalChartViewModel?.chartpercentage?.optimalPercent ??
                  0),
          ChartData(
              'Stressful',
              provider.journalChartViewModel?.chartpercentage
                      ?.stressfullPercent ??
                  0),
          ChartData(
              'Passive',
              provider.journalChartViewModel?.chartpercentage?.passivePercent ??
                  0),
          ChartData(
              'Destructive',
              provider.journalChartViewModel?.chartpercentage
                      ?.destructivePercent ??
                  0),
        ].where((e) => e.y > 0).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<JournalListProvider>(
      builder: (context, provider, _) {
        return provider.journalChartViewModelLoading
            ? Center(
                child: CupertinoActivityIndicator(
                  color: ColorsContent.newThemeColor,
                  radius: 15,
                ),
              )
            : provider.journalChartStatusCode != 404
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 25),

                          // ✅ PIE CHART FIRST
                          SfCircularChart(
                            tooltipBehavior: tooltip,
                            series: <CircularSeries>[
                              PieSeries<ChartData, String>(
                                dataSource: data,
                                xValueMapper: (ChartData d, _) => d.x,
                                yValueMapper: (ChartData d, _) => d.y,
                                pointColorMapper: (ChartData d, _) =>
                                    colorMap[d.x] ?? Colors.grey,

                                // 👇 Add this line for custom label text with %
                                dataLabelMapper: (ChartData d, _) => "${d.y}%",

                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.inside,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ✅ LEGEND BELOW CHART
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            child: CustomLegend(
                              data: data,
                              colorMap: colorMap,
                            ),
                          ),

                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(ImageConstant.noDataNumu),
                      const Text(
                        "No data found",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Check back later",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
      },
    );
  }
}

class CustomLegend extends StatelessWidget {
  final List<ChartData> data;
  final Map<String, Color> colorMap;

  const CustomLegend({
    Key? key,
    required this.data,
    required this.colorMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensures even distribution: 2 columns layout
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // ✅ two columns
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            childAspectRatio: 5, // adjust spacing between text and dot
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final d = data[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorMap[d.x] ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  d.x,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final int y;
}

/// --------------------
/// BELOW PIE - DETAILS
/// --------------------
class EmotionBreakdownList extends StatefulWidget {
  const EmotionBreakdownList({super.key});

  @override
  State<EmotionBreakdownList> createState() => _EmotionBreakdownListState();
}

class _EmotionBreakdownListState extends State<EmotionBreakdownList> {
  String? expandedKey;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JournalListProvider>(context);
    final chart = provider.journalChartViewModel?.chart;
    final support = provider.journalChartViewModel?.supportemotions ?? [];

    final sections = [
      {
        'key': 'Optimal',
        'color': ColorsContent.optimalStateColor.withOpacity(0.3),
        'title': 'Optimal',
        'data': chart?.optimal,
        'percent': chart?.optimal?.percent ?? 0,
        'count': chart?.optimal?.count ?? 0,
      },
      {
        'key': 'Stressful',
        'color': ColorsContent.stressFullStateColor.withOpacity(0.3),
        'title': 'Stressful',
        'data': chart?.stressful,
        'percent': chart?.stressful?.percent ?? 0,
        'count': chart?.stressful?.count ?? 0,
      },
      {
        'key': 'Passive',
        'color': ColorsContent.passiveStateColor.withOpacity(0.3),
        'title': 'Passive',
        'data': chart?.passive,
        'percent': chart?.passive?.percent ?? 0,
        'count': chart?.passive?.count ?? 0,
      },
      {
        'key': 'Destructive',
        'color': ColorsContent.destructiveStateColor.withOpacity(0.3),
        'title': 'Destructive',
        'data': chart?.destructive,
        'percent': chart?.destructive?.percent ?? 0,
        'count': chart?.destructive?.count ?? 0,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        child: Column(
          children: [
            for (final section in sections)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: section['color'] as Color, // KEEP ORIGINAL COLOR
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: section['title'] == "Optimal"
                              ? ColorsContent.optimalStateColor
                              : section['title'] == "Stressful"
                              ? ColorsContent.stressFullStateColor
                              : section['title'] == "Passive"
                              ? ColorsContent.passiveStateColor
                              : section['title'] == "Destructive"
                              ? ColorsContent.destructiveStateColor
                              : ColorsContent.newThemeColor,
                          // KEEP ORIGINAL COLOR
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: const EdgeInsets.only(left: 0, right: 0),
                      initiallyExpanded: expandedKey == section['key'],
                      // ⭐ CUSTOM DROPDOWN ICON
                      trailing: Icon(
                        expandedKey == section['key']
                            ? Icons.arrow_drop_up // when expanded
                            : Icons.arrow_drop_down, // when collapsed
                        color: section['title'] == "Optimal"
                            ? ColorsContent.optimalStateColor
                            : section['title'] == "Stressful"
                            ? ColorsContent.stressFullStateColor
                            : section['title'] == "Passive"
                            ? ColorsContent.passiveStateColor
                            : section['title'] == "Destructive"
                            ? ColorsContent.destructiveStateColor
                            : ColorsContent.newThemeColor,
                        size: 28,
                      ),
                      onExpansionChanged: (isExpanded) {
                        setState(() {
                          expandedKey =
                              isExpanded ? section['key'] as String : null;
                        });
                      },
                      title:Text(
                        '${section['title']} (${section['count']}) ${(section['percent'] as num).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: section['title'] == "Optimal"
                              ? ColorsContent.optimalStateColor
                              : section['title'] == "Stressful"
                              ? ColorsContent.stressFullStateColor
                              : section['title'] == "Passive"
                              ? ColorsContent.passiveStateColor
                              : section['title'] == "Destructive"
                              ? ColorsContent.destructiveStateColor
                              : ColorsContent.newThemeColor, // default
                        ),
                      ),

                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.white, // EXPANDED PORTION COLOR
                          child: Column(
                            children: (() {
                              final data = section['data'];
                              if (data == null) return <Widget>[];

                              final emotions = (data as dynamic).emotions
                                      as List<dynamic>? ??
                                  [];

                              final children = <Widget>[];

                              for (int i = 0; i < emotions.length; i++) {
                                final e = emotions[i];
                                final emotionTitle =
                                    (e as dynamic).emotionTitle?.toString() ??
                                        '';

                                children.add(
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      emotionTitle.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: ColorsContent.greyText,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );

                                if (i < emotions.length - 1) {
                                  children.add(
                                     Divider(
                                      color: ColorsContent.expandedBorderColor,
                                      thickness: 1.0,
                                      height: 0,
                                    ),
                                  );
                                }
                              }

                              return children;
                            })(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // -----------------------------
            // Supporting Emotions (same logic)
            // -----------------------------
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: ColorsContent.optimalStateColor,
                borderRadius: BorderRadius.circular(0),
              ),
              child: ExpansionTile(
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,

                // ⭐ CUSTOM WHITE ICON (DROP DOWN / UP)
                trailing: Icon(
                  expandedKey == "supporting"
                      ? Icons.arrow_drop_down // when expanded
                      : Icons.arrow_drop_down, // when collapsed
                  color: Colors.white,
                  size: 28,
                ),

                initiallyExpanded: expandedKey == "supporting",
                onExpansionChanged: (isExpanded) {
                  setState(() {
                    expandedKey = isExpanded ? "supporting" : null;
                  });
                },

                title: Row(
                  children: [
                    const Text(
                      'My Supporting Emotions  ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Text(
                        '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        for (int i = 0; i < support.length; i++) ...[
                          ListTile(
                            dense: true,
                            title: Text(
                              (support[i].emotionTitle ?? '')
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                final emotionId =
                                    (support[i].emotionId ?? '').toString();

                                customPopup(
                                  context: context,
                                  onPressedDelete: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => Center(
                                        child: CupertinoActivityIndicator(
                                          color: ColorsContent.newThemeColor,
                                          radius: 15,
                                        ),
                                      ),
                                    );

                                    final result =
                                        await provider.deleteReminderFunction(
                                      emotion_id: emotionId,
                                      context: context,
                                    );

                                    if (mounted) Navigator.of(context).pop();

                                    if (result) {
                                      await provider.fetchJournalChartView(
                                          context: context);

                                      if (mounted &&
                                          Navigator.canPop(context)) {
                                        Navigator.of(context).pop();
                                      }

                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Emotion removed successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Failed to remove emotion'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  title: 'Confirm Delete',
                                  content:
                                      'Are you sure you want to delete this reminder?',
                                );
                              },
                              child: SvgPicture.asset(
                                ImageConstant.numuCloseChart,
                              ),
                            ),
                          ),
                          if (i < support.length - 1)
                            const Divider(color: Colors.black, thickness: 0.5),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:logger/logger.dart';
// import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
// import 'package:provider/provider.dart';
//
// import '../../../utils/core/image_constant.dart';
// import '../../../utils/theme/colors.dart';
//
// class ChartViewList extends StatelessWidget {
//   const ChartViewList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         SizedBox(height: size.height * 0.02),
//         SizedBox(
//           height: size.height * 0.60,
//           width: double.infinity,
//           child: const ChartQuadrantWidget(),
//         ),
//       ],
//     );
//   }
// }
//
// // Emotional Drive Profile Quadrant Chart
// class ChartQuadrantWidget extends StatefulWidget {
//   const ChartQuadrantWidget({Key? key}) : super(key: key);
//
//   @override
//   ChartQuadrantWidgetState createState() => ChartQuadrantWidgetState();
// }
//
// class ChartQuadrantWidgetState extends State<ChartQuadrantWidget> {
//   List<ChartData> data = [];
//   final Map<String, Color> colorMap = {
//     'Optimal': const Color(0xFFB3E5AB),
//     'Stressful': const Color(0xFF5DD9C1),
//     'Passive': const Color(0xFFFFD9A8),
//     'Destructive': const Color(0xFFFF7A5C),
//   };
//   var logger = Logger();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _fetchData();
//     });
//   }
//
//   Future<void> _fetchData() async {
//     final journalListProvider =
//     Provider.of<JournalListProvider>(context, listen: false);
//     await journalListProvider.fetchJournalChartView(context: context);
//
//     if (journalListProvider.journalChartViewModel != null) {
//       setState(() {
//         data = [
//           ChartData(
//             'Optimal',
//             journalListProvider
//                 .journalChartViewModel?.chartpercentage!.optimalPercent
//                 ?.toInt() ??
//                 0,
//           ),
//           ChartData(
//             'Stressful',
//             journalListProvider
//                 .journalChartViewModel?.chartpercentage!.stressfullPercent
//                 ?.toInt() ??
//                 0,
//           ),
//           ChartData(
//             'Passive',
//             journalListProvider
//                 .journalChartViewModel?.chartpercentage!.passivePercent
//                 ?.toInt() ??
//                 0,
//           ),
//           ChartData(
//             'Destructive',
//             journalListProvider
//                 .journalChartViewModel?.chartpercentage!.destructivePercent
//                 ?.toInt() ??
//                 0,
//           ),
//         ];
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Consumer<JournalListProvider>(
//       builder: (context, journalListProvider, _) {
//         logger.w(
//             "data ${journalListProvider.journalChartViewModel?.chartpercentage!.optimalPercent?.toDouble()}");
//
//         return SingleChildScrollView(
//           child: journalListProvider.journalChartViewModelLoading
//               ? Center(
//             child: CupertinoActivityIndicator(
//               color: ColorsContent.newThemeColor,
//               radius: 15,
//             ),
//           )
//               : journalListProvider.journalChartStatusCode != 404
//               ? Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(
//                   color: const Color(0xFFE0E0E0),
//                   width: 1,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 24),
//                   const Text(
//                     'EMOTIONAL DRIVE PROFILE',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF999999),
//                       letterSpacing: 1.2,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Padding(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: EmotionalDriveChart(
//                       optimalPercent: journalListProvider
//                           .journalChartViewModel
//                           ?.chartpercentage!
//                           .optimalPercent
//                           ?.toInt() ??
//                           0,
//                       stressfulPercent: journalListProvider
//                           .journalChartViewModel
//                           ?.chartpercentage!
//                           .stressfullPercent
//                           ?.toInt() ??
//                           0,
//                       passivePercent: journalListProvider
//                           .journalChartViewModel
//                           ?.chartpercentage!
//                           .passivePercent
//                           ?.toInt() ??
//                           0,
//                       destructivePercent: journalListProvider
//                           .journalChartViewModel
//                           ?.chartpercentage!
//                           .destructivePercent
//                           ?.toInt() ??
//                           0,
//                       colorMap: colorMap,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           )
//               : Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SvgPicture.asset(
//                 ImageConstant.noDataNumu,
//               ),
//               const Text("No data found",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   )),
//               const SizedBox(height: 10),
//               const Text("Check back later",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.black,
//                     fontWeight: FontWeight.normal,
//                   )),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class EmotionalDriveChart extends StatefulWidget {
//   final int optimalPercent;
//   final int stressfulPercent;
//   final int passivePercent;
//   final int destructivePercent;
//   final Map<String, Color> colorMap;
//
//   const EmotionalDriveChart({
//     Key? key,
//     required this.optimalPercent,
//     required this.stressfulPercent,
//     required this.passivePercent,
//     required this.destructivePercent,
//     required this.colorMap,
//   }) : super(key: key);
//
//   @override
//   State<EmotionalDriveChart> createState() => _EmotionalDriveChartState();
// }
//
// class _EmotionalDriveChartState extends State<EmotionalDriveChart>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Chart axes labels
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const SizedBox(width: 40),
//             ...List.generate(11, (i) {
//               int value = -5 + (i * 1);
//               return SizedBox(
//                 width: 30,
//                 child: Text(
//                   '$value',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     color: Color(0xFF999999),
//                     fontFamily: 'Poppins',
//                   ),
//                 ),
//               );
//             }),
//             const SizedBox(width: 20),
//           ],
//         ),
//         const SizedBox(height: 8),
//         // Main chart area
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Y-axis labels
//             SizedBox(
//               width: 40,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(11, (i) {
//                   int value = 5 - (i * 1);
//                   return SizedBox(
//                     height: 35,
//                     child: Center(
//                       child: Text(
//                         '$value',
//                         style: const TextStyle(
//                           fontSize: 10,
//                           color: Color(0xFF999999),
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//             // Chart quadrants
//             Expanded(
//               child: SizedBox(
//                 height: 385,
//                 child: AnimatedBuilder(
//                   animation: _animation,
//                   builder: (context, child) {
//                     return Stack(
//                       children: [
//                         // Quadrant backgrounds
//                         Row(
//                           children: [
//                             // Left side (Stressful + Destructive)
//                             Expanded(
//                               child: Column(
//                                 children: [
//                                   // Top-left: Stressful
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: widget.colorMap['Stressful'],
//                                         border: Border(
//                                           right: BorderSide(
//                                             color: Colors.white,
//                                             width: 2,
//                                           ),
//                                           bottom: BorderSide(
//                                             color: Colors.white,
//                                             width: 2,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Stressful',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white.withOpacity(0.7),
//                                             fontFamily: 'Poppins',
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   // Bottom-left: Destructive
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: widget.colorMap['Destructive'],
//                                         border: Border(
//                                           right: BorderSide(
//                                             color: Colors.white,
//                                             width: 2,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Destructive',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white.withOpacity(0.7),
//                                             fontFamily: 'Poppins',
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             // Right side (Optimal + Passive)
//                             Expanded(
//                               child: Column(
//                                 children: [
//                                   // Top-right: Optimal
//                                   Expanded(
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         color: widget.colorMap['Optimal'],
//                                         border: Border(
//                                           bottom: BorderSide(
//                                             color: Colors.white,
//                                             width: 2,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Optimal',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white.withOpacity(0.7),
//                                             fontFamily: 'Poppins',
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   // Bottom-right: Passive
//                                   Expanded(
//                                     child: Container(
//                                       color: widget.colorMap['Passive'],
//                                       child: Center(
//                                         child: Text(
//                                           'Passive',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white.withOpacity(0.7),
//                                             fontFamily: 'Poppins',
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         // Axes lines (center crosshair)
//                         Center(
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: CustomPaint(
//                                   painter: AxesPainter(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Data points with animation
//                         AnimatedDataPoint(
//                           animationValue: _animation.value,
//                           xPos: widget.optimalPercent,
//                           yPos: widget.optimalPercent,
//                           isPositiveX: true,
//                           isPositiveY: true,
//                         ),
//                         AnimatedDataPoint(
//                           animationValue: _animation.value,
//                           xPos: widget.stressfulPercent,
//                           yPos: widget.stressfulPercent,
//                           isPositiveX: false,
//                           isPositiveY: true,
//                         ),
//                         AnimatedDataPoint(
//                           animationValue: _animation.value,
//                           xPos: widget.passivePercent,
//                           yPos: widget.passivePercent,
//                           isPositiveX: true,
//                           isPositiveY: false,
//                         ),
//                         AnimatedDataPoint(
//                           animationValue: _animation.value,
//                           xPos: widget.destructivePercent,
//                           yPos: widget.destructivePercent,
//                           isPositiveX: false,
//                           isPositiveY: false,
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//             // Right side space
//             const SizedBox(width: 20),
//           ],
//         ),
//         const SizedBox(height: 16),
//         // X-axis label
//         const Text(
//           'Emotion',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF0066FF),
//             fontFamily: 'Poppins',
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'Emotion',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//             color: Colors.black,
//             fontFamily: 'Poppins',
//           ),
//         ),
//         const SizedBox(height: 8),
//         // Y-axis label
//         Transform.rotate(
//           angle: -1.5708, // -90 degrees
//           child: const Text(
//             'Drive',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFFFF6633),
//               fontFamily: 'Poppins',
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class AxesPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 2.0
//       ..style = PaintingStyle.stroke;
//
//     final centerX = size.width / 2;
//     final centerY = size.height / 2;
//
//     // Vertical line (emotion axis)
//     canvas.drawLine(
//       Offset(centerX, 0),
//       Offset(centerX, size.height),
//       paint,
//     );
//
//     // Horizontal line (drive axis)
//     canvas.drawLine(
//       Offset(0, centerY),
//       Offset(size.width, centerY),
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
//
// class AnimatedDataPoint extends StatelessWidget {
//   final double animationValue;
//   final int xPos;
//   final int yPos;
//   final bool isPositiveX;
//   final bool isPositiveY;
//
//   const AnimatedDataPoint({
//     Key? key,
//     required this.animationValue,
//     required this.xPos,
//     required this.yPos,
//     required this.isPositiveX,
//     required this.isPositiveY,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final xOffset = isPositiveX ? (xPos * 30 * animationValue) : -(xPos * 30 * animationValue);
//     final yOffset = isPositiveY ? -(yPos * 30 * animationValue) : (yPos * 30 * animationValue);
//
//     final scale = animationValue;
//
//     return Positioned(
//       left: 50 + xOffset,
//       top: 100 + yOffset,
//       child: Transform.scale(
//         scale: scale,
//         child: Opacity(
//           opacity: animationValue,
//           child: Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: const Color(0xFF5B9FD3),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF5B9FD3).withOpacity(0.5),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ChartData {
//   ChartData(this.x, this.y);
//
//   final String x;
//   final int y;
// }
