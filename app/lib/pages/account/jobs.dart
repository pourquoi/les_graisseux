import 'package:app/controllers/jobs.dart';
import 'package:app/controllers/user.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:app/routes.dart' as routes;

class _AccountJobsController extends JobsController {}

class AccountJobsPage extends StatefulWidget
{
  final _AccountJobsController controller = Get.put(_AccountJobsController());
  final UserController userController = Get.find();

  _AccountJobsPageState createState() => _AccountJobsPageState();
}

class _AccountJobsPageState extends State<AccountJobsPage> {

  void initState() {
    super.initState();
    widget.controller.params.value.user = widget.userController.user.value.id;
    widget.controller.load();
  }

  Widget build(BuildContext context) {
      return Scaffold(
        floatingActionButton: IconButton(icon: Icon(Icons.add), onPressed: () {
          Get.toNamed(routes.onboarding, arguments: {'type': ProfileType.Customer});
        }),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text('My jobs'),
              floating: true,
              snap: false,
              actions: <Widget>[
              ],
              pinned: true,
              expandedHeight: 100.0,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Get.bottomSheet(
                                Container(
                                  child: Column(
                                    children: [
                                      RadioListTile(
                                        title: Text('Hot'),
                                        value: 'hot', 
                                        groupValue: widget.controller.params.value.sort, 
                                        onChanged: (_) {
                                          widget.controller.params.value.sort = 'hot';
                                          widget.controller.params.refresh();
                                          widget.controller.load();
                                          Get.back();
                                        }
                                      ),
                                      RadioListTile(
                                        title: Text('New'),
                                        value: 'new', 
                                        groupValue: widget.controller.params.value.sort, 
                                        onChanged: (_) {
                                          widget.controller.params.value.sort = 'new';
                                          widget.controller.params.refresh();
                                          widget.controller.load();
                                          Get.back();
                                        }
                                      ),
                                      RadioListTile(
                                        title: Text('Distance'),
                                        value: 'distance', 
                                        groupValue: widget.controller.params.value.sort, 
                                        onChanged: (_) {
                                          widget.controller.params.value.sort = 'distance';
                                          widget.controller.params.refresh();
                                          widget.controller.load();
                                          Get.back();
                                        }
                                      )
                                    ],
                                  )
                                )
                              );
                            },
                            child: Row(
                              children: [
                                Obx(() => widget.controller.params.value.sort != null ?
                                  Text(widget.controller.params.value.sort.tr) : 
                                  Text('Sort by')
                                ),
                                Icon(FontAwesomeIcons.caretDown)
                              ],
                            )
                          )
                        ]
                      )
                    ]
                  )
                ),
                stretchModes: <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ]
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
                            return CircularProgressIndicator();
                          } else {
                            return Text('1');
                          }
                        } else {
                          return Text('2');
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
        Get.toNamed(routes.account_job.replaceFirst(':job', widget.controller.items[idx].id.toString()));
      },
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text('${widget.controller.items[idx].id} ${idx}' +
          (widget.controller.items[idx].title ?? '')))
    );
  }
}
