import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/app/widgets/buttons.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/widgets/text_fields.dart';
import 'package:logistix/features/auth/application/utils/auth_network_image.dart';
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
  String? onValidate() {
    /// Validates the form fields and checks if all images are uploaded
    final fieldsValidated =
        validatorKey.currentState!.validateAndCheck() &&
        (pickup != null && dropoff != null);

    if (fieldsValidated) {
      for (final imagePath in ref.read(orderImagesProvider).requireValue) {
        final uploadState = ref.read(uploadImageProvider(imagePath));
        // Check if image is still uploading or if upload has failed
        if (uploadState.isLoading || !uploadState.hasValue) {
          return "Please check your image uploads.";
        }
      }
      return null;
      // return ref.read(orderImagesProvider).isLoading ||
      //     ref.read(orderImagesProvider).hasError;
      // All fields are valid and images are uploaded
    }
    // Fields are not valid
    return 'Please fill all required fields.';
  }

  @override
  Widget build(BuildContext context) {
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
              const _ImagesSection(),
              const SizedBox(height: 32),
              const _DeliveryFareWidget(),
              const SizedBox(height: 32),
              ElevatedLoadingButton.icon(
                controller: roundedLoadingButtonController,
                resetAfterDuration: duration_3s,
                onPressed:
                    ref.watch(orderImagesProvider).isLoading
                        ? null
                        : () {
                          final provider = ref.watch(orderImagesProvider);
                          validateAndCreateOrder(
                            DeliveryRequestData(
                              description: descriptionController.text.trim(),
                              pickup: pickup,
                              dropoff: dropoff,
                              imagePaths: provider.requireValue,
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

class _ImagesSection extends StatelessWidget {
  const _ImagesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = .25.sw - 20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Add Images (optional)", style: theme.textTheme.labelLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: size,
          child: Consumer(
            builder: (context, ref, child) {
              final urls = ref.watch(orderImagesProvider).value ?? [];
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: (urls.length + 1).clamp(
                  0,
                  DeliveryOrderImagesNotifier.maxImages,
                ),
                itemBuilder: (context, index) {
                  if (index < urls.length) {
                    return Container(
                      width: size,
                      padding: padding_16,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius_8,
                        image: DecorationImage(
                          image:
                              urls[index].startsWith("http")
                                  ? NetworkImageWithAuth(urls[index])
                                  : FileImage(File(urls[index])),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          ref
                              .read(orderImagesProvider.notifier)
                              .removeImage(index);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white54,
                        ),
                        icon: FutureBuilder(
                          future:
                              ref.exists(uploadImageProvider(urls[index]))
                                  ? ref.watch(
                                    uploadImageProvider(urls[index]).future,
                                  )
                                  : null,
                          builder: (context, snap) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.clear),
                                if (snap.connectionState ==
                                    ConnectionState.waiting)
                                  const CircularProgressIndicator(),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      ref.read(orderImagesProvider.notifier).uploadImage();
                    },
                    child: SizedBox.square(
                      dimension: size,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius_8,
                          color: theme.colorScheme.primary.withAlpha(13),
                          border: Border.all(color: theme.colorScheme.primary),
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
      ],
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
