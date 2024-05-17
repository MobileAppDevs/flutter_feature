import 'package:feature/feature/load_screen/loader.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart'; 

class LoadScreen extends StatefulWidget {
  const LoadScreen(
      {Key? key,
      required this.widget,
      required this.isLoading,
      this.isLoaderChange})
      : super(key: key);
  final Widget? widget;
  final bool? isLoading;
  final bool? isLoaderChange;

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: widget.isLoaderChange == true
          ? LoadingOverlay(
              isLoading: widget.isLoading ?? false,
              opacity: 1.0,
              color: Colors.transparent,
              progressIndicator: const LoadingWidget(),
              child: widget.widget!)
              // child:widget.isLoading == true ?const SizedBox.shrink(): widget.widget!)
          : LoadingOverlay(
              isLoading: widget.isLoading ?? false,
              opacity: 1.0,
              color: Colors.transparent,
              progressIndicator: const LoadingWidget(),
              child: widget.widget!),
              // child:widget.isLoading == true ?const SizedBox.shrink(): widget.widget!)

    );
  }
}


