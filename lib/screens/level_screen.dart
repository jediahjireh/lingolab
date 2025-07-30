import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingolab/auth_screen/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  // theme colours
  static const Color darkBlueBackground = Color(0xFF1A1B3A);
  static const Color redPrimary = Color(0xFFE53E3E);
  static const Color paleYellow = Color(0xFFFFF9C4);
  static const Color cardColor = Color(0xFF2D2E4F);
  static const Color levelUnlockedColor = Color(0xFFFF6B6B);
  static const Color levelLockedColor = Color(0xFF4A4B6E);

  int _currentIndex = 0;

  // available languages to learn
  final List<String> _languages = [
    'German',
    'Spanish',
    'French',
    'Tamil',
    'Japanese',
    'Afrikaans',
    'Italian',
    'Korean',
  ];

  /// shows language selection dialog and updates user's preferred language
  Future<void> _changeLanguage() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    String? selectedLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            "Select Language",
            style: TextStyle(color: paleYellow),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((lang) {
              return ListTile(
                title: Text(lang, style: const TextStyle(color: paleYellow)),
                onTap: () {
                  Navigator.pop(context, lang);
                },
                hoverColor: redPrimary.withOpacity(0.1),
              );
            }).toList(),
          ),
        );
      },
    );

    // update language in firestore if user selected one and widget is still mounted
    if (selectedLanguage != null && mounted) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'language': selectedLanguage},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Language changed to $selectedLanguage"),
              backgroundColor: redPrimary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to update language"),
              backgroundColor: redPrimary,
            ),
          );
        }
      }
    }
  }

  /// handle user logout and navigation to sign in screen
  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to sign out"),
            backgroundColor: redPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // query to get user's levels ordered by level number
    final levelsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('levels')
        .orderBy('levelNumber');

    return Scaffold(
      backgroundColor: darkBlueBackground,
      body: SafeArea(
        child: Column(
          children: [
            // header with app title and settings menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    "LingoLab",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.bold,
                      color: paleYellow,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.settings,
                      color: paleYellow,
                      size: 28,
                    ),
                    color: cardColor,
                    onSelected: (value) async {
                      if (value == 'language') {
                        await _changeLanguage();
                      } else if (value == 'logout') {
                        await _handleLogout();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'language',
                        child: ListTile(
                          leading: Icon(Icons.language, color: paleYellow),
                          title: Text(
                            "Change Language",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: ListTile(
                          leading: Icon(Icons.logout, color: redPrimary),
                          title: Text(
                            "Log out",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // user profile card with streak and current language
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: redPrimary),
                  );
                }

                final userData = snapshot.data!;
                final email = userData['email'] ?? 'User';
                // extract username from email
                final name = email.split('@')[0];
                final streak = userData['streak'] ?? 0;
                final language = userData['language'] ?? 'German';

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // user avatar
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: darkBlueBackground,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: paleYellow,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // user info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, $name!",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: paleYellow,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Learning: $language",
                              style: TextStyle(
                                fontSize: 16,
                                color: paleYellow.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // streak counter
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [redPrimary, Color(0xFFFF8A80)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "🔥 $streak",
                              style: const TextStyle(
                                color: paleYellow,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "days",
                              style: TextStyle(color: paleYellow, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // snake path levels display
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: levelsQuery.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: redPrimary),
                      );
                    }

                    final levels = snapshot.data!.docs;

                    return SingleChildScrollView(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: levels.asMap().entries.map((entry) {
                          final index = entry.key;
                          final doc = entry.value;

                          final levelNumber = doc['levelNumber'] ?? index + 1;
                          final title = doc['title'] ?? 'Level';
                          final bool isUnlocked =
                              doc['isUnlocked'] ?? (levelNumber == 1);
                          final bool isLeft = index % 2 == 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Row(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: isLeft
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              children: [
                                if (!isLeft)
                                  Transform.translate(
                                    offset: const Offset(40, 40),
                                    // NOTE: bigger x and y values nudge more right and lower
                                    child: Lottie.asset(
                                      'assets/animation/panda-walk.json',
                                      height: 140,
                                      width: 140,
                                    ),
                                  ),

                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: isUnlocked
                                          ? () {
                                              /*  TODO: navigate user to screen one
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ScreenOne(
                                                      levelNumber: levelNumber,
                                                    ),
                                                  ),
                                                );
                                                */

                                              print(
                                                "YOU will be redirected to screen one",
                                              );
                                            }
                                          : null,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: EdgeInsets.zero,
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: isUnlocked
                                                ? [
                                                    levelUnlockedColor,
                                                    redPrimary,
                                                  ]
                                                : [levelLockedColor, cardColor],
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isUnlocked
                                                    ? Icons.star
                                                    : Icons.lock,
                                                color: paleYellow,
                                                size: 28,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '$levelNumber',
                                                style: const TextStyle(
                                                  color: paleYellow,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: paleYellow,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isLeft)
                                  Transform.translate(
                                    offset: Offset(-20, 60),
                                    // NOTE: bigger x and y values nudge more right and lower
                                    child: Lottie.asset(
                                      'assets/animation/panda-roll.json',
                                      height: 140,
                                      width: 140,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),

            // bottom navigation bar
            BottomNavigationBar(
              backgroundColor: cardColor,
              currentIndex: _currentIndex,
              selectedItemColor: redPrimary,
              unselectedItemColor: paleYellow.withOpacity(0.6),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                if (index == 1) {
                  print("You will be redirected to the leaderboard screen");

                  /* TODO: navigate to leaderboard screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            );
            */
                } else if (index == 2) {
                  print("You will be redirected to the profile screen");

                  /* TODO: navigate to profile screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
             */
                }
              },
              // navigation tabs
              items: [
                // home tab
                BottomNavigationBarItem(
                  icon: _currentIndex == 0
                      ?
                        // selected state icon
                        Image.asset(
                          'assets/images/home-selected.png',
                          width: 24,
                          height: 24,
                        )
                      : Image.asset(
                          'assets/images/home.png',
                          width: 24,
                          height: 24,
                        ),
                  label: "Home",
                ),

                // leaderboard tab
                BottomNavigationBarItem(
                  icon: _currentIndex == 1
                      ?
                        // selected state icon
                        Image.asset(
                          'assets/images/rank-selected.png',
                          width: 24,
                          height: 24,
                        )
                      : Image.asset(
                          'assets/images/rank.png',
                          width: 24,
                          height: 24,
                        ),
                  label: "Leaderboard",
                ),

                // profile tab
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/avatars/avatar.png',
                    width: 24,
                    height: 24,
                  ),
                  label: "Profile",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
