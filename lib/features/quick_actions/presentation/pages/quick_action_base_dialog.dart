import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:logistix/core/presentation/widgets/async_state_widget.dart';
import 'package:logistix/core/presentation/widgets/text_validator_provider_forncard.dart';
import 'package:logistix/features/quick_actions/presentation/logic/quick_actions_types.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/quick_action_widget.dart';

abstract class QADialogData {}

abstract class QAConsumerStatefulDialog<T extends QADialogData>
    extends ConsumerStatefulWidget {
  const QAConsumerStatefulDialog({super.key, this.initialData});
  final T? initialData;

  @override
  QAConsumerState createState();
}

abstract class QAConsumerState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T>
    with TextValidatorProviderFornCardBuilder {
  final pageController = PageController();

  void onConfirm() => Navigator.pop(context);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}


class QADialogBase extends StatefulWidget {
  const QADialogBase({
    super.key,
    required this.action,
    required this.pages,
    this.pageController,
    required this.onSubmit,
    required this.footerBuilder,
  });

  final QuickAction action;
  final List<Widget> pages;
  final PageController? pageController;
  final Future Function() onSubmit;
  final Widget Function(int page, AsyncSnapshot status) footerBuilder;

  @override
  State<QADialogBase> createState() => _FoodQASectionState();
}

class _FoodQASectionState extends State<QADialogBase> {
  late final PageController pageController;
  AsyncSnapshot snapshot = AsyncSnapshot.nothing();

  @override
  void initState() {
    pageController = widget.pageController ?? PageController();
    super.initState();
  }

  Future computation() {
    snapshot = AsyncSnapshot.waiting();
    return widget.onSubmit().then(
      (data) {
        if (mounted) {
          setState(() {
            snapshot = AsyncSnapshot.withData(ConnectionState.done, data);
          });
        }
      },
      onError: (e, s) {
        if (mounted) {
          setState(() {
            snapshot = AsyncSnapshot.withError(ConnectionState.done, e, s);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if (widget.pageController == null) pageController.dispose();
    super.dispose();
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QuickActionIcon(action: widget.action, size: 64),
              const SizedBox(height: 8),
              Text(
                widget.action.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 390,
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...widget.pages,
                    AsyncStatusView(
                      computation: computation,
                      onRetry: computation,
                      successMessage: 'Your order has been placed!',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ListenableBuilder(
                listenable: pageController,
                builder: (context, child) {
                  return AnimatedSmoothIndicator(
                    count: widget.pages.length,
                    activeIndex: pageController.page?.round().clamp(0, 1) ?? 0,
                    effect: JumpingDotEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      activeDotColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListenableBuilder(
                  listenable: pageController,
                  builder: (context, child) {
                    final pageIndex = pageController.page?.round() ?? 0;
                    return Row(
                      children: [
                        if (pageIndex < widget.pages.length)
                          BackButton(
                            onPressed: pageIndex > 0 ? previousPage : null,
                          ),
                        SizedBox(width: 2),
                        Expanded(
                          child: widget.footerBuilder(pageIndex, snapshot),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
