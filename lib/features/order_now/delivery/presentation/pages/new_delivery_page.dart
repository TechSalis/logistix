import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/presentation/widgets/elevated_loading_button.dart';
import 'package:logistix/app/presentation/widgets/location_text_field.dart';
import 'package:logistix/app/presentation/widgets/text_field_with_heading.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/order_now/delivery/application/logic/delivery_order_rp.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class NewDeliveryPage extends StatefulWidget {
  const NewDeliveryPage({super.key});

  @override
  State<NewDeliveryPage> createState() => _NewDeliveryPageState();
}

class _NewDeliveryPageState extends State<NewDeliveryPage> {
  final descriptionController = TextEditingController();
  final dropoffController = TextEditingController();
  final pickupController = TextEditingController();

  final roundedLoadingButtonController = RoundedLoadingButtonController();
  final validatorKey = GlobalKey<FormValidatorGroupState>();

  DeliveryRequestData? data;

  @override
  void dispose() {
    descriptionController.dispose();
    dropoffController.dispose();
    pickupController.dispose();
    super.dispose();
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
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: padding_16,
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
                        controller: descriptionController,
                        validatorProvider: RequiredValidatorProvider,
                        label: const Text("Pickup Location"),
                        child: LocationTextField(
                          controller: pickupController,
                          decoration: const InputDecoration(
                            hintText: "Choose pickup location",
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFieldLabelAndErrorDisplayWidget(
                        controller: descriptionController,
                        validatorProvider: RequiredValidatorProvider,
                        label: const Text("Dropoff Location"),
                        child: LocationTextField(
                          controller: dropoffController,
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
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
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
                          onTap:
                              ref
                                  .read(deliveryOrderImagesProvider.notifier)
                                  .pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: borderRadius_8,
                              color: theme.colorScheme.primary.withAlpha(13),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            child: const Icon(Icons.add_a_photo),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const _DeliveryFareWidget(),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, child) {
                  if (data != null &&
                      ref.exists(requestDeliveryProvider(data!))) {
                    ref.listen(requestDeliveryProvider(data!), (p, n) {
                      switch (n) {
                        case AsyncLoading():
                          roundedLoadingButtonController.start();
                          break;
                        case AsyncData():
                          roundedLoadingButtonController.success();
                          break;
                        case AsyncError():
                          roundedLoadingButtonController.error();
                          break;
                        default:
                      }
                    });
                  }
                  return ElevatedLoadingButton.icon(
                    controller: roundedLoadingButtonController,
                    onPressed: () {
                      if (!validatorKey.currentState!.validateAndCheck()) {
                        setState(() => data = null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all required fields."),
                          ),
                        );
                      } else {
                        setState(() {
                          data = DeliveryRequestData(
                            description: descriptionController.text,
                            pickup: pickupController.text,
                            dropoff: dropoffController.text,
                            imagePaths: ref.read(deliveryOrderImagesProvider),
                          );
                        });
                        ref.read(requestDeliveryProvider(data!));
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Request Delivery"),
                  );
                },
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
        color: theme.colorScheme.primary.withAlpha(13),
        borderRadius: borderRadius_12,
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
