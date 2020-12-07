import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchFiltersHeader extends StatelessWidget {
  final String title;
  final int total;

  const SearchFiltersHeader({Key key, @required this.title, @required this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text(title, style: TextStyle(fontSize: 24),)
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 30),
          child: Row(
            children: [
              Container(width: 10, height: 1, color: Colors.grey),
              Text('$total results', style: TextStyle(fontSize: 16)),
              Expanded(child: Container(height: 1, color: Colors.grey))
            ]
          )
        ),
        Row(
          children: [Padding(
            padding: EdgeInsets.only(bottom: 20, left: 10),
            child: Text('Filter by :'.toUpperCase(), style: TextStyle(fontSize: 12))
          )]
        )
      ],
    ));
  }
}

class SearchFilter extends StatelessWidget {
  final Widget child;
  final String title;
  final IconData icon;
  final Function onAdd;
  final Function onReset;
  final bool empty;
  final bool multiple;

  const SearchFilter({Key key, @required this.child, this.icon, this.multiple = false, this.empty = false, this.title, this.onAdd, this.onReset}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    IconData _icon = icon ?? FontAwesomeIcons.ellipsisH;
    if (multiple && !empty) {
      //_icon = FontAwesomeIcons.plus;
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (title != null ? 
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: this.onAdd,
                    child: 
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Ink(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            color: Colors.amberAccent,
                            shape: BoxShape.circle,
                          ), 
                          child: SizedBox(
                            height: 35,
                            width: 35,
                            child: IconButton(
                              iconSize: 20,
                              padding: EdgeInsets.all(5),
                              icon: Icon(_icon, color: Colors.black),
                              onPressed: this.onAdd,
                            )
                          )
                        ),
                        Container(color: Colors.grey, height: 1, width: 40,),
                        SizedBox(width: 5),
                        Text(
                          title.toUpperCase(), 
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                        ),
                        SizedBox(width: 5),
                        Expanded(child: Container(color: Colors.grey, height: 1,)),
                      ]
                    )
                  )
                ),
                !empty ?
                Ink(
                  decoration: BoxDecoration(
                    //border: Border.all(color: Colors.grey, width: 1.0),
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ), 
                  child: SizedBox(
                    height: 35,
                    width: 35,
                    child: IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.all(5),
                    icon: Icon(FontAwesomeIcons.times, color: Colors.grey),
                    onPressed: this.onReset,
                  ))
                ) : SizedBox.shrink()
              ]
            )
          )
          : SizedBox.shrink()),
          this.child,
          SizedBox(height: 20,)
        ],
      )
    );
  }
}