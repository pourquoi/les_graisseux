import 'package:app/models/vehicle_tree.dart';
import 'package:app/widgets/popup/vehicle_picker.dart';
import 'package:app/widgets/ui/filter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VehicleFilter extends StatefulWidget {
  final Function onChange;
  final List<VehicleTree> initialSelection;

  VehicleFilter({Key key, @required this.onChange, this.initialSelection}) : super(key: key);

  @override
  _VehicleFilterState createState() => _VehicleFilterState();
}

class _VehicleFilterState extends State<VehicleFilter> {
  List<VehicleTree> _vehicles = [];

  void initState() {
    super.initState();
    if (widget.initialSelection != null) _vehicles = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
       child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(
              _vehicles.length > 0 ?
              _vehicles.map((VehicleTree vehicle) {
                return Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Wrap(
                    children: [
                      Chip(
                        label: Text(vehicle.fullName, overflow: TextOverflow.ellipsis),
                        onDeleted: () {
                          _vehicles.remove(vehicle);
                          widget.onChange(_vehicles);
                        },
                      )
                    ]
                  )
                );
              }).toList() : [SizedBox.shrink()]
            )
          ],
        )
       )
    );

    return SearchFilter(
      title: 'Cars',
      icon: FontAwesomeIcons.car,
      child: child,
      multiple: true,
      empty: _vehicles.length == 0,
      onAdd: () async {
        VehicleTree vehicle = await showSearch(
          context: context,
          delegate: VehicleSearch(),
        );
        if (vehicle != null && _vehicles.firstWhere((element) => vehicle.id == element.id, orElse: () => null) == null) {
          setState(() {_vehicles.add(vehicle);});
          widget.onChange(_vehicles);
        }
      },
      onReset: () {
        setState(() {_vehicles = [];});
        widget.onChange(_vehicles);
      }
    );
  }
}