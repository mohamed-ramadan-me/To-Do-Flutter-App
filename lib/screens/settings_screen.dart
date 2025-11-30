import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/theme_service.dart';
import '../services/tutorial_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
      // Try external application first
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          // Fallback to platformDefault
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Cannot open $url')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionHeader(context, 'Theme'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(isDark ? 'Enabled' : 'Disabled'),
              value: isDark,
              onChanged: (value) => themeService.toggleTheme(),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tutorial Section
          _buildSectionHeader(context, 'Tutorial'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: const Text('Reset Tutorial'),
              subtitle: const Text('Show the delete task tutorial again'),
              leading: Icon(
                Icons.restore,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                Provider.of<TutorialService>(
                  context,
                  listen: false,
                ).resetTutorials();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tutorial reset successfully')),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Developers Header
                  Center(
                    child: Text(
                      'Developed By',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mohamed Ramadan (First)
                  _buildDeveloperCard(
                    context,
                    name: 'Mohamed Ramadan',
                    imagePath: 'assets/mohamed_ramadan.png',
                    linkedInUrl:
                        'https://www.linkedin.com/in/mohamed-ramadan-me/',
                    githubUrl: 'https://github.com/mohamed-ramadan-me',
                  ),

                  const SizedBox(height: 16),

                  // Mostafa Rashidy (Second)
                  _buildDeveloperCard(
                    context,
                    name: 'Mostafa Rashidy',
                    imagePath: 'assets/mostafa_rashidy.png',
                    linkedInUrl: 'https://www.linkedin.com/in/mostafa-rashidy/',
                    githubUrl: 'https://github.com/MostafaRashidy',
                  ),

                  const SizedBox(height: 24),

                  // Made with Flutter
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Made with ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Text('❤️', style: TextStyle(fontSize: 18)),
                        Text(
                          ' using Flutter',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context, {
    required String name,
    required String imagePath,
    required String linkedInUrl,
    required String githubUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 32, // Slightly larger avatar
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 16),

          // Name and Social Icons Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // Larger font size for better visibility
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Social Icons Row
                Row(
                  children: [
                    // LinkedIn
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const FaIcon(FontAwesomeIcons.linkedin, size: 20),
                        tooltip: 'LinkedIn',
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF0A66C2),
                        onPressed: () => _launchUrl(linkedInUrl, context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // GitHub
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const FaIcon(FontAwesomeIcons.github, size: 20),
                        tooltip: 'GitHub',
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        onPressed: () => _launchUrl(githubUrl, context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
