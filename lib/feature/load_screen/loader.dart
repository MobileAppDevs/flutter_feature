import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  double height = 60.00;
  double width = 60.00;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.black,
            ),
            child:const SpinKitCircle(
              color: Colors.white,
              size: 40.0,
            ),
          )
        ],
      ),
    );
  }
}