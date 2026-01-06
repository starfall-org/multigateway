import 'package:flutter/material.dart';
import '../../../../shared/utils/app_version.dart';

/// Màn hình thông tin về ứng dụng
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _version = '';

  @override
  void initState() {
    super.initState();
    getAppVersion().then((version) {
      setState(() {
        _version = version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('About App'),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Information and details'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
      ),
      body: SafeArea(top: false, bottom: true, child: _buildBody()),
    );
  }

  /// Xây dựng nội dung chính của màn hình
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppInfoCard(),
          const SizedBox(height: 24),
          _buildDevelopersSection(),
          const SizedBox(height: 24),
          _buildLegalSection(),
          const SizedBox(height: 24),
          _buildSupportSection(),
        ],
      ),
    );
  }

  /// Xây dựng card thông tin ứng dụng
  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App Icon và tên
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.token, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              tl('AI Gateway'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tl('Multi-provider LLM client.'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Version', _version),
          ],
        ),
      ),
    );
  }

  /// Xây dựng hàng thông tin
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần nhà phát triển
  Widget _buildDevelopersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Developers'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDeveloperItem(
                  name: 'Starfall Organization',
                  role: 'Developer',
                  description: 'Organization with passion for AI technology',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng item nhà phát triển
  Widget _buildDeveloperItem({
    required String name,
    required String role,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                name[0],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  /// Xây dựng phần pháp lý
  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Legal'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.description,
                title: 'Privacy Policy',
                subtitle: 'View data privacy policy',
                onTap: () => _openPrivacyPolicy(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.rule,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                onTap: () => _openTermsOfService(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.info_outline,
                title: 'Public Limit License',
                subtitle: 'Public source license information',
                onTap: () => _openOpenSource(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần hỗ trợ
  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Support'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.bug_report,
                title: 'Report Bug',
                subtitle: 'Send bug reports to us',
                onTap: () => _reportBug(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.lightbulb_outline,
                title: 'Feature Request',
                subtitle: 'Propose new features',
                onTap: () => _requestFeature(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Learn how to use the app',
                onTap: () => _openHelpCenter(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng tile điều khiển
  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  /// Handlers cho các hành động
  void _openPrivacyPolicy() {
    context.showInfoSnackBar(tl('Privacy policy opened'));
  }

  void _openTermsOfService() {
    context.showInfoSnackBar(tl('Terms of service opened'));
  }

  void _openOpenSource() {
    context.showInfoSnackBar(tl('Open source info opened'));
  }

  void _reportBug() {
    context.showInfoSnackBar(tl('Bug report opened'));
  }

  void _requestFeature() {
    context.showInfoSnackBar(tl('Feature request opened'));
  }

  void _openHelpCenter() {
    context.showInfoSnackBar(tl('Help center opened'));
  }
}
