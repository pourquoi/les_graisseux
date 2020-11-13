import 'package:app/controllers/jobs.dart';
import 'package:app/models/address.dart';
import 'package:app/pages/address_picker.dart';
import 'package:app/services/google/place_service.dart';
import 'package:app/widgets/ui/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;

class _PublicJobsController extends JobsController {}

class JobsPage extends StatefulWidget
{
  final _PublicJobsController controller = Get.put(_PublicJobsController());
  final PlaceApiProvider placeApi = Get.put(PlaceApiProvider());

  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {

  void initState() {
    super.initState();  
    widget.controller.load();
  }

  Widget build(BuildContext context) {
      return Scaffold(
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              snap: false,
              actions: <Widget>[
                IconButton(icon: Icon(Icons.settings), onPressed: null)
              ],
              pinned: true,
              expandedHeight: 150.0,
              title: Text('Jobs'),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(() {
                          if (widget.controller.params.value.address != null && widget.controller.params.value.address.geolocated) {
                            return Row(
                              children: [
                                Icon(Icons.place, color: Colors.grey,),
                                Expanded(
                                  child: Text(widget.controller.params.value.address.toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20, color: Colors.white,))
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.black),
                                  onPressed: () {
                                    widget.controller.params.value.address = null;
                                    widget.controller.params.refresh();
                                    widget.controller.load();
                                  },
                                )
                              ]
                            );
                          } else {
                            return GestureDetector(
                              onTap: () async {
                                widget.placeApi.initSession();

                                final Suggestion result = await showSearch(
                                  context: context,
                                  delegate: AddressSearch(),
                                );
                                
                                if (result != null) {
                                  final placeDetails = await widget.placeApi.getPlaceDetailFromId(result.placeId);
                                  widget.controller.params.value.address = Address.fromPlace(placeDetails);
                                  widget.controller.params.value.distance = 1000;
                                  widget.controller.params.refresh();
                                  widget.controller.load();
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.place, color: Colors.grey,),
                                  Expanded(
                                    child: Text('Around...', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20, color: Colors.grey,))
                                  ),
                                ]
                              )
                            );
                          }
                        })
                      ]
                    )
                  )
                ),
                stretchModes: <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                title: null
              ),
            ),
            Obx( () =>
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                    if (idx < widget.controller.items.length)
                      return buildRow(context, idx);
                    else if (idx == widget.controller.items.length) {
                      if (widget.controller.pagination.value.next != null) {
                        widget.controller.more();
                        return Center(child:CircularProgressIndicator());
                      } else {
                        return Container(
                          color: Colors.blueGrey,
                          child: Center(child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('end of results'.toUpperCase(), style: TextStyle(color: Colors.grey, fontSize: 10))
                          ))
                        );
                      }
                    } else {
                      return Container();
                    }
                  },
                  childCount: widget.controller.items.length + 1
                )
              ),
            )
          ],
        )
      );
  }

  Widget buildRow(BuildContext context, int idx) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(routes.job.replaceFirst(':job', widget.controller.items[idx].id.toString()));
      },
      child: Column(
        children: [
          Text('${widget.controller.items[idx].customer.user.username}'),
          Padding(
            padding: EdgeInsets.all(40),
            child: Text('${widget.controller.items[idx].id} ${idx}' +
              (widget.controller.items[idx].title ?? ''))
          ),
          Text('applied: ' + (widget.controller.items[idx].application != null ? 'yes' : 'no')),
          Text('mine: ' + (widget.controller.items[idx].mine ? 'yes' : 'no')),
          Container(color: Colors.grey, height: 3)
        ]
      )
    );
  }
}
