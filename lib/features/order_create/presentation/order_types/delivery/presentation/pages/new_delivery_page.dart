import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/app/widgets/buttons.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/app/widgets/text_fields.dart';
import 'package:logistix/features/auth/presentation/utils/auth_network_image.dart';
import 'package:logistix/features/form_validator/widgets/text_field_with_heading.dart';
import 'package:logistix/features/form_validator/application/textfield_validators.dart';
import 'package:logistix/features/form_validator/widgets/text_validator_provider_forn.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/order_create/presentation/order_types/delivery/application/logic/delivery_order_rp.dart';
import 'package:logistix/features/order_create/presentation/order_types/delivery/presentation/widgets/dlelivery_created_dialog.dart';
import 'package:logistix/features/order_create/presentation/widgets/create_order_widgets.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:progress_state_button/iconed_button.dart';

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
      for (final path in ref.read(imagesUploadProvider).requireValue.keys) {
        final uploading = ref
            .read(imagesUploadProvider.notifier)
            .isUploading(path);
        // Check if image is still uploading
        if (uploading) return "Please wait for your image uploads.";
      }
      // return ref.read(orderImagesProvider).isLoading ||
      //     ref.read(orderImagesProvider).hasError;
      // All fields are valid and images are uploaded
    } else {
      // Fields are not valid
      return 'Please fill all required fields.';
    }
    return null;
  }

  @override
  void onOrderCreated(Order order) {
    showOrderSummarySheet(context, order);
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
                            prefixIcon: Icon(Icons.local_post_office_outlined),
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
                            prefixIcon: Icon(Icons.pin_drop_outlined),
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
                            prefixIcon: Icon(Icons.home_work_outlined),
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
                state: buttonController,
                resetAfterDuration: duration_3s,
                onPressed:
                    ref.watch(imagesUploadProvider).isLoading
                        ? null
                        : () {
                          final images =
                              ref
                                  .watch(imagesUploadProvider)
                                  .requireValue
                                  .values
                                  .whereType<String>();

                          validateAndCreateOrder(
                            DeliveryRequestData(
                              description: descriptionController.text.trim(),
                              pickup: pickup,
                              dropoff: dropoff,
                              imageUrls: images,
                            ),
                          );
                        },
                button: IconedButton(
                  color: Theme.of(context).colorScheme.secondary,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  text: "Request Delivery",
                ),
              ),
              const SizedBox(height: 32),
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
              final images = ref.watch(imagesUploadProvider).value ?? {};
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: (images.length + 1).clamp(
                  0,
                  ref.read(imagesUploadProvider.notifier).maxImages,
                ),
                itemBuilder: (context, index) {
                  if (index < images.length) {
                    final entry = images.entries.elementAt(index);
                    return Container(
                      width: size,
                      padding: padding_16,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius_8,
                        image: DecorationImage(
                          image:
                              entry.value != null
                                  ? AppNetworkImage(entry.value!)
                                  : FileImage(File(entry.key)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref
                              .read(imagesUploadProvider.notifier)
                              .removeImage(index);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white54,
                        ),
                        icon: FutureBuilder(
                          future:
                              ref.exists(uploadImageRequestProvider(entry.key))
                                  ? ref.watch(
                                    uploadImageRequestProvider(
                                      entry.key,
                                    ).future,
                                  )
                                  : null,
                          builder: (context, snap) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.clear),
                                if (snap.connectionState ==
                                    ConnectionState.waiting)
                                  const CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      ref.read(imagesUploadProvider.notifier).uploadImage();
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
