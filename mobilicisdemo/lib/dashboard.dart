import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:mobilicisdemo/proposal.dart';

import 'camera.dart';
import 'constants.dart';

List<CameraDescription> cameras = [];

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Map<String, dynamic> _apiData = <String, dynamic>{};

  TextEditingController _make = TextEditingController();
  TextEditingController _model = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
      print('dataDevMake:  ' + deviceData['manufacturer'].toString());
      print('dataDevModel:  ' + deviceData['model'].toString());
    });
    print(_deviceData.toString());
  }

  void _deviceManuallyAPI() async {
    final response = await http.post(
      Uri.parse('https://ssdqa.mobilicis.com/smartrouting/api/v1/getProposals'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader:
            "${Constants.tokenType} ${Constants.accessToken}"
      },
      body: jsonEncode(<String, String>{
        'make': _make.text.toString(),
        'model': _model.text.toString(),
      }),
    );

    // print('devAPI :  ' + json.decode(response.body).toString());

    if (response.statusCode == 200) {
      setState(() {
        _apiData = json.decode(response.body);
        var items = [];
        for (var i in _apiData['data']['srtRecommendedProposals']) {
          items.add(i['proposalType']);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return Proposals(props: items);
            },
          ),
        );

      });
    } else {
      throw Exception('Failed to load api');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    try {
                      WidgetsFlutterBinding.ensureInitialized();
                      cameras = await availableCameras();
                    } on CameraException catch (e) {
                      print(e.code + ' ' + e.description);
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return CameraExampleHome();
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.shade200,
                              offset: Offset(2, 4),
                              blurRadius: 5,
                              spreadRadius: 2)
                        ],
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.lightBlueAccent,
                              Colors.blueAccent
                            ])),
                    child: Text(
                      'Camera',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),

                //TODO: Manually Data API
                Text('Type Make & Model Manually'),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    // style: textStyle,
                    controller: _make,
                    decoration: InputDecoration(
                        labelText: 'Make',
                        hintText: 'Company',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    // style: textStyle,
                    controller: _model,
                    decoration: InputDecoration(
                        labelText: 'Model',
                        hintText: 'Model Number',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                InkWell(
                  onTap: _deviceManuallyAPI,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.shade200,
                              offset: Offset(2, 4),
                              blurRadius: 5,
                              spreadRadius: 2)
                        ],
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.lightBlueAccent,
                              Colors.blueAccent
                            ])),
                    child: Text(
                      'Proposals',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),

                SizedBox(
                  height: 30,
                ),

                Text('Current device details: '),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Make : '+_deviceData['manufacturer'].toString()+
                    '\nModel : '+ _deviceData['model'].toString()),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
