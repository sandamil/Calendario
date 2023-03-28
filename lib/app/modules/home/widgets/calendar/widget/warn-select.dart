import 'package:flutter/material.dart';


typedef SetWarnCallback = Function(String warn);
typedef SetNoWarn = Function(bool value);
typedef SelectWarnList = Function(int item, bool value);

class WarnView extends StatefulWidget {
  final SetWarnCallback setWarnCallback;
  final SetNoWarn setNoWarnCallback;
  final SelectWarnList selectWarnListCallback;
  final bool noWarn;
  final List initWarnList;
  WarnView(this.noWarn, this.initWarnList, this.setNoWarnCallback,
      this.selectWarnListCallback, this.setWarnCallback);

  @override
  State<StatefulWidget> createState() {
    return WarnViewState();
  }
}

class WarnViewState extends State<WarnView> {
  late List _warnList;
  late bool _warn;
  @override
  void initState() {
    super.initState();
    setState(() {
      _warn = widget.noWarn;
      _warnList = widget.initWarnList;
    });
  }

  Widget _buildLineBetween() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Center(
        child: Container(
          width: 320, //max-width is 240
          height: 1,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildNoWarnList(BuildContext context) {
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _warnList.length,
        itemBuilder: (context, item) {
          return CheckboxListTile(
            title: Text(
              _warnList[item]['name'],
              style: TextStyle(color: Colors.black26),
            ),
            value: false, onChanged: (bool? value) {  },

          );
        });
  }

  Widget _buildSelectWarnList(BuildContext context) {
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _warnList.length,
        itemBuilder: (context, item) {
          return CheckboxListTile(
            title: Text(_warnList[item]['name']),
            value: _warnList[item]['select'],
            onChanged: (bool? value) {
              widget.selectWarnListCallback(item, value!);
              setState(() {
                _warnList[item]['select'] = value;
              });
              List _selectWarnList = [];
              _warnList.forEach((e) {
                if (e['select']) {
                  _selectWarnList.add(e);
                }
              });
              _warnShowString(_selectWarnList);
            },
          );
        });
  }

  void _warnShowString(List list) {
    switch (list.length) {
      case 0:
        widget.setWarnCallback('Sin recordatorio');
        widget.setNoWarnCallback(true);
        break;
      case 1:
        widget.setWarnCallback(list[0]['name']);
        break;
      case 2:
        widget.setWarnCallback('${list[1]['name']},${list[0]['name']}');
        break;
      default:
        widget.setWarnCallback(
            '${list.last['name']},${list[list.length - 2]['name']},...');
    }
  }

  Widget _isWarn() {
    return SwitchListTile(
      title: const Text('No recordar'),
      value: _warn,
      onChanged: (bool value) {
        setState(() {
          _warn = value;
        });
        if (value) {
          widget.setWarnCallback('Sin recordatorio');
          widget.setNoWarnCallback(true);
        } else {
          setState(() {
            _warnList.forEach((e) {
              e['select'] = false;
            });
            _warnList[0]['select'] = true;
          });
          widget.setWarnCallback('Al principio');
          widget.selectWarnListCallback(0, true);
          widget.setNoWarnCallback(false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0, // for elevation
          title: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
//          margin: EdgeInsets.only(top: 8, bottom: 32, left: 10),
            child: Text(
              'Editar Nota',

              style: TextStyle(

                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Theme.of(context).primaryColor),
              overflow: TextOverflow.clip,
              softWrap: false,
            ),
          ),
          leading: IconButton(
              icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
              iconSize: 28,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: ListView(
          children: <Widget>[
            _isWarn(),
            _buildLineBetween(),
            _warn ? _buildNoWarnList(context) : _buildSelectWarnList(context)
          ],
        ));
  }
}
