import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SQLite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchDataAndSave() async {
    final data = await ApiService.fetchData();
    for (var item in data) {
      await databaseHelper.insertPost({'id': item['id'], 'title': item['title'], 'body': item['body']});
    }
  }

  Future<void> uploadData() async {
    final posts = await databaseHelper.getPosts();
    for (var post in posts) {
      final response = await http.post(
        Uri.parse('https://api.mockfly.dev/mocks/386eeb6f-a7ae-4246-ad90-acd5625d0dad/posts'),
        body: jsonEncode(post),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 201 && response.statusCode != 200) { // 201 Created or 200 OK
        print('Failed to upload data: ${response.statusCode} ${response.body}');
        throw Exception('Failed to upload data');
      } else {
        print('Data uploaded successfully: ${response.body}');
      }
    }
  }

  Future<void> fetchPosts() async {
    List<Map<String, dynamic>> fetchedPosts = await databaseHelper.getPosts();
    setState(() {
      posts = fetchedPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Fetching and Upload using APIs'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: fetchDataAndSave,
              child: Text('Fetch and Save Data'),
            ),
            ElevatedButton(
              onPressed: uploadData,
              child: Text('Upload Data'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayDataPage(posts: posts),
                  ),
                );
              },
              child: Text('Display Stored Data'),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiService {
  static Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('https://api.mockfly.dev/mocks/386eeb6f-a7ae-4246-ad90-acd5625d0dad/posts'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class DisplayDataPage extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  const DisplayDataPage({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stored Data'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(posts[index]['title']),
            subtitle: Text(posts[index]['body']),
          );
        },
      ),
    );
  }
}
