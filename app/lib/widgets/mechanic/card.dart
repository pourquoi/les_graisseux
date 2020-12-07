import 'package:app/models/mechanic.dart';
import 'package:flutter/material.dart';

class MechanicCard extends StatelessWidget {
  final Mechanic mechanic;
  final Function onTap;
  const MechanicCard({Key key, this.mechanic, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
          child: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.end,
              //mainAxisSize: MainAxisSize.max,
              children: [
                ( 
                  mechanic.user.avatar != null && mechanic.user.avatar.thumbUrl != null ? 
                  Ink.image(
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    image: NetworkImage(mechanic.user.avatar.thumbUrl)
                  ) :
                  Icon(Icons.person, size: 72)
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Text((mechanic.user.username ?? '-'), style: TextStyle(fontSize: 20))
                    ),
                    (
                      mechanic.user.address != null ?
                        Padding(
                          padding: EdgeInsets.only(left: 24.0),
                          child: Text(mechanic.user.address.locality)
                        ) : SizedBox.shrink()
                    )
                  ]
                )
              ]
            )
          ]
        ))
      )
    );
  }
}