import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedTheme = 'Light';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Load the saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'Light';
    });
  }

  // Save the selected theme preference
  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Preferences',
      theme: _selectedTheme == 'Light' ? ThemeData.light() : ThemeData.dark(),
      home: FirstScreen(
        onThemeChanged: (theme) {
          setState(() {
            _selectedTheme = theme;
          });
          _saveTheme(theme); // Save the theme when changed
        },
      ),
    );
  }
}

class FirstScreen extends StatefulWidget {
  final Function(String) onThemeChanged;

  const FirstScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final _usernameController = TextEditingController();
  String _selectedTheme = 'Light';

  // Function to save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _usernameController.text);
    prefs.setString('theme', _selectedTheme);
  }

  // Function to validate form and save data
  void _handleSavePreferences() {
    if (_usernameController.text.isNotEmpty) {
      _savePreferences().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preferences Saved')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a username')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username:'),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(hintText: 'Enter username'),
            ),
            SizedBox(height: 20),
            Text('Theme:'),
            DropdownButton<String>(
              value: _selectedTheme,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTheme = newValue!;
                });
                widget.onThemeChanged(_selectedTheme); // Notify the parent widget
              },
              items: <String>['Light', 'Dark']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSavePreferences,
              child: Text('Save Preferences'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SecondScreen(),
                  ),
                );
              },
              child: Text('View Preferences'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Toggle theme between Light and Dark
                  _selectedTheme = _selectedTheme == 'Light' ? 'Dark' : 'Light';
                });
                widget.onThemeChanged(_selectedTheme); // Notify parent widget about theme change
              },
              child: Text('Toggle Theme'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  // Function to get saved preferences
  Future<Map<String, String?>> _getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? theme = prefs.getString('theme');
    return {'username': username, 'theme': theme};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Preferences')),
      body: FutureBuilder<Map<String, String?>>(
        future: _getPreferences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading preferences'));
          } else if (snapshot.hasData) {
            var prefs = snapshot.data!;
            String username = prefs['username'] ?? 'No username saved';
            String theme = prefs['theme'] ?? 'No theme selected';
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: $username', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Theme: $theme', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          } else {
            return Center(child: Text('No preferences saved'));
          }
        },
      ),
    );
  }
}
