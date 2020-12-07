import 'package:app/controllers/jobs.dart';
import 'package:app/models/job.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:app/widgets/job/card.dart';
import 'package:app/services/google/places.dart';
import 'package:app/widgets/ui/address_filter.dart';
import 'package:app/widgets/ui/filter.dart';
import 'package:app/widgets/ui/service_filter.dart';
import 'package:app/widgets/ui/vehicle_filter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:app/routes.dart' as routes;

class _PublicJobsController extends JobsController {}

class _ListFilters extends StatelessWidget
{
  final _PublicJobsController controller = Get.put(_PublicJobsController());

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() => SearchFiltersHeader(title: 'pages.jobs.title'.tr, total: controller.pagination.value.total)),
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
              controller.params.value.vehicles = vehicles ?? [];
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
              controller.params.value.distance = 50;
              controller.params.value.address = address;
              controller.params.refresh();
              controller.load();
            }
          ))
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
            title: Text(('sorts.'+JobQueryParameters.SORT_HOT).tr),
            value: JobQueryParameters.SORT_HOT, 
            groupValue: value, 
            onChanged: onChanged
          ),
          RadioListTile(
            title: Text(('sorts.'+JobQueryParameters.SORT_NEW).tr),
            value: JobQueryParameters.SORT_NEW, 
            groupValue: value, 
            onChanged: onChanged
          ),
          Obx(() => showDistance ?
            RadioListTile(
              title: Text(('sorts.'+JobQueryParameters.SORT_DISTANCE).tr),
              value: JobQueryParameters.SORT_DISTANCE.tr, 
              groupValue: value, 
              onChanged: onChanged
            ) : SizedBox.shrink()
          )
        ],
      )
    );
  }
}

class JobsPage extends StatefulWidget
{
  final _PublicJobsController controller = Get.put(_PublicJobsController());
  final PlaceApiProvider placeApi = Get.put(PlaceApiProvider());

  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> 
{
  void initState() {
    super.initState();
    widget.controller.load();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _ListFilters(),
      body: RefreshIndicator(
        onRefresh: () async {
          await widget.controller.load();
        },
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
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
            //expandedHeight: 98.0,
            floating: true,
            snap: false,
            actions: <Widget>[
              OutlineButton(
                textColor: Colors.black,
                onPressed: () {
                  Get.bottomSheet(Obx(() => _SortSheet(
                    value: widget.controller.params.value.sort,
                    onChanged: (v) {
                      widget.controller.sortBy(v);
                      Get.back();
                    },
                    showDistance: widget.controller.params.value.address != null && widget.controller.params.value.address.geolocated,
                  )));
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
            pinned: true,
            title: Text('pages.jobs.title'.tr),
          ),
          Obx( () =>
            SliverList(
              delegate: SliverChildBuilderDelegate((context, idx) {
                if (idx < widget.controller.items.length) {
                  Job job = widget.controller.items[idx];
                  return JobCard(
                    job: widget.controller.items[idx], 
                    onTap: () => Get.toNamed(routes.job.replaceFirst(':job', job.id.toString()))
                  );
                } else if (idx == widget.controller.items.length) {
                  if (widget.controller.pagination.value.next != null) {
                    widget.controller.more();
                    return Center(child:CircularProgressIndicator());
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              },
              childCount: widget.controller.items.length + 1
              )
            )
          )
        ],
      ))
    );
  }
}
