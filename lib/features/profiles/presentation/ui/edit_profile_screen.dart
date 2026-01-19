import 'package:flutter/material.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/llm/presentation/widgets/view_profile_dialog.dart';
import 'package:multigateway/features/profiles/presentation/controllers/edit_profile_controller.dart';
import 'package:multigateway/features/profiles/presentation/widgets/profile_config_tab.dart';
import 'package:multigateway/features/profiles/presentation/widgets/profile_controller_provider.dart';
import 'package:multigateway/features/profiles/presentation/widgets/profile_general_tab.dart';
import 'package:multigateway/features/profiles/presentation/widgets/profile_tools_tab.dart';
import 'package:signals/signals_flutter.dart';

class AddProfileScreen extends StatefulWidget {
  final ChatProfile? profile;

  const AddProfileScreen({super.key, this.profile});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen>
    with SingleTickerProviderStateMixin {
  late EditProfileController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _controller = EditProfileController();
    _controller.initialize(widget.profile);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.profile != null;

    return ProfileControllerProvider(
      controller: _controller,
      child: Watch((context) {
        return Scaffold(
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isEditing)
                FloatingActionButton(
                  heroTag: "info",
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewProfileDialog(profile: widget.profile!),
                      ),
                    );
                  },
                  child: const Icon(Icons.info_outline),
                ),
              if (isEditing) const SizedBox(width: 16),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 0,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.person), text: 'Info'),
                Tab(icon: Icon(Icons.settings), text: 'Config'),
                Tab(icon: Icon(Icons.build), text: 'Tools'),
              ],
            ),
          ),
          body: SafeArea(
            top: true,
            bottom: true,
            child: TabBarView(
              controller: _tabController,
              children: const [
                ProfileGeneralTab(),
                ProfileConfigTab(),
                ProfileToolsTab(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
