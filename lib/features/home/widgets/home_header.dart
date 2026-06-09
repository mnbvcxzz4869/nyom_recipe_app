import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nyom_recipe_app/features/auth/providers/auth_provider.dart';
import 'package:nyom_recipe_app/features/auth/repositories/auth_repository.dart';
import '../../../core/theme/app_theme.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readableToday = DateFormat('EEEE, d MMM').format(DateTime.now());
    final currentUserAsync = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                readableToday,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.greyAccent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              currentUserAsync.when(
                data: (user) => Text(
                  'Hello, ${user?.username ?? 'Chef'}! 👋',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                loading: () => Text('Hello! 👋',
                    style: Theme.of(context).textTheme.headlineLarge),
                error: (_, __) => Text('Hello, Chef! 👋',
                    style: Theme.of(context).textTheme.headlineLarge),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showProfileDialog(context, ref),
            child: currentUserAsync.when(
              data: (user) => CircleAvatar(
                radius: 24,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!) as ImageProvider
                    : const AssetImage('assets/profile-pics.png'),
              ),
              loading: () => const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/profile-pics.png'),
              ),
              error: (_, __) => const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/profile-pics.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showProfileDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      content: Text('Would you like to log out?',
          style: Theme.of(context).textTheme.titleMedium),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await ref.read(authRepositoryProvider).signOut();
          },
          child: Text('Logout', style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}