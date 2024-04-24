import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/common_size_helper.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/common_widgets/widgets/common_text_feild.dart';
import 'package:performarine/common_widgets/widgets/common_widgets.dart';
import 'package:performarine/common_widgets/widgets/custom_fleet_dailog.dart';
import 'package:performarine/models/fleet_dashboard_model.dart' as dash;
import 'package:performarine/models/fleet_details_model.dart';
import 'package:performarine/models/fleet_list_model.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/pages/bottom_navigation.dart';
import 'package:performarine/pages/fleet/widgets/fleet_details_card.dart';
import 'package:performarine/pages/fleet/widgets/member_details_widget.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class FleetVesselScreen extends StatefulWidget {
  int? tabIndex;
  String? fleetId, fleetName;
  final bool? isCalledFromMyFleetScreen, isCalledFromFleetsImInWidget;

  FleetVesselScreen(
      {super.key,
        this.tabIndex,
        this.isCalledFromMyFleetScreen = false,
        this.isCalledFromFleetsImInWidget = false,
        this.fleetId, this.fleetName});

  @override
  State<FleetVesselScreen> createState() => _FleetVesselScreenState();
}

class _FleetVesselScreenState extends State<FleetVesselScreen>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scafoldKey = GlobalKey();

  final DatabaseService _databaseService = DatabaseService();
  late Future<List<CreateVessel>> getVesselFuture;
  TabController? _tabController;

  late CommonProvider commonProvider;
  FleetListModel? fleetdata;
  FleetData? selectedFleetvalue;

  int currentTabIndex = 0;
  Future<FleetDetailsModel>? future;
  bool? isUpdateFleetBtnClicked = false;

  TextEditingController fleetIdController = TextEditingController();

  @override
  void initState() {
    commonProvider = context.read<CommonProvider>();

    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.tabIndex ?? 0);
    _tabController!.addListener(_handleTabSelection);
    getVesselFuture = _databaseService.vessels();
    if (widget.tabIndex != null) {
      currentTabIndex = widget.tabIndex!;
      setState(() {});
    }

    debugPrint("TABINDEX FLEET ID ${widget.fleetName}");

    if(widget.isCalledFromFleetsImInWidget!)
      {
        fleetIdController.text = '${widget.fleetName}';
      }

    getFleetDetails();

    debugPrint("TABINDEX ${widget.isCalledFromFleetsImInWidget}");

    // TODO: implement initState
    super.initState();
  }

  void getFleetDetails() async {
    fleetdata = await commonProvider.getFleetListdata(
        token: commonProvider.loginModel!.token,
        scaffoldKey: _scafoldKey,
        context: context);
    if(widget.isCalledFromFleetsImInWidget!)
      {
        future = commonProvider.getFleetDetailsData(context, commonProvider.loginModel!.token!, widget.fleetId!, _scafoldKey);
        setState(() {});
      }else
        {
          if(fleetdata!.data!=null && fleetdata!.data!.isNotEmpty){

            if(widget.isCalledFromMyFleetScreen!)
            {
              selectedFleetvalue = (fleetdata!.data ?? []).firstWhere((element) => element.id == widget.fleetId);
            }
            else
            {
              selectedFleetvalue = fleetdata!.data!.first;
            }
            // selectedFleetvalue = fleetdata!.data!.first;

            future = commonProvider.getFleetDetailsData(context, commonProvider.loginModel!.token!, selectedFleetvalue!.id!, _scafoldKey);
            setState(() {});
          }else{
            setState(() {

            });
          }
        }
    /*if (fleetdata!.data != null && fleetdata!.data!.isNotEmpty) {
      if (widget.isCalledFromMyFleetScreen!) {
        if(widget.fleetsIamIn != null){
          selectedFleetvalue = (fleetdata!.data ?? [])
              .firstWhere((element) => element.id == widget.fleetId);
        }
        else if(widget.myFleets != null){
          selectedFleetvalue = (fleetdata!.data ?? [])
              .firstWhere((element) => element.id == widget.fleetId, orElse: () {
                return FleetData(
            fleetName: widget.myFleets!.fleetName,
            id: widget.myFleets!.id,
          );
              });
        }

      } else {
        selectedFleetvalue = fleetdata!.data!.first;
      }
      // selectedFleetvalue = fleetdata!.data!.first;

      future = commonProvider.getFleetDetailsData(
          context,
          commonProvider.loginModel!.token!,
          selectedFleetvalue!.id!,
          _scafoldKey);
      setState(() {});
    } else {
      setState(() {});
    }*/
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      switch (_tabController!.index) {
        case 0:
          currentTabIndex = 0;
          setState(() {});
          break;
        case 1:
          currentTabIndex = 1;
          setState(() {});
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    commonProvider = context.watch<CommonProvider>();
    return Scaffold(
        key: _scafoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: commonText(
            context: context,
            text: 'Fleet Details',
            fontWeight: FontWeight.w600,
            textColor: Colors.black87,
            textSize: displayWidth(context) * 0.045,
          ),
          actions: [
           widget.isCalledFromFleetsImInWidget!
            ? SizedBox()
           : Container(
              margin: EdgeInsets.only(right: 10),
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  debugPrint("EDIT FLEET ${fleetdata!.data![0].id}");

                  CustomFleetDailog().showEditFleetDialog(
                      context: context,
                      fleetData: fleetdata!.data,
                      selectedFleetValue: selectedFleetvalue,
                      onUpdateChange: (value) {
                        Navigator.pop(context);
                        setState(() {
                          isUpdateFleetBtnClicked = true;
                        });

                        debugPrint("EDIT FLEET ${value.first}");
                        debugPrint("EDIT FLEET ${value.last}");

                        commonProvider
                            .editFleetDetails(
                                context,
                                commonProvider.loginModel!.token!,
                                value.first,
                                value.last,
                                _scafoldKey)
                            .then((value) {
                          if (value != null) {
                            if (value.status!) {
                              setState(() {
                                isUpdateFleetBtnClicked = false;
                              });
                              getFleetDetails();
                            } else {
                              setState(() {
                                isUpdateFleetBtnClicked = false;
                              });
                            }
                          } else {
                            setState(() {
                              isUpdateFleetBtnClicked = false;
                            });
                          }
                        }).catchError((e) {
                          setState(() {
                            isUpdateFleetBtnClicked = false;
                          });
                        });
                      });
                },
                child: isUpdateFleetBtnClicked!
                    ? CircularProgressIndicator(
                        color: blueColor,
                      )
                    : commonText(
                        text: 'Edit Fleet',
                        textColor: blueColor,
                        fontWeight: FontWeight.w500,
                        textSize: 13),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () async {
                  await SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavigation()),
                      ModalRoute.withName(""));
                },
                icon: Image.asset('assets/icons/performarine_appbar_icon.png'),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              SizedBox(
                child: widget.isCalledFromFleetsImInWidget!
                ? Container(
                  alignment: Alignment.centerLeft,
                  height: 55,
                  width: displayWidth(context),
                  decoration: BoxDecoration(
                    color: dropDownBackgroundColor,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: commonText(
                        text: '${widget.fleetName}',
                        textColor: buttonBGColor,
                        fontWeight: FontWeight.w500,
                        textSize: 16),
                  ),
                )
                : fleetdata != null && fleetdata!.data != null
                    ? DropdownButtonHideUnderline(
                        child: DropdownButtonFormField2<FleetData>(
                          value: selectedFleetvalue,
                          iconStyleData: IconStyleData(
                              icon: Icon(
                            Icons.keyboard_arrow_down,
                            size: 30,
                          )),
                          isExpanded: true,
                          buttonStyleData: ButtonStyleData(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.only(left: 20, right: 40)),
                          decoration: InputDecoration(
                            //errorText: _showDropdownError1 ? 'Select Vessel' : null,

                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),

                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5, color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5, color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color:
                                        Colors.red.shade300.withOpacity(0.7)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            errorStyle: TextStyle(
                                fontFamily: inter,
                                fontSize: displayWidth(context) * 0.025),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color:
                                        Colors.red.shade300.withOpacity(0.7)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            fillColor: dropDownBackgroundColor,
                            filled: true,

                            hintStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? "Filter By" == 'User SubRole'
                                        ? Colors.black54
                                        : Colors.white
                                    : Colors.black,
                                fontSize: displayWidth(context) * 0.034,
                                fontFamily: outfit,
                                fontWeight: FontWeight.w300),
                          ),
                          hint: Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(
                              left: 15,
                            ),
                            child: Text(
                              'Select Fleet',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: displayWidth(context) * 0.032,
                                  fontFamily: outfit,
                                  fontWeight: FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          items: fleetdata!.data!
                              .map((value) => DropdownMenuItem(
                                    child: commonText(
                                        text: value.fleetName,
                                        fontWeight: FontWeight.w400,
                                        textSize: 16,
                                        textColor: buttonBGColor),
                                    value: value,
                                  ))
                              .toList(),
                          onChanged: (newValue) {
                            debugPrint(
                                "SELECTED FLEET ID ${newValue!.fleetName}");

                            future = commonProvider.getFleetDetailsData(
                                context,
                                commonProvider.loginModel!.token!,
                                newValue.id!,
                                _scafoldKey);
                            setState(() {});
                          },
                        ),
                      )
                    : CircularProgressIndicator(color: blueColor),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 1,
                      color: Colors.black,
                      margin: EdgeInsets.only(
                        left: 20,
                        right: 100,
                      ),
                      width: displayWidth(context) / 1.2,
                    ),
                  ),
                  TabBar(
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.white,
                    indicator: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: currentTabIndex == 0
                                    ? Radius.circular(20)
                                    : Radius.circular(0),
                                bottomLeft: currentTabIndex == 0
                                    ? Radius.circular(20)
                                    : Radius.circular(0),
                                topRight: currentTabIndex == 1
                                    ? Radius.circular(20)
                                    : Radius.circular(0),
                                bottomRight: currentTabIndex == 1
                                    ? Radius.circular(20)
                                    : Radius.circular(0))),
                        color: blueColor),
                    tabs: [
                      Tab(
                        child: Container(
                          child: commonText(text: 'Members'),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: commonText(text: 'Vessels'),
                        ),
                      ),
                    ],
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ],
              )),
              fleetdata != null && fleetdata!.data != null
                  ? Expanded(
                      child: FutureBuilder<FleetDetailsModel>(
                        future: future,
                        builder: (context, snapShot) {
                          if (snapShot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                                height: displayHeight(context) / 1.5,
                                child: Center(
                                    child: const CircularProgressIndicator(
                                        color: blueColor)));
                          } else if (snapShot.data == null) {
                            return Container(
                              height: displayHeight(context) / 1.4,
                              child: Center(
                                child: commonText(
                                    context: context,
                                    text: 'No data found',
                                    fontWeight: FontWeight.w500,
                                    textColor: Colors.black,
                                    textSize: displayWidth(context) * 0.05,
                                    textAlign: TextAlign.start),
                              ),
                            );
                          } else {
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setter) {
                              // debugPrint("MEMBERS ${snapShot.data!.myFleets!.isEmpty}");
                              return TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  MemberDetailsWidget(
                                      memberList: (snapShot.data!.myFleets ?? []).isEmpty
                                              ? []
                                              : snapShot.data!.myFleets![0].members ?? [],
                                    isCalledFromFleetsImIn:  widget.isCalledFromFleetsImInWidget!,
                                    scaffoldKey: _scafoldKey,
                                    fleetId :widget.fleetId
                                  ),
                                  FleetDetailsCard(
                                      scaffoldKey: _scafoldKey,
                                      fleetVesselsList:
                                          (snapShot.data!.myFleets ?? [])
                                                  .isEmpty
                                              ? []
                                              : snapShot.data!.myFleets![0]
                                                      .fleetVessels! ??
                                                  [])
                                ],
                                controller: _tabController,
                              );
                            });
                          }
                        },
                      ),
                    )
                  : Container(
                      height: displayHeight(context) / 2,
                      child: Center(
                          child: CircularProgressIndicator(
                        color: blueColor,
                      ))),
            ],
          ),
        ));
  }
}
