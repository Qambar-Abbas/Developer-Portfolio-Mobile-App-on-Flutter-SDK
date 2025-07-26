import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Developer Profile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: DeveloperProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DeveloperProfilePage extends StatefulWidget {
  DeveloperProfilePage({super.key});

  @override
  _DeveloperProfilePageState createState() => _DeveloperProfilePageState();
}

class _DeveloperProfilePageState extends State<DeveloperProfilePage>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _headerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();
  late final AnimationController _contentController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();
  late final AnimationController _floatingController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  late final Animation<double> _headerAnimation = CurvedAnimation(
    parent: _headerController,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _contentAnimation = CurvedAnimation(
    parent: _contentController,
    curve: Curves.easeOutQuart,
  );
  late final Animation<double> _floatingAnimation = CurvedAnimation(
    parent: _floatingController,
    curve: Curves.easeInOut,
  );

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  String _appVersion = '';
  bool _isEditing = false;
  final String _password = 'qambar';

  // Profile data stored in JSON format
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadAppVersion();
    _initializeProfileData();
    _loadSavedData();
  }

  void _scrollListener() {
    final collapsed = _scrollController.offset > 200;
    if (collapsed != _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = collapsed);
    }
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'Version ${info.version}';
    });
  }

  void _initializeProfileData() {
    _profileData = {
      'name': 'Qambar Abbas',
      'role': 'Senior Flutter Developer',
      'location': 'New Delhi, India',
      'image': 'https://avatars.githubusercontent.com/u/168618726?v=4',
      'about': 'Passionate Flutter developer with 5+ years of experience creating beautiful, performant mobile applications.',
      'tags': ['Mobile Development', 'UI/UX Design', 'Team Leadership', 'Agile Methodology'],
      'skills': [
        {'name': 'Flutter', 'level': 0.95},
        {'name': 'Dart', 'level': 0.90},
        {'name': 'Firebase', 'level': 0.85},
        {'name': 'React Native', 'level': 0.75},
        {'name': 'Node.js', 'level': 0.80},
        {'name': 'Python', 'level': 0.70},
      ],
      'experience': [
        {
          'title': 'Mobile App Developer',
          'company': 'DefineDigitals Pvt Ltd',
          'period': '2025 - Current',
          'description': 'Developed and maintained cross-platform mobile applications using Flutter and React Native.'
        },
        {
          'title': 'Frontend Intern',
          'company': 'Draconic Technology Pvt Ltd',
          'period': '2023 - 2024',
          'description': 'Started career building responsive web applications and learning mobile development.'
        }
      ],
      'projects': [
        {
          'name': 'Nuevadesk CRM',
          'description': 'CRM for managing customer relationships',
          'tech': ['Flutter', 'REST', 'Insta360']
        },
        {
          'name': 'Eat-It',
          'description': 'Food suggestion with voting and family sharing',
          'tech': ['Flutter', 'Dart', 'Firebase']
        },
        {
          'name': 'MediCare Pro',
          'description': 'Healthcare management system for doctors',
          'tech': ['Flutter', 'Python', 'AWS']
        }
      ],
      'education': [
        {
          'degree': 'Bachelor of Computer Applications',
          'institution': 'Noida International University',
          'period': '2022 - 2025',
          'details': ''
        },
        {
          'degree': 'Flutter Development Certification',
          'institution': 'Google Developers',
          'period': '2023',
          'details': 'Advanced Flutter concepts and best practices'
        }
      ],
      'contact': [
        {'type': 'Email', 'value': 'qambarofficial313@gmail.com'},
        {'type': 'Phone', 'value': '8510842558'},
        {'type': 'Website', 'value': 'Qambar-Abbas.github.io'},
        {'type': 'Github', 'value': 'github.com/Qambar-Abbas'}
      ],
      'footer': {
        'mainText': "Let's Build Something Amazing Together",
        'copyright': '© 2024 Qambar Abbas. All rights reserved.'
      }
    };
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('profileData');

    if (jsonData != null) {
      setState(() {
        _profileData = jsonDecode(jsonData);
      });
    }
  }

  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileData', jsonEncode(_profileData));
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _promptPassword() async {
    String? input;
    await showDialog(
      context: context,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF0A0E27),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.blue.withOpacity(0.5), width: 1),
            ),
          ),
        ),
        child: AlertDialog(
          title: const Text(
            'Enter Password',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                autofocus: true,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => input = v,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '🔒 Hint: If you don\'t know the password, check the app description on Google Play Store.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                if (input == _password) {
                  setState(() => _isEditing = true);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wrong password')),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    setState(() => _isEditing = false);
    _saveAllData(); // Save to local storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editSimpleField(
      String fieldKey,
      String title,
      bool isMultiline,
      ) async {
    String? value = _profileData[fieldKey];
    TextEditingController controller = TextEditingController(text: value);

    await showDialog(
      context: context,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF0A0E27),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.blue.withOpacity(0.5), width: 1),
            ),
          ),
        ),
        child: AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: isMultiline ? null : 1,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter $title',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                setState(() => _profileData[fieldKey] = controller.text);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editJsonField(
      String sectionKey,
      String title,
      ) async {
    String jsonText = jsonEncode(_profileData[sectionKey]);
    bool hasError = false;

    await showDialog(
      context: context,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF0A0E27),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.blue.withOpacity(0.5), width: 1),
            ),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $title', style: const TextStyle(color: Colors.white)),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: jsonText),
                        maxLines: null,
                        style: TextStyle(
                            color: hasError ? Colors.red : Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 14
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Edit JSON data...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) => jsonText = value,
                      ),
                    ),
                    if (hasError)
                      Text(
                        'Invalid JSON format!',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tip: Use proper JSON syntax. Maintain the structure.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    try {
                      final parsed = jsonDecode(jsonText);
                      setState(() {
                        _profileData[sectionKey] = parsed;
                        hasError = false;
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() => hasError = true);
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _headerAnimation,
                builder: (_, __) => Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                            Color(0xFF6B73FF),
                          ],
                        ),
                      ),
                    ),
                    ...List.generate(20, (i) {
                      return AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (_, __) => Positioned(
                          left: (i * 37) % MediaQuery.of(context).size.width,
                          top:
                          50 +
                              (i * 23) % 300 +
                              20 * _floatingAnimation.value,
                          child: Container(
                            width: 4 + (i % 3) * 2,
                            height: 4 + (i % 3) * 2,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                    Center(
                      child: Transform.scale(
                        scale: _headerAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _isEditing
                                  ? _editSimpleField('image', 'Image URL', false)
                                  : null,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                    _profileData['image'],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _isEditing
                                  ? () => _editSimpleField('name', 'Name', false)
                                  : null,
                              child: Text(
                                _profileData['name'],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _isEditing
                                  ? () => _editSimpleField('role', 'Role', false)
                                  : null,
                              child: Text(
                                _profileData['role'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _isEditing
                                      ? () => _editSimpleField('location', 'Location', false)
                                      : null,
                                  child: Text(
                                    _profileData['location'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _contentAnimation,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, 50 * (1 - _contentAnimation.value)),
                child: Opacity(
                  opacity: _contentAnimation.value,
                  child: Column(
                    children: [
                      _buildAboutSection(),
                      _buildSkillsSection(),
                      _buildExperienceSection(),
                      _buildProjectsSection(),
                      _buildEducationSection(),
                      _buildContactSection(),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  Widget _buildAboutSection() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: _glassmorphismDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('About Me', Icons.person),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isEditing
                    ? () => _editSimpleField('about', 'About Me', true)
                    : null,
                child: Text(
                  _profileData['about'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: (_profileData['tags'] as List).map(
                      (tag) => GestureDetector(
                    onTap: _isEditing ? () => _editJsonField('tags', 'Tags') : null,
                    child: _buildTag(tag),
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        ),
        if (_isEditing)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              onPressed: () => _editSimpleField('about', 'About Me', true),
            ),
          ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(24),
          decoration: _glassmorphismDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Skills & Expertise', Icons.code),
              const SizedBox(height: 20),
              ...(_profileData['skills'] as List).asMap().entries.map(
                    (entry) => _buildSkillBar(
                  entry.value['name'],
                  entry.value['level'],
                  _getColorForIndex(entry.key),
                ),
              ),
            ],
          ),
        ),
        if (_isEditing)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              onPressed: () => _editJsonField('skills', 'Skills & Expertise'),
            ),
          ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.cyan,
      Colors.green,
      Colors.yellow,
    ];
    return colors[index % colors.length];
  }

  Widget _buildSkillBar(String skill, double level, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(level * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: level,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(24),
          decoration: _glassmorphismDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Experience', Icons.timeline),
              const SizedBox(height: 20),
              ...(_profileData['experience'] as List).map((exp) => _buildExperienceCard(exp)).toList(),
            ],
          ),
        ),
        if (_isEditing)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              onPressed: () => _editJsonField('experience', 'Experience'),
            ),
          ),
      ],
    );
  }

  IconData _getIconForExperience(String title) {
    if (title.contains('Intern')) return Icons.school;
    if (title.contains('Developer')) return Icons.code;
    return Icons.work;
  }

  Widget _buildExperienceCard(Map<String, dynamic> exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIconForExperience(exp['title']), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exp['company'],
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exp['period'],
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  exp['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(24),
          decoration: _glassmorphismDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Featured Projects', Icons.folder),
              const SizedBox(height: 20),
              ...(_profileData['projects'] as List).asMap().entries.map(
                    (entry) => _buildProjectCard(entry.value, entry.key),
              ),
            ],
          ),
        ),
        if (_isEditing)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              onPressed: () => _editJsonField('projects', 'Projects'),
            ),
          ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    Color color = _getColorForIndex(index);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project['description'],
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: (project['tech'] as List).map(
                  (tech) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tech,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(24),
          decoration: _glassmorphismDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Education', Icons.school),
              const SizedBox(height: 20),
              ...(_profileData['education'] as List).map((edu) => _buildEducationCard(edu)).toList(),
            ],
          ),
        ),
        if (_isEditing)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              onPressed: () => _editJsonField('education', 'Education'),
            ),
          ),
      ],
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu['degree'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            edu['institution'],
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            edu['period'],
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            edu['details'],
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(24),
          decoration: _glassmorphismDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Contact & Social', Icons.connect_without_contact),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: (_profileData['contact'] as List).length,
                itemBuilder: (context, index) {
                  final contact = _profileData['contact'][index];
                  return _buildContactCard(contact);
                },
              ),
            ],
          ),
        ),
        if (_isEditing)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              onPressed: () => _editJsonField('contact', 'Contact'),
            ),
          ),
      ],
    );
  }

  Future<void> _handleContactTap(Map<String, dynamic> contact) async {
    final value = contact['value'];
    final type = contact['type'].toString().toLowerCase();

    Uri uri;
    switch (type) {
      case 'email':
        uri = Uri(scheme: 'mailto', path: value);
        break;
      case 'phone':
        uri = Uri(scheme: 'tel', path: value);
        break;
      case 'website':
        uri = Uri.parse(value.startsWith('http') ? value : 'https://$value');
        break;
      case 'github':
        final githubValue = value.startsWith('github.com/')
            ? value.replaceFirst('github.com/', '')
            : value;
        uri = Uri.parse(
          value.startsWith('http') ? value : 'https://github.com/$githubValue',
        );
        break;
      case 'twitter':
        final twitterValue = value.startsWith('twitter.com/')
            ? value.replaceFirst('twitter.com/', '')
            : value;
        uri = Uri.parse(
          value.startsWith('http')
              ? value
              : 'https://twitter.com/$twitterValue',
        );
        break;
      default:
        return;
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $uri')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    Color color;
    switch (contact['type'].toString().toLowerCase()) {
      case 'email':
        color = Colors.red;
        break;
      case 'phone':
        color = Colors.green;
        break;
      case 'website':
        color = Colors.blue;
        break;
      case 'github':
        color = Colors.purple;
        break;
      case 'twitter':
        color = Colors.lightBlue;
        break;
      default:
        color = Colors.white;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _handleContactTap(contact),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(_getContactIcon(contact['type']), color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                contact['value'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getContactIcon(String type) {
    switch (type.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'website':
        return Icons.language;
      case 'github':
        return Icons.code;
      case 'twitter':
        return Icons.mediation_sharp;
      default:
        return Icons.contact_page;
    }
  }

  Widget _buildFooter() {
    final footer = _profileData['footer'];

    // Phone number extraction
    String? phoneNumber;
    try {
      final phoneContact = (_profileData['contact'] as List).firstWhere(
            (contact) => contact['type'].toString().toLowerCase() == 'phone',
        orElse: () => {'value': ''},
      );

      phoneNumber = phoneContact['value'].toString().replaceAll(
        RegExp(r'[^0-9+]'),
        '',
      );

      if (phoneNumber.isNotEmpty && phoneNumber.startsWith('+91')) {
        phoneNumber = phoneNumber.substring(3);
      }
    } catch (e) {
      phoneNumber = null;
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: _glassmorphismDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                footer['mainText'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();

                  if (phoneNumber != null && phoneNumber.isNotEmpty) {
                    final Uri whatsappUri = Uri.parse(
                      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent("Hello Qambar, I saw your developer profile and would like to connect with you.")}',
                    );

                    if (await canLaunchUrl(whatsappUri)) {
                      await launchUrl(
                        whatsappUri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not launch WhatsApp'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No phone number available'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Get In Touch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                footer['copyright'],
                style: const TextStyle(color: Colors.white60, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              if (_appVersion.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _appVersion,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        if (_isEditing)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              onPressed: () => _editJsonField('footer', 'Footer'),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
          mini: true,
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () async {
            HapticFeedback.mediumImpact();
            try {
              final box = context.findRenderObject() as RenderBox?;
              await Share.share(
                'Check out '
                    'Link To App'
                    '\n'
                    '${_profileData['name']}\'s developer profile:\n\n'
                    '${_profileData['role']}\n'
                    '${_profileData['location']}\n\n'
                    'Skills: ${(_profileData['skills'] as List).map((s) => s['name']).join(', ')}\n\n'
                    'Contact: ${(_profileData['contact'] as List).map((c) => '${c['type']}: ${c['value']}').join(', ')}',
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
            }
          },
          backgroundColor: Colors.purple,
          child: const Icon(Icons.share, color: Colors.white),
          mini: true,
        ),
        const SizedBox(height: 8),
        if (_isEditing)
          FloatingActionButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isEditing = false;
                _loadSavedData(); // Reload saved data to cancel changes
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Changes discarded')),
              );
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            mini: true,
            child: const Icon(Icons.close),
          ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            !_isEditing ? _promptPassword() : _save();
          },
          backgroundColor: _isEditing ? Colors.green : Colors.blue,
          foregroundColor: Colors.white,
          mini: true,
          child: Icon(_isEditing ? Icons.save : Icons.edit),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BoxDecoration _glassmorphismDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    );
  }
}