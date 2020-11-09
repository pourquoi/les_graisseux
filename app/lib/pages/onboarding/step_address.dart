
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/address.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/address_picker.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:app/services/google/place_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepAddress extends StatefulWidget {
  final OnboardingController controller = Get.find();
  final UserController userController = Get.find();
  final AccountJobController jobController = Get.find();
  final PlaceApiProvider placeApi = Get.put(PlaceApiProvider());

  StepAddress({Key key}) : super(key: key);

  _StepAddressState createState() => _StepAddressState();
}
  
class _StepAddressState extends State<StepAddress> {
  final _controller = TextEditingController();

  OnboardingAddress get stepController => widget.controller.steps[OnboardingStep.Address];

  List<GlobalKey<ItemFaderState>> keys;
  
  void initState() {
    super.initState();
    keys = List.generate(1, (_) => GlobalKey<ItemFaderState>());
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isValid {
    Address address = widget.controller.profileType.value == ProfileType.Customer ? widget.jobController.job.value.address : widget.userController.user.value.address;
    return address != null && address.geolocated;
  }

  void submit() async {
    if (isValid) {
      for (GlobalKey<ItemFaderState> key in keys) {
        if (key.currentState != null) {
          await key.currentState.hide();
        }
      }
      widget.controller.next();
    }
  }
  
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 32),
        Spacer(),
        Padding(
          padding: EdgeInsets.only(left: 64, right: 8),
          child: TextField(
            controller: _controller,
            readOnly: true,
            onTap: () async {
              widget.placeApi.initSession();

              final Suggestion result = await showSearch(
                context: context,
                delegate: AddressSearch(),
              );
              
              if (result != null) {
                final placeDetails = await widget.placeApi.getPlaceDetailFromId(result.placeId);
                setState(() {
                  //_controller.text = result.description;
                  Address address = Address.fromPlace(placeDetails);
                  stepController.setAddress(address);
                  _controller.text = address.toString();
                });
              }
            },
            decoration: InputDecoration(
              icon: Container(
                width: 10,
                height: 10,
                child: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
              ),
              hintText: "Enter your shipping address",
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
            ),
          ),
        ),
        SizedBox(height: 24,),
        Padding(
          padding: EdgeInsets.only(left: 64, right: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() => RaisedButton(
                onPressed: () => widget.controller.loading.value ? null : submit(),
                child: widget.controller.loading.value ? CircularProgressIndicator() : Icon(Icons.navigate_next_rounded)
              )),
            ]
          )
        ),
        Spacer()
      ]
    );
  }
}
