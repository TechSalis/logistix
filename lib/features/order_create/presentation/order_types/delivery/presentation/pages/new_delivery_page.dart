import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/app/widgets/buttons.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/widgets/text_fields.dart';
import 'package:logistix/features/form_validator/widgets/text_field_with_heading.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/order_create/presentation/order_types/delivery/application/logic/delivery_order_rp.dart';
import 'package:logistix/features/order_create/presentation/widgets/create_order_widgets.dart';

class NewDeliveryPage extends ConsumerStatefulWidget {
  const NewDeliveryPage({super.key});

  @override
  ConsumerState<NewDeliveryPage> createState() => _NewDeliveryPageState();
}

class _NewDeliveryPageState extends ConsumerState<NewDeliveryPage>
    with CreateOrderWidgetMixin, BaseCreateOrderTemplateMixin {
  @override
  bool onValidate() {
    return (validatorKey.currentState!.validateAndCheck() &&
        (pickup != null && dropoff != null));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("New Delivery")),
      body: Padding(
        padding: padding_H16,
        child: FormValidatorGroupWidget(
          key: validatorKey,
          child: ListView(
            children: [
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: padding_24,
                  child: Column(
                    children: [
                      TextFieldLabelAndErrorDisplayWidget(
                        controller: descriptionController,
                        validatorProvider: RequiredValidatorProvider,
                        label: const Text("What do you need delivered?"),
                        child: TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            hintText: "e.g. A package, envelope, documents",
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFieldLabelAndErrorDisplayWidget(
                        controller: pickupController,
                        validatorProvider: RequiredValidatorProvider,
                        label: const Text("Pickup Location"),
                        child: AddressTextField(
                          heroTag: "pickup",
                          address: pickup,
                          onAddressChanged: (value) {
                            pickupController.text = value.name;
                            pickup = value;
                          },
                          decoration: const InputDecoration(
                            hintText: "Choose pickup location",
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFieldLabelAndErrorDisplayWidget(
                        controller: dropoffController,
                        validatorProvider: RequiredValidatorProvider,
                        label: const Text("Dropoff Location"),
                        child: AddressTextField(
                          heroTag: "dropoff",
                          address: dropoff,
                          onAddressChanged: (value) {
                            dropoffController.text = value.name;
                            dropoff = value;
                          },
                          decoration: const InputDecoration(
                            hintText: "Choose dropoff location",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text("Add Images (optional)", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: .25.sw - 20,
                child: Consumer(
                  builder: (context, ref, child) {
                    final imagePaths = ref.watch(deliveryOrderImagesProvider);
                    return ListView.separated(
                      itemCount: (imagePaths.length + 1).clamp(0, 4),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (index < imagePaths.length) {
                          return ClipRRect(
                            borderRadius: borderRadius_8,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.file(
                                  File(imagePaths[index]),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                IconButton(
                                  onPressed: () {
                                    ref
                                        .read(
                                          deliveryOrderImagesProvider.notifier,
                                        )
                                        .removeImage(index);
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white54,
                                  ),
                                  icon: const Icon(Icons.clear),
                                ),
                              ],
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(deliveryOrderImagesProvider.notifier)
                                .pickImage();
                          },
                          child: SizedBox.square(
                            dimension: .25.sw - 20,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: borderRadius_8,
                                color: theme.colorScheme.primary.withAlpha(13),
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              child: const Icon(Icons.add_a_photo),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              const _DeliveryFareWidget(),
              const SizedBox(height: 32),
              ElevatedLoadingButton.icon(
                controller: roundedLoadingButtonController,
                resetAfterDuration: duration_3s,
                onPressed: () {
                  validateAndCreateOrder(
                    DeliveryRequestData(
                      description: descriptionController.text.trim(),
                      pickup: pickup,
                      dropoff: dropoff,
                      imagePaths: ref.read(deliveryOrderImagesProvider),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Request Delivery"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryFareWidget extends StatelessWidget {
  const _DeliveryFareWidget();

  @override
  Widget build(BuildContext context) {
    String? estimateTime = "20-30 min";
    String? estimateFare = "₦1,500 - ₦2,500";
    final theme = Theme.of(context);
    return Container(
      padding: padding_16,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Estimated Fare",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(estimateFare, style: theme.textTheme.bodyMedium),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "ETA",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(estimateTime, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
