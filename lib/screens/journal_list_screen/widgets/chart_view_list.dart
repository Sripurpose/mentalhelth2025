import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../utils/core/image_constant.dart';
import '../../../utils/theme/colors.dart';

class ChartViewList extends StatelessWidget {
  const ChartViewList({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: size.height * 0.02,
        ),
        SizedBox(
          height: size.height * 0.60,
          width: double.infinity,
          child: const ChartCircularWidget(),
        ),
      ],
    );
  }
}

//chart widget
class ChartCircularWidget extends StatefulWidget {
  const ChartCircularWidget({Key? key}) : super(key: key);

  @override
  ChartCircularWidgetState createState() => ChartCircularWidgetState();
}

class ChartCircularWidgetState extends State<ChartCircularWidget> {
  late TooltipBehavior tooltip;
  List<ChartData> data = []; // Initialize with an empty list
  final Map<String, Color> colorMap = {
    'Optimal': ColorsContent.optimalStateColor,
    'Stressful': ColorsContent.stressFullStateColor,
    'Passive':ColorsContent.passiveStateColor,
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
    final journalListProvider =
        Provider.of<JournalListProvider>(context, listen: false);
    await journalListProvider.fetchJournalChartView(context: context);

    if (journalListProvider.journalChartViewModel != null) {
      setState(() {
        data = [
          ChartData(
            'Optimal',
            journalListProvider
                    .journalChartViewModel?.chartpercentage!.optimalPercent
                    ?.toInt() ??
                0,
          ),
          ChartData(
            'Stressful',
            journalListProvider
                    .journalChartViewModel?.chartpercentage!.stressfullPercent
                    ?.toInt() ??
                0,
          ),
          ChartData(
            'Passive',
            journalListProvider
                    .journalChartViewModel?.chartpercentage!.passivePercent
                    ?.toInt() ??
                0,
          ),
          ChartData(
            'Destructive',
            journalListProvider
                    .journalChartViewModel?.chartpercentage!.destructivePercent
                    ?.toInt() ??
                0,
          ),
        ]
            .where((dataPoint) => dataPoint.y > 0)
            .toList(); // Filter out zero values
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<JournalListProvider>(
      builder: (context, journalListProvider, _) {
        logger.w(
            "data ${journalListProvider.journalChartViewModel?.chartpercentage!.optimalPercent?.toDouble()}");
        // if (data.isEmpty) {
        //   return const Center(
        //     child: CircularProgressIndicator(
        //       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Replace with your desired color
        //     ),
        //   );
        // }else{
        //   Center(
        //     child: Image.asset(
        //       ImageConstant.noData,
        //     ),
        //   );
        // }
        return SingleChildScrollView(
          child: journalListProvider.journalChartViewModelLoading
              ?   Center(child: CupertinoActivityIndicator(
            color: ColorsContent.newThemeColor,
            radius: 15,
          ))
              : journalListProvider.journalChartStatusCode != 404
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // Background color
                                  border: Border.all(color: ColorsContent.goalNotCompletedColor, width: 0.5), // Border with dynamic color
                                  borderRadius: BorderRadius.circular(8), // Rounded corners
                                ),
                      child: Column(
                          children: [
                            const SizedBox(height: 25,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40.0),
                              child: CustomLegend(
                                data: [
                                  ChartData(
                                      'Optimal',
                                      journalListProvider.journalChartViewModel
                                              ?.chartpercentage!.optimalPercent
                                              ?.toInt() ??
                                          0),
                                  ChartData(
                                      'Stressful',
                                      journalListProvider.journalChartViewModel
                                              ?.chartpercentage!.stressfullPercent
                                              ?.toInt() ??
                                          0),
                                  ChartData(
                                      'Passive',
                                      journalListProvider.journalChartViewModel
                                              ?.chartpercentage!.passivePercent
                                              ?.toInt() ??
                                          0),
                                  ChartData(
                                      'Destructive',
                                      journalListProvider.journalChartViewModel
                                              ?.chartpercentage!.destructivePercent
                                              ?.toInt() ??
                                          0),
                                ],
                                colorMap: colorMap,
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.37,
                              //   color: Colors.indigo,
                              child:
                              // SfCircularChart(
                              //   legend: const Legend(
                              //     isVisible: false, // Hide default legend
                              //   ),
                              //   series: <CircularSeries>[
                              //     DoughnutSeries<ChartData, String>(
                              //       dataSource: data,
                              //       xValueMapper: (ChartData data, _) => data.x,
                              //       yValueMapper: (ChartData data, _) => data.y,
                              //       pointColorMapper: (ChartData data, _) {
                              //         return colorMap[data.x] ?? Colors.grey;
                              //       },
                              //       cornerStyle: CornerStyle.bothFlat,
                              //       strokeColor: Colors.white,
                              //       strokeWidth: 2.0,
                              //       explode: true,
                              //       legendIconType: LegendIconType.circle,
                              //       explodeAll: true,
                              //       dataLabelSettings: DataLabelSettings(
                              //         isVisible: true,
                              //         labelIntersectAction:
                              //             LabelIntersectAction.shift,
                              //         labelAlignment: ChartDataLabelAlignment.auto,
                              //         useSeriesColor: true,
                              //         labelPosition: ChartDataLabelPosition.inside,
                              //         builder: (dynamic data,
                              //             ChartPoint<dynamic> point,
                              //             ChartSeries<dynamic, dynamic> series,
                              //             int pointIndex,
                              //             int seriesIndex) {
                              //           final value =
                              //               point.y; // Format to two decimal places
                              //           return Text(
                              //             '$value%',
                              //             style: const TextStyle(
                              //               color: Colors.white,
                              //               // Change this to your desired color
                              //               fontSize: 20,
                              //               // Optional: Adjust font size
                              //               fontWeight: FontWeight
                              //                   .bold, // Optional: Adjust font weight
                              //             ),
                              //           );
                              //         },
                              //       ),
                              //       enableTooltip: true,
                              //     )
                              //   ],
                              // ),

                              SfCircularChart(
                                series: <CircularSeries>[
                                  PieSeries<ChartData, String>(
                                    dataSource: data,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y ?? 0, // Ensure non-null values
                                    pointColorMapper: (ChartData data, _) => colorMap[data.x] ?? Colors.grey,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      labelPosition: ChartDataLabelPosition.inside,
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      builder: (dynamic chartData, ChartPoint<dynamic> point,
                                          ChartSeries<dynamic, dynamic> series, int pointIndex, int seriesIndex) {

                                        // Ensure point.y is not null
                                        final num value = point.y ?? 0;

                                        // Calculate total sum of all y-values
                                        final num total = data.fold(0, (num sum, ChartData e) => sum + (e.y ?? 0));

                                        // Calculate percentage
                                        final String percentage =
                                        (total > 0) ? ((value / total) * 100).toStringAsFixed(1) : "0";

                                        return Text(
                                          '$value%', // Display value and percentage
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                          ),
                                        );
                                      },
                                    ),
                                    explode: false, // Ensure segments stay together
                                  ),
                                ],
                              )


                            ),
                            const SizedBox(height: 25,),
                          ],
                        ),
                    ),
                  )
                  : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                ImageConstant.noDataNumu,
              ),
              const Text("No data found",
                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Check back later",
                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal)),
            ],
          )
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
    List<Widget> legendItems = data.map((ChartData dataPoint) {
      final color = colorMap[dataPoint.x] ?? Colors.grey;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            dataPoint.x,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      );
    }).toList();

    return Wrap(
      spacing: 20, // Horizontal space between items
      runSpacing: 10, // Vertical space between rows
      alignment: WrapAlignment.start, // Center align the row
      children: legendItems,
    );
  }
}


class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final int y;
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
