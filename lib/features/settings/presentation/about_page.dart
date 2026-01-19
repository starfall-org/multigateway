import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/widgets/about/app_info_card.dart';
import 'package:multigateway/features/settings/presentation/widgets/about/developers_section.dart';
import 'package:multigateway/features/settings/presentation/widgets/about/legal_section.dart';
import 'package:multigateway/features/settings/presentation/widgets/about/support_section.dart';
import 'package:multigateway/shared/utils/app_version.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Màn hình thông tin về ứng dụng
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';
  final Uri _repoUrl = Uri.parse('https://github.com/starfall-org/multigateway');
  final Uri _issuesUrl =
      Uri.parse('https://github.com/starfall-org/multigateway/issues/new/choose');
  final Uri _featureRequestUrl = Uri.parse(
    'https://github.com/starfall-org/multigateway/issues/new?labels=enhancement',
  );
  final Uri _licenseUrl =
      Uri.parse('https://github.com/starfall-org/multigateway/blob/main/LICENSE');

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('About App'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Information and details'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInfoCard(version: _version),
              const SizedBox(height: 24),
              const DevelopersSection(),
              const SizedBox(height: 24),
              LegalSection(
                onPrivacyPolicyTap: _openPrivacyPolicy,
                onTermsOfServiceTap: _openTermsOfService,
                onOpenSourceTap: _openOpenSource,
              ),
              const SizedBox(height: 24),
              SupportSection(
                onReportBugTap: _reportBug,
                onRequestFeatureTap: _requestFeature,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handlers cho các hành động
  Future<void> _openPrivacyPolicy() async {
    await _openLink(_repoUrl, tl('Could not open privacy policy link'));
  }

  Future<void> _openTermsOfService() async {
    await _openLink(_repoUrl, tl('Could not open terms link'));
  }

  Future<void> _openOpenSource() async {
    await _openLink(_licenseUrl, tl('Could not open license link'));
  }

  Future<void> _reportBug() async {
    await _openLink(_issuesUrl, tl('Could not open GitHub issues'));
  }

  Future<void> _requestFeature() async {
    await _openLink(
      _featureRequestUrl,
      tl('Could not open feature request link'),
    );
  }

  Future<void> _openLink(Uri url, String errorMessage) async {
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      context.showErrorSnackBar(errorMessage);
    }
  }
}
