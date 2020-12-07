import 'package:app/models/address.dart';
import 'package:app/widgets/popup/address_picker.dart';
import 'package:app/services/google/places.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddressForm extends StatefulWidget
{
  final Function onChange;
  final Address address;
  final PlaceApiProvider placeApi = Get.put(PlaceApiProvider());

  AddressForm({Key key, this.address, this.onChange}) : super(key: key);

  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm>
{
  final _controller = TextEditingController();

  void initState() {
    super.initState();
    if (widget.address != null && widget.address.geolocated) {
      _controller.text = widget.address.toString();
    }
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context)
  {
    return TextField(
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
          Address address;
          try {
            address = Address.fromPlace(placeDetails);
          } catch(err) {
            return;
          }

          if (widget.onChange != null) {
            await widget.onChange(address);
          }

          setState(() {
            _controller.text = address.toString();
          });
        }
      },
      decoration: InputDecoration(
        icon: Icon(
          FontAwesomeIcons.home,
        ),
        hintText: "Enter your address",
        //border: InputBorder.none,
        //contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
      ),
    );
  }
}