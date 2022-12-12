import 'package:flutter/material.dart';
import 'package:flutter_sqflite_example/common_widgets/utils/colors.dart';
import 'package:flutter_sqflite_example/common_widgets/utils/common_size_helper.dart';
import 'package:flutter_sqflite_example/common_widgets/widgets/common_buttons.dart';
import 'package:flutter_sqflite_example/common_widgets/widgets/common_text_feild.dart';
import 'package:flutter_sqflite_example/common_widgets/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class AddNewVesselStepTwo extends StatefulWidget {
  final PageController? pageController;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  // final AddVesselData? addVesselData;
  final bool? isEdit;
  const AddNewVesselStepTwo(
      {Key? key,
      this.pageController,
      this.scaffoldKey,
      /*this.addVesselData,*/
      this.isEdit})
      : super(key: key);

  @override
  State<AddNewVesselStepTwo> createState() => _AddNewVesselStepTwoState();
}

class _AddNewVesselStepTwoState extends State<AddNewVesselStepTwo>
    with AutomaticKeepAliveClientMixin<AddNewVesselStepTwo> {
  late GlobalKey<ScaffoldState> scaffoldKey;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController freeBoardController = TextEditingController();
  TextEditingController lengthOverallController = TextEditingController();
  TextEditingController moldedBeamController = TextEditingController();
  TextEditingController moldedDepthController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController builtYearController = TextEditingController();

  FocusNode freeBoardFocusNode = FocusNode();
  FocusNode lengthOverallFocusNode = FocusNode();
  FocusNode moldedBeamFocusNode = FocusNode();
  FocusNode moldedDepthFocusNode = FocusNode();
  FocusNode sizeFocusNode = FocusNode();
  FocusNode capacityFocusNode = FocusNode();
  FocusNode builtYearFocusNode = FocusNode();

  //late CommonProvider commonProvider;

  bool? isBtnClicked = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      scaffoldKey = widget.scaffoldKey!;
    });

    //commonProvider = context.read<CommonProvider>();

    /* if (widget.isEdit!) {
      if (widget.addVesselData != null) {
        freeBoardController.text = widget.addVesselData!.freeBoard!.toString();
        lengthOverallController.text =
            widget.addVesselData!.lengthOverall!.toString();
        moldedBeamController.text = widget.addVesselData!.beam!.toString();
        moldedDepthController.text = widget.addVesselData!.depth!.toString();
        sizeController.text = widget.addVesselData!.vesselSize!.toString();
        capacityController.text = widget.addVesselData!.capacity!.toString();
        builtYearController.text = widget.addVesselData!.builtYear!.toString();
      }
    }*/
  }

  @override
  Widget build(BuildContext context) {
    // commonProvider = context.watch<CommonProvider>();

    return Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: displayHeight(context) * 0.02),
                  commonText(
                      context: context,
                      text: 'Step 2/2',
                      fontWeight: FontWeight.w600,
                      textColor: Colors.black,
                      textSize: displayWidth(context) * 0.04,
                      textAlign: TextAlign.start),
                  SizedBox(height: displayHeight(context) * 0.02),
                  commonText(
                      context: context,
                      text: 'Size of the boat',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black54,
                      textSize: displayWidth(context) * 0.035,
                      textAlign: TextAlign.start),
                  SizedBox(height: displayHeight(context) * 0.02),
                  CommonTextField(
                      controller: freeBoardController,
                      focusNode: freeBoardFocusNode,
                      labelText: 'Freeboard (ft)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: lengthOverallFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel freeboard';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: lengthOverallController,
                      focusNode: lengthOverallFocusNode,
                      labelText: 'Length overall (m)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: moldedBeamFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel length overall';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: moldedBeamController,
                      focusNode: moldedBeamFocusNode,
                      labelText: 'Beam (ft)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: moldedDepthFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel beam';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: moldedDepthController,
                      focusNode: moldedDepthFocusNode,
                      labelText: 'Draft (ft)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType:
                          TextInputType.numberWithOptions(decimal: true),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: sizeFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel draft';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.025),
                  commonText(
                      context: context,
                      text: 'Engine characteristics*',
                      fontWeight: FontWeight.w500,
                      textColor: Colors.black54,
                      textSize: displayWidth(context) * 0.035,
                      textAlign: TextAlign.start),
                  SizedBox(height: displayHeight(context) * 0.025),
                  CommonTextField(
                      controller: sizeController,
                      focusNode: sizeFocusNode,
                      labelText: 'Size (hp)',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: capacityFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel size';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: capacityController,
                      focusNode: capacityFocusNode,
                      labelText: 'Capacity (cc)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 6,
                      prefixIcon: null,
                      requestFocusNode: builtYearFocusNode,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel capacity';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                  SizedBox(height: displayHeight(context) * 0.015),
                  CommonTextField(
                      controller: builtYearController,
                      focusNode: builtYearFocusNode,
                      labelText: 'Built Year (YYYY)*',
                      hintText: '',
                      suffixText: null,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.number,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 4,
                      prefixIcon: null,
                      requestFocusNode: null,
                      obscureText: false,
                      onTap: () {},
                      onChanged: (String value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter vessel built year';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        print(value);
                      }),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: displayHeight(context) * 0.01,
                      top: displayHeight(context) * 0.02),
                  child: isBtnClicked!
                      ? CircularProgressIndicator()
                      : CommonButtons.getActionButton(
                          title:
                              widget.isEdit! ? 'Update Vessel' : 'Add Vessel',
                          context: context,
                          fontSize: displayWidth(context) * 0.042,
                          textColor: Colors.white,
                          buttonPrimaryColor: buttonBGColor,
                          borderColor: buttonBGColor,
                          width: displayWidth(context),
                          onTap: () async {
                            /*if (formKey.currentState!.validate()) {
                          setState(() {
                            isBtnClicked = true;
                          });

                          FocusScope.of(context)
                              .requestFocus(new FocusNode());

                          commonProvider.addVesselRequestModel!.freeBoard =
                              freeBoardController.text;
                          commonProvider.addVesselRequestModel!
                              .lenghtOverAll = lengthOverallController.text;
                          commonProvider.addVesselRequestModel!.beam =
                              moldedBeamController.text;
                          commonProvider.addVesselRequestModel!.depth =
                              moldedDepthController.text;
                          commonProvider.addVesselRequestModel!.size =
                              sizeController.text;
                          commonProvider.addVesselRequestModel!.capacity =
                              capacityController.text;
                          commonProvider.addVesselRequestModel!.builtYear =
                              builtYearController.text;

                          if (widget.isEdit!) {
                            debugPrint(
                                'VESSEL ID ${widget.addVesselData!.id!}');

                            commonProvider
                                .editVessel(
                                context,
                                commonProvider.addVesselRequestModel,
                                commonProvider.loginModel!.userId!,
                                commonProvider.loginModel!.token!,
                                widget.addVesselData!.id!,
                                widget.scaffoldKey!)
                                .then((value) async {
                              setState(() {
                                isBtnClicked = false;
                              });

                              if (value != null) {
                                if (value.status!) {
                                  setState(() {
                                    isBtnClicked = false;
                                  });

                                  var result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SuccessfullyAddedScreen(
                                                data: value.addVesselData,
                                                isEdit: widget.isEdit)),
                                  );

                                  if (result != null) {
                                    if (result) {
                                      Navigator.of(context).pop(true);
                                    }
                                  }
                                }
                              }
                            }).catchError((e) {
                              setState(() {
                                isBtnClicked = false;
                              });
                            });
                          } else {
                            commonProvider
                                .addVessel(
                                context,
                                commonProvider.addVesselRequestModel,
                                commonProvider.loginModel!.userId!,
                                commonProvider.loginModel!.token!,
                                widget.scaffoldKey!)
                                .then((value) {
                              setState(() {
                                isBtnClicked = false;
                              });

                              if (value != null) {
                                if (value.status!) {
                                  setState(() {
                                    isBtnClicked = false;
                                  });

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SuccessfullyAddedScreen(
                                                data: value.addVesselData,
                                                isEdit: widget.isEdit)),
                                  );
                                }
                              }
                            }).catchError((e) {
                              setState(() {
                                isBtnClicked = false;
                              });
                            });
                          }
                        }*/
                          }),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
