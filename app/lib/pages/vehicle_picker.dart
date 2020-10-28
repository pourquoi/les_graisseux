import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';

import 'package:app/controllers/vehicles.dart';
import 'package:app/services/endpoints/vehicle_tree.dart';

class VehiclePicker extends StatefulWidget {
  final VehiclesController controller = Get.put(VehiclesController());

  VehiclePicker({Key key}) : super(key: key);

  _VehiclePickerState createState() => _VehiclePickerState();
}

class _VehiclePickerState extends State<VehiclePicker> {
  TextEditingController _searchController;

  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      widget.controller
          .search(q: _searchController.text, level: VehicleTreeLevel.brand);
    });
  }

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            body: SafeArea(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'service.search_hint'.tr)),
            Obx(() {
              return Expanded(
                  child: ListView.builder(
                itemCount: widget.controller.items.length,
                itemBuilder: (_, idx) {
                  return GestureDetector(
                      onTap: () {
                        Get.back(result: widget.controller.items[idx]);
                      },
                      child: Text('${idx}' +
                          (widget.controller.items[idx].name ?? '')));
                },
              ));
            }),
          ],
        ))));
  }
}
