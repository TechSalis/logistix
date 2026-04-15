import 'package:dispatcher/src/core/extensions/chat_platform_extension.dart';
import 'package:dispatcher/src/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:dispatcher/src/features/more/presentation/cubit/more_cubit.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<ChatPlatform?> _tabs = [
    null,
    ChatPlatform.WHATSAPP,
    ChatPlatform.FACEBOOK,
    ChatPlatform.INSTAGRAM,
    ChatPlatform.TIKTOK,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTab(ChatPlatform? platform) {
    return BlocBuilder<MoreCubit, MoreState>(
      builder: (context, moreState) {
        final integrations =
            moreState.whenOrNull(
              loaded: (_, user) => user?.companyProfile?.integrations,
            ) ??
            <CompanyIntegration>[];

        final isIntegrated = _isPlatformIntegrated(integrations, platform);
        final opacity = (platform != null && !isIntegrated) ? 0.5 : 1.0;

        if (platform == null) {
          return Opacity(
            opacity: opacity,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.all_inbox, size: 16),
                SizedBox(width: 8),
                Text('All'),
              ],
            ),
          );
        }

        return Opacity(
          opacity: opacity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              platform.icon(),
              const SizedBox(width: 8),
              Text(platform.displayName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    ChatPlatform? platform,
    List<Conversation> conversations,
    List<CompanyIntegration> integrations,
  ) {
    final cubit = context.read<ChatCubit>();

    // Check if platform is integrated
    final isIntegrated = _isPlatformIntegrated(integrations, platform);

    if (platform != null && !isIntegrated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LogistixColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: LogistixColors.border),
                ),
                child: const Icon(
                  Icons.link_off,
                  size: 32,
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Platform Not Connected',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LogistixColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect ${platform.displayName} in Settings to start receiving messages',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: LogistixColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filter conversations for this platform
    final filtered = platform == null
        ? conversations
        : conversations.where((c) => c.platform == platform).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LogistixColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: LogistixColors.border),
                ),
                child: Icon(
                  platform == null ? Icons.all_inbox : Icons.message_outlined,
                  size: 32,
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                platform == null
                    ? 'No messages yet'
                    : 'No ${platform.displayName} messages',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: LogistixColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                platform == null
                    ? 'Messages from all connected platforms will appear here'
                    : 'Messages from ${platform.displayName} will appear here',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: LogistixColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView.separated(
        controller: cubit.scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final conversation = filtered[index];
          return _ConversationTile(
            conversation: conversation,
            platformBadge: conversation.platform.icon(),
            onTap: () {
              context.push(DispatcherRoutes.chatDetails(conversation.id));
            },
          );
        },
      ),
    );
  }

  bool _isPlatformIntegrated(
    List<CompanyIntegration> integrations,
    ChatPlatform? platform,
  ) {
    if (platform == null) return true; // "All" tab is always available
    return integrations.any((i) => i.platform == platform && i.isActive);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Column(
          children: [
            SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: LogistixColors.border.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                  indicatorColor: LogistixColors.primary,
                  labelColor: LogistixColors.primary,
                  unselectedLabelColor: LogistixColors.textSecondary,
                  tabs: _tabs
                      .map((platform) => Tab(child: _buildTab(platform)))
                      .toList(),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return BlocBuilder<MoreCubit, MoreState>(
                    builder: (context, moreState) {
                      final integrations = moreState.maybeWhen(
                        loaded: (_, user) =>
                            user?.companyProfile?.integrations ??
                            <CompanyIntegration>[],
                        orElse: () => <CompanyIntegration>[],
                      );

                      if (state.isLoading && state.conversations.isEmpty) {
                        return const Center(child: BootstrapInlineLoader());
                      }

                      return TabBarView(
                        controller: _tabController,
                        children: _tabs.map((platform) {
                          return _buildTabContent(
                            context,
                            platform,
                            state.conversations,
                            integrations,
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    this.platformBadge,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final Widget? platformBadge;

  bool _hasUnread() {
    // For now, let's just assume no unread logic yet or random
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = conversation.lastMessageAt.toRelative();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: LogistixColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LogistixColors.border.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'avatar_${conversation.id}',
                    child: BootstrapAvatar(
                      name:
                          conversation.customerName ?? conversation.platformId,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: platformBadge,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conversation.customerName ??
                                conversation.platformId,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: LogistixColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: _hasUnread()
                                ? LogistixColors.primary
                                : LogistixColors.textSecondary,
                            fontWeight: _hasUnread()
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (conversation.lastMessageSenderType ==
                            SenderType.DISPATCHER)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.done_all,
                              size: 14,
                              color: LogistixColors.primary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            conversation.lastMessageBody ?? 'No messages yet',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: _hasUnread()
                                  ? LogistixColors.text
                                  : LogistixColors.textSecondary,
                              fontWeight: _hasUnread()
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.autoReplyEnabled)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: LogistixColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: LogistixColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              'AUTO',
                              style: TextStyle(
                                color: LogistixColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
