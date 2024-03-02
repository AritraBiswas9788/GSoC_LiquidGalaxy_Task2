import 'package:flutter/material.dart';
import 'package:lg_connection/components/connection_flag.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lg_connection/connections/ssh.dart';
import 'package:dartssh2/dartssh2.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool connectionStatus = false;
  late SSH ssh;

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _loadSettings();
    _connectToLG();
  }

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _sshPortController.dispose();
    _rigsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _sshPortController.text = prefs.getString('sshPort') ?? '';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', _ipController.text);
    }
    if (_usernameController.text.isNotEmpty) {
      await prefs.setString('username', _usernameController.text);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    if (_sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', _sshPortController.text);
    }
    if (_rigsController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', _rigsController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, connectionStatus);
        return true;
      },
      child: Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: Scaffold(
          backgroundColor: Colors.deepPurple.shade300,
          appBar: AppBar(
            title: const Text('Connection Settings'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(3.0, 16.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ConnectionFlag(
                          status: connectionStatus, backgroundColor: Colors.white54,
                        ),
                      ],
                    )
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _ipController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.computer),
                      labelText: 'IP address',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIconColor: Colors.white,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      enabledBorder:OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      hintText: 'Enter Master IP',

                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'LG Username',
                      hintText: 'Enter your username',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIconColor: Colors.white,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      enabledBorder:OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'LG Password',
                      hintText: 'Enter your password',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIconColor: Colors.white,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      enabledBorder:OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: TextField(
                    controller: _sshPortController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.settings_ethernet),
                      labelText: 'SSH Port',
                      hintText: '22',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIconColor: Colors.white,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      enabledBorder:OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: TextField(
                    controller: _rigsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.memory),
                      labelText: 'No. of LG rigs',
                      hintText: 'Enter the number of rigs',
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIconColor: Colors.white,
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      enabledBorder:OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.green),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    await _saveSettings();
                    SSH ssh = SSH();
                    bool? result = await ssh.connectToLG();
                    if (result == true) {
                      setState(() {
                        connectionStatus = true;
                      });
                      print('Connected to LG successfully');
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cast,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'CONNECT TO LG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
