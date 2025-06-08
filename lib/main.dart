import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

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
  const DeveloperProfilePage({super.key});

  @override
  _DeveloperProfilePageState createState() => _DeveloperProfilePageState();
}

class _DeveloperProfilePageState extends State<DeveloperProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _floatingController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _floatingAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutQuart,
    );

    _floatingAnimation = CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_scrollListener);

    // Start animations
    _headerController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _contentController.forward();
    });
    _floatingController.repeat(reverse: true);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = true;
      });
    } else if (_scrollController.offset <= 200 && _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = false;
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _contentAnimation,
              builder: (context, child) {
                return Transform.translate(
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Animated background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                        Color(0xFF6B73FF),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Floating particles effect
                ...List.generate(20, (index) {
                  return AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left:
                            (index * 37.0) % MediaQuery.of(context).size.width,
                        top:
                            50 +
                            (index * 23.0) % 300 +
                            (20 * _floatingAnimation.value),
                        child: Container(
                          width: 4 + (index % 3) * 2,
                          height: 4 + (index % 3) * 2,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  );
                }),
                // Profile content
                Center(
                  child: Transform.scale(
                    scale: _headerAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile picture with glow effect
                        Container(
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
                            child: CircleAvatar(
                              radius: 58,
                              backgroundImage: NetworkImage(
                                '''https://avatars.githubusercontent.com/u/168618726?v=4''',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Name with typewriter effect
                        Text(
                          'Qambar Abbas',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Senior Flutter Developer',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'New Delhi, India',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('About Me', Icons.person),
          SizedBox(height: 16),
          Text(
            'Passionate Flutter developer with 5+ years of experience creating beautiful, performant mobile applications. I specialize in cross-platform development, state management, and creating delightful user experiences that users love.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildTag('Mobile Development'),
              _buildTag('UI/UX Design'),
              _buildTag('Team Leadership'),
              _buildTag('Agile Methodology'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    final skills = [
      {'name': 'Flutter', 'level': 0.95, 'color': Colors.blue},
      {'name': 'Dart', 'level': 0.90, 'color': Colors.teal},
      {'name': 'Firebase', 'level': 0.85, 'color': Colors.orange},
      {'name': 'React Native', 'level': 0.75, 'color': Colors.cyan},
      {'name': 'Node.js', 'level': 0.80, 'color': Colors.green},
      {'name': 'Python', 'level': 0.70, 'color': Colors.yellow},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(24),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Skills & Expertise', Icons.code),
          SizedBox(height: 20),
          ...skills.map(
            (skill) => _buildSkillBar(
              skill['name'] as String,
              skill['level'] as double,
              skill['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBar(String skill, double level, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(level * 100).toInt()}%',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),
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
    final experiences = [
      // {
      //   'title': 'Senior Flutter Developer',
      //   'company': 'TechCorp Solutions',
      //   'period': '2022 - Present',
      //   'description':
      //       'Lead mobile development team, architected scalable Flutter applications serving 100K+ users.',
      //   'icon': Icons.work,
      // },
      {
        'title': 'Mobile App Developer',
        'company': 'DefineDigitals Pvt Ltd',
        'period': '2025 - Current',
        'description':
            'Developed and maintained cross-platform mobile applications using Flutter and React Native.',
        'icon': Icons.phone_android,
      },
      {
        'title': 'Technical Intern',
        'company': 'DefineDigitals Pvt Ltd',
        'period': '2023 - 2024',
        'description':
            'Started career building responsive web applications and learning mobile development.',
        'icon': Icons.computer,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(24),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Experience', Icons.timeline),
          SizedBox(height: 20),
          ...experiences.map((exp) => _buildExperienceCard(exp)).toList(),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> exp) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
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
              gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(exp['icon'], color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  exp['company'],
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  exp['period'],
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                SizedBox(height: 12),
                Text(
                  exp['description'],
                  style: TextStyle(
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
    final projects = [
      {
        'name': 'Nuevadesk CRM',
        'description': 'CRM for managing customer relationships',
        'tech': ['Flutter', 'REST', 'Insta360'],
        'color': Colors.green,
      },
      {
        'name': 'Eat-It',
        'description': 'Food sugesstion with voting and family sharing',
        'tech': ['Flutter', 'Dart', 'Firebase'],
        'color': Colors.orange,
      },
      {
        'name': 'MediCare Pro',
        'description': 'Healthcare management system for doctors',
        'tech': ['Flutter', 'Python', 'AWS'],
        'color': Colors.red,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(24),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Featured Projects', Icons.folder),
          SizedBox(height: 20),
          ...projects.map((project) => _buildProjectCard(project)).toList(),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            project['color'].withOpacity(0.1),
            project['color'].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: project['color'].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project['name'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            project['description'],
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: (project['tech'] as List<String>)
                .map(
                  (tech) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: project['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tech,
                      style: TextStyle(
                        color: project['color'],
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(24),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Education', Icons.school),
          SizedBox(height: 20),
          _buildEducationCard(
            'Bachelor of Computer Applications',
            'Noida International University',
            '2022 - 2025',
            // 'Graduated Magna Cum Laude • GPA: 3.8/4.0',
            '',
          ),
          SizedBox(height: 16),
          _buildEducationCard(
            'Flutter Development Certification',
            'Google Developers',
            '2023',
            'Advanced Flutter concepts and best practices',
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(
    String degree,
    String institution,
    String period,
    String details,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            degree,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            institution,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(period, style: TextStyle(color: Colors.white60, fontSize: 12)),
          SizedBox(height: 8),
          Text(
            details,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final contacts = [
      {
        'icon': Icons.email,
        'label': 'qambarofficial313@gmail.com',
        'color': Colors.red,
      },
      {'icon': Icons.phone, 'label': '+91 85108 42558', 'color': Colors.green},
      {
        'icon': Icons.language,
        'label': 'qambarofficial.github.io',
        'color': Colors.blue,
      },
      {
        'icon': Icons.code,
        'label': 'github.com/qambarofficial',
        'color': Colors.purple,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(24),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Contact & Social', Icons.connect_without_contact),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return _buildContactCard(contact);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: contact['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: contact['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(contact['icon'], color: contact['color'], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              contact['label'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: _glassmorphismDecoration(),
      child: Column(
        children: [
          Text(
            'Let\'s Build Something Amazing Together',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Add contact action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Get In Touch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            '© 2024 Qambar Abbas. All rights reserved.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: Colors.blue,
          child: Icon(Icons.keyboard_arrow_up, color: Colors.white),
          mini: true,
        ),
        SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Add share functionality
          },
          backgroundColor: Colors.purple,
          child: Icon(Icons.share, color: Colors.white),
          mini: true,
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
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
