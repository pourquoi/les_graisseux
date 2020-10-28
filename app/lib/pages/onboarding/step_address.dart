
// user or job address

import 'package:app/controllers/account/job.dart';
import 'package:app/controllers/onboarding.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/address.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/address_picker.dart';
import 'package:app/services/google/place_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

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

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isValid {
    Address address = widget.controller.profileType.value == ProfileType.Customer ? widget.jobController.job.value.address : widget.userController.user.value.address;
    return address != null && address.geolocated;
  }
  
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _controller,
          readOnly: true,
          onTap: () async {
            // generate a new token here
            final sessionToken = Uuid().v4();
            final Suggestion result = await showSearch(
              context: context,
              delegate: AddressSearch(sessionToken: sessionToken),
            );
            // This will change the text displayed in the TextField
            if (result != null) {
              final placeDetails = await widget.placeApi
                  .getPlaceDetailFromId(result.placeId);
              setState(() {
                _controller.text = result.description;

                stepController.setAddress(Address.fromPlace(placeDetails));
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
        Obx(() {
          Address address = widget.controller.profileType.value == ProfileType.Customer ? widget.jobController.job.value.address : widget.userController.user.value.address;
          if (address == null) {
            return Text('no address');
          } else {
            return Text(address.toString());
          }
        }),
        RaisedButton(
          onPressed: () => isValid ? widget.controller.next() : null,
          child: Text('next')
        )
      ]
    );
  }
}
