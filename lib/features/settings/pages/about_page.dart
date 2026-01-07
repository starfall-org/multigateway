import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/ui/widgets/about/app_info_card.dart';
import 'package:multigateway/features/settings/ui/widgets/about/developers_section.dart';
import 'package:multigateway/features/settings/ui/widgets/about/legal_section.dart';
import 'package:multigateway/features/settings/ui/widgets/about/support_section.dart';
import 'package:multigateway/shared/utils/app_version.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Màn hình thông tin về ứng dụng
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
                onHelpCenterTap: _openHelpCenter,
              ),
            ],
          ),
        ),
      ),
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
