import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';

class WizardStepsContainer extends StatelessWidget {
  int activeStep;
  final List<String> imagePaths;
  final List<String> titles;
  final List<Widget> pages;

  WizardStepsContainer({
    required this.activeStep,
    required this.imagePaths,
    required this.titles,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
      child: WizardSteps(
        activeStep: activeStep,
        imagePaths: imagePaths,
        titles: titles,
        pages: pages,
        onStepTapped: (index) {
          // Handle step tap
          // You can update the active step here if needed
        },
      ),
    );
  }
}

class WizardSteps extends StatefulWidget {
  int activeStep;
  final List<String> imagePaths;
  final List<String> titles;
  final List<Widget> pages;
  final Function(int) onStepTapped;

  WizardSteps({
    Key? key,
    required this.activeStep,
    required this.imagePaths,
    required this.titles,
    required this.pages,
    required this.onStepTapped,
  }) : super(key: key);

  @override
  State<WizardSteps> createState() => _WizardStepsState();
}

class _WizardStepsState extends State<WizardSteps> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              EasyStepper(
                activeStepTextColor: Colors.black87,
                internalPadding: 0,
                showStepBorder: false,
                activeStep: widget.activeStep,
                stepShape: StepShape.rRectangle,
                stepBorderRadius: 15,
                borderThickness: 2,
                stepRadius: 28,
                finishedStepBorderColor: Colors.deepOrange,
                finishedStepTextColor: Colors.deepOrange,
                finishedStepBackgroundColor: Colors.deepOrange,
                activeStepIconColor: Colors.deepOrange,
                showLoadingAnimation: false,
                steps: List.generate(widget.imagePaths.length, (index) {
                  return EasyStep(
                      customStep: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Opacity(
                          opacity: widget.activeStep >= index ? 1 : 0.3,
                          child: Image.network(widget.imagePaths[index]),
                        ),
                      ),
                      customTitle: widget.pages[widget.activeStep]);
                }),
                onStepReached: (index) => setState(() {
                  widget.activeStep = index;
                  widget.pages[index];
                  widget.onStepTapped(index);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
