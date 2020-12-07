
import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/address.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/onboarding/common.dart';
import 'package:app/services/google/places.dart';
import 'package:app/widgets/form/address.dart';
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
  OnboardingAddress get stepController => widget.controller.steps[OnboardingStep.Address];

  List<GlobalKey<ItemFaderState>> keys;
  
  void initState() {
    super.initState();
    keys = List.generate(1, (_) => GlobalKey<ItemFaderState>());
  }

  void dispose() {
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
        ItemFader(
          itemCount: 1,
          itemIndex: 0,
          key: keys[0],
          child: Obx(() {
            Address address = widget.controller.profileType.value == ProfileType.Customer ? widget.jobController.job.value.address : widget.userController.user.value.address;
            return AddressForm(
              address: address,
              onChange: (address) async {
                await stepController.setAddress(address);
              }
            );
          })
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(() => RaisedButton(
              onPressed: () => widget.controller.loading.value ? null : submit(),
              child: widget.controller.loading.value ? CircularProgressIndicator() : Icon(Icons.navigate_next_rounded)
            )),
          ]
        )
      ]
    );
  }
}
