import 'package:app/models/address.dart';
import 'package:app/widgets/popup/address_picker.dart';
import 'package:app/services/google/places.dart';
import 'package:app/widgets/ui/filter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:meta/meta.dart';

class AddressFilter extends StatefulWidget
{
  final Address address;
  final int range;
  final Function onChange;
  final Function onRangeChange;
  final PlaceApiProvider placeApi = Get.put(PlaceApiProvider());
  
  AddressFilter({Key key, @required this.address, @required this.onChange, @required this.onRangeChange, this.range}) : super(key: key);
  _AddressFilterState createState() => _AddressFilterState();
}

class _AddressFilterState extends State<AddressFilter>
{
  double _range = 0;
  List<int> _ranges = [5, 30, 100, 500];

  void initState() {
    super.initState();
    if (widget.range != null) {
      for(int i=0; i<_ranges.length; i++) {
        if (_ranges[i] >= widget.range) {
          _range = i.toDouble();
          break;
        }
      }
    }
  }

  Widget build(_) {
    Widget child;
    if (widget.address == null || !widget.address.geolocated) {
      child = Container();
    } else {
      child = Padding(
        padding: EdgeInsets.all(15),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 0.0),
            child: Chip(
              label: Text(widget.address.toString(), overflow: TextOverflow.ellipsis),
              onDeleted: () {
                widget.onChange(null);
              },
            )
          ),
          Padding(
            padding: EdgeInsets.only(right: 0.0),
            child: Row(
            children: [

              Text(_ranges[_range.toInt()].toString().padLeft(4, ' ') + ' km'),
              Expanded(
              child:SliderTheme(
                data: SliderThemeData(

                ),
                child: Slider(
                  value: _range,
                  min: 0,
                  max: (_ranges.length-1).toDouble(),
                  divisions: _ranges.length,
                  label: _ranges[_range.toInt()].toString() + ' km',
                  onChanged: (double value) {
                    setState(() {
                      _range = value;
                    });
                    widget.onRangeChange(_ranges[_range.toInt()]);
                  },
                )
              )),
            ]
          ))
        ]
      ));
    }
    
    return SearchFilter(
      title: 'Location',
      icon: FontAwesomeIcons.mapMarkedAlt,
      multiple: false,
      empty: widget.address == null || !widget.address.geolocated,
      onAdd: () async {
        widget.placeApi.initSession();

        final Suggestion result = await showSearch(
          context: context,
          delegate: AddressSearch(),
        );
        
        if (result != null) {
          final placeDetails = await widget.placeApi.getPlaceDetailFromId(result.placeId);
          widget.onChange(Address.fromPlace(placeDetails));
        }
      },
      onReset: () => widget.onChange(null),
      child: child
    );
  }
}