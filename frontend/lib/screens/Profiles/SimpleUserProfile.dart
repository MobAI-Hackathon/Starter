import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }

  static of(BuildContext context) {}
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  void loadProfileData() async {
    // Simulating JSON data loading
    String jsonString = '''
    {
      "name": "MELISSA",
      "victories": 23,
      "loses": 1,
      "winRate": 98,
      "friends": [
        {"name": "Maren Workman", "points": 325, "status": "online", "flag": "🇩🇪"},
        {"name": "Brandon Matrovs", "points": 124, "status": "offline", "flag": "🇵🇭"},
        {"name": "Manuela Lipshutz", "points": 437, "status": "online", "flag": "🇮🇹"}
      ]
    }
    ''';
    setState(() {
      profileData = json.decode(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      body: profileData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          profileData['name'],
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatisticCard("${profileData['victories']} Victories", Icons.emoji_events, Colors.yellow),
                      _buildStatisticCard("${profileData['winRate']}% Win Rate", Icons.bolt, Colors.blue),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text("Friends", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: profileData['friends'].length,
                      itemBuilder: (context, index) {
                        var friend = profileData['friends'][index];
                        return _buildFriendCard(friend);
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticCard(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return Card(
      color: Colors.white10,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(friend['flag'], style: TextStyle(fontSize: 24)),
        ),
        title: Text(friend['name'], style: TextStyle(color: Colors.white)),
        subtitle: Text("${friend['points']} points", style: TextStyle(color: Colors.white70)),
        trailing: Text(
          friend['status'],
          style: TextStyle(color: friend['status'] == "online" ? Colors.green : Colors.grey),
        ),
      ),
    );
  }
}
