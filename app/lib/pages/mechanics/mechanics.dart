import 'package:app/models/mechanic.dart';
import 'package:app/models/vehicle_tree.dart';
import 'package:app/services/endpoints/mechanic.dart';
import 'package:app/widgets/mechanic/card.dart';
import 'package:app/widgets/popup/vehicle_picker.dart';
import 'package:app/widgets/ui/address_filter.dart';
import 'package:app/widgets/ui/filter.dart';
import 'package:app/widgets/ui/service_filter.dart';
import 'package:app/widgets/ui/vehicle_filter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;
import 'package:app/controllers/mechanics.dart';

class _ListFilters extends StatelessWidget
{
  final MechanicsController controller = Get.find();

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() => SearchFiltersHeader(title: 'pages.mechanics.title'.tr, total: controller.pagination.value.total)),
          Obx(() => ServiceFilter(
            initialSelection: controller.params.value.services,
            onChange: (services) {
              controller.params.value.services = services;
              controller.params.refresh();
              controller.load();
            }
          )),
          Obx(() => VehicleFilter(
            initialSelection: controller.params.value.vehicles,
            onChange: (vehicles) {
              controller.params.value.vehicles = vehicles;
              controller.params.refresh();
              controller.load();
            },
          )),
          Obx(() => AddressFilter(
            address: controller.params.value.address,
            range: controller.params.value.distance,
            onRangeChange: (range) {
              controller.params.value.distance = range;
              controller.params.refresh();
              controller.load();
            },
            onChange: (address) {
              controller.params.value.address = address;
              controller.params.refresh();
              controller.load();
            }
          )),
        ]
      )
    );
  }
}

class _SortSheet extends StatelessWidget {
  final String value;
  final Function onChanged;
  final bool showDistance;
  const _SortSheet({Key key, @required this.value, this.onChanged, this.showDistance=false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.amber, width: 5)
        )
      ),
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RadioListTile(
            title: Text(('sorts.'+MechanicQueryParameters.SORT_HOT).tr),
            value: MechanicQueryParameters.SORT_HOT, 
            groupValue: value, 
            onChanged: onChanged
          ),
          RadioListTile(
            title: Text(('sorts.'+MechanicQueryParameters.SORT_NEW).tr),
            value: MechanicQueryParameters.SORT_NEW, 
            groupValue: value, 
            onChanged: onChanged
          ),
          Obx(() => showDistance ?
            RadioListTile(
              title: Text(('sorts.'+MechanicQueryParameters.SORT_DISTANCE).tr),
              value: MechanicQueryParameters.SORT_DISTANCE.tr, 
              groupValue: value, 
            onChanged: onChanged
            ) : SizedBox.shrink()
          )
        ],
      )
    );
  }
}

class MechanicsPage extends StatefulWidget
{
  final MechanicsController controller = Get.put(MechanicsController());

  _MechanicsPageState createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage> 
{
  void initState() {
    super.initState();
    widget.controller.load();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _ListFilters(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(left: 0),
            child: IconButton(
              icon: Icon(FontAwesomeIcons.slidersH),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 0),
          child: Text('pages.mechanics.title'.tr)
        ),
        actions: [
          OutlineButton(
            textColor: Colors.black,
            onPressed: () {
              Get.bottomSheet(
                _SortSheet(
                  value: widget.controller.params.value.sort,
                  onChanged: (v) {
                    widget.controller.sortBy(v);
                    Get.back();
                  },
                  showDistance: widget.controller.params.value.address != null && widget.controller.params.value.address.geolocated
                )
              );
            },
            child: Row(
              children: [
                Obx(() => widget.controller.params.value.sort != null ?
                  Text(('sorts.'+widget.controller.params.value.sort).tr) : 
                  Text('sort_by'.tr)
                ),
                Icon(FontAwesomeIcons.caretDown)
              ],
            )
          )
        ],
        //backgroundColor: Colors.transparent,
        //elevation: 0,
        centerTitle: false,
        //titleSpacing: 0,
      ),
      body: SafeArea(
        child:
          Obx(() {
            return ListView.builder(
              itemCount: widget.controller.items.length + 1,
              itemBuilder: (_, idx) {
                if (idx < widget.controller.items.length) {
                  Mechanic mechanic = widget.controller.items[idx];
                  return MechanicCard(
                    onTap: () => Get.toNamed(routes.mechanic.replaceFirst(':mechanic', mechanic.id.toString())),
                    mechanic: mechanic
                  );
                } else if (idx == widget.controller.items.length) {
                  if (widget.controller.pagination.value.next != null) {
                    widget.controller.more();
                    return Center(child:CircularProgressIndicator());
                  } else {
                    return SizedBox.shrink();
                  }
                } else {
                  return Container();
                }
              },
            );
          }),
      )
    );
  }
}