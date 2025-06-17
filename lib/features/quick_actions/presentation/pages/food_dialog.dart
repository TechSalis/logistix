import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/core/constants/colors.dart';
import 'package:logistix/core/presentation/logic/form_validator_rp.dart';
import 'package:logistix/core/presentation/widgets/page_indicator/effects/jumping_dot_effect.dart';
import 'package:logistix/core/presentation/widgets/page_indicator/smooth_page_indicator.dart';
import 'package:logistix/features/quick_actions/presentation/logic/food_dialog_validator.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_enum.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/location_text_field.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/price_selector_widget.dart';

class FoodQASection extends ConsumerStatefulWidget {
  const FoodQASection({super.key});

  @override
  ConsumerState<FoodQASection> createState() => _FoodQASectionState();
}

class _FoodQASectionState extends ConsumerState<FoodQASection> {
  final pickUpTEC = TextEditingController();
  final dropoffTEC = TextEditingController();
  final descriptionTEC = TextEditingController();

  int page = 0;

  @override
  void dispose() {
    pickUpTEC.dispose();
    dropoffTEC.dispose();
    descriptionTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  BackButton(
                    onPressed: () {
                      if (page > 0) {
                        setState(() => page--);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Order Food',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: QuickAction.food.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              IndexedStack(
                index: page,
                alignment: Alignment.topCenter,
                children: [
                  _P1DescriptionWidget(descriptionTEC: descriptionTEC),
                  _P2LocationWidget(
                    dropoffTEC: dropoffTEC,
                    pickUpTEC: pickUpTEC,
                  ),
                ],
              ),
              SizedBox(height: 40),
              AnimatedSmoothIndicator(
                activeIndex: page,
                count: 2,
                effect: JumpingDotEffect(
                  dotWidth: 8,
                  dotHeight: 8,
                  activeDotColor: QuickAction.food.color,
                  // activeDotColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),
              IndexedStack(
                index: page,
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onContiunue,
                      child: Text('Continue'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      label: Text('Confirm'),
                      icon: Icon(Icons.check_circle_outline),
                      onPressed: _onConfirm,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  _onContiunue() {
    final group = FormValidatorGroup(ref, [
      FormValidationData(
        descriptionTEC,
        descriptionValidatorProvider(descriptionTEC),
      ),
    ]);
    if (group.validateAndCheck()) {
      setState(() => page = 1);
    }
  }

  _onConfirm() {
    final group = FormValidatorGroup(ref, [
      FormValidationData(dropoffTEC, dropoffValidatorProvider(dropoffTEC)),
    ]);
    if (group.validateAndCheck()) {
      // setState(() => page = 1);
    }
  }
}

class _P2LocationWidget extends StatelessWidget {
  const _P2LocationWidget({required this.dropoffTEC, required this.pickUpTEC});

  final TextEditingController dropoffTEC;
  final TextEditingController pickUpTEC;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _TextFieldSectionBuilder(
          provider: dropoffValidatorProvider(dropoffTEC),
          title: 'Dropoff Location*',
          textfieldWidget: LocationTextField(
            controller: dropoffTEC,
            decoration: InputDecoration(
              hintText: 'Where is the food going?',
              prefixIcon: Icon(Icons.other_houses_outlined),
            ),
          ),
        ),
        _TextFieldSectionBuilder(
          title: 'Restaurant/Pickup Location',
          textfieldWidget: LocationTextField(
            controller: pickUpTEC,
            decoration: InputDecoration(
              hintText: 'Restaurant name or address',
              prefixIcon: Icon(QuickAction.food.icon),
            ),
          ),
        ),
      ],
    );
  }
}

class _P1DescriptionWidget extends StatelessWidget {
  const _P1DescriptionWidget({required this.descriptionTEC});

  final TextEditingController descriptionTEC;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TextFieldSectionBuilder(
          provider: descriptionValidatorProvider(descriptionTEC),
          title: 'Description*',
          textfieldWidget: TextFormField(
            minLines: 3,
            maxLines: 3,
            controller: descriptionTEC,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            inputFormatters: [LengthLimitingTextInputFormatter(255)],
            decoration: InputDecoration(
              hintText:
                  'What are you ordering?\nLeave a message for the rider.',
            ),
          ),
        ),
        PriceSelectorField(onChanged: (value) {}),
      ],
    );
  }
}

class OrderFareWidget extends StatelessWidget {
  const OrderFareWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: QuickActionColors.food[100],
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        children: [
          DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Estimated Fare'), Text(r'N5300 - N20000')],
            ),
          ),
          SizedBox(height: 8),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.titleSmall!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Based on distance and time'),
                Text(r'15-25 min'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFieldSectionBuilder extends ConsumerWidget {
  const _TextFieldSectionBuilder({
    required this.title,
    required this.textfieldWidget,
    this.provider,
  });

  final String title;
  final Widget textfieldWidget;
  final ProviderListenable<String?>? provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = provider == null ? null : ref.watch(provider!);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          textfieldWidget,
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              error ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
