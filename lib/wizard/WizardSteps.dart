import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:testtapp/screens/DisplayService.dart';
import 'package:testtapp/widgets/AppBarEebvents.dart';
import 'package:testtapp/widgets/app_drawer.dart';

class WizardSteps extends StatefulWidget {
  final int activeStep;
  final List<String> imagePaths;
  final List<String> titles;
  final List<DocumentReference> pages;
  final ValueChanged<int> onStepTapped;
  final String id;

  WizardSteps({
    Key? key,
    required this.activeStep,
    required this.imagePaths,
    required this.titles,
    required this.pages,
    required this.onStepTapped,
    required this.id,
  }) : super(key: key);

  @override
  State<WizardSteps> createState() => _WizardStepsState();
}

class _WizardStepsState extends State<WizardSteps> {
  late int activeStep;

  @override
  void initState() {
    super.initState();
    activeStep = widget.activeStep;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerSize =
        screenWidth * 0.8; // Adjust size for better mobile fit

    return SafeArea(
      child: Scaffold(
        appBar: AppBarEebvents(), // Correct usage of appBar
        drawer: AppDrawer(
          onItemTapped: (int) {},
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // EasyStepper for navigation at the top
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: EasyStepper(
                  activeStepTextColor: Colors.black87,
                  internalPadding: 0,
                  showStepBorder: false,
                  activeStep: activeStep,
                  stepShape: StepShape.rRectangle,
                  stepBorderRadius: 15,
                  borderThickness: 2,
                  stepRadius: 28,
                  finishedStepBorderColor:
                      const Color.fromARGB(255, 248, 241, 239),
                  finishedStepTextColor: Color.fromARGB(255, 209, 205, 203),
                  finishedStepBackgroundColor:
                      const Color.fromARGB(255, 244, 232, 228),
                  showLoadingAnimation: false,
                  steps: List.generate(widget.imagePaths.length, (index) {
                    return EasyStep(
                      customStep: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Opacity(
                              opacity: activeStep >= index ? 1 : 0.3,
                              child: Image.network(
                                widget.imagePaths[index],
                              ),
                            ),
                          ),
                        ],
                      ),
                      //  customTitle: Text(widget.titles[index]),
                    );
                  }),
                  onStepReached: (index) {
                    setState(() {
                      activeStep = index;
                      widget.onStepTapped(index);
                    });
                  },
                ),
              ),
              // Central container to display the DisplayService
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: DisplayService(
                    idService: widget.pages[activeStep],
                    Eventid: FirebaseFirestore.instance
                        .collection('event_types')
                        .doc(widget.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
