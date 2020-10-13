import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';

import 'package:app/controllers/services.dart';

class ServicePicker extends StatefulWidget {
  final ServicesController controller = Get.put(ServicesController());

  ServicePicker({Key key}) : super(key: key);

  _ServicePickerState createState() => _ServicePickerState();
}

class _ServicePickerState extends State<ServicePicker> {
  TextEditingController _searchController;

  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      widget.controller.search(q: _searchController.text);
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
                          (widget.controller.items[idx].label ?? '')));
                },
              ));
            }),
          ],
        ))));
  }
}
