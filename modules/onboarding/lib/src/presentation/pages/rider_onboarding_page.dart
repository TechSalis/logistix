import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:onboarding/onboarding.dart';
import 'package:onboarding/src/domain/repositories/company_repository.dart';
import 'package:phone_text_field/phone_text_field.dart';
import 'package:shared/shared.dart';

class RiderOnboardingPage extends StatefulWidget {
  const RiderOnboardingPage({super.key});

  @override
  State<RiderOnboardingPage> createState() => _RiderOnboardingPageState();
}

class _RiderOnboardingPageState extends State<RiderOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _registrationNumberController = TextEditingController();

  PhoneNumber? _phoneNumber;

  @override
  void dispose() {
    _registrationNumberController.dispose();
    super.dispose();
  }

  void _submitOnboarding() {
    if (_formKey.currentState?.validate() != true) return;

    // final onboardingState = context.read<OnboardingBloc>().state;

    // if (onboardingState.isIndependent && onboardingState.permitUrl == null) {
    //   return context.toast.showToast(
    //     'Please upload your solo-rider permit',
    //     type: ToastType.error,
    //   );
    // }

    // if (!onboardingState.isIndependent && onboardingState.company == null) {
    //   return context.toast.showToast(
    //     'Please select your company or check independent',
    //     type: ToastType.error,
    //   );
    // }

    context.read<OnboardingBloc>().add(
      OnboardingEvent.submitRiderOnboarding(
        phoneNumber: _phoneNumber?.completeNumber ?? '',
        registrationNumber: _registrationNumberController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OnboardingBloc, OnboardingState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == OnboardingStatus.success) {
              context.toast.showToast(
                'Profile setup complete!',
                type: ToastType.success,
              );
              context.go(ModuleRoutePaths.rider);
            } else if (state.status == OnboardingStatus.error) {
              context.toast.showToast(
                state.message ?? 'An error occurred',
                type: ToastType.error,
              );
            }
          },
        ),
        // BlocListener<UploadCubit, UploadState>(
        //   listener: (context, state) {
        //     state.whenOrNull(
        //       success: (key) {
        //         context.read<OnboardingBloc>().add(
        //           OnboardingEvent.updateProgress(permitUrl: key),
        //         );
        //         context.toast.showToast(
        //           'Permit uploaded successfully',
        //           type: ToastType.success,
        //         );
        //       },
        //       error: (message) {
        //         context.toast.showToast(
        //           message ?? 'Upload failed',
        //           type: ToastType.error,
        //         );
        //       },
        //     );
        //   },
        // ),
      ],
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, onboardingState) {
          // final isIndependent = onboardingState.isIndependent;
          // final permitUrl = onboardingState.permitUrl;
          final selectedCompany = onboardingState.company;

          return Scaffold(
            appBar: AppBar(title: const Text('Rider Information')),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: [
                    Icon(
                      Icons.motorcycle,
                      size: 80,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Complete Your Profile',
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We need some information to set up your rider account',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: LogistixColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    PhoneTextField(
                      initialCountryCode: 'ng',
                      onChanged: (value) => _phoneNumber = value,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _registrationNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Reg No',
                        prefixIcon: Icon(Icons.pin_outlined),
                        hintText: 'e.g., ABC-1234',
                      ),
                      validator: FormBuilderValidators.required(),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    // CheckboxListTile(
                    //   title: const Text('I am an Independent Rider'),
                    //   value: isIndependent,
                    //   onChanged: (val) {
                    //     val ??= false;
                    //     context.read<OnboardingBloc>().add(
                    //       OnboardingEvent.updateProgress(
                    //         isIndependent: val,
                    //         company: val ? null : onboardingState.company,
                    //       ),
                    //     );
                    //   },
                    // ),
                    // const SizedBox(height: 16),
                    // if (isIndependent)
                    //   BlocBuilder<UploadCubit, UploadState>(
                    //     builder: (context, state) {
                    //       final isUploading = state.maybeWhen(
                    //         loading: () => true,
                    //         orElse: () => false,
                    //       );
                    //       return ElevatedButton.icon(
                    //         onPressed: isUploading
                    //             ? null
                    //             : context.read<UploadCubit>().pickAndUploadFile,
                    //         icon: isUploading
                    //             ? const SizedBox(
                    //                 width: 20,
                    //                 height: 20,
                    //                 child: CircularProgressIndicator(
                    //                   strokeWidth: 2,
                    //                 ),
                    //               )
                    //             : Icon(
                    //                 permitUrl != null
                    //                     ? Icons.check_circle
                    //                     : Icons.upload_file,
                    //               ),
                    //         label: Text(
                    //           isUploading
                    //               ? 'Uploading...'
                    //               : (permitUrl != null
                    //                     ? 'Permit Uploaded'
                    //                     : 'Upload Solo-Rider Permit'),
                    //         ),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: permitUrl != null
                    //               ? LogistixColors.success
                    //               : null,
                    //         ),
                    //       );
                    //     },
                    //   )
                    // else
                    DropdownSearch<Company>(
                      items: (String filter, _) async {
                        final repo = context.read<CompanyRepository>();
                        final result = await repo.getCompanies(search: filter);
                        return result.map((_) => const [], (r) => r.items);
                      },
                      compareFn: EqualityFilter<Company>(
                        (state) => state.id,
                      ).call,
                      itemAsString: (company) => company.name,
                      selectedItem: selectedCompany,
                      suffixProps: const DropdownSuffixProps(
                        clearButtonProps: ClearButtonProps(isVisible: true),
                        dropdownButtonProps: DropdownButtonProps(
                          isVisible: false,
                        ),
                      ),
                      onChanged: (company) {
                        context.read<OnboardingBloc>().add(
                          OnboardingEvent.updateProgress(company: company),
                        );
                      },
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: 'Associated Company',
                          hintText: 'Search for your company',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        loadingBuilder: (_, _) {
                          return const LogistixLoadingIndicator();
                        },
                        searchFieldProps: const TextFieldProps(
                          autofocus: true,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: 'Type to search...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      validator: (address) {
                        return address == null
                            ? 'Please select your company'
                            : null;
                      },
                    ),

                    const SizedBox(height: 32),
                    BlocBuilder<OnboardingBloc, OnboardingState>(
                      builder: (context, state) {
                        final isLoading =
                            state.status == OnboardingStatus.loading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _submitOnboarding,
                          child: isLoading
                              ? const LogistixInlineLoader()
                              : const Text('Complete Setup'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
