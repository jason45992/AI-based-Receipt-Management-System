import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:tripo/widgets/my_app_bar.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(
          title: "Placeholder Example", implyLeading: false, context: context),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SnappingSheet(
          snappingPositions: [
            SnappingPosition.factor(
              positionFactor: 0.0,
              snappingCurve: Curves.easeOutExpo,
              snappingDuration: Duration(seconds: 1),
              grabbingContentOffset: GrabbingContentOffset.top,
            ),
            SnappingPosition.factor(
              snappingCurve: Curves.elasticOut,
              snappingDuration: Duration(milliseconds: 1750),
              positionFactor: 0.5,
            ),
            SnappingPosition.factor(
              grabbingContentOffset: GrabbingContentOffset.bottom,
              snappingCurve: Curves.bounceOut,
              snappingDuration: Duration(seconds: 1),
              positionFactor: 1.0,
            ),
          ],
          // child: DummyBackgroundContent(),
          grabbingHeight: 100,
          grabbing: Container(
            color: Colors.white.withOpacity(0.75),
            child: Placeholder(color: Colors.black),
          ),
          sheetAbove: SnappingSheetContent(
            draggable: true,
            child: Container(
                color: Colors.white.withOpacity(0.75),
                child: Placeholder(color: Colors.green)),
          ),
          sheetBelow: SnappingSheetContent(
            draggable: true,
            child: Container(
              color: Colors.white.withOpacity(0.75),
              child: Placeholder(color: Colors.green[800] ?? Colors.green),
            ),
          ),
        ),
      ),
    );
  }
}
