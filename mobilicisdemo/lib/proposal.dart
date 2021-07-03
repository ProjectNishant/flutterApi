import 'package:flutter/material.dart';

final List<int> colorCodes = <int>[600, 500, 400, 300, 200, 100];


class Proposals extends StatefulWidget {
  final List props;
  Proposals({Key key, @required this.props}) : super(key: key);

  @override
  _ProposalsState createState() => _ProposalsState();
}

class _ProposalsState extends State<Proposals> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proposals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(

                  children: [
                    ListView.builder(

                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.props.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 50,
                          color: Colors.amber[colorCodes[index]],
                          child: Center(child: Text('${widget.props[index]}')),
                        );
                      },
                      // separatorBuilder: (BuildContext context, int index) =>
                      //     const Divider(),
                    ),
                  ],
                )
            ),
          ),
        ),

    );
  }
}
