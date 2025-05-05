import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:bronconest_app/pages/welcome_page.dart';
import 'package:bronconest_app/widgets/image_gradient_overlay.dart';
import 'package:bronconest_app/globals.dart';
import 'package:bronconest_app/styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> schools = [];
  bool isLoading = true;

  String? name;

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _fetchUserInfo();
    _fetchSchools();
    _initializeVideo();
  }

  @override
  void dispose() {
    // save video duration for persistent video
    lastVideoPosition = _controller.value.position;

    _controller.dispose();

    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/home/720p60_cut.mp4');

    await _controller.initialize();

    _controller
      ..setVolume(0)
      ..setLooping(true);

    // resume from last position, pseudo persistent
    await _controller.seekTo(lastVideoPosition);

    await _controller.play();

    // ensure the first frame is shown after the video is initialized
    setState(() {});
  }

  Future<void> _fetchSchools() async {
    try {
      final schoolsSnapshot =
          await FirebaseFirestore.instance.collection('schools').get();
      setState(() {
        schools = schoolsSnapshot.docs.map((doc) => doc.id).toList();
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching schools: $e')));
      }
    }
  }

  Future<void> _fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    String fullName = prefs.getString('userName')!;

    // only get the "first name"
    setState(() => name = fullName.substring(0, fullName.indexOf(' ')));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          ImageGradientOverlay(
            startLocation: Alignment.bottomCenter,
            startColor: Color.fromARGB(150, 0, 0, 0),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Text(
                      'BroncoNest',
                      style: Styles.homePageTitleTextStyle.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Welcome ${name ?? ''}',
                      style: Styles.largeTextStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 38.0, right: 20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.logout, size: 24.0, color: Colors.white),
                  onPressed: () async => _logout(),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: 64.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Start exploring \nyour new home at',
                      style: Styles.largeTextStyle.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 100,
                      child: DropdownButton<String>(
                        value: schools.contains(school) ? school : null,
                        style: Styles.largeTextStyle,
                        dropdownColor: Color.fromARGB(200, 0, 0, 0),
                        borderRadius: BorderRadius.circular(10.0),
                        elevation: 1,
                        isExpanded: true,
                        iconEnabledColor: Colors.white,
                        iconDisabledColor: Colors.white,
                        items:
                            schools.map((String schoolName) {
                              return DropdownMenuItem<String>(
                                value: schoolName,
                                child: Center(
                                  child: Text(
                                    schoolName.toUpperCase(),
                                    style: Styles.largeTextStyle.copyWith(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            school = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Old contents of home page:
          // Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Text('Home Page'),
          //       Text('School: $school'),
          //       Text('User ID: $userId'),
          //       isLoading
          //           ? const CircularProgressIndicator()
          //           : DropdownButton<String>(
          //             value: schools.contains(school) ? school : null,
          //             hint: const Text('Select a school'),
          //             items:
          //                 schools.map((String schoolName) {
          //                   return DropdownMenuItem<String>(
          //                     value: schoolName,
          //                     child: Text(schoolName),
          //                   );
          //                 }).toList(),
          //             onChanged: (String? newValue) {
          //               setState(() {
          //                 school = newValue!;
          //               });
          //             },
          //           ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
