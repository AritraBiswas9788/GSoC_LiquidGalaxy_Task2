import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:lg_connection/utils/helper.dart';

import '../utils/kml_makers.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  late SSHClient? _client;

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();
    print('reached here');

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));
      _client = SSHClient(socket, username: _username, onPasswordRequest: () {
        return _passwordOrKey;
      });
      print("IP: $_host , port: $_port");
      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }

  }
  int sendRigs()
  {
    return int.parse(_numberOfRigs);
  }

  Future<SSHSession?> execute() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      return await _client!.execute('echo "search=Mountain View" > /tmp/query.txt');
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }
  resetRefresh(context) async {
    try {
      if(_client==null)
        return;
      for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
        String search =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
        String replace = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        await _client?.run(
            'sshpass -p ${_passwordOrKey} ssh -t lg$i \'echo ${_passwordOrKey} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
    } catch (error) {
      showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
    }
  }
  rebootLG(context) async {

      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
    try {
      for (var i = int.parse(_numberOfRigs); i >=1 ; i--) {
        await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"'
        );
      }
    } catch (error) {
      showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
      return null;
    }
  }

  flyTo(context, double latitude, double longitude, double zoom, double tilt,
      double bearing) async {
    if (_client == null) {
      print('SSH client is not initialized.');
      return null;
    }
    try {
      await _client!.execute(
          'echo "flytoview=${KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
    } catch (error) {
      try {
        // await connectionRetry(context);
        //await flyTo(context, latitude, longitude, zoom, tilt, bearing);
        print(error.toString());
      } catch (e) {}
    }
  }
  flyToOrbit(context, double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    if (_client == null) {
      print('SSH client is not initialized.');
      return null;
    }
    try {
      print('hey');
      var j = 0;
      for (int i = 0; i <= 360; i += 34) {
        if (j == 360) {
          j = 0;
        }
        await _client!.run(
            'echo "flytoview=${KMLMakers.orbitLookAtLinear(
                latitude, longitude, zoom, double.parse(j.toString()), double.parse(i.toString()))}" > /tmp/query.txt');
        j+=5;
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      final uptime = await _client!.run('uptime');
      print(utf8.decode(uptime));
    } catch (error) {
      //await connectionRetry(context);
      await flyToOrbit(context, latitude, longitude, zoom, tilt, bearing);
    }
  }
  setRefresh(context) async {
    try {
      for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
        if(_client==null) {
          return;
        }
        String search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        String replace =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await _client!.run(
            'sshpass -p ${_passwordOrKey} ssh -t lg$i \'echo ${_passwordOrKey} | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml\'');
        await _client!.run(
            'sshpass -p ${_passwordOrKey} ssh -t lg$i \'echo ${_passwordOrKey} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      print("Refresh set");
      }
    } catch (error) {
      showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
      print("Refresh error");
    }
  }
  Future<void> renderInSlave(context, int slaveNo, String kml) async {
    try {
      if(_client==null) {
        return;
      }
      await _client!.run("echo '$kml' > /var/www/html/kml/slave_$slaveNo.kml");
      print("balloon sent");
      await setRefresh(context);
      print("refresh sent");

      return;
    } catch (error) {
      showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
      print("render error");
      return;
    }
  }
  Future<void> panToCity(String city) async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return;
      }
      await _client!.execute('echo "search=$city" > /tmp/query.txt');
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return;
    }
  }
  startOrbit(context) async {
    try {
      await _client!.run('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (error) {
      //await SSH(ref: ref).connectionRetry(context);
      //await startOrbit(context);
      print("failed: ${error.toString()}");
    }
  }
  makeFile(String filename, String content) async {
    var localPath = await getApplicationDocumentsDirectory();
    File localFile = File('${localPath.path}/filename.kml');
    await localFile.writeAsString(content);
    return localFile;
  }
  kmlFileUpload(context, File inputFile, String kmlName) async {
    try {
      if(_client==null)
        return;
      bool uploading = true;
      final sftp = await _client!.sftp();
      final file = await sftp.open('/var/www/html/$kmlName.kml',
          mode: SftpFileOpenMode.create |
          SftpFileOpenMode.truncate |
          SftpFileOpenMode.write);
      var fileSize = await inputFile.length();
      file.write(inputFile.openRead().cast(), onProgress: (progress) {
        print(progress/fileSize);
        if (fileSize == progress) {
          uploading = false;
        }
      });
      if (file == null) {
        return;
      }
      await waitWhile(() => uploading);
      //ref.read(loadingPercentageProvider.notifier).state = null;
    } catch (error) {
      showSnackBar(
          context: context, message: error.toString(), color: Colors.red);
    }
  }
  runKml(context, String kmlName) async {
    try {
      if(_client==null)
        return;
      print('running kml');
      await _client!.run('echo "\nhttp://lg1:81/$kmlName.kml" > /var/www/html/kmls.txt');
    } catch (error) {

      print('Error occurred while running');
    }
  }
}
