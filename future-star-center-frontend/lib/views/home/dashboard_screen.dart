import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppConstants.appName),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _handleLogout(context),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        user?.fullName ?? 'User',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.role != null) ...[
                        const SizedBox(height: AppConstants.smallPadding),
                        Chip(
                          label: Text(
                            user!.role.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.secondary,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.extraLargePadding),

                // Quick stats or dashboard content
                Text(
                  'Dashboard',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                Text(
                  'Welcome to Future Star Center admin panel. This is where you can manage the clinic operations.',
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: AppConstants.extraLargePadding),

                // Feature cards or menu items
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.defaultPadding,
                    mainAxisSpacing: AppConstants.defaultPadding,
                    children: [
                      _buildDashboardCard(
                        context,
                        icon: Icons.people,
                        title: 'Patients',
                        subtitle: 'Manage patient records',
                        onTap: () {
                          // TODO: Navigate to patients screen
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Appointments',
                        subtitle: 'Schedule & manage',
                        onTap: () {
                          // TODO: Navigate to appointments screen
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.assessment,
                        title: 'Assessments',
                        subtitle: 'Development tracking',
                        onTap: () {
                          // TODO: Navigate to assessments screen
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'App configuration',
                        onTap: () {
                          // TODO: Navigate to settings screen
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Logout button
                CustomButton(
                  text: 'Logout',
                  onPressed: () => _handleLogout(context),
                  isOutlined: true,
                  width: double.infinity,
                  height: 48,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding / 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
