import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/core/extensions/chat_platform_extension.dart';
import 'package:dispatcher/src/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> with SingleTickerProviderStateMixin {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().fetchConversationsRunner();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          indicatorColor: LogistixColors.primary,
          labelColor: LogistixColors.primary,
          unselectedLabelColor: LogistixColors.textSecondary,
          tabs: _tabs.map((platform) {
            if (platform == null) {
              return const Tab(text: 'All');
            }
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  platform.icon(),
                  const SizedBox(width: 8),
                  Text(platform.displayName),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          final cubit = context.read<ChatCubit>();
          final runner = cubit.fetchConversationsRunner;

          return AsyncRunnerBuilder(
            runner: runner,
            builder: (context, runnerState, _) {
              if (runnerState.status.isRunning && state.conversations.isEmpty) {
                return const Center(child: BootstrapInlineLoader());
              }

              if (runnerState.status.isFailure && state.conversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: LogistixColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        runnerState.result?.error.message ??
                            'Failed to load messages',
                      ),
                      const SizedBox(height: 16),
                      BootstrapButton(
                        label: 'Try Again',
                        onPressed: runner.call,
                      ),
                    ],
                  ),
                );
              }

              if (state.conversations.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 48,
                        color: LogistixColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(color: LogistixColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: _tabs.map((platform) {
                  final filtered = platform == null
                      ? state.conversations
                      : state.conversations
                          .where((c) => c.platform == platform)
                          .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No conversations for this platform',
                        style: TextStyle(color: LogistixColors.textSecondary),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: runner.call,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 88),
                      itemBuilder: (context, index) {
                        final conversation = filtered[index];
                        return _ConversationTile(
                          conversation: conversation,
                          platformBadge: conversation.platform.icon(),
                          onTap: () {
                            cubit.selectConversation(conversation);
                            context.push(
                              DispatcherRoutes.chatDetails(conversation.id),
                            );
                          },
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
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

  @override
  Widget build(BuildContext context) {
    final timeStr = conversation.lastMessageAt.toRelative();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BootstrapSpacing.pagePadding,
          vertical: BootstrapSpacing.sm,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'avatar_${conversation.id}',
                  child: BootstrapAvatar(
                    name: conversation.customerName ?? conversation.platformId,
                    size: 56,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: platformBadge,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.customerName ?? conversation.platformId,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _hasUnread()
                              ? LogistixColors.primary
                              : LogistixColors.textSecondary,
                          fontWeight: _hasUnread()
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conversation.lastMessageSenderType == SenderType.DISPATCHER)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.done_all,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          conversation.lastMessageBody ?? 'No messages yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _hasUnread()
                                ? Colors.black
                                : LogistixColors.textSecondary,
                            fontWeight: _hasUnread()
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
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
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AUTO',
                            style: TextStyle(
                              color: LogistixColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
    );
  }

  bool _hasUnread() {
    // For now, let's just assume no unread logic yet or random
    return false;
  }
}
