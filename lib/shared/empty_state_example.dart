import 'package:flutter/material.dart';
import 'theme.dart';
import 'components.dart';

/// This is an example screen demonstrating how to use the emptyState component
/// in different scenarios throughout the app.
class EmptyStateExample extends StatelessWidget {
  const EmptyStateExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empty States'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empty State Examples',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'These are examples of empty states that can be used throughout the app when there is no data to display.',
              style: AppTheme.bodyText,
            ),
            const SizedBox(height: 24),
            
            // Example 1: No Appointments
            _buildExampleCard(
              title: 'No Appointments',
              child: AppComponents.emptyState(
                message: 'You don\'t have any appointments yet.',
                actionText: 'Book an Appointment',
                onAction: () {
                  // Navigate to appointment booking
                },
                icon: Icons.calendar_today_rounded,
                iconColor: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Example 2: No Search Results
            _buildExampleCard(
              title: 'No Search Results',
              child: AppComponents.emptyState(
                message: 'No results found for your search. Try different keywords or filters.',
                icon: Icons.search_off_rounded,
                iconColor: AppTheme.secondaryColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Example 3: No Notifications
            _buildExampleCard(
              title: 'No Notifications',
              child: AppComponents.emptyState(
                message: 'You don\'t have any notifications yet. We\'ll notify you about important updates and appointments.',
                icon: Icons.notifications_off_rounded,
                iconColor: AppTheme.accentColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Example 4: Network Error
            _buildExampleCard(
              title: 'Network Error',
              child: AppComponents.emptyState(
                message: 'Unable to connect to the server. Please check your internet connection and try again.',
                actionText: 'Retry',
                onAction: () {
                  // Retry network request
                },
                icon: Icons.wifi_off_rounded,
                iconColor: AppTheme.errorColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Example 5: No Medical Records
            _buildExampleCard(
              title: 'No Medical Records',
              child: AppComponents.emptyState(
                message: 'You don\'t have any medical records yet. Records will appear here after your appointments.',
                icon: Icons.folder_off_rounded,
                iconColor: AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExampleCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.heading4,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          height: 300,
          child: child,
        ),
      ],
    );
  }
}
