import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

/// A premium, decorative scaffold for Authentication and Onboarding flows.
///
/// Features:
/// - Floating decorative background circles
/// - Sliver-based scrolling for smooth header transitions
/// - Integrated [BootstrapEntrance] animations for children
class LogistixAuthScaffold extends StatelessWidget {
  const LogistixAuthScaffold({
    required this.children,
    this.title,
    this.subtitle,
    this.header,
    this.onBack,
    this.footer,
    this.appBarActions,
    super.key,
  });

  /// The main content of the page, automatically wrapped in [BootstrapEntrance].
  final List<Widget> children;

  /// Optional title shown below the header/icon.
  final String? title;

  /// Optional subtitle shown below the title.
  final String? subtitle;

  /// Optional header widget (e.g., an Icon or Image).
  final Widget? header;

  /// Optional footer widget (e.g., a primary action button).
  final Widget? footer;

  /// Optional callback for the back button.
  final VoidCallback? onBack;

  /// Optional actions for the SliverAppBar.
  final List<Widget>? appBarActions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Decorative Background - Top Right
          Positioned(
            top: -100,
            right: -100,
            child: _DecorativeCircle(
              size: 300,
              color: LogistixColors.primary.withValues(alpha: 0.04),
            ),
          ),
          // Decorative Background - Bottom Left
          Positioned(
            bottom: -150,
            left: -150,
            child: _DecorativeCircle(
              size: 400,
              color: LogistixColors.primary.withValues(alpha: 0.02),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        floating: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: onBack != null
                            ? IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                ),
                                onPressed: onBack,
                              )
                            : null,
                        actions: appBarActions,
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BootstrapSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (header != null) ...[
                                Center(child: header),
                                const SizedBox(height: BootstrapSpacing.lg),
                              ],
                              if (title != null) ...[
                                Text(
                                  title!,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.headlineSmall?.bold
                                      .copyWith(color: LogistixColors.text),
                                ),
                                const SizedBox(height: BootstrapSpacing.xs),
                              ],
                              if (subtitle != null) ...[
                                Text(
                                  subtitle!,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: LogistixColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: BootstrapSpacing.xxl),
                              ],
                              BootstrapEntrance(
                                children: children,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Add padding at the bottom to ensure content isn't 
                      // covered by footer or bottom safe area
                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: 120),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (footer != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  BootstrapSpacing.lg,
                  BootstrapSpacing.md,
                  BootstrapSpacing.lg,
                  MediaQuery.of(context).padding.bottom + BootstrapSpacing.md,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white,
                    ],
                    stops: const [0, 0.4, 1],
                  ),
                ),
                child: footer,
              ),
            ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
