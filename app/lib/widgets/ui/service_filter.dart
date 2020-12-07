import 'package:app/models/service_tree.dart';
import 'package:app/widgets/popup/service_picker.dart';
import 'package:app/widgets/ui/filter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServiceFilter extends StatefulWidget {
  final Function onChange;
  final List<ServiceTree> initialSelection;

  ServiceFilter({Key key, @required this.onChange, this.initialSelection}) : super(key: key);

  @override
  _ServiceFilterState createState() => _ServiceFilterState();
}

class _ServiceFilterState extends State<ServiceFilter> {
  List<ServiceTree> _services = [];

  void initState() {
    super.initState();
    if (widget.initialSelection != null) _services = widget.initialSelection;
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
              _services.length > 0 ?
              _services.map((ServiceTree service) {
                return Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Wrap(
                    children: [
                      Chip(
                        label: Text(service.label, overflow: TextOverflow.ellipsis),
                        onDeleted: () {
                          _services.remove(service);
                          widget.onChange(_services);
                        }
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
      title: 'Services',
      icon: FontAwesomeIcons.toolbox,
      child: child,
      multiple: true,
      empty: _services.length == 0,
      onAdd: () async {
        ServiceTree service = await showSearch(
          context: context,
          delegate: ServiceSearch(),
        );
        if (service != null && _services.firstWhere((element) => service.id == element.id, orElse: () => null) == null) {
          setState(() {_services.add(service);});
          widget.onChange(_services);
        }
      },
      onReset: () {
        setState(() {_services = [];});
        widget.onChange(_services);
      },
    );
  }
}